import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'edit_alert_modal.dart';

class ViewAlertModal extends StatelessWidget {
  final String title;
  final String sector;
  final String timeAgo;
  final String type; // 'critico' | 'alerta' | 'comunicado'
  final String description;
  final int readCount;
  final int totalCount;
  final bool isResolved;

  const ViewAlertModal({
    super.key,
    required this.title,
    required this.sector,
    required this.timeAgo,
    required this.type,
    required this.description,
    required this.readCount,
    required this.totalCount,
    this.isResolved = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String sector,
    required String timeAgo,
    required String type,
    required String description,
    required int readCount,
    required int totalCount,
    bool isResolved = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ViewAlertModal(
        title: title,
        sector: sector,
        timeAgo: timeAgo,
        type: type,
        description: description,
        readCount: readCount,
        totalCount: totalCount,
        isResolved: isResolved,
      ),
    );
  }

  Color get _typeColor {
    if (type == 'critico') return const Color(0xFFDC2626);
    if (type == 'alerta') return const Color(0xFFD97706);
    return const Color(0xFF3B5BDB);
  }

  String get _typeLabel {
    if (type == 'critico') return 'CRÍTICO';
    if (type == 'alerta') return 'ALERTA';
    return 'COMUNICADO';
  }

  IconData get _typeIcon {
    if (type == 'critico') return Icons.warning_rounded;
    if (type == 'alerta') return Icons.notification_important_rounded;
    return Icons.campaign_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final readPct = totalCount > 0 ? readCount / totalCount : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _handle(),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _buildAlertCard(),
                  const SizedBox(height: 16),
                  _buildStatsRow(readPct),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 16),
                  _buildMetaCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  // ── Handle ────────────────────────────────────────────────────────────────────

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  // ── Alert card ────────────────────────────────────────────────────────────────

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, size: 12, color: _typeColor),
                    const SizedBox(width: 5),
                    Text(
                      _typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _typeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'RESOLVIDO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2340),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                sector,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(double readPct) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.remove_red_eye_outlined,
            iconColor: const Color(0xFF3B5BDB),
            bgColor: const Color(0xFF3B5BDB).withValues(alpha: 0.06),
            value: '$readCount',
            label: 'Leituras',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.group_outlined,
            iconColor: const Color(0xFF6B7280),
            bgColor: const Color(0xFFF8F9FE),
            value: '$totalCount',
            label: 'Destinatários',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.pie_chart_outline_rounded,
            iconColor: readPct >= 0.7 ? const Color(0xFF059669) : const Color(0xFFD97706),
            bgColor: readPct >= 0.7
                ? const Color(0xFF059669).withValues(alpha: 0.06)
                : const Color(0xFFD97706).withValues(alpha: 0.06),
            value: '${(readPct * 100).round()}%',
            label: 'Taxa',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────────────────

  // ── Description card ──────────────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descrição',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2340),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Meta card ─────────────────────────────────────────────────────────────────

  Widget _buildMetaCard() {
    final readPct = totalCount > 0 ? readCount / totalCount : 0.0;
    final pctColor = readPct >= 0.7 ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taxa de Leitura',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$readCount de $totalCount leram',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              Text(
                '${(readPct * 100).round()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: pctColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: readPct,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation(pctColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action bar ────────────────────────────────────────────────────────────────

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAF0))),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, size: 15),
            label: const Text('Fechar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFE8EAF0)),
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                EditAlertModal.show(
                  context,
                  title: title,
                  sector: sector,
                  type: type,
                  description: description,
                );
              },
              icon: const Icon(LucideIcons.pencil, size: 15),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF3B5BDB)),
                foregroundColor: const Color(0xFF3B5BDB),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Resolver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
