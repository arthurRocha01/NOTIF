import 'package:flutter/material.dart';
import 'package:notif_app/shared/widgets/status_badge.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_durations.dart';

class AlertStatusChip extends StatelessWidget {
  final AlertStatus status;
  const AlertStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) => StatusBadge(
        label: status.label,
        color: status.color,
        backgroundColor: status.backgroundColor,
        icon: status.icon,
      );
}

class AlertLevelChip extends StatelessWidget {
  final AlertLevel level;
  const AlertLevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) => StatusBadge(
        label: level.label,
        color: level.color,
        backgroundColor: level.backgroundColor,
        icon: level.icon,
      );
}

class UrgencySelector extends StatelessWidget {
  final AlertLevel selected;
  final ValueChanged<AlertLevel> onChanged;

  const UrgencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nível de urgência',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: AlertLevel.values.map((level) {
            final isSelected = selected == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != AlertLevel.values.last ? AppSpacing.sm : 0,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(level),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? level.backgroundColor
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? level.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          level.icon,
                          size: 16,
                          color: isSelected
                              ? level.color
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? level.color
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
