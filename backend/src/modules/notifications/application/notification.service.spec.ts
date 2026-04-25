import { Test, TestingModule } from '@nestjs/testing';
import { NotificationService } from './notification.service';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import { FcmService } from '../infrastructure/fcm.service';
import { UserService } from '../../users/application/user.service';
import { AssignmentService } from '../../assignments/application/assignment.service';
import { User } from '../../users/domain/user.entity';
import { UserRole } from '../../users/domain/types';

const makeUser = (fcmToken: string | null) =>
  User.reconstitute(
    'user-' + Math.random().toString(36).slice(2),
    'Nome',
    'email@test.com',
    'hash',
    'sector-id',
    UserRole.EMPLOYEE,
    fcmToken as string,
    new Date(),
  );

const mockNotificationRepo = {
  save: jest.fn(),
  findAll: jest.fn(),
  findById: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

const mockUserService = {
  listUsersBySectorId: jest.fn(),
  listUsers: jest.fn(),
  removeTokensByUser: jest.fn(),
};

const mockFcmService = {
  sendMulticast: jest.fn(),
};

const mockAssignmentService = {
  createAssignment: jest.fn(),
};

const baseDto = {
  title: 'Título da notificação',
  message: 'Mensagem com mais de dez caracteres',
  level: 'HIGH' as const,
  slaMinutes: 30,
  sectorId: 'sector-id',
  authorId: 'author-id',
  requiresAcknowledgment: true,
};

describe('NotificationService — fluxo FCM', () => {
  let service: NotificationService;

  beforeEach(async () => {
    jest.clearAllMocks();
    mockNotificationRepo.save.mockResolvedValue(undefined);
    mockAssignmentService.createAssignment.mockResolvedValue(undefined);
    mockUserService.removeTokensByUser.mockResolvedValue(undefined);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        { provide: NotificationRepository, useValue: mockNotificationRepo },
        { provide: FcmService, useValue: mockFcmService },
        { provide: UserService, useValue: mockUserService },
        { provide: AssignmentService, useValue: mockAssignmentService },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
  });

  describe('Targeting — quem recebe o push', () => {
    it('chama sendMulticast com os tokens dos usuários do setor', async () => {
      const users = [makeUser('token-1'), makeUser('token-2')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockFcmService.sendMulticast.mockResolvedValue([]);

      await service.createNotification(baseDto);

      expect(mockFcmService.sendMulticast).toHaveBeenCalledWith(
        ['token-1', 'token-2'],
        baseDto.title,
        baseDto.message,
      );
    });

    it('exclui usuários sem fcmToken do multicast', async () => {
      const users = [makeUser('token-valido'), makeUser(null), makeUser('token-outro')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockFcmService.sendMulticast.mockResolvedValue([]);

      await service.createNotification(baseDto);

      const [tokens] = mockFcmService.sendMulticast.mock.calls[0] as [string[]];
      expect(tokens).toEqual(['token-valido', 'token-outro']);
      expect(tokens).not.toContain(null);
    });

    it('não chama sendMulticast quando nenhum usuário do setor tem fcmToken', async () => {
      mockUserService.listUsersBySectorId.mockResolvedValue([makeUser(null), makeUser(null)]);

      await service.createNotification(baseDto);

      expect(mockFcmService.sendMulticast).not.toHaveBeenCalled();
    });

    it('usa listUsers para notificação global (sectorId ausente)', async () => {
      const globalDto = { ...baseDto, sectorId: undefined };
      mockUserService.listUsers.mockResolvedValue([makeUser('token-global')]);
      mockFcmService.sendMulticast.mockResolvedValue([]);

      await service.createNotification(globalDto);

      expect(mockUserService.listUsers).toHaveBeenCalled();
      expect(mockUserService.listUsersBySectorId).not.toHaveBeenCalled();
    });
  });

  describe('Limpeza de tokens inválidos', () => {
    it('chama removeTokensByUser com os tokens que falharam', async () => {
      const users = [makeUser('token-ok'), makeUser('token-falho')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockFcmService.sendMulticast.mockResolvedValue(['token-falho']);

      await service.createNotification(baseDto);

      expect(mockUserService.removeTokensByUser).toHaveBeenCalledWith(['token-falho']);
    });

    it('não chama removeTokensByUser quando todos os envios têm sucesso', async () => {
      const users = [makeUser('token-a'), makeUser('token-b')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockFcmService.sendMulticast.mockResolvedValue([]);

      await service.createNotification(baseDto);

      expect(mockUserService.removeTokensByUser).not.toHaveBeenCalled();
    });
  });

  describe('Assignments — independência do FCM', () => {
    it('cria assignments para todos os usuários do setor, incluindo os sem token', async () => {
      const users = [makeUser('token-x'), makeUser(null)];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockFcmService.sendMulticast.mockResolvedValue([]);

      await service.createNotification(baseDto);

      expect(mockAssignmentService.createAssignment).toHaveBeenCalledTimes(2);
    });
  });
});
