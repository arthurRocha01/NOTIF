import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';

class CriticalAlertOverlay extends ConsumerWidget {
  final AssignmentModel assignment;

  const CriticalAlertOverlay({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = assignment.notificationTitle ?? 'Notificação Crítica';
    final message = assignment.notificationMessage;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFDC2626),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.alertOctagon,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ALERTA CRÍTICO',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                if (message != null && message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.5,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Você deve confirmar ciência para continuar usando o aplicativo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
}
