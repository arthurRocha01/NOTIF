const mockSendEachForMulticast = jest.fn();

jest.mock('firebase-admin/app', () => ({
  getApps: jest.fn(() => [{}]),
  initializeApp: jest.fn(),
  applicationDefault: jest.fn(),
}));

jest.mock('firebase-admin/messaging', () => ({
  getMessaging: jest.fn(() => ({
    sendEachForMulticast: mockSendEachForMulticast,
  })),
}));

import { Test, TestingModule } from '@nestjs/testing';
import { FcmService } from './fcm.service';

describe('FcmService', () => {
  let service: FcmService;

  beforeEach(async () => {
    mockSendEachForMulticast.mockReset();

    const module: TestingModule = await Test.createTestingModule({
      providers: [FcmService],
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
          notification: { title: 'Alerta Crítico', body: 'Leia com atenção' },
        }),
      );
    });
  });
});
