import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alerts/models/alert_status.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../sectors/providers/sector_provider.dart';
import 'dashboard_filter_provider.dart';

// ── Modelos auxiliares ────────────────────────────────────────────────────────

class AttentionSector {
  final String id;       // nome resolvido ou UUID como fallback
  final double rate;
  final int pendingCount;

  const AttentionSector({
    required this.id,
    required this.rate,
    required this.pendingCount,
  });
}

class SectorStatusBreakdown {
  final int pending;
  final int viewed;
  final int acknowledged;
  final int overdue;

  const SectorStatusBreakdown({
    required this.pending,
    required this.viewed,
    required this.acknowledged,
    required this.overdue,
  });
}

// ── DashboardData ─────────────────────────────────────────────────────────────

class DashboardData {
  final String topSector;
  final double topSectorRate;

  /// sectorName → taxa de adesão (acknowledged / total)
  final Map<String, double> sectorRates;

  /// Setores com taxa < 60%, ordenados do pior para o melhor
  final List<AttentionSector> attentionSectors;

  /// KPIs globais (respeitam o filtro de período)
  final int totalAssignments;
  final int totalAcknowledged;
  final int totalPending;
  final int totalCritical;

  /// Breakdown de status para o setor selecionado (null = nenhum selecionado)
  final SectorStatusBreakdown? selectedSectorBreakdown;

  const DashboardData({
    required this.topSector,
    required this.topSectorRate,
    required this.sectorRates,
    required this.attentionSectors,
    required this.totalAssignments,
    required this.totalAcknowledged,
    required this.totalPending,
    required this.totalCritical,
    this.selectedSectorBreakdown,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final dashboardProvider = Provider<DashboardData>((ref) {
  final alertState  = ref.watch(alertProvider);
  final sectorState = ref.watch(sectorProvider);
  final filter      = ref.watch(dashboardFilterProvider);

  final notifications = alertState.notifications;
  var   assignments   = alertState.allAssignments;

  // ── 1. Filtro de período ────────────────────────────────────────────────
  if (filter.period != DashboardPeriod.all) {
    final cutoff = DateTime.now().subtract(
      filter.period == DashboardPeriod.week
          ? const Duration(days: 7)
          : const Duration(days: 30),
    );
    assignments = assignments
        .where((a) => a.createdAt.isAfter(cutoff))
        .toList();
  }

  // ── 2. Resolver nomes de setor (UUID → nome) ────────────────────────────
  final sectorNameById = {
    for (final s in sectorState.sectors) s.id: s.name,
  };

  String resolveName(String id) => sectorNameById[id] ?? id;

  // ── 3. KPIs globais ─────────────────────────────────────────────────────
  final totalAssignments  = assignments.length;
  final totalAcknowledged = assignments
      .where((a) => a.status == AssignmentStatus.acknowledged).length;
  final totalPending = assignments
      .where((a) => a.status == AssignmentStatus.pending).length;
  final totalCritical = assignments
      .where((a) => a.notificationLevel == AlertLevel.critical).length;

  // ── 4. Mapa notificationId → sectorId (só notificações setorizadas) ─────
  final sectorById = {
    for (final n in notifications)
      if (n.targetSectorId != null) n.id: n.targetSectorId!,
  };

  // ── 5. Acumuladores por sectorId ─────────────────────────────────────────
  final Map<String, int> total        = {};
  final Map<String, int> acknowledged = {};
  final Map<String, int> pending      = {};

  for (final a in assignments) {
    final sectorId = sectorById[a.notificationId];
    if (sectorId == null) continue; // notificação global → ignora

    total[sectorId]        = (total[sectorId] ?? 0) + 1;
    if (a.status == AssignmentStatus.acknowledged) {
      acknowledged[sectorId] = (acknowledged[sectorId] ?? 0) + 1;
    }
    if (a.status == AssignmentStatus.pending) {
      pending[sectorId] = (pending[sectorId] ?? 0) + 1;
    }
  }

  if (total.isEmpty) {
    return DashboardData(
      topSector: 'Nenhum',
      topSectorRate: 0.0,
      sectorRates: {},
      attentionSectors: [],
      totalAssignments: totalAssignments,
      totalAcknowledged: totalAcknowledged,
      totalPending: totalPending,
      totalCritical: totalCritical,
    );
  }

  // ── 6. Taxas por setor (usando nome resolvido como chave) ────────────────
  final sectorRates = {
    for (final e in total.entries)
      resolveName(e.key): (acknowledged[e.key] ?? 0) / e.value,
  };

  // ── 7. Top setor ──────────────────────────────────────────────────────────
  final sorted = sectorRates.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topSector = sorted.first.key;
  final topRate   = sorted.first.value;

  // ── 8. Attention sectors (< 60%, pior primeiro, com detalhes) ────────────
  final attentionSectors = total.entries
      .map((e) {
        final rate         = (acknowledged[e.key] ?? 0) / e.value;
        final pendingCount = pending[e.key] ?? 0;
        return AttentionSector(
          id:           resolveName(e.key),
          rate:         rate,
          pendingCount: pendingCount,
        );
      })
      .where((a) => a.rate < 0.6)
      .toList()
    ..sort((a, b) => a.rate.compareTo(b.rate)); // pior primeiro

  // ── 9. Breakdown do setor selecionado ─────────────────────────────────────
  SectorStatusBreakdown? breakdown;
  final selectedId = filter.selectedSectorId;
  if (selectedId != null) {
    final sectorAssignments = assignments.where((a) {
      final sid = sectorById[a.notificationId];
      return sid == selectedId;
    }).toList();

    breakdown = SectorStatusBreakdown(
      pending:      sectorAssignments.where((a) => a.status == AssignmentStatus.pending).length,
      viewed:       sectorAssignments.where((a) => a.status == AssignmentStatus.viewed).length,
      acknowledged: sectorAssignments.where((a) => a.status == AssignmentStatus.acknowledged).length,
      overdue:      sectorAssignments.where((a) => a.status == AssignmentStatus.overdue).length,
    );
  }

  return DashboardData(
    topSector:               topSector,
    topSectorRate:           topRate,
    sectorRates:             sectorRates,
    attentionSectors:        attentionSectors,
    totalAssignments:        totalAssignments,
    totalAcknowledged:       totalAcknowledged,
    totalPending:            totalPending,
    totalCritical:           totalCritical,
    selectedSectorBreakdown: breakdown,
  );
});
