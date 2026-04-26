import { Injectable } from '@nestjs/common';
import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getMessaging, type BatchResponse } from 'firebase-admin/messaging';

@Injectable()
export class FcmService {
  constructor() {
    if (getApps().length === 0) {
      initializeApp({
        credential: applicationDefault(),
      });
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

    const message = {
      tokens,
      notification: { title, body },
      data,
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

      console.log(
        `Notificação - sucessos: ${response.successCount} | falhas: ${response.failureCount}`,
      );

      return this.retrieveFailedTokens(response, tokens);
    } catch (error) {
      console.log('Erro de conexão ou falha crítica no Firebase', error);
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
      notification: { title, body },
      data,
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
      console.log('Erro ao enviar mensagem individual via Firebase', error);
      return null;
    }
  }

  private retrieveFailedTokens(
    response: BatchResponse,
    tokenOrder: string[],
  ): string[] {
    const failures: string[] = [];

    if (response.failureCount > 0) {
      response.responses.forEach((res, idx) => {
        if (!res.success) {
          failures.push(tokenOrder[idx]);
        }
      });
    }
    return failures;
  }
}
