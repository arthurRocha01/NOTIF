import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../screen/alert_details_screen.dart';

class AssignmentsBody extends StatefulWidget {
  final List<AssignmentModel> assignments;
  final bool isLoading;
  final bool isBlocked;
  final bool isSupervisor;
  final Future<void> Function() onRefresh;
  final void Function(String assignmentId)? onAcknowledge;

  const AssignmentsBody({
    super.key,
    required this.assignments,
    required this.isLoading,
    required this.isBlocked,
    required this.onRefresh,
    this.isSupervisor = false,
    this.onAcknowledge,
  });

  @override
  State<AssignmentsBody> createState() => _AssignmentsBodyState();
}

class _AssignmentsBodyState extends State<AssignmentsBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AssignmentModel> get _pending => widget.assignments
      .where((a) =>
          a.status == AssignmentStatus.pending ||
          a.status == AssignmentStatus.viewed ||
          a.status == AssignmentStatus.overdue)
      .toList()
    ..sort((a, b) {
      // Críticos e atrasados primeiro
      final aPriority = a.status == AssignmentStatus.overdue ? 0 : a.notificationLevel == AlertLevel.critical ? 1 : 2;
      final bPriority = b.status == AssignmentStatus.overdue ? 0 : b.notificationLevel == AlertLevel.critical ? 1 : 2;
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      return b.createdAt.compareTo(a.createdAt);
    });

  List<AssignmentModel> get _done => widget.assignments
      .where((a) => a.status == AssignmentStatus.acknowledged)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<AssignmentModel> get _all {
    final all = [...widget.assignments]..sort((a, b) {
        final aScore = a.status == AssignmentStatus.overdue
            ? 0
            : a.notificationLevel == AlertLevel.critical
                ? 1
                : a.status == AssignmentStatus.acknowledged
                    ? 10
                    : 5;
        final bScore = b.status == AssignmentStatus.overdue
            ? 0
            : b.notificationLevel == AlertLevel.critical
                ? 1
                : b.status == AssignmentStatus.acknowledged
                    ? 10
                    : 5;
        if (aScore != bScore) return aScore.compareTo(bScore);
        return b.createdAt.compareTo(a.createdAt);
      });
    return all;
  }

  int get _criticalCount => widget.assignments
      .where((a) =>
          a.notificationLevel == AlertLevel.critical &&
          a.status != AssignmentStatus.acknowledged)
      .length;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF4A6CF7),
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              pendingCount: _pending.length,
              doneCount: _done.length,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_all),
            _buildList(_pending, emptyLabel: 'Nenhuma notificação pendente'),
            _buildList(_done, emptyLabel: 'Nenhuma notificação confirmada'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final total    = widget.assignments.length;
    final pending  = _pending.length;
    final critical = _criticalCount;

    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSupervisor ? 'Painel de Alertas' : 'Minhas Notificações',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.isSupervisor
                ? 'Visão geral de todos os setores'
                : 'Acompanhe os avisos do seu setor',
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF94A3B8)),
          ),

          // ── Banner de bloqueio ──────────────────────────────────────────
          if (widget.isBlocked) ...[
            const SizedBox(height: 12),
            _BlockingBanner(),
          ],

          // ── Resumo rápido ───────────────────────────────────────────────
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Total',
                count: total,
                color: const Color(0xFF4A6CF7),
                bg: const Color(0xFFEEF2FF),
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Pendentes',
                count: pending,
                color: const Color(0xFFF59E0B),
                bg: const Color(0xFFFEF3C7),
              ),
              if (critical > 0) ...[
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Críticos',
                  count: critical,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEE2E2),
                  icon: LucideIcons.alertOctagon,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AssignmentModel> items, {String? emptyLabel}) {
    if (widget.isLoading && widget.assignments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A6CF7)),
      );
    }

    if (items.isEmpty) {
      return _EmptyState(label: emptyLabel ?? 'Nenhuma notificação');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final a = items[i];
        final canAcknowledge =
            a.status != AssignmentStatus.acknowledged && a.isCritical;
        return _AssignmentCard(
          assignment: a,
          onAcknowledge: canAcknowledge
              ? () => widget.onAcknowledge?.call(a.id)
              : null,
        );
      },
    );
  }
}

