import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alerts/providers/alert_provider.dart';

/// 1. DEFINIÇÃO DA CLASSE (O que o Dashboard precisa segurar)
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

/// 2. O PROVIDER (A lógica que transforma Alertas em Dados de Dashboard)
final dashboardProvider = Provider<DashboardData>((ref) {
  // Observa o estado dos alertas (unificando ativos e histórico)
  final alertState = ref.watch(alertProvider);
  final allAlerts = [...alertState.activeAlerts, ...alertState.history];

  if (allAlerts.isEmpty) {
    return DashboardData(
      topSector: "Nenhum",
      topSectorRate: 0.0,
      sectorRates: {},
      attentionSectors: [],
    );
  }

  // Mapa para acumular as taxas de leitura por setor
  Map<String, List<double>> ratesBySector = {};

  for (var alert in allAlerts) {
    for (var sector in alert.sectors) {
      ratesBySector.putIfAbsent(sector, () => []);
      ratesBySector[sector]!.add(alert.readRate);
    }
  }

  // Calcula a média de leitura de cada setor
  Map<String, double> finalRates = {};
  ratesBySector.forEach((sector, rates) {
    if (rates.isNotEmpty) {
      final sum = rates.reduce((a, b) => a + b);
      finalRates[sector] = sum / rates.length;
    }
  });

  // Identifica o melhor setor (Top Sector)
  var sortedSectors = finalRates.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  String topSector = sortedSectors.isNotEmpty ? sortedSectors.first.key : "Nenhum";
  double topRate = sortedSectors.isNotEmpty ? sortedSectors.first.value : 0.0;

  // Filtra setores com adesão crítica (abaixo de 60%)
  List<String> attention = finalRates.entries
      .where((e) => e.value < 0.6)
      .map((e) => e.key)
      .toList();

  return DashboardData(
    topSector: topSector,
    topSectorRate: topRate,
    sectorRates: finalRates,
    attentionSectors: attention,
  );
});