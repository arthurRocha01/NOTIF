import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'alert_confirmation_detail_screen.dart';
import '../modals/create_alert_modal.dart';
import '../modals/create_confirmation_modal.dart';
import '../modals/view_alert_modal.dart';

class AlertsCentralScreen extends StatefulWidget {
  const AlertsCentralScreen({super.key});

  @override
  State<AlertsCentralScreen> createState() => _AlertsCentralScreenState();
}

class _AlertsCentralScreenState extends State<AlertsCentralScreen> {
  int _selectedTab = 0;

  static const _avisos = [
    _MockAviso(
      sector: 'SETOR DE TI',
      timeAgo: 'há 2h',
      title: 'Atualização do sistema de acesso',
      description:
          'O sistema de catracas será atualizado amanhã das 08h às 10h. Acesso manual será liberado durante a janela.',
      type: _AvisoType.comunicado,
      isCritical: false,
      readCount: 12,
      totalCount: 30,
    ),
    _MockAviso(
      sector: 'MANUTENÇÃO ELÉTRICA',
      timeAgo: 'há 5h',
      title: 'Desligamento programado do Rack Principal',
      description:
          'Janela de manutenção elétrica nesta sexta-feira, das 22h às 01h. Servidores serão desligados por 30 min.',
      type: _AvisoType.alerta,
      isCritical: true,
      readCount: 8,
      totalCount: 25,
    ),
    _MockAviso(
      sector: 'SETOR DE RH',
      timeAgo: 'ontem',
      title: 'Treinamento NR-10 obrigatório',
      description:
          'Todos os supervisores devem concluir o módulo NR-10 até sexta-feira. Acesse pelo portal de treinamentos.',
      type: _AvisoType.comunicado,
      isCritical: false,
      readCount: 45,
      totalCount: 60,
    ),
  ];

  static const _confirmacoes = [
    _MockConfirmacao(
      title: 'Atualização do Windows 11',
      sentAt: 'hoje às 09:00',
      simCount: 18,
      naoCount: 2,
      pendentesCount: 5,
      isDone: false,
    ),
    _MockConfirmacao(
      title: 'Simulação de Evacuação — Bloco B',
      sentAt: 'ontem às 14:30',
      simCount: 30,
      naoCount: 0,
      pendentesCount: 0,
      isDone: true,
    ),
    _MockConfirmacao(
      title: 'Verificação de Equipamentos NR-10',
      sentAt: 'há 2 dias',
      simCount: 20,
      naoCount: 3,
      pendentesCount: 2,
      isDone: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildTabToggle(),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF6741D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CENTRAL DE ALERTAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Central de Alertas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gerencie e monitore seus alertas',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Buscar alertas, setores ou equipamentos...',
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    const tabs = ['Avisos Gerais', 'Confirmações (Radar)'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.textPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _selectedTab == 0 ? _buildAvisosTab() : _buildConfirmacoesTab(),
    );
  }

  // ── AVISOS GERAIS ────────────────────────────────────────────────────────────

  Widget _buildAvisosTab() {
    return ListView(
      key: const ValueKey('avisos'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl,
      ),
      children: [
        _buildCriarAvisoCTA(),
        const SizedBox(height: AppSpacing.lg),
        ..._avisos.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildAvisoCard(a),
            )),
      ],
    );
  }

  Widget _buildCriarAvisoCTA() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2340), Color(0xFF2D3A5C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo Aviso',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Envie um comunicado, alerta ou aviso crítico.',
                  style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => CreateAlertModal.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+ Criar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2340),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _avisoType(_MockAviso aviso) {
    if (aviso.isCritical) return 'critico';
    if (aviso.type == _AvisoType.alerta) return 'alerta';
    return 'comunicado';
  }

  Widget _buildAvisoCard(_MockAviso aviso) {
    return GestureDetector(
      onTap: () => ViewAlertModal.show(
        context,
        title: aviso.title,
        sector: aviso.sector,
        timeAgo: aviso.timeAgo,
        type: _avisoType(aviso),
        description: aviso.description,
        readCount: aviso.readCount,
        totalCount: aviso.totalCount,
      ),
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: aviso.isCritical
              ? AppColors.critical.withValues(alpha: 0.2)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeBadge(aviso),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${aviso.sector} · ${aviso.timeAgo}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            aviso.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            aviso.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${aviso.readCount} leituras',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text(
                    'Ver detalhes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.accent),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildTypeBadge(_MockAviso aviso) {
    final color = aviso.isCritical ? AppColors.critical : AppColors.accent;
    final label = aviso.isCritical
        ? 'CRÍTICO'
        : aviso.type == _AvisoType.alerta
            ? 'ALERTA'
            : 'COMUNICADO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (aviso.isCritical) ...[
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.critical,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── CONFIRMAÇÕES (RADAR) ─────────────────────────────────────────────────────

  Widget _buildConfirmacoesTab() {
    return ListView(
      key: const ValueKey('confirmacoes'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl,
      ),
      children: [
        _buildConfirmacoesCTA(),
        const SizedBox(height: AppSpacing.xl),
        _buildHistoricoHeader(),
        const SizedBox(height: AppSpacing.md),
        ..._confirmacoes.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildConfirmacaoCard(c),
            )),
      ],
    );
  }

  Widget _buildConfirmacoesCTA() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF7048E8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sensors_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova Confirmação em Massa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Envie uma pergunta e acompanhe as respostas no mapa.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => CreateConfirmationModal.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B5BDB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                elevation: 0,
              ),
              child: const Text('+ Criar Confirmação'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Histórico de Confirmações',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${_confirmacoes.length} envios',
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildConfirmacaoCard(_MockConfirmacao conf) {
    final color = conf.isDone ? const Color(0xFF059669) : AppColors.accent;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AlertConfirmationDetailScreen(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    conf.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        conf.isDone ? 'CONCLUÍDO' : 'EM ANDAMENTO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildMiniStat('${conf.simCount}', 'Sim', const Color(0xFF059669)),
                const SizedBox(width: 20),
                _buildMiniStat('${conf.naoCount}', 'Não', AppColors.critical),
                const SizedBox(width: 20),
                _buildMiniStat('${conf.pendentesCount}', 'Pendentes', AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enviado ${conf.sentAt}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'Ver Radar de Respostas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accent),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

// ── Mock data models ──────────────────────────────────────────────────────────

enum _AvisoType { alerta, comunicado }

class _MockAviso {
  final String sector;
  final String timeAgo;
  final String title;
  final String description;
  final _AvisoType type;
  final bool isCritical;
  final int readCount;
  final int totalCount;

  const _MockAviso({
    required this.sector,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.type,
    required this.isCritical,
    required this.readCount,
    required this.totalCount,
  });
}

class _MockConfirmacao {
  final String title;
  final String sentAt;
  final int simCount;
  final int naoCount;
  final int pendentesCount;
  final bool isDone;

  const _MockConfirmacao({
    required this.title,
    required this.sentAt,
    required this.simCount,
    required this.naoCount,
    required this.pendentesCount,
    required this.isDone,
  });
}
