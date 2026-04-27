import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onResolve;

  const AlertCard({
    super.key,
    required this.alert,
    this.onResolve,
  });

  Color get _accentColor {
    return switch (alert.level) {
      AlertLevel.critical => AppColors.critical,
      AlertLevel.high     => AppColors.warning,
      AlertLevel.medium   => AppColors.accent,
      AlertLevel.low      => AppColors.textTertiary,
    };
  }

  String get _levelLabel {
    return switch (alert.level) {
      AlertLevel.critical => 'CRÍTICO',
      AlertLevel.high     => 'ALTO',
      AlertLevel.medium   => 'MÉDIO',
      AlertLevel.low      => 'BAIXO',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: _accentColor, width: 3),
          top: const BorderSide(color: AppColors.border, width: 0.5),
          right: const BorderSide(color: AppColors.border, width: 0.5),
          bottom: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _LevelBadge(label: _levelLabel, color: _accentColor),
              ],
            ),

            const SizedBox(height: 8),

            // ── Mensagem ──────────────────────────────────────────────────
            Text(
              alert.message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ── Footer ────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(LucideIcons.clock,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.timeOnly(alert.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (onResolve != null)
                  GestureDetector(
                    onTap: onResolve,
                    child: Row(
                      children: [
                        const Icon(LucideIcons.check,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          'Resolver',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge de nível ────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LevelBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
