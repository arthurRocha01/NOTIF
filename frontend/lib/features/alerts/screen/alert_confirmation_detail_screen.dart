import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class AlertConfirmationDetailScreen extends StatelessWidget {
  const AlertConfirmationDetailScreen({super.key});

  static const _title = 'Confirmação de Atualização Crítica';
  static const _sentAt = '14:30';
  static const _sector = 'TI — Lab Alpha';
  static const _simCount = 24;
  static const _naoCount = 2;
  static const _pendentesCount = 4;
  static const _total = 30;
  static const _responseRate = 0.87;

  static final _radarGrid = [
    _GridRow('A', [
      _SS.sim, _SS.sim, _SS.nao, _SS.sim,
      null,
      _SS.sim, _SS.pendente, _SS.sim,
    ]),
    _GridRow('B', [
      _SS.sim, _SS.sim, _SS.sim, _SS.sim,
      null,
      _SS.sim, _SS.sim, _SS.sim,
    ]),
    _GridRow('C', [
      _SS.nao, _SS.sim, _SS.sim, _SS.sim,
      null,
      _SS.pendente, _SS.sim, _SS.pendente,
    ]),
    _GridRow('D', [
      _SS.sim, _SS.sim, _SS.pendente, _SS.sim,
      null,
      _SS.sim, _SS.sim, _SS.sim,
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl,
                ),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsRow(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRadarCard(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
          ),
          const Expanded(
            child: Text(
              'DETALHES DO ALERTA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge('BOOLEAN · SIM/NÃO', AppColors.accent),
              const SizedBox(width: 8),
              _buildBadge('EM ANDAMENTO', const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            _title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enviado às $_sentAt · Setor: $_sector',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taxa de resposta',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '${(_responseRate * 100).toStringAsFixed(0)}% (${(_responseRate * _total).toInt()}/$_total)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _responseRate,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Sim', _simCount, const Color(0xFF059669), Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Não', _naoCount, AppColors.critical, Icons.cancel_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Pendentes', _pendentesCount, AppColors.textTertiary, Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Radar de Respostas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Lab Alpha · 32 estações',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Layout físico do setor — toque em uma estação para detalhes.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildGrid(),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        const Center(
          child: Text(
            'LOUSA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ..._radarGrid.map(_buildGridRow),
      ],
    );
  }

  Widget _buildGridRow(_GridRow row) {
    int col = 0;
    final cells = <Widget>[
      SizedBox(
        width: 16,
        child: Text(
          row.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
      ),
      const SizedBox(width: 6),
    ];
    for (final state in row.stations) {
      if (state == null) {
        cells.add(const SizedBox(width: 12));
      } else {
        col++;
        cells.add(
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: _buildStationCell(col.toString().padLeft(2, '0'), state),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: cells),
    );
  }

  Widget _buildStationCell(String number, _SS state) {
    late Color bg, borderColor, textColor;
    switch (state) {
      case _SS.sim:
        bg = const Color(0xFF059669).withValues(alpha: 0.15);
        borderColor = const Color(0xFF059669).withValues(alpha: 0.35);
        textColor = const Color(0xFF059669);
      case _SS.nao:
        bg = AppColors.critical.withValues(alpha: 0.1);
        borderColor = AppColors.critical.withValues(alpha: 0.35);
        textColor = AppColors.critical;
      case _SS.pendente:
        bg = AppColors.background;
        borderColor = AppColors.border;
        textColor = AppColors.textTertiary;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Sim', const Color(0xFF059669), filled: true),
        const SizedBox(width: 20),
        _legendItem('Não', AppColors.critical, filled: true),
        const SizedBox(width: 20),
        _legendItem('Pendente', AppColors.textTertiary, filled: false),
      ],
    );
  }

  Widget _legendItem(String label, Color color, {required bool filled}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: filled ? 0 : 1.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text('Reenviar para Pendentes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
    );
  }
}

class _GridRow {
  final String label;
  final List<_SS?> stations;
  const _GridRow(this.label, this.stations);
}

enum _SS { sim, nao, pendente }
