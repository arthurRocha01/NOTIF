import { Injectable } from '@nestjs/common';
import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

@Injectable()
export class FcmService {
  constructor() {
    if (getApps().length === 0) {
      initializeApp({
        credential: applicationDefault(), // GOOGLE_APPLICATION_CREDENTIALS
      });
    }
  }

  async sendMulticast(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<string[]> {
    const message = {
      tokens,
      notification: { title, body },
      data,
    };

    try {
      const response = await getMessaging().sendEachForMulticast(message);

      console.log(
        `Notificação - sucessos: ${response.successCount} falhas: ${response.failureCount} falhas`,
      );

      const failedTokens: string[] = [];
      if (response.failureCount > 0) {
        response.responses.forEach((res, idx) => {
          if (!res.success) {
            failedTokens.push(tokens[idx]);
          }
        });
      }
    } catch (error) {
      console.log('Erro de conexão ou falha crítica no Firebase', error);
      return [];
    }
  }
}