// ── Tab bar delegate (sticky) ─────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final int pendingCount;
  final int doneCount;

  const _TabBarDelegate({
    required this.tabController,
    required this.pendingCount,
    required this.doneCount,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicatorColor: const Color(0xFF4A6CF7),
        indicatorWeight: 2.5,
        labelColor: const Color(0xFF4A6CF7),
        unselectedLabelColor: const Color(0xFF94A3B8),
        labelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          const Tab(text: 'Todos'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pendentes'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  _TabBadge(count: pendingCount),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Confirmados'),
                if (doneCount > 0) ...[
                  const SizedBox(width: 6),
                  _TabBadge(
                      count: doneCount,
                      color: const Color(0xFF10B981),
                      bg: const Color(0xFFD1FAE5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.pendingCount != pendingCount || old.doneCount != doneCount;
}

class _TabBadge extends StatelessWidget {
  final int count;
  final Color color;
  final Color bg;

  const _TabBadge({
    required this.count,
    this.color = const Color(0xFFF59E0B),
    this.bg = const Color(0xFFFEF3C7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;
  final IconData? icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            '$count $label',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blocking banner ───────────────────────────────────────────────────────────

class _BlockingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFDC2626).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.shieldOff,
                color: Color(0xFFDC2626), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ação necessária',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Você tem alertas críticos pendentes. Confirme a ciência para continuar.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFB91C1C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Assignment card ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback? onAcknowledge;

  const _AssignmentCard({required this.assignment, this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final level    = assignment.notificationLevel;
    final status   = assignment.status;
    final isDone   = status == AssignmentStatus.acknowledged;
    final isOverdue = status == AssignmentStatus.overdue;

    final Color accentColor = isDone
        ? const Color(0xFF10B981)
        : isOverdue
            ? const Color(0xFFDC2626)
            : level.color;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AlertDetailsScreen(assignment: assignment),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra lateral colorida por nível
                Container(width: 4, color: accentColor),

                // Conteúdo do card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Linha superior: ícone + título + chip ───────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFFD1FAE5)
                                    : level.backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDone ? LucideIcons.checkCircle2 : level.icon,
                                color: isDone
                                    ? const Color(0xFF10B981)
                                    : level.color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                assignment.notificationTitle ?? 'Notificação',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDone
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF0F172A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusChip(status: status),
                          ],
                        ),

                        // ── Mensagem preview ────────────────────────────────
                        if (assignment.notificationMessage != null &&
                            assignment.notificationMessage!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            assignment.notificationMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // ── Linha inferior: nível + prazo ───────────────────
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: level.backgroundColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                level.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: level.color,
                                ),
                              ),
                            ),
                            if (assignment.dueAt != null && !isDone) ...[
                              const SizedBox(width: 8),
                              Icon(
                                LucideIcons.clock,
                                size: 11,
                                color: isOverdue
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatDue(assignment.dueAt!),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: isOverdue
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isOverdue
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Icon(LucideIcons.chevronRight,
                                size: 14, color: const Color(0xFFCBD5E1)),
                          ],
                        ),

                        // ── Botão confirmar ciência ─────────────────────────
                        if (onAcknowledge != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onAcknowledge,
                              icon: const Icon(LucideIcons.checkCircle2,
                                  size: 15),
                              label: Text(
                                'Confirmar ciência',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDue(DateTime due) {
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) return 'Vencido';
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'em ${diff.inHours}h';
    return 'em ${diff.inDays}d';
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bellOff,
              size: 32,
              color: Color(0xFF4A6CF7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
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
    );
  }
}
