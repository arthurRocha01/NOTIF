import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/alerts/modals/create_alert_modal.dart';
import 'package:notif_app/features/alerts/modals/create_message_modal.dart';
import 'package:notif_app/features/alerts/widgets/monitoring_alert_card.dart';
import 'package:notif_app/features/alerts/widgets/assignments_body.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';

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

  // null = "Todos os níveis"
  AlertLevel? _selectedLevel;

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
      final matchesSector = _selectedSectorId == null ||
          alert.isGlobal ||
          alert.targetSectorId == _selectedSectorId;
      final matchesLevel =
          _selectedLevel == null || alert.level == _selectedLevel;
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch = alert.title.toLowerCase().contains(query) ||
          alert.message.toLowerCase().contains(query);
      return matchesSector && matchesLevel && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state       = ref.watch(alertProvider);
    final sectorState = ref.watch(sectorProvider);

    ref.listen<String?>(
      alertProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error, style: GoogleFonts.inter()),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
    );

    final criticalCount = state.notifications
        .where((n) => n.level == AlertLevel.critical)
        .length;

    final pendingAssignments = state.assignments
        .where((a) => a.status != AssignmentStatus.acknowledged)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // ── TabBar ───────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF4A6CF7),
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: const Color(0xFF4A6CF7),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                _buildTabLabel(
                  'Painel',
                  count: criticalCount,
                  badgeColor: const Color(0xFFDC2626),
                  badgeBg: const Color(0xFFFEE2E2),
                ),
                _buildTabLabel(
                  'Minhas notificações',
                  count: pendingAssignments,
                  badgeColor: const Color(0xFF4A6CF7),
                  badgeBg: const Color(0xFFEEF2FF),
                ),
              ],
            ),
          ),

          // ── Conteúdo das abas ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
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
                  isSupervisor: true,
                  onRefresh: () => ref.read(alertProvider.notifier).loadAssignments(),
                  onAcknowledge: (id) => ref
                      .read(alertProvider.notifier)
                      .acknowledge(id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Tab _buildTabLabel(
    String label, {
    int count = 0,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
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
    final filtered      = _getFilteredAlerts(alerts);
    final criticalCount = alerts.where((a) => a.level == AlertLevel.critical).length;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(alertProvider.notifier).loadNotifications();
        await ref.read(sectorProvider.notifier).loadSectors();
      },
      color: const Color(0xFF4A6CF7),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // ── Summary ──────────────────────────────────────────────────────
          if (alerts.isNotEmpty) ...[
            _buildSummaryHeader(alerts.length, criticalCount),
            const SizedBox(height: 16),
          ],

          // ── Ações rápidas ────────────────────────────────────────────────
          _buildQuickActions(),
          const SizedBox(height: 16),

          // ── Filtros ──────────────────────────────────────────────────────
          _buildFilters(sectorState),
          const SizedBox(height: 16),

          // ── Lista ────────────────────────────────────────────────────────
          if (isLoading && alerts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF4A6CF7)),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((a) => MonitoringAlertCard(
                  key: ValueKey(a.id),
                  alert: a,
                  sectorName: a.isGlobal
                      ? null
                      : sectorState.sectors
                          .where((s) => s.id == a.targetSectorId)
                          .map((s) => s.name)
                          .firstOrNull,
                )),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(int total, int critical) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              icon: LucideIcons.bell,
              iconColor: const Color(0xFF4A6CF7),
              iconBg: const Color(0xFFEEF2FF),
              value: '$total',
              label: 'Total',
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: _SummaryTile(
              icon: LucideIcons.alertOctagon,
              iconColor: const Color(0xFFDC2626),
              iconBg: const Color(0xFFFEE2E2),
              value: '$critical',
              label: 'Críticos',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Novo Alerta',
            icon: LucideIcons.bellRing,
            color: const Color(0xFFDC2626),
            onTap: () => CreateAlertModal.show(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Comunicado',
            icon: LucideIcons.megaphone,
            color: const Color(0xFF1A2340),
            onTap: () => CreateMessageModal.show(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(SectorState sectorState) {
    return Column(
      children: [
        // ── Campo de busca ────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Pesquisar registros...',
              hintStyle: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF94A3B8)),
              prefixIcon: const Icon(LucideIcons.search,
                  size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ── Chips de nível ────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SectorChip(
                label: 'Todos',
                isSelected: _selectedLevel == null,
                onTap: () => setState(() => _selectedLevel = null),
              ),
              ...AlertLevel.values.map((level) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _SectorChip(
                      label: level.label,
                      isSelected: _selectedLevel == level,
                      selectedColor: level.color,
                      onTap: () => setState(() => _selectedLevel = level),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Chips de setor ────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SectorChip(
                label: 'Todos',
                isSelected: _selectedSectorId == null,
                onTap: () => setState(() => _selectedSectorId = null),
              ),
              if (sectorState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ...sectorState.sectors.map((sector) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _SectorChip(
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bellOff,
                  size: 32, color: Color(0xFF4A6CF7)),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro encontrado',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Puxe para baixo para atualizar',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary tile ──────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sector chip ───────────────────────────────────────────────────────────────

class _SectorChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _SectorChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedColor ?? const Color(0xFF4A6CF7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
