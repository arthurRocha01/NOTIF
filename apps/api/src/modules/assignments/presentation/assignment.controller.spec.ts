import { Test, TestingModule } from '@nestjs/testing';
import { AssignmentController } from './assignment.controller';
import { AssignmentService } from '../application/assignment.service';

describe('AssignmentController', () => {
  let controller: AssignmentController;
  let service: jest.Mocked<AssignmentService>;

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

  const mockReq = (overrides = {}) => ({
    user: {
      userId: 'user-1',
      role: 'ADMIN',
      sectorId: 'sector-1',
      ...overrides,
    },
  });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssignmentController],
      providers: [
        {
          provide: AssignmentService,
          useValue: {
            listAssignments: jest.fn().mockResolvedValue([mockAssignment]),
            listMyAlerts: jest.fn().mockResolvedValue([
              {
                assignment: mockAssignment,
                notification: { title: 'Título', message: 'Mensagem' },
              },
            ]),
            getInboxSummary: jest.fn().mockResolvedValue({
              total: 1,
              pending: 1,
              overdue: 0,
              critical: 1,
              isBlocked: true,
              alerts: [],
            }),
            getAssignmentDetails: jest.fn().mockResolvedValue(mockAssignment),
            deleteAssignment: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    controller = module.get<AssignmentController>(AssignmentController);
    service = module.get(AssignmentService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all assignments as DTOs', async () => {
      const result = await controller.findAll();

      expect(service.listAssignments).toHaveBeenCalled();
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findMine', () => {
    it('should return user assignments without status filter', async () => {
      const req = mockReq();
      const result = await controller.findMine(req as any);

      expect(service.listMyAlerts).toHaveBeenCalledWith(
        'user-1',
        undefined,
      );
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
    });

    it('should return user assignments with status filter', async () => {
      const req = mockReq();
      const result = await controller.findMine(req as any, 'pending,viewed');

      expect(service.listMyAlerts).toHaveBeenCalledWith(
        'user-1',
        'pending,viewed',
      );
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findById', () => {
    it('should return assignment by id as DTO', async () => {
      const result = await controller.findById('assignment-1');

      expect(service.getAssignmentDetails).toHaveBeenCalledWith('assignment-1');
      expect(result).toBeDefined();
    });
  });

  describe('delete', () => {
    it('should delete assignment by id', async () => {
      await controller.delete('assignment-1');

      expect(service.deleteAssignment).toHaveBeenCalledWith('assignment-1');
    });
  });

  describe('inboxSummary', () => {
    it('should return inbox summary for authenticated user', async () => {
      const req = mockReq();
      const result = await controller.inboxSummary(req as any);

      expect(service.getInboxSummary).toHaveBeenCalledWith('user-1');
      expect(result).toHaveProperty('total');
      expect(result).toHaveProperty('pending');
      expect(result).toHaveProperty('overdue');
      expect(result).toHaveProperty('critical');
      expect(result).toHaveProperty('isBlocked');
      expect(result).toHaveProperty('alerts');
    });
  });
});
