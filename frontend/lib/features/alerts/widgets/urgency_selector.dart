import 'package:flutter/material.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_durations.dart';

/// Seletor de urgência (Normal / Crítico) para criação de alertas.
///
/// Renderiza dois cards horizontais com feedback visual animado.
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
            final isLast = level == AlertLevel.values.last;

            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: isLast ? 0 : AppSpacing.sm),
                child: _LevelOption(
                  level: level,
                  isSelected: isSelected,
                  onTap: () => onChanged(level),
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

  const _LevelOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
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
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                level.icon,
                key: ValueKey(isSelected),
                size: 16,
                color: isSelected
                    ? level.color
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
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}