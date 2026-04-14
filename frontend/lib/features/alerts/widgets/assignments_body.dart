import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../screen/alert_details_screen.dart';

class AssignmentsBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final pending = assignments
        .where((a) =>
            a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.viewed ||
            a.status == AssignmentStatus.overdue)
        .toList();

    final done = assignments
        .where((a) => a.status == AssignmentStatus.acknowledged)
        .toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minhas Notificações',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSupervisor
                        ? 'Visão geral de todos os setores.'
                        : 'Acompanhe os avisos do seu setor.',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF64748B)),
                  ),
                  if (isBlocked) ...[
                    const SizedBox(height: 12),
                    const _BlockingBanner(),
                  ],
                ],
              ),
            ),
          ),
          if (isLoading && assignments.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (pending.isNotEmpty) ...[
              _sectionHeader('Pendentes (${pending.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _AssignmentCard(
                    assignment: pending[i],
                    onAcknowledge: (pending[i].isCritical ||
                            pending[i].notificationLevel == AlertLevel.high)
                        ? () => onAcknowledge?.call(pending[i].id)
                        : null,
                  ),
                  childCount: pending.length,
                ),
              ),
            ],
            if (done.isNotEmpty) ...[
              _sectionHeader('Confirmados'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _AssignmentCard(assignment: done[i]),
                  childCount: done.length,
                ),
              ),
            ],
            if (assignments.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Nenhuma notificação',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _BlockingBanner extends StatelessWidget {
  const _BlockingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.block, color: Color(0xFFDC2626), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Você possui notificações críticas pendentes. Confirme a ciência para continuar.',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback? onAcknowledge;

  const _AssignmentCard({required this.assignment, this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final status = assignment.status;
    final level = assignment.notificationLevel;
    final isOverdue = status == AssignmentStatus.overdue;
    final isDone = status == AssignmentStatus.acknowledged;

    final Color borderColor = isOverdue
        ? const Color(0xFFDC2626)
        : isDone
            ? const Color(0xFF10B981)
            : level.color;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AlertDetailsScreen(assignment: assignment),
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? Colors.transparent
                : borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: level.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(level.icon, color: level.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.notificationTitle ?? 'Notificação',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        _StatusChip(status: status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.label,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    if (assignment.dueAt != null && !isDone) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Prazo: ${_formatDue(assignment.dueAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF94A3B8),
                          fontWeight: isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                    if (onAcknowledge != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onAcknowledge,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Confirmar ciência',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: level.color,
                            side: BorderSide(color: level.color),
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isDone)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
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

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
