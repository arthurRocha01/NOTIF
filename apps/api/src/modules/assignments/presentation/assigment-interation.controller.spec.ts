import { Test, TestingModule } from '@nestjs/testing';
import { AssigmentInterationController } from './assigment-interation.controller';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';

describe('AssigmentInterationController', () => {
  let controller: AssigmentInterationController;
  let service: jest.Mocked<AssignmentsInteractionService>;

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

  const mockReq = (overrides = {}) => ({
    user: {
      userId: 'user-1',
      role: 'EMPLOYEE',
      sectorId: 'sector-1',
      ...overrides,
    },
  });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssigmentInterationController],
      providers: [
        {
          provide: AssignmentsInteractionService,
          useValue: {
            getBlockingAssignments: jest.fn().mockResolvedValue([mockAssignment]),
            syncDeliveries: jest.fn().mockResolvedValue(3),
            markAsViewed: jest.fn().mockResolvedValue(undefined),
            acknowledge: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    controller = module.get<AssigmentInterationController>(AssigmentInterationController);
    service = module.get(AssignmentsInteractionService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getBlocking', () => {
    it('should return blocking assignments', async () => {
      const req = mockReq();
      const result = await controller.getBlocking(req as any);

      expect(service.getBlockingAssignments).toHaveBeenCalledWith('user-1');
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('sync', () => {
    it('should sync deliveries and return count', async () => {
      const req = mockReq();
      const result = await controller.sync(req as any);

      expect(service.syncDeliveries).toHaveBeenCalledWith('user-1');
      expect(result).toEqual({
        message: 'Sincronização concluída',
        deliveredCount: 3,
      });
    });
  });

  describe('view', () => {
    it('should mark assignment as viewed', async () => {
      const req = mockReq();
      const result = await controller.view('assignment-1', req as any);

      expect(service.markAsViewed).toHaveBeenCalledWith('user-1', 'assignment-1');
      expect(result).toEqual({ message: 'Notificação visualizada' });
    });
  });

  describe('acknowledge', () => {
    it('should acknowledge assignment', async () => {
      const req = mockReq();
      const result = await controller.acknowledge('assignment-1', req as any);

      expect(service.acknowledge).toHaveBeenCalledWith('user-1', 'assignment-1');
      expect(result).toEqual({ message: 'Ciência confirmada com sucesso' });
    });
  });
});
