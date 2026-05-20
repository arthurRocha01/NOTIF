import 'package:notif_app/core/api/api_client.dart';

class AttentionSector {
  final String name;
  final double rate;
  final int pendingCount;

  const AttentionSector({
    required this.name,
    required this.rate,
    required this.pendingCount,
  });

  factory AttentionSector.fromJson(Map<String, dynamic> json) {
    return AttentionSector(
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
      pendingCount: json['pendingCount'] as int,
    );
  }
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

  factory SectorStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return SectorStatusBreakdown(
      pending: json['pending'] as int,
      viewed: json['viewed'] as int,
      acknowledged: json['acknowledged'] as int,
      overdue: json['overdue'] as int,
    );
  }
}

class DashboardData {
  final int totalNotifications;
  final int totalAcknowledged;
  final int totalPending;
  final int totalCritical;
  final String topSector;
  final double topSectorRate;
  final Map<String, double> sectorRates;
  final List<AttentionSector> attentionSectors;
  final SectorStatusBreakdown? selectedSectorBreakdown;

  const DashboardData({
    required this.totalNotifications,
    required this.totalAcknowledged,
    required this.totalPending,
    required this.totalCritical,
    required this.topSector,
    required this.topSectorRate,
    required this.sectorRates,
    required this.attentionSectors,
    this.selectedSectorBreakdown,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    bool isGlobal(String name) => name.toLowerCase() == 'global';

    // "Global" é broadcast para todos os setores, não um setor real — excluir das métricas
    final sectorRates = (json['sectorRates'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toDouble()))
          ..removeWhere((k, _) => isGlobal(k));

    final attentionSectors = (json['attentionSectors'] as List<dynamic>)
        .map((e) => AttentionSector.fromJson(e as Map<String, dynamic>))
        .where((s) => !isGlobal(s.name))
        .toList();

    // Se o backend apontou "Global" como top setor, recalcula pelo maior real
    String topSector = json['topSector'] as String;
    double topSectorRate = (json['topSectorRate'] as num).toDouble();
    if (isGlobal(topSector) && sectorRates.isNotEmpty) {
      final top = sectorRates.entries.reduce((a, b) => a.value >= b.value ? a : b);
      topSector = top.key;
      topSectorRate = top.value;
    }

    return DashboardData(
      totalNotifications: json['totalNotifications'] as int,
      totalAcknowledged: json['totalAcknowledged'] as int,
      totalPending: json['totalPending'] as int,
      totalCritical: json['totalCritical'] as int,
      topSector: topSector,
      topSectorRate: topSectorRate,
      sectorRates: sectorRates,
      attentionSectors: attentionSectors,
      selectedSectorBreakdown: json['selectedSectorBreakdown'] != null
          ? SectorStatusBreakdown.fromJson(
              json['selectedSectorBreakdown'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class DashboardService {
  Future<DashboardData> getSummary({String? period, String? sectorId}) async {
    final params = [
      if (period != null) 'period=$period',
      if (sectorId != null) 'sectorId=$sectorId',
    ];
    final query = params.isNotEmpty ? '?${params.join("&")}' : '';
    final data = await ApiClient.get('/dashboard/summary$query');
    return DashboardData.fromJson(data as Map<String, dynamic>);
  }
}
