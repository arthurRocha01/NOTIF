import { Test, TestingModule } from '@nestjs/testing';
import { AssignmentsInteractionService } from './assignments-interaction.service';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';
import { NotificationRepository } from '../../../modules/notifications/infrastructure/notification.repository.impl';

describe('AssignmentsInteractionService', () => {
  let service: AssignmentsInteractionService;
  let assignmentRepo: jest.Mocked<NotificationAssignmentRepository>;
  let notificationRepo: jest.Mocked<NotificationRepository>;

  const mockAssignment = {
    getId: () => 'assignment-1',
    getUserId: () => 'user-1',
    getNotificationId: () => 'notif-1',
    getNotificationLevel: () => 'CRITICAL',
    getNotificationRequiresAcknowledge: () => true,
    getStatus: () => 'PENDING',
    getCreatedAt: () => new Date(),
    getDueAt: () => null,
    getDeliveredAt: () => null,
    getViewedAt: () => null,
    getAcknowledgedAt: () => null,
    isBlocking: () => true,
    canAcknowledge: () => true,
    isOverdue: () => false,
    getResponseTimeInMs: () => null,
    markAsDelivered: jest.fn(),
    markAsViewed: jest.fn(),
    markAsRecognized: jest.fn(),
  };

  const mockNotification = {
    getId: () => 'notif-1',
    getSlaMinutes: () => 60,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AssignmentsInteractionService,
        {
          provide: NotificationAssignmentRepository,
          useValue: {
            findById: jest.fn().mockResolvedValue(mockAssignment),
            findByUserId: jest.fn().mockResolvedValue([mockAssignment]),
            findBlockingByUserId: jest.fn().mockResolvedValue([mockAssignment]),
            update: jest.fn().mockResolvedValue(undefined),
          },
        },
        {
          provide: NotificationRepository,
          useValue: {
            findById: jest.fn().mockResolvedValue(mockNotification),
          },
        },
      ],
    }).compile();

    service = module.get<AssignmentsInteractionService>(
      AssignmentsInteractionService,
    );
    assignmentRepo = module.get(NotificationAssignmentRepository);
    notificationRepo = module.get(NotificationRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getBlockingAssignments', () => {
    it('should return blocking assignments for user', async () => {
      const result = await service.getBlockingAssignments('user-1');

      expect(assignmentRepo.findBlockingByUserId).toHaveBeenCalledWith(
        'user-1',
      );
      expect(result).toEqual([mockAssignment]);
    });
  });

  describe('syncDeliveries', () => {
    it('should sync pending deliveries', async () => {
      const result = await service.syncDeliveries('user-1');

      expect(assignmentRepo.findByUserId).toHaveBeenCalledWith('user-1');
      expect(notificationRepo.findById).toHaveBeenCalledWith('notif-1');
      expect(mockAssignment.markAsDelivered).toHaveBeenCalledWith(60);
      expect(assignmentRepo.update).toHaveBeenCalled();
      expect(result).toBe(1);
    });

    it('should return 0 when no pending assignments', async () => {
      assignmentRepo.findByUserId.mockResolvedValue([]);

      const result = await service.syncDeliveries('user-1');

      expect(result).toBe(0);
      expect(notificationRepo.findById).not.toHaveBeenCalled();
    });
  });

  describe('markAsViewed', () => {
    it('should mark assignment as viewed', async () => {
      await service.markAsViewed('user-1', 'assignment-1');

      expect(assignmentRepo.findById).toHaveBeenCalledWith('assignment-1');
      expect(mockAssignment.markAsViewed).toHaveBeenCalled();
      expect(assignmentRepo.update).toHaveBeenCalledWith(mockAssignment);
    });

    it('should throw NotFoundException when assignment not found', async () => {
      assignmentRepo.findById.mockResolvedValue(null);

      await expect(service.markAsViewed('user-1', 'not-found')).rejects.toThrow(
        'Obrigação de notificação não encontrada',
      );
    });

    it('should throw ForbiddenException when userId does not match', async () => {
      await expect(
        service.markAsViewed('other-user', 'assignment-1'),
      ).rejects.toThrow('Acesso negado a esta notificação');
    });
  });

  describe('acknowledge', () => {
    it('should acknowledge assignment', async () => {
      await service.acknowledge('user-1', 'assignment-1');

      expect(assignmentRepo.findById).toHaveBeenCalledWith('assignment-1');
      expect(mockAssignment.markAsRecognized).toHaveBeenCalled();
      expect(assignmentRepo.update).toHaveBeenCalledWith(mockAssignment);
    });

    it('should throw NotFoundException when assignment not found', async () => {
      assignmentRepo.findById.mockResolvedValue(null);

      await expect(service.acknowledge('user-1', 'not-found')).rejects.toThrow(
        'Obrigação de notificação não encontrada',
      );
    });

    it('should throw ForbiddenException when userId does not match', async () => {
      await expect(
        service.acknowledge('other-user', 'assignment-1'),
      ).rejects.toThrow('Acesso negado a esta notificação');
    });
  });
});
