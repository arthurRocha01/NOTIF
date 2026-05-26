import type { DashboardSummaryDto } from '../dto/dashboard-summary.dto';

export interface IDashboardRepository {
  getSummary(params: {
    authorId?: string;
    cutoff?: Date;
    selectedSectorId?: string;
  }): Promise<DashboardSummaryDto>;
}
