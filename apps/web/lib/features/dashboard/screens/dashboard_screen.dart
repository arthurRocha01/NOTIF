import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sectorProvider.notifier).loadSectors();
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(dashboardProvider);
    await ref.read(sectorProvider.notifier).loadSectors();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final filter         = ref.watch(dashboardFilterProvider);
    final sectors        = ref.watch(sectorProvider).sectors;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF4A6CF7),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Título da página ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Painel de Gestão',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Métricas em tempo real',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.refreshCw,
                      color: Color(0xFF4A6CF7),
                      size: 20,
                    ),
                    tooltip: 'Atualizar',
                    onPressed: _refresh,
                  ),
                ],
              ),
            ),
          ),

          // ── Filtro de período ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _PeriodFilter(current: filter.period),
            ),
          ),

          // ── Conteúdo principal ────────────────────────────────────────────
          ...dashboardAsync.when(
            loading: () => [
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A6CF7)),
                ),
              ),
            ],
            error: (_, __) => [
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          color: Color(0xFF94A3B8), size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Não foi possível carregar o painel.',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            data: (stats) => [
              // ── KPI cards (grid 2×2) ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: DashboardKpiRow(
                    totalNotifications: stats.totalNotifications,
                    totalAcknowledged: stats.totalAcknowledged,
                    totalPending: stats.totalPending,
                    totalCritical: stats.totalCritical,
                  ),
                ),
              ),

              // ── Setor mais atento ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: HighlightCard(
                    sector: stats.topSector,
                    rate: stats.topSectorRate,
                  ),
                ),
              ),

              // ── Taxa por setor ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _SectionCard(
                    title: 'Taxa de Adesão por Setor',
                    subtitle: filter.selectedSectorId != null
                        ? 'Detalhes do setor selecionado'
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
                                    .where((s) => s.id == filter.selectedSectorId)
                                    .firstOrNull
                                    ?.name ??
                                filter.selectedSectorId!,
                          )
                        : DashboardBarChart(sectorRates: stats.sectorRates),
                  ),
                ),
              ),

              // ── Atenção necessária ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: AttentionCard(sectors: stats.attentionSectors),
                ),
              ),
            ],
          ),
        ],
      ),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: options.map((o) {
          final selected = o.period == current;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(dashboardFilterProvider.notifier).setPeriod(o.period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF4A6CF7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF64748B),
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

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
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
