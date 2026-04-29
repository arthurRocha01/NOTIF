import { Injectable, Logger } from '@nestjs/common';
import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getMessaging, type BatchResponse } from 'firebase-admin/messaging';
import * as fs from 'fs';

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);

  constructor() {
    const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    this.logger.log(`[init] GOOGLE_APPLICATION_CREDENTIALS="${credPath ?? '(não definida)'}"`);

    if (credPath) {
      const exists = fs.existsSync(credPath);
      this.logger.log(`[init] Arquivo de credencial existe no disco: ${exists}`);
      if (!exists) {
        this.logger.error(`[init] CRÍTICO: arquivo não encontrado em "${credPath}" — FCM vai falhar`);
      }
    } else {
      this.logger.error('[init] CRÍTICO: GOOGLE_APPLICATION_CREDENTIALS não está definida — applicationDefault() vai falhar');
    }

    if (getApps().length === 0) {
      this.logger.log('[init] Inicializando Firebase Admin SDK via applicationDefault()...');
      try {
        initializeApp({ credential: applicationDefault() });
        this.logger.log('[init] Firebase Admin SDK inicializado com sucesso');
      } catch (error: any) {
        this.logger.error(`[init] Falha ao inicializar Firebase Admin SDK | message: ${error?.message}`, error);
      }
    } else {
      this.logger.log('[init] Firebase Admin SDK já inicializado, reutilizando instância');
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

    this.logger.log(
      `[sendMulticast] Iniciando | tokens: ${tokens.length} | level: ${level ?? 'N/A'} | title: "${title}"`,
    );

    if (tokens.length === 0) {
      this.logger.warn('[sendMulticast] Nenhum token fornecido, envio abortado');
      return [];
    }

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
      this.logger.log('[sendMulticast] Chamando sendEachForMulticast...');
      const response = await getMessaging().sendEachForMulticast(message);

      this.logger.log(
        `[sendMulticast] Concluído | sucessos: ${response.successCount} | falhas: ${response.failureCount} | total: ${tokens.length}`,
      );

      if (response.failureCount > 0) {
        response.responses.forEach((res, idx) => {
          if (!res.success) {
            this.logger.warn(
              `[sendMulticast] Falha token[${idx}] | code: ${res.error?.code} | message: ${res.error?.message} | token: ...${tokens[idx].slice(-8)}`,
            );
          }
        });
      }

      return this.retrieveFailedTokens(response, tokens);
    } catch (error: any) {
      this.logger.error(
        `[sendMulticast] Erro crítico | code: ${error?.code} | message: ${error?.message}`,
        error,
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
    const isCritical = level === 'CRITICAL';
    const shortToken = `...${token.slice(-8)}`;

    this.logger.log(
      `[sendToToken] Iniciando | level: ${level ?? 'N/A'} | title: "${title}" | token: ${shortToken}`,
    );

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
      this.logger.log(`[sendToToken] Chamando Firebase send | token: ${shortToken}`);
      await getMessaging().send(message);
      this.logger.log(`[sendToToken] Entregue com sucesso | token: ${shortToken}`);
      return null;
    } catch (error: any) {
      const invalidCodes = [
        'messaging/invalid-registration-token',
        'messaging/registration-token-not-registered',
      ];
      if (invalidCodes.includes(error?.code)) {
        this.logger.warn(
          `[sendToToken] Token inválido/não registrado | code: ${error.code} | token: ${shortToken}`,
        );
        return token;
      }
      this.logger.error(
        `[sendToToken] Erro inesperado | code: ${error?.code} | message: ${error?.message} | token: ${shortToken}`,
        error,
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
