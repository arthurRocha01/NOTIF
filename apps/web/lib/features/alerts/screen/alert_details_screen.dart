import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_status.dart';
import '../models/my_assignment_model.dart';
import '../providers/alert_provider.dart';
import '../widgets/sla_countdown.dart';

class AlertDetailsScreen extends ConsumerWidget {
  final MyAssignmentModel assignment;

  const AlertDetailsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(alertProvider).notifications;
    final notification = notifications
        .where((n) => n.id == assignment.notificationId)
        .firstOrNull;

    final title = assignment.notificationTitle ?? notification?.title ?? 'Notificação';
    final message = assignment.notificationMessage ?? notification?.message;
    final level = assignment.notificationLevel;
    final status = assignment.status;
    final isQuest = assignment.notificationRequiresAcknowledgment &&
        level != AlertLevel.critical;
    final headerColor =
        isQuest ? const Color(0xFF6B4BF7) : level.color;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: CustomScrollView(
        slivers: [
          // ── AppBar com gradiente por nível ──────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: headerColor,
            leading: IconButton(
              tooltip: 'Voltar',
              icon: const Icon(LucideIcons.arrowLeft,
                  color: Colors.white, semanticLabel: 'Voltar'),
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
                    colors: [headerColor, headerColor.withValues(alpha: 0.75)],
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
                        if (isQuest)
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
                                const Icon(LucideIcons.clipboardCheck,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'COM RESPOSTA',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
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
                                Icon(level.icon, size: 12, color: Colors.white),
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
                          color: Colors.white.withValues(alpha: 0.80),
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
                          _RowDivider(),
                          Row(
                            children: [
                              Icon(LucideIcons.clock,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.40)),
                              const SizedBox(width: 8),
                              Text(
                                'Prazo',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              const Spacer(),
                              SlaCountdown(
                                dueAt: assignment.dueAt,
                                acknowledgedAt: assignment.acknowledgedAt,
                              ),
                            ],
                          ),
                        ],
                        if (assignment.authorName != null) ...[
                          _RowDivider(),
                          _InfoRow(
                            icon: LucideIcons.user,
                            label: 'Remetente',
                            value: assignment.authorName!,
                          ),
                        ],
                        if (assignment.acknowledgedAt != null) ...[
                          _RowDivider(),
                          _InfoRow(
                            icon: LucideIcons.checkCircle2,
                            label: 'Confirmado em',
                            value: _formatDate(assignment.acknowledgedAt!),
                            valueColor: const Color(0xFF4ADE80),
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
                          iconLabel: 'Recebido',
                          label: 'Notificação recebida',
                          time: _formatDate(assignment.createdAt),
                          done: true,
                          isFirst: true,
                        ),
                        _TimelineStep(
                          icon: LucideIcons.eye,
                          iconLabel: 'Visualizado',
                          label: 'Visualizado',
                          time: assignment.viewedAt != null
                              ? _formatDate(assignment.viewedAt!)
                              : null,
                          done: assignment.viewedAt != null,
                        ),
                        if (assignment.status == AssignmentStatus.denied)
                          _TimelineStep(
                            icon: LucideIcons.xCircle,
                            iconLabel: 'Recusado',
                            label: isQuest ? 'Alerta recusado' : 'Alerta negado',
                            time: assignment.deniedAt != null
                                ? _formatDate(assignment.deniedAt!)
                                : null,
                            done: true,
                            isLast: true,
                          )
                        else
                          _TimelineStep(
                            icon: LucideIcons.checkCircle2,
                            iconLabel: 'Confirmado',
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

                  // ── Status / Ação ─────────────────────────────────────────
                  const SizedBox(height: 16),
                  _buildStatusSection(context, ref, assignment, level, isQuest),

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

  Widget _buildStatusSection(
    BuildContext context,
    WidgetRef ref,
    MyAssignmentModel assignment,
    AlertLevel level,
    bool isQuest,
  ) {
    final status = assignment.status;

    if (status == AssignmentStatus.acknowledged) {
      return _StatusBanner(
        icon: LucideIcons.checkCircle2,
        label: 'Ciência confirmada',
        subtitle: assignment.acknowledgedAt != null
            ? 'em ${_formatDate(assignment.acknowledgedAt!)}'
            : null,
        color: const Color(0xFF10B981),
      );
    }

    if (status == AssignmentStatus.denied) {
      return _StatusBanner(
        icon: LucideIcons.xCircle,
        label: isQuest ? 'Alerta recusado' : 'Alerta negado',
        subtitle: assignment.deniedAt != null
            ? 'em ${_formatDate(assignment.deniedAt!)}'
            : null,
        color: const Color(0xFF6B7280),
      );
    }

    final actionColor =
        isQuest ? const Color(0xFF6B4BF7) : level.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AssignmentStatus.viewed)
          _StatusBanner(
            icon: LucideIcons.eye,
            label: isQuest ? 'Visualizado — responda abaixo' : 'Alerta visualizado',
            color: isQuest ? const Color(0xFF6B4BF7) : const Color(0xFF3B82F6),
          ),
        if (status == AssignmentStatus.overdue)
          _StatusBanner(
            icon: LucideIcons.alertCircle,
            label: 'Prazo expirado',
            color: const Color(0xFFDC2626),
          ),
        if (status == AssignmentStatus.pending)
          _StatusBanner(
            icon: LucideIcons.clock,
            label: isQuest ? 'Aguardando sua resposta' : 'Pendente',
            color: isQuest ? const Color(0xFF6B4BF7) : const Color(0xFF94A3B8),
          ),
        if (assignment.canAcknowledge || assignment.canDeny) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (assignment.canDeny)
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Recusar este alerta',
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(alertProvider.notifier)
                            .deny(assignment.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: Text(
                        'Recusar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFF4B5563)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              if (assignment.canDeny && assignment.canAcknowledge)
                const SizedBox(width: 10),
              if (assignment.canAcknowledge)
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Confirmar ciência deste alerta',
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(alertProvider.notifier)
                            .acknowledge(assignment.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: Text(
                        'Confirmar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.40)),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.40),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
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
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.40)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      );
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String? iconLabel;
  final String label;
  final String? time;
  final bool done;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.done,
    this.iconLabel,
    this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        done ? const Color(0xFF4ADE80) : Colors.white.withValues(alpha: 0.20);
    final Color lineColor = done
        ? const Color(0xFF4ADE80).withValues(alpha: 0.30)
        : Colors.white.withValues(alpha: 0.12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 10, color: lineColor),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFF4ADE80).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
                child: Icon(icon, size: 13, color: dotColor,
                    semanticLabel: iconLabel),
              ),
              if (!isLast)
                Container(width: 2, height: 10, color: lineColor),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      color: done
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.40),
                    ),
                  ),
                ),
                if (time != null)
                  Text(
                    time!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.40),
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

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;

  const _StatusBanner({
    required this.icon,
    required this.label,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.70),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}