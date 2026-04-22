import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';

class DashboardDonutChart extends StatefulWidget {
  final SectorStatusBreakdown breakdown;
  final String sectorName;

  const DashboardDonutChart({
    super.key,
    required this.breakdown,
    required this.sectorName,
  });

  @override
  State<DashboardDonutChart> createState() => _DashboardDonutChartState();
}

class _DashboardDonutChartState extends State<DashboardDonutChart> {
  int _touchedIndex = -1;

  static const _pending      = Color(0xFF94A3B8);
  static const _viewed       = Color(0xFF4A6CF7);
  static const _acknowledged = Color(0xFF16A34A);
  static const _overdue      = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final bd    = widget.breakdown;
    final total = bd.pending + bd.viewed + bd.acknowledged + bd.overdue;

    if (total == 0) {
      return Center(
        child: Text(
          'Sem dados para este setor',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        ),
      );
    }

    final sections = <_Section>[
      _Section('Pendente',    bd.pending,      _pending),
      _Section('Visualizado', bd.viewed,       _viewed),
      _Section('Confirmado',  bd.acknowledged, _acknowledged),
      _Section('Atrasado',    bd.overdue,      _overdue),
    ].where((s) => s.count > 0).toList();

    return Row(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 44,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: sections.asMap().entries.map((e) {
                final isTouched = e.key == _touchedIndex;
                final s        = e.value;
                final pct      = (s.count / total * 100).toInt();
                return PieChartSectionData(
                  color:       s.color,
                  value:       s.count.toDouble(),
                  radius:      isTouched ? 38 : 30,
                  title:       isTouched ? '$pct%' : '',
                  titleStyle:  GoogleFonts.inter(
                    color:      Colors.white,
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.sectorName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...sections.map((s) => _LegendRow(
                    color: s.color,
                    label: s.label,
                    count: s.count,
                    total: total,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section {
  final String label;
  final int    count;
  final Color  color;
  const _Section(this.label, this.count, this.color);
}

class _LegendRow extends StatelessWidget {
  final Color  color;
  final String label;
  final int    count;
  final int    total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (count / total * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
          ),
          Text('$count ($pct%)',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
