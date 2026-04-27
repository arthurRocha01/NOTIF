import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardBarChart extends StatelessWidget {
  /// sectorName → taxa (0.0–1.0), já ordenado do maior para o menor
  final Map<String, double> sectorRates;

  const DashboardBarChart({super.key, required this.sectorRates});

  Color _barColor(double value) {
    if (value >= 0.8) return const Color(0xFF16A34A);
    if (value >= 0.6) return const Color(0xFF4A6CF7);
    if (value >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    if (sectorRates.isEmpty) {
      return Center(
        child: Text(
          'Nenhum dado disponível',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        ),
      );
    }

    final entries = sectorRates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final barGroups = entries.asMap().entries.map((e) {
      final idx   = e.key;
      final value = e.value.value;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: value * 100,
            color: _barColor(value),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      );
    }).toList();

    final chartHeight = (entries.length * 52.0).clamp(120.0, 320.0);

    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}%',
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                  final name = entries[idx].key;
                  final short = name.length > 6 ? '${name.substring(0, 5)}.' : name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      short,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1A2340),
              getTooltipItem: (group, _, rod, __) {
                final name = entries[group.x].key;
                return BarTooltipItem(
                  '$name\n${rod.toY.toInt()}%',
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
