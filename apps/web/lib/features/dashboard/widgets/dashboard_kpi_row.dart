import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notif_app/core/constants/app_colors.dart';

class DashboardKpiRow extends StatelessWidget {
  final int totalAssignments;
  final int totalAcknowledged;
  final int totalPending;
  final int totalCritical;

  const DashboardKpiRow({
    super.key,
    required this.totalAssignments,
    required this.totalAcknowledged,
    required this.totalPending,
    required this.totalCritical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Total',
                value: '$totalAssignments',
                accentColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                label: 'Confirmados',
                value: '$totalAcknowledged',
                accentColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Pendentes',
                value: '$totalPending',
                accentColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                label: 'Críticos',
                value: '$totalCritical',
                accentColor: AppColors.critical,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: accentColor, width: 2),
          top: const BorderSide(color: AppColors.border, width: 0.5),
          right: const BorderSide(color: AppColors.border, width: 0.5),
          bottom: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
