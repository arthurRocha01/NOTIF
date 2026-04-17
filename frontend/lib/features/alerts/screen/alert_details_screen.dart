import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../providers/alert_provider.dart';

class AlertDetailsScreen extends ConsumerWidget {
  final AssignmentModel assignment;

  const AlertDetailsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title   = assignment.notificationTitle ?? 'Notificação';
    final message = assignment.notificationMessage;
    final level   = assignment.notificationLevel;
    final status  = assignment.status;
    final isDone    = status == AssignmentStatus.acknowledged;
    final isOverdue = status == AssignmentStatus.overdue;
    final canAcknowledge = !isDone && assignment.isCritical;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // ── AppBar com gradiente por nível ──────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: level.color,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Detalhes',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [level.color, level.color.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(level.icon,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                level.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mensagem ─────────────────────────────────────────────
                  if (message != null && message.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Mensagem',
                      icon: LucideIcons.messageSquare,
                      child: Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF334155),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Informações ───────────────────────────────────────────
                  _SectionCard(
                    title: 'Informações',
                    icon: LucideIcons.info,
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: LucideIcons.calendar,
                          label: 'Recebido',
                          value: _formatDate(assignment.createdAt),
                        ),
                        if (assignment.dueAt != null) ...[
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _InfoRow(
                            icon: LucideIcons.clock,
                            label: 'Prazo',
                            value: _formatDueVerbose(
                                assignment.dueAt!, isOverdue),
                            valueColor: isOverdue
                                ? const Color(0xFFDC2626)
                                : null,
                          ),
                        ],
                        if (assignment.acknowledgedAt != null) ...[
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _InfoRow(
                            icon: LucideIcons.checkCircle2,
                            label: 'Confirmado em',
                            value: _formatDate(assignment.acknowledgedAt!),
                            valueColor: const Color(0xFF10B981),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Linha do tempo ────────────────────────────────────────
                  _SectionCard(
                    title: 'Histórico',
                    icon: LucideIcons.activity,
                    child: Column(
                      children: [
                        _TimelineStep(
                          icon: LucideIcons.bell,
                          label: 'Notificação recebida',
                          time: _formatDate(assignment.createdAt),
                          done: true,
                          isFirst: true,
                        ),
                        _TimelineStep(
                          icon: LucideIcons.eye,
                          label: 'Visualizado',
                          time: assignment.viewedAt != null
                              ? _formatDate(assignment.viewedAt!)
                              : null,
                          done: assignment.viewedAt != null,
                        ),
                        _TimelineStep(
                          icon: LucideIcons.checkCircle2,
                          label: 'Ciência confirmada',
                          time: assignment.acknowledgedAt != null
                              ? _formatDate(assignment.acknowledgedAt!)
                              : null,
                          done: assignment.acknowledgedAt != null,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Botão confirmar ───────────────────────────────────────
                  if (canAcknowledge) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(alertProvider.notifier)
                              .acknowledge(assignmentId: assignment.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(LucideIcons.checkCircle2, size: 18),
                        label: Text(
                          'Confirmar ciência',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: level.color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatDueVerbose(DateTime due, bool isOverdue) {
    if (isOverdue) return 'Vencido';
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) return 'Vencido';
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'em ${diff.inHours}h';
    return 'em ${diff.inDays}d';
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? time;
  final bool done;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.done,
    this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        done ? const Color(0xFF10B981) : const Color(0xFFE2E8F0);
    final Color lineColor =
        done ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFE2E8F0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna do eixo vertical
        SizedBox(
          width: 28,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                    width: 2, height: 10, color: lineColor),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
                child: Icon(icon, size: 13, color: dotColor),
              ),
              if (!isLast)
                Container(
                    width: 2, height: 10, color: lineColor),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Conteúdo
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 0 : 10, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          done ? FontWeight.w600 : FontWeight.w400,
                      color: done
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                if (time != null)
                  Text(
                    time!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
