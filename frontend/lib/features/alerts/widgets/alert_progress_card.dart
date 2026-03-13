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
          _CardDescription(description: alert.description),
          const SizedBox(height: AppSpacing.lg),
          _ReadRateBar(
            readRate: alert.readRate,
            readCount: alert.readCount,
            totalUsers: alert.totalUsers,
          ),
          if (alert.sectors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _SectorChips(sectors: alert.sectors),
          ],
          const SizedBox(height: AppSpacing.lg),
          _ActionRow(
            onDetails: onDetails,
            onResolve: onResolve,
          ),
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

class _CardDescription extends StatelessWidget {
  final String description;
  const _CardDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ReadRateBar extends StatelessWidget {
  final double readRate;
  final int readCount;
  final int totalUsers;

  const _ReadRateBar({
    required this.readRate,
    required this.readCount,
    required this.totalUsers,
  });

  Color get _barColor {
    final pct = readRate * 100;
    if (pct >= 80) return AppColors.resolved;
    if (pct >= 50) return AppColors.warning;
    return AppColors.critical;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (readRate * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Taxa de leitura',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (totalUsers > 0)
                    TextSpan(
                      text: '  $readCount/$totalUsers',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: readRate.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(_barColor),
          ),
        ),
      ],
    );
  }
}

class _SectorChips extends StatelessWidget {
  final List<String> sectors;
  const _SectorChips({required this.sectors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: sectors
          .take(4)
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
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
    );
  }
}
