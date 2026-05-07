import { Test, TestingModule } from '@nestjs/testing';
import { DashboardService } from './dashboard.service';
import { DashboardRepository } from '../infrastructure/dashboard.repository.impl';

describe('DashboardService', () => {
  let service: DashboardService;
  let repo: jest.Mocked<DashboardRepository>;

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

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        {
          provide: DashboardRepository,
          useValue: {
            getSummary: jest.fn().mockResolvedValue(mockSummary),
          },
        },
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
    repo = module.get(DashboardRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return summary without period filter', async () => {
    const result = await service.getSummary({
      userRole: 'ADMIN',
    });

    expect(repo.getSummary).toHaveBeenCalledWith({
      sectorId: undefined,
      cutoff: undefined,
      selectedSectorId: undefined,
    });
    expect(result).toEqual(mockSummary);
  });

  it('should pass sectorId for supervisor', async () => {
    await service.getSummary({
      userRole: 'SUPERVISOR',
      userSectorId: 'sector-1',
    });

    expect(repo.getSummary).toHaveBeenCalledWith(
      expect.objectContaining({ sectorId: 'sector-1' }),
    );
  });

  it('should not pass sectorId for admin', async () => {
    await service.getSummary({
      userRole: 'ADMIN',
      userSectorId: 'sector-1',
    });

    expect(repo.getSummary).toHaveBeenCalledWith(
      expect.objectContaining({ sectorId: undefined }),
    );
  });

  it('should set cutoff for week period', async () => {
    const now = Date.now();
    const weekAgo = now - 7 * 24 * 60 * 60 * 1000;

    await service.getSummary({
      userRole: 'ADMIN',
      period: 'week',
    });

    const call = repo.getSummary.mock.calls[0][0];
    expect(call.cutoff).toBeDefined();
    expect(call.cutoff.getTime()).toBeGreaterThanOrEqual(weekAgo - 1000);
    expect(call.cutoff.getTime()).toBeLessThanOrEqual(now);
  });

  it('should set cutoff for month period', async () => {
    const now = Date.now();
    const monthAgo = now - 30 * 24 * 60 * 60 * 1000;

    await service.getSummary({
      userRole: 'ADMIN',
      period: 'month',
    });

    const call = repo.getSummary.mock.calls[0][0];
    expect(call.cutoff).toBeDefined();
    expect(call.cutoff.getTime()).toBeGreaterThanOrEqual(monthAgo - 1000);
    expect(call.cutoff.getTime()).toBeLessThanOrEqual(now);
  });

  it('should not set cutoff when period is all', async () => {
    await service.getSummary({
      userRole: 'ADMIN',
      period: 'all',
    });

    expect(repo.getSummary).toHaveBeenCalledWith(
      expect.objectContaining({ cutoff: undefined }),
    );
  });

  it('should pass selectedSectorId when provided', async () => {
    await service.getSummary({
      userRole: 'ADMIN',
      selectedSectorId: 'sector-2',
    });

    expect(repo.getSummary).toHaveBeenCalledWith(
      expect.objectContaining({ selectedSectorId: 'sector-2' }),
    );
  });
});
