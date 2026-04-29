import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../providers/alert_provider.dart';
import '../screen/alert_details_screen.dart';
import '../../../core/constants/app_colors.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AssignmentModel> get _pending => widget.assignments
      .where((a) =>
          a.status == AssignmentStatus.pending ||
          a.status == AssignmentStatus.viewed)
      .toList()
    ..sort((a, b) {
      final aPriority = a.notificationLevel == AlertLevel.critical ? 0 : 1;
      final bPriority = b.notificationLevel == AlertLevel.critical ? 0 : 1;
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      return b.createdAt.compareTo(a.createdAt);
    });

  List<AssignmentModel> get _overdue => widget.assignments
      .where((a) => a.status == AssignmentStatus.overdue)
      .toList()
    ..sort((a, b) {
      final aPriority = a.notificationLevel == AlertLevel.critical ? 0 : 1;
      final bPriority = b.notificationLevel == AlertLevel.critical ? 0 : 1;
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
      color: AppColors.primary,
      strokeWidth: 1.5,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              pendingCount: _pending.length,
              overdueCount: _overdue.length,
              doneCount: _done.length,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_all),
            _buildList(_pending, emptyLabel: 'Nenhuma notificação pendente'),
            _buildList(_overdue, emptyLabel: 'Nenhuma notificação atrasada'),
            _buildList(_done, emptyLabel: 'Nenhuma notificação confirmada'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final total    = widget.assignments.length;
    final pending  = _pending.length;
    final overdue  = _overdue.length;
    final critical = _criticalCount;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSupervisor ? 'Painel de Alertas' : 'Notificações',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),

          // ── Stats inline ──────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 13),
              children: [
                TextSpan(
                  text: '$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(
                  text: ' total',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
                if (pending > 0) ...[
                  const TextSpan(
                    text: '  ·  ',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  TextSpan(
                    text: '$pending',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  const TextSpan(
                    text: ' pendentes',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
                if (overdue > 0) ...[
                  const TextSpan(
                    text: '  ·  ',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  TextSpan(
                    text: '$overdue',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.critical,
                    ),
                  ),
                  const TextSpan(
                    text: ' atrasados',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
                if (critical > 0) ...[
                  const TextSpan(
                    text: '  ·  ',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  TextSpan(
                    text: '$critical',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.critical,
                    ),
                  ),
                  const TextSpan(
                    text: ' críticos',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),

          // ── Banner de bloqueio ────────────────────────────────────────────
          if (widget.isBlocked) ...[
            const SizedBox(height: 16),
            const _BlockingBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildList(List<AssignmentModel> items, {String? emptyLabel}) {
    if (widget.isLoading && widget.assignments.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(label: emptyLabel ?? 'Nenhuma notificação'),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final a = items[i];
        final canAcknowledge =
            a.status != AssignmentStatus.acknowledged && a.canAcknowledge;
        return _AssignmentCard(
          assignment: a,
          onAcknowledge:
              canAcknowledge ? () => widget.onAcknowledge?.call(a.id) : null,
        );
      },
    );
  }
}

// ── Tab bar delegate (sticky) ─────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final int pendingCount;
  final int overdueCount;
  final int doneCount;

  const _TabBarDelegate({
    required this.tabController,
    required this.pendingCount,
    required this.overdueCount,
    required this.doneCount,
  });

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 1.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w400),
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: 'Todos'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pendentes'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 5),
                  _TabCount(count: pendingCount, color: AppColors.warning),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Atrasados'),
                if (overdueCount > 0) ...[
                  const SizedBox(width: 5),
                  _TabCount(count: overdueCount, color: AppColors.critical),
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
                  const SizedBox(width: 5),
                  _TabCount(count: doneCount, color: AppColors.success),
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
      old.pendingCount != pendingCount ||
      old.overdueCount != overdueCount ||
      old.doneCount != doneCount;
}

class _TabCount extends StatelessWidget {
  final int count;
  final Color color;

  const _TabCount({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count',
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── Blocking banner ───────────────────────────────────────────────────────────

class _BlockingBanner extends StatelessWidget {
  const _BlockingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.critical, width: 3),
          top: BorderSide(color: AppColors.border, width: 0.5),
          right: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldOff,
              color: AppColors.critical, size: 15),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ação necessária',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.critical,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Confirme a ciência dos alertas críticos para continuar.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;
  final VoidCallback? onAcknowledge;

  const _AssignmentCard({required this.assignment, this.onAcknowledge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level    = assignment.notificationLevel;
    final status   = assignment.status;
    final isDone   = status == AssignmentStatus.acknowledged;
    final isOverdue = status == AssignmentStatus.overdue;

    final Color accentColor = isDone
        ? AppColors.success
        : isOverdue
            ? AppColors.critical
            : level.color;

    return GestureDetector(
      onTap: () {
        if (status == AssignmentStatus.pending ||
            status == AssignmentStatus.viewed) {
          ref.read(alertProvider.notifier).markAsViewed(assignment.id);
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AlertDetailsScreen(assignment: assignment),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
            top: const BorderSide(color: AppColors.border, width: 0.5),
            right: const BorderSide(color: AppColors.border, width: 0.5),
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título + status ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      assignment.notificationTitle ?? 'Notificação',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDone
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusDot(status: status),
                ],
              ),

              // ── Mensagem preview ──────────────────────────────────────────
              if (assignment.notificationMessage != null &&
                  assignment.notificationMessage!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  assignment.notificationMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ── Footer: nível + prazo ─────────────────────────────────────
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    level.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (assignment.dueAt != null && !isDone) ...[
                    const SizedBox(width: 10),
                    Icon(
                      LucideIcons.clock,
                      size: 11,
                      color: isOverdue
                          ? AppColors.critical
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDue(assignment.dueAt!),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isOverdue
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isOverdue
                            ? AppColors.critical
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(LucideIcons.chevronRight,
                      size: 13, color: AppColors.border),
                ],
              ),

              // ── Botão confirmar ciência ───────────────────────────────────
              if (onAcknowledge != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5, color: AppColors.border),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onAcknowledge,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.checkCircle2,
                          size: 13, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Confirmar ciência',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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

// ── Status dot ────────────────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: status.color,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
          const Icon(LucideIcons.bellOff,
              size: 28, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Puxe para baixo para atualizar',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
