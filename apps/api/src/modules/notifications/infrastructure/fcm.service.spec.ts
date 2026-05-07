const mockSendEachForMulticast = jest.fn();
const mockSend = jest.fn();

jest.mock('firebase-admin/app', () => ({
  getApps: jest.fn(() => [{}]),
  initializeApp: jest.fn(),
  applicationDefault: jest.fn(),
}));

jest.mock('firebase-admin/messaging', () => ({
  getMessaging: jest.fn(() => ({
    sendEachForMulticast: mockSendEachForMulticast,
    send: mockSend,
  })),
}));

import { Test, TestingModule } from '@nestjs/testing';
import { FcmService } from './fcm.service';
import { UserService } from '../../users/application/user.service';

describe('FcmService', () => {
  let service: FcmService;

  beforeEach(async () => {
    mockSendEachForMulticast.mockReset();
    mockSend.mockReset();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FcmService,
        {
          provide: UserService,
          useValue: {
            removeTokensByUser: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    service = module.get<FcmService>(FcmService);
  });

  describe('sendMulticast', () => {
    it('retorna array vazio quando todos os envios têm sucesso', async () => {
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 2,
        failureCount: 0,
        responses: [
          { success: true, messageId: 'msg-1' },
          { success: true, messageId: 'msg-2' },
        ],
      });

      const result = await service.sendMulticast(
        ['token-a', 'token-b'],
        'Título',
        'Mensagem',
      );

      expect(result).toEqual([]);
    });

    it('retorna exatamente os tokens que falharam, mantendo a ordem', async () => {
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 2,
        responses: [
          { success: true, messageId: 'msg-1' },
          { success: false, error: { code: 'messaging/invalid-registration-token' } },
          { success: false, error: { code: 'messaging/registration-token-not-registered' } },
        ],
      });

      const result = await service.sendMulticast(
        ['token-ok', 'token-invalido', 'token-expirado'],
        'Título',
        'Mensagem',
      );

      expect(result).toEqual(['token-invalido', 'token-expirado']);
    });

    it('retorna apenas o token do índice que falhou quando um de dois falha', async () => {
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 1,
        responses: [
          { success: false, error: { code: 'messaging/invalid-registration-token' } },
          { success: true, messageId: 'msg-2' },
        ],
      });

      const result = await service.sendMulticast(
        ['token-ruim', 'token-bom'],
        'Título',
        'Mensagem',
      );

      expect(result).toEqual(['token-ruim']);
      expect(result).not.toContain('token-bom');
    });

    it('retorna array vazio quando Firebase lança exceção', async () => {
      mockSendEachForMulticast.mockRejectedValue(new Error('Falha de conexão'));

      const result = await service.sendMulticast(['token-a'], 'Título', 'Mensagem');

      expect(result).toEqual([]);
    });

    it('envia tokens, título e corpo corretos para o Firebase', async () => {
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 0,
        responses: [{ success: true, messageId: 'msg-1' }],
      });

      await service.sendMulticast(['token-x'], 'Alerta Crítico', 'Leia com atenção');

      expect(mockSendEachForMulticast).toHaveBeenCalledWith(
        expect.objectContaining({
          tokens: ['token-x'],
          data: expect.objectContaining({
            title: 'Alerta Crítico',
            message: 'Leia com atenção',
          }),
        }),
      );
    });

    describe('payload de prioridade', () => {
      beforeEach(() => {
        mockSendEachForMulticast.mockResolvedValue({
          successCount: 1,
          failureCount: 0,
          responses: [{ success: true, messageId: 'msg-1' }],
        });
      });

      it('envia payload CRITICAL com prioridade máxima no Android', async () => {
        await service.sendMulticast(['token-x'], 'Título', 'Corpo', undefined, 'CRITICAL');

        expect(mockSendEachForMulticast).toHaveBeenCalledWith(
          expect.objectContaining({
            android: expect.objectContaining({
              priority: 'high',
              notification: expect.objectContaining({
                channelId: 'critical',
                notificationPriority: 'PRIORITY_MAX',
                defaultSound: true,
                defaultVibrateTimings: true,
              }),
            }),
          }),
        );
      });

      it('envia payload CRITICAL com apns-priority 10', async () => {
        await service.sendMulticast(['token-x'], 'Título', 'Corpo', undefined, 'CRITICAL');

        expect(mockSendEachForMulticast).toHaveBeenCalledWith(
          expect.objectContaining({
            apns: expect.objectContaining({
              headers: expect.objectContaining({ 'apns-priority': '10' }),
              payload: expect.objectContaining({
                aps: expect.objectContaining({ sound: 'default' }),
              }),
            }),
          }),
        );
      });

      it('envia payload não-CRITICAL com prioridade normal no Android', async () => {
        await service.sendMulticast(['token-x'], 'Título', 'Corpo', undefined, 'INFO');

        expect(mockSendEachForMulticast).toHaveBeenCalledWith(
          expect.objectContaining({
            android: expect.objectContaining({
              priority: 'normal',
              notification: expect.objectContaining({
                channelId: 'default',
                notificationPriority: 'PRIORITY_DEFAULT',
              }),
            }),
          }),
        );
      });

      it('envia payload não-CRITICAL com apns-priority 5', async () => {
        await service.sendMulticast(['token-x'], 'Título', 'Corpo', undefined, 'INFO');

        expect(mockSendEachForMulticast).toHaveBeenCalledWith(
          expect.objectContaining({
            apns: expect.objectContaining({
              headers: expect.objectContaining({ 'apns-priority': '5' }),
            }),
          }),
        );
      });

      it('usa prioridade normal quando level não é fornecido', async () => {
        await service.sendMulticast(['token-x'], 'Título', 'Corpo');

        expect(mockSendEachForMulticast).toHaveBeenCalledWith(
          expect.objectContaining({
            android: expect.objectContaining({ priority: 'normal' }),
          }),
        );
      });
    });
  });

  describe('sendToToken', () => {
    it('retorna null quando envio tem sucesso', async () => {
      mockSend.mockResolvedValue('message-id');

      const result = await service.sendToToken('token-x', 'Título', 'Corpo');

      expect(result).toBeNull();
    });

    it('retorna o token quando firebase retorna invalid-registration-token', async () => {
      const error = Object.assign(new Error(), { code: 'messaging/invalid-registration-token' });
      mockSend.mockRejectedValue(error);

      const result = await service.sendToToken('token-invalido', 'Título', 'Corpo');

      expect(result).toBe('token-invalido');
    });

    it('retorna o token quando firebase retorna registration-token-not-registered', async () => {
      const error = Object.assign(new Error(), { code: 'messaging/registration-token-not-registered' });
      mockSend.mockRejectedValue(error);

      const result = await service.sendToToken('token-expirado', 'Título', 'Corpo');

      expect(result).toBe('token-expirado');
    });

    it('retorna null para erros não relacionados a token inválido', async () => {
      mockSend.mockRejectedValue(new Error('Falha de conexão'));

      const result = await service.sendToToken('token-x', 'Título', 'Corpo');

      expect(result).toBeNull();
    });

    it('envia payload CRITICAL com prioridade máxima', async () => {
      mockSend.mockResolvedValue('message-id');

      await service.sendToToken('token-x', 'Título', 'Corpo', undefined, 'CRITICAL');

      expect(mockSend).toHaveBeenCalledWith(
        expect.objectContaining({
          token: 'token-x',
          android: expect.objectContaining({ priority: 'high' }),
          apns: expect.objectContaining({
            headers: expect.objectContaining({ 'apns-priority': '10' }),
          }),
        }),
      );
    });
  });
});
