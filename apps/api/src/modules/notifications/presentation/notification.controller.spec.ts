import { Test, TestingModule } from '@nestjs/testing';
import { NotificationController } from './notification.controller';
import { NotificationService } from '../application/notification.service';

describe('NotificationController', () => {
  let controller: NotificationController;
  let service: jest.Mocked<NotificationService>;

  const mockNotification = {
    getId: () => 'notif-1',
    getTitle: () => 'Título',
    getMessage: () => 'Mensagem',
    getLevel: () => 'HIGH',
    getSlaMinutes: () => 30,
    getRequiresAcknowledgment: () => true,
    getSectorId: () => 'sector-1',
    getAuthorId: () => 'author-1',
    getCreatedAt: () => new Date(),
  };

  const mockReq = (overrides = {}) => ({
    user: {
      userId: 'user-1',
      role: 'SUPERVISOR',
      sectorId: 'sector-1',
      ...overrides,
    },
  });

  const mockDto = {
    title: 'Título',
    message: 'Mensagem com mais de dez caracteres',
    level: 'HIGH' as const,
    slaMinutes: 30,
    sectorId: 'sector-1',
    requiresAcknowledgment: true,
  };

  const mockUpdateDto = {
    title: 'Novo título',
    requiresAcknowledgment: false,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NotificationController],
      providers: [
        {
          provide: NotificationService,
          useValue: {
            listNotifications: jest.fn().mockResolvedValue([mockNotification]),
            getNotificationById: jest.fn().mockResolvedValue(mockNotification),
            createNotification: jest.fn().mockResolvedValue(mockNotification),
            updateNotification: jest.fn().mockResolvedValue(mockNotification),
            deleteNotification: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    controller = module.get<NotificationController>(NotificationController);
    service = module.get(NotificationService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all notifications without filters', async () => {
      const result = await controller.findAll();

      expect(service.listNotifications).toHaveBeenCalledWith(
        undefined,
        undefined,
      );
      expect(Array.isArray(result)).toBe(true);
    });

    it('should filter by level and sectorId', async () => {
      const result = await controller.findAll('CRITICAL', 'sector-1');

      expect(service.listNotifications).toHaveBeenCalledWith(
        'CRITICAL',
        'sector-1',
      );
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findById', () => {
    it('should return notification by id as DTO', async () => {
      const result = await controller.findById('notif-1');

      expect(service.getNotificationById).toHaveBeenCalledWith('notif-1');
      expect(result).toBeDefined();
    });
  });

  describe('create', () => {
    it('should create notification and return DTO', async () => {
      const req = mockReq();
      const result = await controller.create(mockDto as any, req as any);

      expect(service.createNotification).toHaveBeenCalledWith(
        mockDto,
        'user-1',
      );
      expect(result).toBeDefined();
    });
  });

  describe('update', () => {
    it('should update notification and return DTO', async () => {
      const result = await controller.update('notif-1', mockUpdateDto as any);

      expect(service.updateNotification).toHaveBeenCalledWith(
        'notif-1',
        mockUpdateDto,
      );
      expect(result).toBeDefined();
    });
  });

  describe('delete', () => {
    it('should delete notification by id', async () => {
      await controller.delete('notif-1');

      expect(service.deleteNotification).toHaveBeenCalledWith('notif-1');
    });
  });
});
