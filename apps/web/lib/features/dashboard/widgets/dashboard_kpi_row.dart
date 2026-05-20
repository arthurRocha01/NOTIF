import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notif_app/core/constants/app_colors.dart';

class DashboardKpiRow extends StatelessWidget {
  final int totalNotifications;
  final int totalAcknowledged;
  final int totalPending;
  final int totalCritical;

  const DashboardKpiRow({
    super.key,
    required this.totalNotifications,
    required this.totalAcknowledged,
    required this.totalPending,
    required this.totalCritical,
  });

  Widget _groupLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.40),
        letterSpacing: 1.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('ALERTAS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Emitidos',
                value: '$totalNotifications',
                accentColor: AppColors.accent,
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
        const SizedBox(height: 16),
        _groupLabel('RESPOSTAS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Confirmados',
                value: '$totalAcknowledged',
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                label: 'Pendentes',
                value: '$totalPending',
                accentColor: AppColors.warning,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1B2D),
          // Criamos uma borda uniforme fina em toda a volta (o Flutter aceita isso com borderRadius)
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Substituímos a borda esquerda por um Container físico que faz o papel do traço colorido
              Container(
                width: 3,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  // Ajustado o padding esquerdo para compensar a barra lateral
                  padding: const EdgeInsets.fromLTRB(13, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              label.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.70),
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}