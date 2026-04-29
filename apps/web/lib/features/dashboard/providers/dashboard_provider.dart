import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alerts/models/alert_model.dart';
import '../../alerts/models/alert_status.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../login/providers/auth_provider.dart';
import '../../sectors/providers/sector_provider.dart';
import '../../../core/model/user_model.dart';
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

  /// sectorName → taxa de adesão (notificações totalmente confirmadas / total)
  final Map<String, double> sectorRates;

  /// Setores com taxa < 60%, ordenados do pior para o melhor
  final List<AttentionSector> attentionSectors;

  /// KPIs do setor do supervisor (respeitam o filtro de período)
  final int totalNotifications;
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
    required this.totalNotifications,
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
  final user        = ref.watch(authProvider);

  final allNotifications = alertState.notifications;
  final allAssignments   = alertState.allAssignments;

  // ── Mapa notificationId → assignments (para cálculo de status) ───────────
  final assignmentsByNotif = <String, List<AssignmentModel>>{};
  for (final a in allAssignments) {
    assignmentsByNotif.putIfAbsent(a.notificationId, () => []).add(a);
  }

  // ── Filtro de período aplicado às notificações ───────────────────────────
  DateTime? cutoff;
  if (filter.period != DashboardPeriod.all) {
    cutoff = DateTime.now().subtract(
      filter.period == DashboardPeriod.week
          ? const Duration(days: 7)
          : const Duration(days: 30),
    );
  }

  List<AlertModel> applyPeriod(List<AlertModel> list) => cutoff == null
      ? list
      : list.where((n) => n.createdAt.isAfter(cutoff!)).toList();

  // ── Resolver nomes de setor ───────────────────────────────────────────────
  final sectorNameById = {
    for (final s in sectorState.sectors) s.id: s.name,
  };
  String resolveName(String id) => sectorNameById[id] ?? id;

  // ── Helpers de status por notificação ────────────────────────────────────
  bool isFullyAcknowledged(String notifId) {
    final assigns = assignmentsByNotif[notifId] ?? [];
    if (assigns.isEmpty) return false;
    return assigns.every((a) => a.status == AssignmentStatus.acknowledged);
  }

  bool hasPending(String notifId) {
    final assigns = assignmentsByNotif[notifId] ?? [];
    return assigns.any((a) =>
        a.status == AssignmentStatus.pending ||
        a.status == AssignmentStatus.viewed);
  }

  // ── 1. KPIs — notificações do setor do supervisor ────────────────────────
  final supervisorSectorId =
      user?.role == UserRole.supervisor ? user?.sectorId : null;

  final sectorNotifications = applyPeriod(
    supervisorSectorId != null
        ? allNotifications
            .where((n) => n.targetSectorId == supervisorSectorId)
            .toList()
        : allNotifications,
  );

  final totalNotifications  = sectorNotifications.length;
  final totalAcknowledged   = sectorNotifications
      .where((n) => isFullyAcknowledged(n.id))
      .length;
  final totalPending        = sectorNotifications
      .where((n) => hasPending(n.id))
      .length;
  final totalCritical       = sectorNotifications
      .where((n) => n.level == AlertLevel.critical)
      .length;

  // ── 2. Gráfico — taxa por setor (todas as notificações setorizadas) ───────
  // Universo: notificações (não assignments); taxa: assignments confirmados / total
  final chartNotifications = applyPeriod(
    allNotifications.where((n) => n.targetSectorId != null).toList(),
  );

  final Map<String, int> totalBySector        = {};
  final Map<String, int> acknowledgedBySector = {};
  final Map<String, int> pendingBySector      = {};

  for (final n in chartNotifications) {
    final sid     = n.targetSectorId!;
    final assigns = assignmentsByNotif[n.id] ?? [];

    // conta a notificação no total do setor (mesmo sem assignments)
    totalBySector[sid] = (totalBySector[sid] ?? 0) + 1;

    // acumula assignments por status para calcular a taxa real
    for (final a in assigns) {
      if (a.status == AssignmentStatus.acknowledged) {
        acknowledgedBySector[sid] = (acknowledgedBySector[sid] ?? 0) + 1;
      }
      if (a.status == AssignmentStatus.pending ||
          a.status == AssignmentStatus.viewed) {
        pendingBySector[sid] = (pendingBySector[sid] ?? 0) + 1;
      }
    }
  }

  if (totalBySector.isEmpty) {
    return DashboardData(
      topSector:          'Nenhum',
      topSectorRate:      0.0,
      sectorRates:        {},
      attentionSectors:   [],
      totalNotifications: totalNotifications,
      totalAcknowledged:  totalAcknowledged,
      totalPending:       totalPending,
      totalCritical:      totalCritical,
    );
  }

  // ── 3. Taxas por setor (acknowledged assignments / total assignments) ───────
  // Conta assignments reais por setor (denominador correto para a taxa)
  final Map<String, int> assignmentsBySector = {};
  for (final e in totalBySector.keys) {
    final notifIds = chartNotifications
        .where((n) => n.targetSectorId == e)
        .map((n) => n.id)
        .toSet();
    assignmentsBySector[e] = allAssignments
        .where((a) => notifIds.contains(a.notificationId))
        .length;
  }

  final sectorRates = {
    for (final e in totalBySector.entries)
      resolveName(e.key): assignmentsBySector[e.key] == 0
          ? 0.0
          : (acknowledgedBySector[e.key] ?? 0) / assignmentsBySector[e.key]!,
  };

  // ── 4. Top setor ──────────────────────────────────────────────────────────
  final sorted = sectorRates.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topSector = sorted.first.key;
  final topRate   = sorted.first.value;

  // ── 5. Attention sectors (< 60%) ─────────────────────────────────────────
  final attentionSectors = totalBySector.keys
      .map((sid) {
        final total      = assignmentsBySector[sid] ?? 0;
        final rate       = total == 0 ? 0.0 : (acknowledgedBySector[sid] ?? 0) / total;
        final pendingCount = pendingBySector[sid] ?? 0;
        return AttentionSector(
          id:           resolveName(sid),
          rate:         rate,
          pendingCount: pendingCount,
        );
      })
      .where((a) => a.rate < 0.6)
      .toList()
    ..sort((a, b) => a.rate.compareTo(b.rate));

  // ── 6. Breakdown do setor selecionado ─────────────────────────────────────
  SectorStatusBreakdown? breakdown;
  final selectedId = filter.selectedSectorId;
  if (selectedId != null) {
    final selectedNotifs = chartNotifications
        .where((n) => n.targetSectorId == selectedId)
        .toList();

    int bPending = 0, bViewed = 0, bAcknowledged = 0, bOverdue = 0;
    for (final n in selectedNotifs) {
      final assigns = assignmentsByNotif[n.id] ?? [];
      for (final a in assigns) {
        switch (a.status) {
          case AssignmentStatus.pending:      bPending++;      break;
          case AssignmentStatus.viewed:       bViewed++;       break;
          case AssignmentStatus.acknowledged: bAcknowledged++; break;
          case AssignmentStatus.overdue:      bOverdue++;      break;
        }
      }
    }

    breakdown = SectorStatusBreakdown(
      pending:      bPending,
      viewed:       bViewed,
      acknowledged: bAcknowledged,
      overdue:      bOverdue,
    );
  }

  return DashboardData(
    topSector:               topSector,
    topSectorRate:           topRate,
    sectorRates:             sectorRates,
    attentionSectors:        attentionSectors,
    totalNotifications:      totalNotifications,
    totalAcknowledged:       totalAcknowledged,
    totalPending:            totalPending,
    totalCritical:           totalCritical,
    selectedSectorBreakdown: breakdown,
  );
});
