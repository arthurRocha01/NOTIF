import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_filter_provider.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:notif_app/features/dashboard/widgets/attention_sector_card.dart';
import 'package:notif_app/features/dashboard/widgets/dashboard_bar_chart.dart';
import 'package:notif_app/features/dashboard/widgets/dashboard_donut_chart.dart';
import 'package:notif_app/features/dashboard/widgets/dashboard_kpi_row.dart';
import 'package:notif_app/features/dashboard/widgets/highlight_card.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    ref.read(alertProvider.notifier).loadNotifications();
    ref.read(alertProvider.notifier).loadAssignments();
    ref.read(sectorProvider.notifier).loadSectors();
  }

  Widget _buildHeader(int activeAlerts, int totalSectors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2340), Color(0xFF4A3F8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'DASHBOARD',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Painel de Gestão',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Métricas em tempo real',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _refresh,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.refreshCw,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick stats chips
          Row(
            children: [
              _StatChip(
                icon: LucideIcons.bell,
                label: '$activeAlerts alerta${activeAlerts != 1 ? 's' : ''} ativo${activeAlerts != 1 ? 's' : ''}',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: LucideIcons.building2,
                label: '$totalSectors setor${totalSectors != 1 ? 'es' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertProvider);
    final stats      = ref.watch(dashboardProvider);
    final filter     = ref.watch(dashboardFilterProvider);
    final sectors    = ref.watch(sectorProvider).sectors;

    final isLoading =
        alertState.isLoadingNotifications || alertState.isLoadingAssignments;

    final activeAlerts = alertState.notifications.length;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF4A6CF7),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(activeAlerts, sectors.length),
          ),

          // ── Filtro de período ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PeriodFilter(current: filter.period),
            ),
          ),

          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4A6CF7)),
              ),
            )
          else ...[
            // ── Label: Métricas ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: _SectionLabel(label: 'MÉTRICAS DO PERÍODO'),
              ),
            ),

            // ── KPI 2×2 ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DashboardKpiRow(
                  totalAssignments:  stats.totalAssignments,
                  totalAcknowledged: stats.totalAcknowledged,
                  totalPending:      stats.totalPending,
                  totalCritical:     stats.totalCritical,
                ),
              ),
            ),

            // ── Destaque ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: HighlightCard(
                  sector: stats.topSector,
                  rate: stats.topSectorRate,
                ),
              ),
            ),

            // ── Label: Análise ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: _SectionLabel(label: 'ANÁLISE POR SETOR'),
              ),
            ),

            // ── Gráfico ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ChartCard(
                  title: 'Taxa de Adesão',
                  subtitle: filter.selectedSectorId != null
                      ? 'Detalhes do setor'
                      : 'Todos os setores · ${filter.periodLabel}',
                  trailing: sectors.isNotEmpty
                      ? _SectorDropdown(
                          sectors: sectors
                              .map((s) => (id: s.id, name: s.name))
                              .toList(),
                          selectedId: filter.selectedSectorId,
                          onChanged: (id) => ref
                              .read(dashboardFilterProvider.notifier)
                              .setSector(id),
                        )
                      : null,
                  child: filter.selectedSectorId != null &&
                          stats.selectedSectorBreakdown != null
                      ? DashboardDonutChart(
                          breakdown: stats.selectedSectorBreakdown!,
                          sectorName: sectors
                                  .where(
                                      (s) => s.id == filter.selectedSectorId)
                                  .firstOrNull
                                  ?.name ??
                              filter.selectedSectorId!,
                        )
                      : DashboardBarChart(sectorRates: stats.sectorRates),
                ),
              ),
            ),

            // ── Atenção necessária ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: AttentionCard(sectors: stats.attentionSectors),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Quick stat chip ───────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF4A6CF7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Filtro de período ─────────────────────────────────────────────────────────

class _PeriodFilter extends ConsumerWidget {
  final DashboardPeriod current;
  const _PeriodFilter({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      (period: DashboardPeriod.week, label: '7 dias'),
      (period: DashboardPeriod.month, label: '30 dias'),
      (period: DashboardPeriod.all, label: 'Todos'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: options.map((o) {
          final selected = o.period == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref
                  .read(dashboardFilterProvider.notifier)
                  .setPeriod(o.period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1A2340)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Dropdown de setor ─────────────────────────────────────────────────────────

class _SectorDropdown extends StatelessWidget {
  final List<({String id, String name})> sectors;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _SectorDropdown({
    required this.sectors,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isDense: true,
          icon: const Icon(LucideIcons.chevronDown,
              size: 14, color: Color(0xFF64748B)),
          style:
              GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0F172A)),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos', style: GoogleFonts.inter(fontSize: 12)),
            ),
            ...sectors.map((s) => DropdownMenuItem<String?>(
                  value: s.id,
                  child: Text(s.name, style: GoogleFonts.inter(fontSize: 12)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Chart card ────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.barChart2,
                    size: 18, color: Color(0xFF4A6CF7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
