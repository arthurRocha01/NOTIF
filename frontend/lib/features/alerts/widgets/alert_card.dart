import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onResolve;

  const AlertCard({
    super.key,
    required this.alert,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.level == AlertLevel.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCritical
              ? AppColors.critical
              : Colors.grey.shade300,
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER
          Row(
            children: [
              Icon(
                isCritical
                    ? Icons.priority_high
                    : Icons.notifications,
                color: isCritical
                    ? AppColors.critical
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),

              /// BADGE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppColors.critical.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCritical ? "CRÍTICO" : "NORMAL",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCritical
                        ? AppColors.critical
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// DESCRIÇÃO
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          /// FOOTER
          Row(
            children: [
              const Icon(Icons.access_time, size: 14),
              const SizedBox(width: 4),
              Text(
                "${alert.createdAt.hour}:${alert.createdAt.minute}",
                style: const TextStyle(fontSize: 12),
              ),

              const Spacer(),

              if (onResolve != null)
                TextButton.icon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.check),
                  label: const Text("Resolver"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}