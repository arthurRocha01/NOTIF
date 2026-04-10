import 'package:flutter/material.dart';
import 'package:notif_app/core/constants/app_radius.dart';
import 'package:notif_app/shared/widgets/hover_card.dart' show HoverCard;

import '../models/alert_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';

class AlertHistoryCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertHistoryCard({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.resolvedLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.resolved, size: 18),
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
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.full(alert.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: alert.level.backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              alert.level.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: alert.level.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
