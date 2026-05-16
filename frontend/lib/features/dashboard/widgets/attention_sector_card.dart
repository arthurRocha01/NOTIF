import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';

class AttentionCard extends StatelessWidget {
  final List<AttentionSector> sectors;

  const AttentionCard({super.key, required this.sectors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.alertTriangle,
                    size: 16, color: Color(0xFFDC2626)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atenção Necessária',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Setores com adesão abaixo de 60%',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              if (sectors.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sectors.length} setor${sectors.length != 1 ? 'es' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (sectors.isEmpty)
            _EmptyState()
          else
            Column(
              children: sectors
                  .map((s) => _AttentionItem(sector: s))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.checkCircle2,
                size: 24, color: Color(0xFF16A34A)),
          ),
          const SizedBox(height: 10),
          Text(
            'Todos em dia!',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Todos os setores com boa adesão',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _AttentionItem extends StatelessWidget {
  final AttentionSector sector;
  const _AttentionItem({required this.sector});

  Color get _color {
    if (sector.rate < 0.2) return const Color(0xFFDC2626);
    if (sector.rate < 0.4) return const Color(0xFFF97316);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (sector.rate * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sector.id,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${sector.pendingCount} pendente${sector.pendingCount != 1 ? 's' : ''}',
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sector.rate,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ],
      ),
    );
  }
}
