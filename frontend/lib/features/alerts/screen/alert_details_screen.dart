import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../providers/alert_provider.dart';

class AlertDetailsScreen extends ConsumerWidget {
  final AssignmentModel assignment;

  const AlertDetailsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = assignment.notificationTitle ?? 'Notificação';
    final message = assignment.notificationMessage;
    final level = assignment.notificationLevel;
    final status = assignment.status;
    final isDone = status == AssignmentStatus.acknowledged;
    final isOverdue = status == AssignmentStatus.overdue;
    final canAcknowledge = !isDone &&
        (assignment.isCritical || level == AlertLevel.high);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalhes',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nível + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: level.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(level.icon, color: level.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 20),

            // Nível
            _InfoRow(label: 'Nível', value: level.label),
            const SizedBox(height: 12),

            // Prazo
            if (assignment.dueAt != null) ...[
              _InfoRow(
                label: 'Prazo',
                value: _formatDue(assignment.dueAt!, isOverdue),
                valueColor: isOverdue ? const Color(0xFFDC2626) : null,
              ),
              const SizedBox(height: 12),
            ],

            // Mensagem
            if (message != null && message.isNotEmpty) ...[
              Text(
                'Mensagem',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Botão de confirmação
            if (canAcknowledge)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(alertProvider.notifier)
                        .acknowledge(assignmentId: assignment.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar ciência',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: level.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDue(DateTime due, bool isOverdue) {
    if (isOverdue) return 'Vencido';
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) return 'Vencido';
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'em ${diff.inHours}h';
    return 'em ${diff.inDays}d';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: valueColor ?? const Color(0xFF1E293B),
            fontWeight:
                valueColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
