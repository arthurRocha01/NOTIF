import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../models/assignment_model.dart';
import '../providers/alert_provider.dart';
import '../../admin/providers/admin_user_provider.dart';
import '../../../core/model/user_model.dart';

class AlertConfirmationsScreen extends ConsumerStatefulWidget {
  final AlertModel alert;

  const AlertConfirmationsScreen({super.key, required this.alert});

  @override
  ConsumerState<AlertConfirmationsScreen> createState() =>
      _AlertConfirmationsScreenState();
}

class _AlertConfirmationsScreenState
    extends ConsumerState<AlertConfirmationsScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(alertProvider.notifier).loadAllAssignments();
      if (ref.read(adminUserProvider).users.isEmpty) {
        ref.read(adminUserProvider.notifier).loadUsers();
      }
    });
  }

  List<AssignmentModel> _applyFilter(List<AssignmentModel> items) {
    return switch (_filter) {
      'pending' => items.where((a) => a.status == AssignmentStatus.pending).toList(),
      'viewed' => items.where((a) => a.status == AssignmentStatus.viewed).toList(),
      'confirmed' => items.where((a) => a.status == AssignmentStatus.acknowledged).toList(),
      'overdue' => items.where((a) => a.status == AssignmentStatus.overdue).toList(),
      'denied' => items.where((a) => a.status == AssignmentStatus.denied).toList(),
      _ => items,
    };
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertProvider);
    final userState = ref.watch(adminUserProvider);

    final all = alertState.allAssignments
        .where((a) => a.notificationId == widget.alert.id)
        .toList();

    final userMap = {for (final u in userState.users) u.id: u};
    final filtered = _applyFilter(all);

    final total = all.length;
    final confirmed =
        all.where((a) => a.status == AssignmentStatus.acknowledged).length;
    final progress = total == 0 ? 0.0 : confirmed / total;

    final isLoading =
        alertState.isLoadingAllAssignments || userState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: widget.alert.level.color,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Acompanhamento',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do alerta
                  Text(
                    widget.alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Card de progresso
                  _ProgressCard(
                    confirmed: confirmed,
                    total: total,
                    progress: progress,
                    all: all,
                    showDenied: widget.alert.requiresAcknowledgment &&
                        widget.alert.level != AlertLevel.critical,
                  ),

                  const SizedBox(height: 16),

                  // Chips de filtro
                  _buildFilterChips(all),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Lista
          if (isLoading && all.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6B8BFF),
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: _buildEmpty(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final assignment = filtered[i];
                    final user = userMap[assignment.userId];
                    return _UserCard(
                      key: ValueKey(assignment.id),
                      assignment: assignment,
                      user: user,
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<AssignmentModel> all) {
    int count(String f) => switch (f) {
          'pending' =>
            all.where((a) => a.status == AssignmentStatus.pending).length,
          'viewed' =>
            all.where((a) => a.status == AssignmentStatus.viewed).length,
          'confirmed' =>
            all.where((a) => a.status == AssignmentStatus.acknowledged).length,
          'overdue' =>
            all.where((a) => a.status == AssignmentStatus.overdue).length,
          'denied' =>
            all.where((a) => a.status == AssignmentStatus.denied).length,
          _ => all.length,
        };

    final chips = [
      ('all', 'Todos', null),
      ('pending', 'Pendente', const Color(0xFF94A3B8)),
      ('viewed', 'Visualizado', const Color(0xFF3B82F6)),
      ('confirmed', 'Confirmado', const Color(0xFF10B981)),
      ('overdue', 'Vencido', const Color(0xFFDC2626)),
      if (widget.alert.requiresAcknowledgment && widget.alert.level != AlertLevel.critical)
        ('denied', 'Negado', const Color(0xFF6B7280)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          final (key, label, chipColor) = chip;
          final isSelected = _filter == key;
          final c = count(key);
          final color = chipColor ?? const Color(0xFF6B8BFF);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  c > 0 ? '$label ($c)' : label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? color
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users,
              size: 44, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Text(
            'Nenhuma atribuição encontrada',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tente mudar o filtro',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress card ─────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int confirmed;
  final int total;
  final double progress;
  final List<AssignmentModel> all;
  final bool showDenied;

  const _ProgressCard({
    required this.confirmed,
    required this.total,
    required this.progress,
    required this.all,
    this.showDenied = false,
  });

  Color get _progressColor {
    if (progress >= 0.8) return const Color(0xFF10B981);
    if (progress >= 0.4) return const Color(0xFFFFA500);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final pending = all
        .where((a) =>
            a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.viewed)
        .length;
    final overdue =
        all.where((a) => a.status == AssignmentStatus.overdue).length;
    final denied =
        all.where((a) => a.status == AssignmentStatus.denied).length;

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Círculo de progresso
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: total == 0 ? 0 : progress,
                          strokeWidth: 6,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.10),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_progressColor),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$confirmed',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _progressColor,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'de $total',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color:
                                      Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$confirmed de $total confirmaram',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% de confirmação',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Barra de progresso linear
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_progressColor),
                ),
              ),
              const SizedBox(height: 14),
              // KPIs resumidos
              Row(
                children: [
                  _KpiChip(
                    label: 'Pendente',
                    value: pending,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  _KpiChip(
                    label: 'Confirmado',
                    value: confirmed,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  _KpiChip(
                    label: 'Vencido',
                    value: overdue,
                    color: const Color(0xFFDC2626),
                  ),
                  if (showDenied) ...[
                    const SizedBox(width: 8),
                    _KpiChip(
                      label: 'Negado',
                      value: denied,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _KpiChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: color.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AssignmentModel assignment;
  final UserModel? user;

  const _UserCard({super.key, required this.assignment, this.user});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  (Color, IconData, String) get _statusStyle =>
      switch (assignment.status) {
        AssignmentStatus.pending => (
          const Color(0xFF94A3B8),
          LucideIcons.clock,
          'Pendente',
        ),
        AssignmentStatus.viewed => (
          const Color(0xFF3B82F6),
          LucideIcons.eye,
          'Visualizado',
        ),
        AssignmentStatus.acknowledged => (
          const Color(0xFF10B981),
          LucideIcons.checkCircle2,
          'Confirmado',
        ),
        AssignmentStatus.overdue => (
          const Color(0xFFDC2626),
          LucideIcons.alertCircle,
          'Vencido',
        ),
        AssignmentStatus.denied => (
          const Color(0xFF6B7280),
          LucideIcons.xCircle,
          'Negado',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? assignment.userId;
    final sector = user?.sectorName ?? '—';
    final (statusColor, statusIcon, statusLabel) = _statusStyle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.40)),
                  ),
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sector,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Timestamps
                      Row(
                        children: [
                          _TimestampChip(
                            icon: LucideIcons.send,
                            label: _formatDate(assignment.deliveredAt),
                            tooltip: 'Entregue',
                          ),
                          const SizedBox(width: 6),
                          _TimestampChip(
                            icon: LucideIcons.eye,
                            label: _formatDate(assignment.viewedAt),
                            tooltip: 'Visualizado',
                          ),
                          const SizedBox(width: 6),
                          _TimestampChip(
                            icon: LucideIcons.checkCircle2,
                            label: _formatDate(assignment.acknowledgedAt),
                            tooltip: 'Confirmado',
                            highlight: assignment.acknowledgedAt != null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _TimestampChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool highlight;

  const _TimestampChip({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFF10B981)
        : Colors.white.withValues(alpha: 0.35);
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
