import { Test, TestingModule } from '@nestjs/testing';
import { AssignmentService } from './assignment.service';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';

describe('AssignmentService', () => {
  let service: AssignmentService;
  let repo: jest.Mocked<NotificationAssignmentRepository>;

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
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AssignmentService,
        {
          provide: NotificationAssignmentRepository,
          useValue: {
            findall: jest.fn().mockResolvedValue([mockAssignment]),
            findById: jest.fn().mockResolvedValue(mockAssignment),
            findAllByUserId: jest.fn().mockResolvedValue([mockAssignment]),
            findByUserId: jest.fn().mockResolvedValue([mockAssignment]),
            save: jest.fn().mockResolvedValue(undefined),
            delete: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    service = module.get<AssignmentService>(AssignmentService);
    repo = module.get(NotificationAssignmentRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('listAssignments', () => {
    it('should return all assignments', async () => {
      const result = await service.listAssignments();
      expect(repo.findall).toHaveBeenCalled();
      expect(result).toEqual([mockAssignment]);
    });
  });

  describe('listMyAssignments', () => {
    it('should return assignments for user without status filter', async () => {
      const result = await service.listMyAssignments('user-1');
      expect(repo.findAllByUserId).toHaveBeenCalledWith('user-1', undefined);
      expect(result).toEqual([mockAssignment]);
    });

    it('should return assignments for user with status filter', async () => {
      const result = await service.listMyAssignments('user-1', 'pending,viewed');
      expect(repo.findAllByUserId).toHaveBeenCalledWith('user-1', 'pending,viewed');
      expect(result).toEqual([mockAssignment]);
    });
  });

  describe('getAssigmentDetails', () => {
    it('should return assignment by id', async () => {
      const result = await service.getAssigmentDetails('assignment-1');
      expect(repo.findById).toHaveBeenCalledWith('assignment-1');
      expect(result).toEqual(mockAssignment);
    });
  });

  describe('listPeddingDeliveries', () => {
    it('should return pending deliveries for user', async () => {
      const result = await service.listPeddingDeliveries('user-1');
      expect(repo.findByUserId).toHaveBeenCalledWith('user-1');
      expect(result).toEqual([mockAssignment]);
    });
  });

  describe('createAssignment', () => {
    it('should create and save assignment', async () => {
      const dto = {
        userId: 'user-1',
        notificationId: 'notif-1',
        notificationLevel: 'CRITICAL' as any,
        requiresAcknowledge: true,
      };

      const result = await service.createAssignment(dto);

      expect(repo.save).toHaveBeenCalled();
      expect(result.getUserId()).toBe('user-1');
    });
  });

  describe('deleteAssignment', () => {
    it('should delete assignment when found', async () => {
      await service.deleteAssignment('assignment-1');
      expect(repo.delete).toHaveBeenCalledWith('assignment-1');
    });

    it('should throw NotFoundException when assignment not found', async () => {
      repo.findById.mockResolvedValue(null);

      await expect(service.deleteAssignment('not-found')).rejects.toThrow(
        'Assignment com ID not-found não encontrado.',
      );
    });
  });
});
