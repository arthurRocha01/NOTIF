import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/dashboard/widgets/attention_sector_card.dart';
import '../providers/dashboard_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../widgets/highlight_card.dart';
import '../widgets/sector_progress_bar.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider);
    final alertState = ref.watch(alertProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Gestão de Notificações", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: () => ref.read(alertProvider.notifier).loadActiveAlerts(),
          )
        ],
      ),
      body: alertState.isLoadingActive 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: () => ref.read(alertProvider.notifier).loadActiveAlerts(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Painel de gestão", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text("Métricas em tempo real", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  // 1. Card de Destaque
                  HighlightCard(sector: stats.topSector, rate: stats.topSectorRate),
                  
                  const SizedBox(height: 20),
                  
                  // 2. Card de Barras de Progresso
                  _buildSectionCard(
                    title: "Taxa de leitura por setor",
                    child: stats.sectorRates.isEmpty 
                      ? const Text("Nenhum dado disponível")
                      : Column(
                          children: stats.sectorRates.entries.map((e) => 
                            SectorProgressBar(label: e.key, value: e.value)).toList(),
                        ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 3. Card de Atenção e Ação
                  AttentionCard(
                    sectors: stats.attentionSectors,
                    onNotify: () {
                      ref.read(alertProvider.notifier).notifyPendingSectors(stats.attentionSectors);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Comandos de reforço enviados para a API!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}