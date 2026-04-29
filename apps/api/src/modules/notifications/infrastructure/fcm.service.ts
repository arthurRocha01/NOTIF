import { Injectable, Logger } from '@nestjs/common';
import { initializeApp, getApps, cert, applicationDefault } from 'firebase-admin/app';
import { getMessaging, type BatchResponse } from 'firebase-admin/messaging';

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);

  constructor() {
    if (getApps().length > 0) return;

    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

    if (serviceAccountJson) {
      try {
        initializeApp({ credential: cert(JSON.parse(serviceAccountJson)) });
      } catch (error: any) {
        this.logger.error(`[init] Falha ao inicializar via FIREBASE_SERVICE_ACCOUNT | ${error?.message}`);
      }
    } else {
      try {
        initializeApp({ credential: applicationDefault() });
      } catch (error: any) {
        this.logger.error(`[init] Falha no applicationDefault() | ${error?.message}`);
      }
    }
  }

  async sendMulticast(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
    level?: string,
  ): Promise<string[]> {
    const isCritical = level === 'CRITICAL';

    if (tokens.length === 0) return [];

    const message = {
      tokens,
      data: { ...data, title, message: body },
      android: {
        priority: (isCritical ? 'high' : 'normal') as 'high' | 'normal',
        notification: {
          channelId: isCritical ? 'critical' : 'default',
          notificationPriority: (isCritical ? 'PRIORITY_MAX' : 'PRIORITY_DEFAULT') as
            | 'PRIORITY_MAX'
            | 'PRIORITY_DEFAULT',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: { 'apns-priority': isCritical ? '10' : '5' },
        payload: { aps: { sound: 'default' } },
      },
    };

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
      this.logger.error(`[sendMulticast] Erro crítico | code: ${error?.code} | message: ${error?.message}`);
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
    const isCritical = level === 'CRITICAL';

    const message = {
      token,
      data: { ...data, title, message: body },
      android: {
        priority: (isCritical ? 'high' : 'normal') as 'high' | 'normal',
        notification: {
          channelId: isCritical ? 'critical' : 'default',
          notificationPriority: (isCritical ? 'PRIORITY_MAX' : 'PRIORITY_DEFAULT') as
            | 'PRIORITY_MAX'
            | 'PRIORITY_DEFAULT',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: { 'apns-priority': isCritical ? '10' : '5' },
        payload: { aps: { sound: 'default' } },
      },
    };

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

  private retrieveFailedTokens(response: BatchResponse, tokenOrder: string[]): string[] {
    const failures: string[] = [];
    if (response.failureCount > 0) {
      response.responses.forEach((res, idx) => {
        if (!res.success) failures.push(tokenOrder[idx]);
      });
    }
    return failures;
  }
}
