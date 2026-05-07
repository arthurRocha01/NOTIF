import { AssignmentStatus, NotificationLevel, Prisma } from '@prisma/client';
import type { IDashboardRepository } from '../domain/dashboard.repository';
import type { DashboardSummaryDto } from '../dto/dashboard-summary.dto';
import { PrismaService } from '../../../prisma/prisma.service';
import { Injectable } from '@nestjs/common';

type AssignmentWithNotification = Prisma.NotificationAssignmentGetPayload<{
  include: { notification: { include: { sector: true } } };
}>;

interface Kpis {
  totalNotifications: number;
  totalAcknowledged: number;
  totalPending: number;
  totalCritical: number;
}

interface SectorStats {
  sectorRates: Record<string, number>;
  attentionSectors: { name: string; rate: number; pendingCount: number }[];
  topSector: string;
  topSectorRate: number;
}

@Injectable()
export class DashboardRepository implements IDashboardRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(params: {
    sectorId?: string;
    cutoff?: Date;
    selectedSectorId?: string;
  }): Promise<DashboardSummaryDto> {
    const { sectorId, cutoff, selectedSectorId } = params;

    const notifFilter = this.buildNotifFilter(sectorId, cutoff);
    const assignments = await this.fetchAssignments(notifFilter);

    const kpis = this.computeKpis(assignments);
    const stats = this.computeSectorStats(assignments);
    const selectedSectorBreakdown = selectedSectorId
      ? this.computeBreakdown(assignments, selectedSectorId)
      : undefined;

    return {
      ...kpis,
      ...stats,
      selectedSectorBreakdown,
    };
  }

  private buildNotifFilter(
    sectorId?: string,
    cutoff?: Date,
  ): Record<string, any> {
    const filter: Record<string, any> = {};

    if (sectorId) {
      filter.OR = [{ sectorId }, { sectorId: null }];
    }

    if (cutoff) {
      filter.createdAt = { gte: cutoff };
    }

    return filter;
  }

  private async fetchAssignments(
    notifFilter: Record<string, any>,
  ): Promise<AssignmentWithNotification[]> {
    return this.prisma.notificationAssignment.findMany({
      where: { notification: notifFilter },
      include: {
        notification: {
          include: { sector: true },
        },
      },
    });
  }

  private computeKpis(assignments: AssignmentWithNotification[]): Kpis {
    const totalNotifications = new Set(assignments.map((a) => a.notificationId))
      .size;

    const totalAcknowledged = assignments.filter(
      (a) => a.status === AssignmentStatus.ACKNOWLEDGED,
    ).length;

    const totalPending = assignments.filter(
      (a) =>
        a.status === AssignmentStatus.PENDING ||
        a.status === AssignmentStatus.VIEWED,
    ).length;

    const totalCritical = assignments.filter(
      (a) => a.notification.level === NotificationLevel.CRITICAL,
    ).length;

    return {
      totalNotifications,
      totalAcknowledged,
      totalPending,
      totalCritical,
    };
  }

  private computeSectorStats(
    assignments: AssignmentWithNotification[],
  ): SectorStats {
    const sectorMap = new Map<
      string,
      { total: number; ack: number; pending: number }
    >();

    for (const a of assignments) {
      const name = a.notification.sector?.name ?? 'Global';
      const entry = sectorMap.get(name) ?? { total: 0, ack: 0, pending: 0 };
      entry.total++;
      if (a.status === AssignmentStatus.ACKNOWLEDGED) entry.ack++;
      if (a.status === AssignmentStatus.PENDING) entry.pending++;
      sectorMap.set(name, entry);
    }

    const sectorRates: Record<string, number> = {};
    const attentionSectors: {
      name: string;
      rate: number;
      pendingCount: number;
    }[] = [];

    for (const [name, data] of sectorMap) {
      const rate =
        data.total === 0 ? 0 : Math.round((data.ack / data.total) * 100) / 100;
      sectorRates[name] = rate;

      if (rate < 0.6) {
        attentionSectors.push({ name, rate, pendingCount: data.pending });
      }
    }

    attentionSectors.sort((a, b) => a.rate - b.rate);

    const sorted = Object.entries(sectorRates).sort((a, b) => b[1] - a[1]);
    const topSector = sorted[0]?.[0] ?? 'Nenhum';
    const topSectorRate = sorted[0]?.[1] ?? 0;

    return { sectorRates, attentionSectors, topSector, topSectorRate };
  }

  private computeBreakdown(
    assignments: AssignmentWithNotification[],
    sectorId: string,
  ): NonNullable<DashboardSummaryDto['selectedSectorBreakdown']> {
    const filtered = assignments.filter(
      (a) =>
        a.notification.sectorId === sectorId ||
        a.notification.sectorId === null,
    );

    return {
      pending: filtered.filter((a) => a.status === 'PENDING').length,
      viewed: filtered.filter((a) => a.status === 'VIEWED').length,
      acknowledged: filtered.filter((a) => a.status === 'ACKNOWLEDGED').length,
      overdue: filtered.filter((a) => a.status === 'OVERDUE').length,
    };
  }
}
