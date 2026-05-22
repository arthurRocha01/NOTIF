import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/models/my_assignment_model.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/widgets/sla_countdown.dart';

class CriticalBlockScreen extends ConsumerStatefulWidget {
  const CriticalBlockScreen({super.key});

  @override
  ConsumerState<CriticalBlockScreen> createState() =>
      _CriticalBlockScreenState();
}

class _CriticalBlockScreenState extends ConsumerState<CriticalBlockScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _acknowledge(String assignmentId) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    await ref.read(alertProvider.notifier).acknowledge(assignmentId);
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date às $time';
  }

  @override
  Widget build(BuildContext context) {
    final blocking = ref.watch(alertProvider).blockingAssignments;

    ref.listen<bool>(
      alertProvider.select((s) => s.isBlocked),
      (_, isBlocked) {
        if (!isBlocked && context.mounted) Navigator.of(context).pop();
      },
    );

    final current = blocking.isNotEmpty ? blocking.first : null;
    final total = blocking.length;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFDC2626),
        body: SafeArea(
          child: Semantics(
            label:
                'Tela bloqueada. ${total > 1 ? "$total alertas críticos pendentes." : "Um alerta crítico pendente."} Confirme ciência para continuar.',
            child: Column(
              children: [
                // ── Barra de progresso ───────────────────────────────────────
                _buildProgressBar(total),

                // ── Conteúdo rolável ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        // Ícone pulsante
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.alertOctagon,
                              color: Colors.white,
                              size: 40,
                              semanticLabel: 'Alerta crítico bloqueante',
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Título
                        Text(
                          current?.notificationTitle ?? 'Notificação Crítica',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Card de detalhes ─────────────────────────────────
                        if (current != null)
                          _DetailsCard(
                            assignment: current,
                            formatDateTime: _formatDateTime,
                          ),

                        // ── Mensagem ─────────────────────────────────────────
                        if (current?.notificationMessage != null &&
                            current!.notificationMessage!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _MessageCard(message: current.notificationMessage!),
                        ],

                        // ── Alertas restantes ────────────────────────────────
                        if (total > 1) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.layers,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.75)),
                                const SizedBox(width: 6),
                                Text(
                                  'Mais ${total - 1} alerta${total - 1 != 1 ? 's' : ''} pendente${total - 1 != 1 ? 's' : ''} após este',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ── Rodapé fixo ──────────────────────────────────────────────
                _buildFooter(current),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              total > 1 ? 'ALERTA 1 DE $total' : 'ALERTA CRÍTICO',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          if (total > 1)
            Row(
              children: List.generate(
                total.clamp(1, 5),
                (i) => Container(
                  margin: const EdgeInsets.only(left: 5),
                  width: i == 0 ? 10 : 6,
                  height: i == 0 ? 10 : 6,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(MyAssignmentModel? current) {
    final status = current?.status;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.info,
                  size: 12, color: Colors.white.withValues(alpha: 0.60)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  status == AssignmentStatus.overdue
                      ? 'Prazo vencido. Confirme a ciência para continuar.'
                      : 'Confirme a ciência para continuar usando o app.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          if (current != null) ...[
            const SizedBox(height: 10),
            _StatusChip(status: current.status),
          ],
          const SizedBox(height: 14),
          if (current != null)
            Semantics(
              button: true,
              label: 'Confirmar ciência do alerta',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _acknowledge(current.id),
                  icon: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFFDC2626).withValues(alpha: 0.70),
                          ),
                        )
                      : const Icon(LucideIcons.checkCircle2, size: 18),
                  label: Text(
                    _isLoading ? 'Confirmando…' : 'Confirmar ciência',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFDC2626),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.65),
                    disabledForegroundColor:
                        const Color(0xFFDC2626).withValues(alpha: 0.45),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Card de detalhes ──────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final MyAssignmentModel assignment;
  final String Function(DateTime) formatDateTime;

  const _DetailsCard({
    required this.assignment,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final hasDue = assignment.dueAt != null && assignment.acknowledgedAt == null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do card
              Row(
                children: [
                  Icon(LucideIcons.info,
                      size: 13, color: Colors.white.withValues(alpha: 0.55)),
                  const SizedBox(width: 6),
                  Text(
                    'DETALHES DO ALERTA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Enviado em
              _DetailRow(
                icon: LucideIcons.calendar,
                label: 'Enviado em',
                value: formatDateTime(assignment.createdAt),
              ),

              // Remetente
              if (assignment.authorName != null) ...[
                _Divider(),
                _DetailRow(
                  icon: LucideIcons.user,
                  label: 'Remetente',
                  value: assignment.authorName!,
                ),
              ],

              // Prazo
              if (hasDue) ...[
                _Divider(),
                _DetailRowWidget(
                  icon: LucideIcons.clock,
                  label: 'Prazo',
                  child: SlaCountdown(
                    dueAt: assignment.dueAt,
                    acknowledgedAt: assignment.acknowledgedAt,
                  ),
                ),
              ],

              // Prazo vencido
              if (assignment.dueAt != null &&
                  assignment.acknowledgedAt == null &&
                  assignment.dueAt!.isBefore(DateTime.now())) ...[],

              // Data de vencimento absoluta
              if (assignment.dueAt != null) ...[
                _Divider(),
                _DetailRow(
                  icon: LucideIcons.calendarClock,
                  label: 'Vence em',
                  value: formatDateTime(assignment.dueAt!),
                ),
              ],

              // Entregue em (deliveredAt)
              if (assignment.deliveredAt != null) ...[
                _Divider(),
                _DetailRow(
                  icon: LucideIcons.send,
                  label: 'Entregue em',
                  value: formatDateTime(assignment.deliveredAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.50)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRowWidget({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.50)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.60),
          ),
        ),
        const Spacer(),
        child,
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.12),
        ),
      );
}

// ── Card de mensagem ──────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  final String message;
  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.messageSquare,
                      size: 13, color: Colors.white.withValues(alpha: 0.55)),
                  const SizedBox(width: 6),
                  Text(
                    'MENSAGEM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.90),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String label;

    switch (status) {
      case AssignmentStatus.viewed:
        icon = LucideIcons.eye;
        label = 'Alerta visualizado';
        break;
      case AssignmentStatus.overdue:
        icon = LucideIcons.alertCircle;
        label = 'Atrasado';
        break;
      case AssignmentStatus.acknowledged:
        icon = LucideIcons.checkCircle2;
        label = 'Ciência confirmada';
        break;
      case AssignmentStatus.pending:
        icon = LucideIcons.clock;
        label = 'Pendente';
        break;
      case AssignmentStatus.denied:
        icon = LucideIcons.xCircle;
        label = 'Negado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
