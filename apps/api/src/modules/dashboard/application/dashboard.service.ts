import { Injectable } from '@nestjs/common';
import { DashboardRepository } from '../infrastructure/dashboard.repository.impl';
import { DashboardSummaryDto } from '../dto/dashboard-summary.dto';

@Injectable()
export class DashboardService {
  constructor(private readonly dashboardRepo: DashboardRepository) {}

  async getSummary(params: {
    userRole: string;
    userSectorId?: string;
    period?: string;
    selectedSectorId?: string;
  }): Promise<DashboardSummaryDto> {
    const { userRole, userSectorId, period, selectedSectorId } = params;

    let cutoff: Date | undefined;
    if (period === 'week') {
      cutoff = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    } else if (period === 'month') {
      cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    }

    const sectorId = userRole === 'SUPERVISOR' ? userSectorId : undefined;

    return this.dashboardRepo.getSummary({
      sectorId,
      cutoff,
      selectedSectorId,
    });
  }
}
