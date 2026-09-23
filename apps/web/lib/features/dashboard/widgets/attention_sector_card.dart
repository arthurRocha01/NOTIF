import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';

class AttentionCard extends StatelessWidget {
  final List<AttentionSector> sectors;

  const AttentionCard({super.key, required this.sectors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.alertTriangle,
                    size: 16, color: Color(0xFFFF6B6B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atenção Necessária',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Setores com baixa adesão (< 60%)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              if (sectors.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.40),
                    ),
                  ),
                  child: Text(
                    '${sectors.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (sectors.isEmpty)
            _EmptyState()
          else
            ...sectors.map(_AttentionItem.new),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(LucideIcons.checkCircle2,
              size: 32, color: const Color(0xFF10B981).withValues(alpha: 0.70)),
          const SizedBox(height: 8),
          Text(
            'Todos os setores com boa adesão',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionItem extends StatelessWidget {
  final AttentionSector sector;
  const _AttentionItem(this.sector);

  Color get _levelColor {
    if (sector.rate < 0.2) return const Color(0xFFDC2626);
    if (sector.rate < 0.4) return const Color(0xFFF97316);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (sector.rate * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      // Envolvemos em um ClipRRect para os cantos arredondados funcionarem com a barra lateral
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            // Mudamos para Border.all para garantir espessura e cores idênticas em toda a volta
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 0.5,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Esta barra substitui a borda esquerda assimétrica que quebrava o Flutter
                Container(
                  width: 3,
                  color: _levelColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _levelColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: _levelColor.withValues(alpha: 0.30)),
                          ),
                          child: Center(
                            child: Text(
                              '$pct%',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _levelColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sector.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sector.pendingCount} pendente${sector.pendingCount != 1 ? 's' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$pct%',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _levelColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: sector.rate,
                                  minHeight: 5,
                                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                                  valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}