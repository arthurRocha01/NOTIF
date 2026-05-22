import 'package:flutter/material.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_durations.dart';

class UrgencySelector extends StatelessWidget {
  final AlertLevel selected;
  final ValueChanged<AlertLevel> onChanged;
  final bool dark;
  final List<AlertLevel>? levels;

  const UrgencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.dark = false,
    this.levels,
  });

  @override
  Widget build(BuildContext context) {
    final displayLevels = levels ?? AlertLevel.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nível de urgência',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: dark
                ? Colors.white.withValues(alpha: 0.65)
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: displayLevels.map((level) {
            final isSelected = selected == level;
            final isLast = level == displayLevels.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.sm),
                child: _LevelOption(
                  level: level,
                  isSelected: isSelected,
                  onTap: () => onChanged(level),
                  dark: dark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LevelOption extends StatelessWidget {
  final AlertLevel level;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dark;

  const _LevelOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (dark
                  ? level.color.withValues(alpha: 0.20)
                  : level.backgroundColor)
              : (dark
                  ? Colors.white.withValues(alpha: 0.07)
                  : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? level.color
                : dark
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                level.icon,
                key: ValueKey(isSelected),
                size: 16,
                color: isSelected
                    ? level.color
                    : dark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              level.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? level.color
                    : dark
                        ? Colors.white.withValues(alpha: 0.65)
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}