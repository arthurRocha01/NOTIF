export class DashboardSummaryDto {
  totalNotifications: number;
  totalAcknowledged: number;
  totalPending: number;
  totalCritical: number;
  topSector: string;
  topSectorRate: number;
  sectorRates: Record<string, number>;
  attentionSectors: { name: string; rate: number; pendingCount: number }[];
  selectedSectorBreakdown?: {
    pending: number;
    viewed: number;
    acknowledged: number;
    overdue: number;
  };
}
