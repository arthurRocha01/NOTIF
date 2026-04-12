import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/modals/create_alert_modal.dart';
import 'package:notif_app/features/alerts/modals/create_message_modal.dart';
import 'package:notif_app/features/alerts/widgets/monitoring_alert_card.dart';
import 'package:notif_app/features/alerts/widgets/assignments_body.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_spacing.dart';

class AlertAdminScreen extends ConsumerStatefulWidget {
  const AlertAdminScreen({super.key});

  @override
  ConsumerState<AlertAdminScreen> createState() => _AlertAdminScreenState();
}

class _AlertAdminScreenState extends ConsumerState<AlertAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  // null = "Todos"; valor = UUID do setor selecionado
  String? _selectedSectorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(alertProvider.notifier).loadNotifications();
      ref.read(sectorProvider.notifier).loadSectors();
      await ref.read(alertProvider.notifier).loadAssignments();
      _markPendingAsViewed();
    });
  }

  void _markPendingAsViewed() {
    final pending = ref
        .read(alertProvider)
        .assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .toList();
    for (final a in pending) {
      ref.read(alertProvider.notifier).markAsViewed(assignmentId: a.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AlertModel> _getFilteredAlerts(List<AlertModel> alerts) {
    return alerts.where((alert) {
      final matchesSector = _selectedSectorId == null ||
          alert.isGlobal ||
          alert.targetSectorId == _selectedSectorId;
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch = alert.title.toLowerCase().contains(query) ||
          alert.message.toLowerCase().contains(query);
      return matchesSector && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertProvider);
    final sectorState = ref.watch(sectorProvider);

    ref.listen<String?>(
      alertProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error),
                backgroundColor: Colors.red.shade700),
          );
        }
      },
    );

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
              'Painel de Monitoramento',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B)),
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
                  _buildTabHeader('Notificações',
                      state.notifications.length, const Color(0xFFB91C1C)),
                  _buildTabHeader('Minhas notificações',
                      state.assignments.where((a) =>
                        a.status != AssignmentStatus.acknowledged).length,
                      const Color(0xFF3B82F6)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildListContent(
              state.notifications,
              state.isLoadingNotifications,
              sectorState,
            ),
            AssignmentsBody(
              assignments: state.assignments,
              isLoading: state.isLoadingAssignments,
              isBlocked: state.isBlocked,
              onRefresh: () =>
                  ref.read(alertProvider.notifier).loadAssignments(),
              onAcknowledge: (id) =>
                  ref.read(alertProvider.notifier).acknowledge(assignmentId: id),
            ),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListContent(
    List<AlertModel> alerts,
    bool isLoading,
    SectorState sectorState,
  ) {
    final filtered = _getFilteredAlerts(alerts);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(alertProvider.notifier).loadNotifications();
        await ref.read(sectorProvider.notifier).loadSectors();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildFilters(sectorState),
          const SizedBox(height: 20),
          if (isLoading && alerts.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map(
                (a) => MonitoringAlertCard(key: ValueKey(a.id), alert: a)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionBtn('Novo Alerta', Icons.add_alert,
            const Color(0xFFB91C1C), () => CreateAlertModal.show(context)),
        const SizedBox(width: 12),
        _buildActionBtn('Comunicado', Icons.campaign,
            const Color(0xFF1E3A8A), () => CreateMessageModal.show(context)),
      ],
    );
  }

  Widget _buildFilters(SectorState sectorState) {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Pesquisar registros...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Chip "Todos"
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildSectorChip(
                  label: 'Todos',
                  isSelected: _selectedSectorId == null,
                  onTap: () => setState(() => _selectedSectorId = null),
                ),
              ),
              // Chips dos setores reais
              if (sectorState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ...sectorState.sectors.map((sector) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSectorChip(
                        label: sector.name,
                        isSelected: _selectedSectorId == sector.id,
                        onTap: () =>
                            setState(() => _selectedSectorId = sector.id),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectorChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      side: BorderSide(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : Colors.transparent),
      labelStyle: TextStyle(
        color: isSelected
            ? const Color(0xFF3B82F6)
            : Colors.grey.shade700,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
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
            Text('Nenhum registro encontrado',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
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
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
