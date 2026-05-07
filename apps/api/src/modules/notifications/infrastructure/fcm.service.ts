import { Injectable, Logger } from '@nestjs/common';
import {
  initializeApp,
  getApps,
  cert,
  applicationDefault,
} from 'firebase-admin/app';
import { getMessaging, type BatchResponse } from 'firebase-admin/messaging';
import type { NotificationAssignment } from '../../../modules/assignments/domain/notification-assignment.entity';
import { UserService } from '../../../modules/users/application/user.service';

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);

  constructor(private readonly usersService: UserService) {
    if (getApps().length > 0) return;

    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

    if (serviceAccountJson) {
      try {
        initializeApp({ credential: cert(JSON.parse(serviceAccountJson)) });
      } catch (error: any) {
        this.logger.error(
          `[init] Falha ao inicializar via FIREBASE_SERVICE_ACCOUNT | ${error?.message}`,
        );
      }
    } else {
      try {
        initializeApp({ credential: applicationDefault() });
      } catch (error: any) {
        this.logger.error(
          `[init] Falha no applicationDefault() | ${error?.message}`,
        );
      }
    }
  }

  async sendToSector(
    users: Awaited<ReturnType<UserService['listUsersBySectorId']>>,
    assignments: NotificationAssignment[],
    title: string,
    message: string,
    notificationId: string,
    level?: string,
  ): Promise<void> {
    const isCritical = level === 'CRITICAL';
    const usersWithToken = users.filter((u) => Boolean(u.getFcmToken()));

    this.logDeliveryInfo(users, usersWithToken, notificationId, level);

    const failedTokens = isCritical
      ? await this.sendCritical(
          users,
          assignments,
          title,
          message,
          notificationId,
          level,
        )
      : await this.sendNormal(
          usersWithToken,
          title,
          message,
          notificationId,
          level,
        );

    if (failedTokens.length > 0) {
      await this.usersService.removeTokensByUser(failedTokens);
    }
  }

  async sendMulticast(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
    level?: string,
  ): Promise<string[]> {
    if (tokens.length === 0) return [];

    const message = this.buildMessage({ tokens }, title, body, data, level);

    try {
      const response = await getMessaging().sendEachForMulticast(message);

      if (response.failureCount > 0) {
        response.responses.forEach((res, idx) => {
          if (!res.success) {
            this.logger.warn(
              `[sendMulticast] Falha token[${idx}] | code: ${res.error?.code} | message: ${res.error?.message}`,
            );
          }
        });
      }

      return this.retrieveFailedTokens(response, tokens);
    } catch (error: any) {
      this.logger.error(
        `[sendMulticast] Erro crítico | code: ${error?.code} | message: ${error?.message}`,
      );
      return [];
    }
  }

  async sendToToken(
    token: string,
    title: string,
    body: string,
    data?: Record<string, string>,
    level?: string,
  ): Promise<string | null> {
    const message = this.buildMessage({ token }, title, body, data, level);

    try {
      await getMessaging().send(message);
      return null;
    } catch (error: any) {
      const invalidCodes = [
        'messaging/invalid-registration-token',
        'messaging/registration-token-not-registered',
      ];
      if (invalidCodes.includes(error?.code)) return token;
      this.logger.error(
        `[sendToToken] Erro inesperado | code: ${error?.code} | message: ${error?.message} | token: ...${token.slice(-8)}`,
      );
      return null;
    }
  }

  private async sendCritical(
    users: Awaited<ReturnType<UserService['listUsersBySectorId']>>,
    assignments: NotificationAssignment[],
    title: string,
    message: string,
    notificationId: string,
    level?: string,
  ): Promise<string[]> {
    const assignmentByUserId = new Map(
      assignments.map((a) => [a.getUserId(), a]),
    );

    const results = await Promise.all(
      users.map(async (user) => {
        const token = user.getFcmToken();
        if (!token) return null;

        const assignment = assignmentByUserId.get(user.getId());
        const failed = await this.sendToToken(
          token,
          title,
          message,
          {
            level: level ?? '',
            notificationId,
            assignmentId: assignment?.getId() ?? '',
          },
          level,
        );

        if (failed) {
          this.logger.warn(`[FCM] Token inválido para userId=${user.getId()}`);
        }

        return failed;
      }),
    );

    return results.filter((t): t is string => t !== null);
  }

  private async sendNormal(
    usersWithToken: Awaited<ReturnType<UserService['listUsersBySectorId']>>,
    title: string,
    message: string,
    notificationId: string,
    level?: string,
  ): Promise<string[]> {
    const tokens = usersWithToken
      .map((user) => user.getFcmToken())
      .filter((token): token is string => Boolean(token));

    if (tokens.length === 0) return [];

    return this.sendMulticast(
      tokens,
      title,
      message,
      {
        level: level ?? '',
        notificationId,
      },
      level,
    );
  }

  private buildMessage(
    target: { tokens: string[] } | { token: string },
    title: string,
    body: string,
    data?: Record<string, string>,
    level?: string,
  ): any {
    const isCritical = level === 'CRITICAL';

    return {
      ...target,
      data: { ...data, title, message: body },
      android: {
        priority: isCritical ? 'high' : 'normal',
        notification: {
          channelId: isCritical ? 'critical' : 'default',
          notificationPriority: isCritical
            ? 'PRIORITY_MAX'
            : 'PRIORITY_DEFAULT',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: { 'apns-priority': isCritical ? '10' : '5' },
        payload: { aps: { sound: 'default' } },
      },
    };
  }

  private logDeliveryInfo(
    users: any[],
    usersWithToken: any[],
    notificationId: string,
    level?: string,
  ): void {
    this.logger.log(
      `[FCM] Enviando notificação | level=${level} | notificationId=${notificationId} | destinatários=${users.length}`,
    );
    this.logger.log(
      `[FCM] Tokens disponíveis: ${usersWithToken.length} | Sem token: ${users.length - usersWithToken.length}`,
    );

    const usersWithoutToken = users.filter((u: any) => !u.getFcmToken());
    if (usersWithoutToken.length > 0) {
      this.logger.log(
        `[FCM] Usuários sem token: ${usersWithoutToken.map((u: any) => u.getId()).join(', ')}`,
      );
    }
  }

  private retrieveFailedTokens(
    response: BatchResponse,
    tokenOrder: string[],
  ): string[] {
    const failures: string[] = [];
    if (response.failureCount > 0) {
      response.responses.forEach((res, idx) => {
        if (!res.success) failures.push(tokenOrder[idx]);
      });
    }
    return failures;
  }
}
