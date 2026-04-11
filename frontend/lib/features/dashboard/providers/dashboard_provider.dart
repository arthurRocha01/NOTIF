import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alerts/models/alert_status.dart';
import '../../alerts/providers/alert_provider.dart';

class DashboardData {
  final String topSector;
  final double topSectorRate;
  final Map<String, double> sectorRates;
  final List<String> attentionSectors;

  DashboardData({
    required this.topSector,
    required this.topSectorRate,
    required this.sectorRates,
    required this.attentionSectors,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final alertState = ref.watch(alertProvider);
  final notifications = alertState.notifications;
  final assignments = alertState.assignments;

  if (notifications.isEmpty || assignments.isEmpty) {
    return DashboardData(
      topSector: 'Nenhum',
      topSectorRate: 0.0,
      sectorRates: {},
      attentionSectors: [],
    );
  }

  // notificationId → targetSectorId (null = global, ignorado no cálculo)
  final sectorById = {
    for (final n in notifications)
      if (n.targetSectorId != null) n.id: n.targetSectorId!,
  };

  // setor → { total, acknowledged }
  final Map<String, int> total = {};
  final Map<String, int> acknowledged = {};

  for (final assignment in assignments) {
    final sectorId = sectorById[assignment.notificationId];
    if (sectorId == null) continue; // notificação global → ignora

    total[sectorId] = (total[sectorId] ?? 0) + 1;
    if (assignment.status == AssignmentStatus.acknowledged) {
      acknowledged[sectorId] = (acknowledged[sectorId] ?? 0) + 1;
    }
  }

  if (total.isEmpty) {
    return DashboardData(
      topSector: 'Nenhum',
      topSectorRate: 0.0,
      sectorRates: {},
      attentionSectors: [],
    );
  }

  final sectorRates = {
    for (final entry in total.entries)
      entry.key: (acknowledged[entry.key] ?? 0) / entry.value,
  };

  final sorted = sectorRates.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topSector = sorted.first.key;
  final topRate = sorted.first.value;
  final attentionSectors =
      sectorRates.entries.where((e) => e.value < 0.6).map((e) => e.key).toList();

  return DashboardData(
    topSector: topSector,
    topSectorRate: topRate,
    sectorRates: sectorRates,
    attentionSectors: attentionSectors,
  );
});
