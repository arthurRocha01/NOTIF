import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../alerts/models/alert_model.dart';
import '../../../core/utils/date_formatter.dart';

class MonitoringAlertCard extends StatelessWidget {
  final AlertModel alert;
  final String? sectorName;

  const MonitoringAlertCard({super.key, required this.alert, this.sectorName});

  @override
  Widget build(BuildContext context) {
    final level = alert.level;
    final requiresAck = alert.requiresAcknowledgment;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Barra lateral colorida por nível ──────────────────────
              Container(width: 4, color: level.color),

              // ── Conteúdo ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Linha do título ─────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: level.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(level.icon,
                                color: level.color, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alert.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge de nível
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: level.backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level.label,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: level.color,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Preview da mensagem ─────────────────────────────
                      const SizedBox(height: 8),
                      Text(
                        alert.message,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ── Rodapé: data · escopo · exige ciência ───────────
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(LucideIcons.clock,
                              size: 12, color: const Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.relative(alert.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            alert.isGlobal
                                ? LucideIcons.globe
                                : LucideIcons.users,
                            size: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.isGlobal
                                ? 'Global'
                                : sectorName ?? 'Setor específico',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          if (requiresAck)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Exige ciência',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD97706),
                                ),
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
