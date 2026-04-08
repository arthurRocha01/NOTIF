import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AlertUserScreen extends StatelessWidget {
  const AlertUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fundo suave (Heurística #8: Estética e design minimalista)
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSectionHeader('Recentes'),
          _buildAlertList(recent: true),
          _buildSectionHeader('Anteriores'),
          _buildAlertList(recent: false),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meus Alertas',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe os avisos e notificações do seu setor.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertList({required bool recent}) {
    // Mock de dados (Heurística #1: Status do sistema através de cores/ícones)
    final alerts = recent 
      ? [
          _AlertData(
            title: 'Manutenção Preventiva',
            desc: 'O elevador do bloco B ficará indisponível das 14h às 16h.',
            time: '10 min atrás',
            type: AlertType.info,
            isRead: false,
          ),
          _AlertData(
            title: 'Urgente: Vazamento',
            desc: 'Detectado vazamento no 3º andar. Equipe técnica a caminho.',
            time: '1h atrás',
            type: AlertType.warning,
            isRead: false,
          ),
        ]
      : [
          _AlertData(
            title: 'Comunicado Geral',
            desc: 'Novas diretrizes de segurança de dados publicadas no portal.',
            time: 'Ontem',
            type: AlertType.success,
            isRead: true,
          ),
        ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _AlertCard(data: alerts[index]),
        childCount: alerts.length,
      ),
    );
  }
}

enum AlertType { info, warning, success }

class _AlertData {
  final String title, desc, time;
  final AlertType type;
  final bool isRead;

  _AlertData({
    required this.title,
    required this.desc,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertData data;

  const _AlertCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Definição de cores baseada na Heurística #4: Consistência e Padrões
    final colorMap = {
      AlertType.info: const Color(0xFF3B82F6),
      AlertType.warning: const Color(0xFFF59E0B),
      AlertType.success: const Color(0xFF10B981),
    };

    final iconMap = {
      AlertType.info: LucideIcons.info,
      AlertType.warning: LucideIcons.alertTriangle,
      AlertType.success: LucideIcons.checkCircle,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isRead ? Colors.transparent : colorMap[data.type]!.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // Heurística #7: Flexibilidade e eficiência de uso
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorMap[data.type]!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconMap[data.type], color: colorMap[data.type], size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          data.time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.desc,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!data.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorMap[data.type],
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}