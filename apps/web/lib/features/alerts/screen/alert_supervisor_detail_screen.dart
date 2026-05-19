import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert_model.dart';

class AlertSupervisorDetailScreen extends StatelessWidget {
  final AlertModel alert;
  final String? sectorName;

  const AlertSupervisorDetailScreen({
    super.key,
    required this.alert,
    this.sectorName,
  });

  @override
  Widget build(BuildContext context) {
    final level = alert.level;
    final sector = sectorName ?? (alert.isGlobal ? 'Global' : '—');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: CustomScrollView(
        slivers: [
          // ── AppBar com gradiente por nível ──────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: level.color,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Detalhes do Alerta',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [level.color, level.color.withValues(alpha: 0.72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _Pill(icon: level.icon, label: level.label),
                        const SizedBox(width: 8),
                        _Pill(
                          icon: alert.isGlobal
                              ? LucideIcons.globe
                              : LucideIcons.building2,
                          label: sector,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alert.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Conteúdo ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (alert.message.isNotEmpty) ...[
                    _SectionCard(
                      title: 'MENSAGEM',
                      icon: LucideIcons.messageSquare,
                      child: Text(
                        alert.message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.80),
                          height: 1.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _SectionCard(
                    title: 'INFORMAÇÕES',
                    icon: LucideIcons.info,
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: LucideIcons.building2,
                          label: 'Setor',
                          value: sector,
                        ),
                        const _RowDivider(),
                        _InfoRow(
                          icon: LucideIcons.calendar,
                          label: 'Criado em',
                          value: _formatDate(alert.createdAt),
                        ),
                        const _RowDivider(),
                        _InfoRow(
                          icon: LucideIcons.clock,
                          label: 'SLA',
                          value: _formatSla(alert.slaMinutes),
                        ),
                        const _RowDivider(),
                        _InfoRow(
                          icon: LucideIcons.checkCircle2,
                          label: 'Requer confirmação',
                          value: alert.effectiveRequiresAcknowledgment
                              ? 'Sim'
                              : 'Não',
                          valueColor: alert.effectiveRequiresAcknowledgment
                              ? const Color(0xFF4ADE80)
                              : Colors.white.withValues(alpha: 0.40),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatSla(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.40)),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.40),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.40)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      );
}