import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/dashboard/widgets/attention_sector_card.dart';
import '../providers/dashboard_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../widgets/highlight_card.dart';
import '../widgets/sector_progress_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertProvider.notifier).loadNotifications();
      ref.read(alertProvider.notifier).loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardProvider);
    final alertState = ref.watch(alertProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: (alertState.isLoadingNotifications || alertState.isLoadingAssignments)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(alertProvider.notifier).loadNotifications();
                ref.read(alertProvider.notifier).loadAssignments();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Painel de gestão",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B)),
                              ),
                              Text(
                                "Métricas em tempo real",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFF1E293B)),
                          tooltip: 'Atualizar',
                          onPressed: () {
                            ref
                                .read(alertProvider.notifier)
                                .loadNotifications();
                            ref
                                .read(alertProvider.notifier)
                                .loadAssignments();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    HighlightCard(
                        sector: stats.topSector, rate: stats.topSectorRate),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Taxa de adesão por setor",
                      child: stats.sectorRates.isEmpty
                          ? const Text("Nenhum dado disponível")
                          : Column(
                              children: stats.sectorRates.entries
                                  .map((e) => SectorProgressBar(
                                      label: e.key, value: e.value))
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 20),
                    AttentionCard(
                      sectors: stats.attentionSectors,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
