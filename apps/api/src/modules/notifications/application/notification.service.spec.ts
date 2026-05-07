import { Test, TestingModule } from '@nestjs/testing';
import { NotificationService } from './notification.service';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import { FcmService } from '../infrastructure/fcm.service';
import { UserService } from '../../users/application/user.service';
import { AssignmentService } from '../../assignments/application/assignment.service';
import { User } from '../../users/domain/user.entity';
import { UserRole } from '../../users/domain/types';
import { NotificationAssignment } from '../../assignments/domain/notification-assignment.entity';

const makeUser = (fcmToken: string | null, id?: string) =>
  User.reconstitute(
    id ?? 'user-' + Math.random().toString(36).slice(2),
    'Nome',
    'email@test.com',
    'hash',
    'sector-id',
    UserRole.EMPLOYEE,
    fcmToken as string,
    new Date(),
  );

const makeAssignment = (userId: string, assignmentId: string, level = 'HIGH') =>
  NotificationAssignment.reconstitute(
    assignmentId,
    userId,
    'notif-id',
    level as any,
    true,
    'PENDING' as any,
    new Date(),
    null,
    null,
    null,
    null,
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
  sendToSector: jest.fn(),
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

describe('NotificationService', () => {
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

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createNotification', () => {
    it('should save notification and create assignments for sector users', async () => {
      const users = [makeUser('token-1'), makeUser('token-2')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockAssignmentService.createAssignment.mockResolvedValue(makeAssignment('user-1', 'assign-1'));

      const result = await service.createNotification(baseDto, 'author-1');

      expect(mockNotificationRepo.save).toHaveBeenCalled();
      expect(mockAssignmentService.createAssignment).toHaveBeenCalledTimes(2);
      expect(result.getTitle()).toBe('Título da notificação');
    });

    it('should call sendToSector with target users', async () => {
      const users = [makeUser('token-1'), makeUser('token-2')];
      mockUserService.listUsersBySectorId.mockResolvedValue(users);
      mockAssignmentService.createAssignment.mockResolvedValue(makeAssignment('user-1', 'assign-1'));

      await service.createNotification(baseDto, 'author-1');

      expect(mockFcmService.sendToSector).toHaveBeenCalledWith(
        users,
        expect.any(Array),
        baseDto.title,
        baseDto.message,
        expect.any(String),
        baseDto.level,
      );
    });

    it('should use listUsers for global notification', async () => {
      const globalDto = { ...baseDto, sectorId: undefined };
      mockUserService.listUsers.mockResolvedValue([makeUser('token-global')]);
      mockAssignmentService.createAssignment.mockResolvedValue(makeAssignment('user-1', 'assign-1'));

      await service.createNotification(globalDto, 'author-1');

      expect(mockUserService.listUsers).toHaveBeenCalled();
      expect(mockUserService.listUsersBySectorId).not.toHaveBeenCalled();
    });

    it('should exclude author and admins from assignments', async () => {
      const author = makeUser('token-auth', 'author-1');
      const admin = User.reconstitute('admin-1', 'Admin', 'admin@test.com', 'hash', 'sector-id', UserRole.ADMIN, 'token-admin', new Date());
      const employee = makeUser('token-emp', 'employee-1');
      mockUserService.listUsersBySectorId.mockResolvedValue([author, admin, employee]);
      mockAssignmentService.createAssignment.mockResolvedValue(makeAssignment('employee-1', 'assign-1'));

      await service.createNotification(baseDto, 'author-1');

      expect(mockAssignmentService.createAssignment).toHaveBeenCalledTimes(1);
    });
  });
});
