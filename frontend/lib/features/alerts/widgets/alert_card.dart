import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import 'alert_status_chip.dart';
import '../../../shared/widgets/hover_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/date_formatter.dart';

/// Card de alerta para a visão do [USER].
///
/// Exibe ícone, título, descrição, nível, status e botão "Ciente"
/// quando [AlertModel.requiresConfirmation] é true.
class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onAcknowledge;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      border: Border(
        left: BorderSide(color: alert.level.color, width: 4),
        top: const BorderSide(color: AppColors.border),
        right: const BorderSide(color: AppColors.border),
        bottom: const BorderSide(color: AppColors.border),
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AlertCardHeader(alert: alert),
          const SizedBox(height: AppSpacing.md),
          Text(
            alert.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (alert.sectors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _SectorRow(sectors: alert.sectors),
          ],
          if (alert.requiresConfirmation && alert.isActive) ...[
            const SizedBox(height: AppSpacing.lg),
            _AcknowledgeButton(
              level: alert.level,
              onTap: onAcknowledge,
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertCardHeader extends StatelessWidget {
  final AlertModel alert;
  const _AlertCardHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: alert.level.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(alert.level.icon,
              color: alert.level.color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AlertStatusChip(status: alert.status),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  AlertLevelChip(level: alert.level),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormatter.relative(alert.createdAt),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectorRow extends StatelessWidget {
  final List<String> sectors;
  const _SectorRow({required this.sectors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: sectors
          .take(3)
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ))
          .toList(),
    );
  }
}

class _AcknowledgeButton extends StatelessWidget {
  final AlertLevel level;
  final VoidCallback? onTap;

  const _AcknowledgeButton({required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: const Text('Ciente'),
        style: ElevatedButton.styleFrom(
          backgroundColor: level.color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}