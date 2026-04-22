import 'package:flutter/material.dart';
import 'package:notif_app/shared/widgets/hover_card.dart' show HoverCard;

import '../models/alert_model.dart';
import 'alert_status_chip.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/date_formatter.dart';

class AlertProgressCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onDetails;
  final VoidCallback? onResolve;

  const AlertProgressCard({
    super.key,
    required this.alert,
    this.onDetails,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(alert: alert),
          const SizedBox(height: AppSpacing.sm),
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          _SectorInfo(alert: alert),
          const SizedBox(height: AppSpacing.lg),
          _ActionRow(onDetails: onDetails, onResolve: onResolve),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final AlertModel alert;
  const _CardHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: alert.level.backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(alert.level.icon, color: alert.level.color, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatter.relative(alert.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AlertLevelChip(level: alert.level),
      ],
    );
  }
}

class _SectorInfo extends StatelessWidget {
  final AlertModel alert;
  const _SectorInfo({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          alert.isGlobal ? Icons.public : Icons.groups,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          alert.isGlobal ? 'Global' : (alert.targetSectorId ?? ''),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        if (alert.requiresAcknowledgment) ...[
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.check_circle_outline,
              size: 14, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'Exige confirmação',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback? onDetails;
  final VoidCallback? onResolve;

  const _ActionRow({this.onDetails, this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDetails,
            icon: const Icon(Icons.visibility_outlined, size: 14),
            label: const Text('Ver detalhes'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 9),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
        if (onResolve != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onResolve,
              icon: const Icon(Icons.check_circle_outline, size: 14),
              label: const Text('Resolver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.resolved,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
