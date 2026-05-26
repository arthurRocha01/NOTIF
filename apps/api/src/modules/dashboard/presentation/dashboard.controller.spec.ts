import { Test, TestingModule } from '@nestjs/testing';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from '../application/dashboard.service';

describe('DashboardController', () => {
  let controller: DashboardController;
  let service: jest.Mocked<DashboardService>;

  const mockSummary = {
    totalNotifications: 42,
    totalAcknowledged: 30,
    totalPending: 8,
    totalCritical: 4,
    topSector: 'TI',
    topSectorRate: 0.92,
    sectorRates: { TI: 0.92, RH: 0.75 },
    attentionSectors: [],
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
      controllers: [DashboardController],
      providers: [
        {
          provide: DashboardService,
          useValue: {
            getSummary: jest.fn().mockResolvedValue(mockSummary),
          },
        },
      ],
    }).compile();

    controller = module.get<DashboardController>(DashboardController);
    service = module.get(DashboardService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service with admin role', async () => {
    const req = mockReq({ role: 'ADMIN' });
    const result = await controller.getSummary(req as any);

    expect(service.getSummary).toHaveBeenCalledWith({
      userRole: 'ADMIN',
      userId: 'user-1',
      period: undefined,
      selectedSectorId: undefined,
    });
    expect(result).toEqual(mockSummary);
  });

  it('should call service with supervisor role', async () => {
    const req = mockReq({ role: 'SUPERVISOR', userId: 'supervisor-1' });
    const result = await controller.getSummary(req as any);

    expect(service.getSummary).toHaveBeenCalledWith({
      userRole: 'SUPERVISOR',
      userId: 'supervisor-1',
      period: undefined,
      selectedSectorId: undefined,
    });
    expect(result).toEqual(mockSummary);
  });

  it('should pass query params to service', async () => {
    const req = mockReq();
    const result = await controller.getSummary(req as any, 'week', 'sector-3');

    expect(service.getSummary).toHaveBeenCalledWith({
      userRole: 'ADMIN',
      userId: 'user-1',
      period: 'week',
      selectedSectorId: 'sector-3',
    });
    expect(result).toEqual(mockSummary);
  });

  it('should handle missing query params', async () => {
    const req = mockReq();
    const result = await controller.getSummary(
      req as any,
      undefined,
      undefined,
    );

    expect(service.getSummary).toHaveBeenCalledWith({
      userRole: 'ADMIN',
      userId: 'user-1',
      period: undefined,
      selectedSectorId: undefined,
    });
    expect(result).toEqual(mockSummary);
  });
});
