import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/modals/create_alert_modal.dart';
import 'package:notif_app/features/alerts/modals/create_message_modal.dart';
import 'package:notif_app/features/alerts/widgets/monitoring_alert_card.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../../../core/constants/app_spacing.dart';

class AlertAdminScreen extends ConsumerStatefulWidget {
  const AlertAdminScreen({super.key});

  @override
  ConsumerState<AlertAdminScreen> createState() => _AlertAdminScreenState();
}

class _AlertAdminScreenState extends ConsumerState<AlertAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedSector = 'Todos';

  final List<String> _sectors = ['Todos', 'TI', 'Operações', 'RH', 'Financeiro', 'Logística', 'Comercial'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AlertModel> _getFilteredAlerts(List<AlertModel> alerts) {
    return alerts.where((alert) {
      final matchesSector = _selectedSector == 'Todos' || (alert.sectors?.contains(_selectedSector) ?? false);
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch = alert.title.toLowerCase().contains(query) || 
                           alert.description.toLowerCase().contains(query);
      return matchesSector && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFFF8FAFC),
            title: const Text(
              "Painel de Monitoramento",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF3B82F6),
                labelColor: const Color(0xFF3B82F6),
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  _buildTabHeader("Ativos", state.activeAlerts.length, const Color(0xFFB91C1C)),
                  _buildTabHeader("Histórico", state.history.length, Colors.grey),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildListContent(state.activeAlerts, state.isLoadingActive, isHistory: false),
            _buildListContent(state.history, state.isLoadingHistory, isHistory: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader(String label, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
              child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListContent(List<AlertModel> alerts, bool isLoading, {required bool isHistory}) {
    final filtered = _getFilteredAlerts(alerts);

    return RefreshIndicator(
      onRefresh: () => isHistory 
          ? ref.read(alertProvider.notifier).loadHistory() 
          : ref.read(alertProvider.notifier).loadActiveAlerts(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          if (!isHistory) ...[
            _buildQuickActions(),
            const SizedBox(height: 16),
          ],
          _buildFilters(),
          const SizedBox(height: 20),
          if (isLoading && alerts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((a) => MonitoringAlertCard(key: ValueKey(a.id), alert: a)).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionBtn("Novo Alerta", Icons.add_alert, const Color(0xFFB91C1C), 
          () => CreateAlertModal.show(context)),
        const SizedBox(width: 12),
        _buildActionBtn("Comunicado", Icons.campaign, const Color(0xFF1E3A8A), 
          () => CreateMessageModal.show(context)),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Pesquisar registros...",
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _sectors.map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s),
                selected: _selectedSector == s,
                onSelected: (v) => setState(() => _selectedSector = s),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF3B82F6).withOpacity(0.1),
                side: BorderSide(color: _selectedSector == s ? const Color(0xFF3B82F6) : Colors.transparent),
                labelStyle: TextStyle(
                  color: _selectedSector == s ? const Color(0xFF3B82F6) : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: _selectedSector == s ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("Nenhum registro encontrado", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}