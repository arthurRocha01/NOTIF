import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/my_assignment_model.dart';
import '../models/alert_status.dart';
import '../providers/alert_provider.dart';
import '../screen/alert_details_screen.dart';
import '../widgets/sla_countdown.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../features/login/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AssignmentsBody
// ─────────────────────────────────────────────────────────────────────────────

class AssignmentsBody extends ConsumerStatefulWidget {
  final List<MyAssignmentModel> assignments;
  final bool isLoading;
  final bool isBlocked;
  final bool isSupervisor;
  final Future<void> Function() onRefresh;
  final void Function(String assignmentId)? onAcknowledge;
  final void Function(String assignmentId)? onDeny;

  const AssignmentsBody({
    super.key,
    required this.assignments,
    required this.isLoading,
    required this.isBlocked,
    required this.onRefresh,
    this.isSupervisor = false,
    this.onAcknowledge,
    this.onDeny,
  });

  @override
  ConsumerState<AssignmentsBody> createState() => _AssignmentsBodyState();
}

class _AssignmentsBodyState extends ConsumerState<AssignmentsBody> {
  String _filter = 'unread';

  // ── Filtros ───────────────────────────────────────────────────────────────
  List<MyAssignmentModel> _applyFilter(List<MyAssignmentModel> all) {
    switch (_filter) {
      case 'all':
        return List.from(all)
          ..sort(_sortScore);
      case 'pending':
        return all
            .where((a) =>
                a.status == AssignmentStatus.pending ||
                a.status == AssignmentStatus.viewed ||
                a.status == AssignmentStatus.overdue)
            .toList()
          ..sort(_sortScore);
      case 'overdue':
        return all
            .where((a) => a.status == AssignmentStatus.overdue)
            .toList()
          ..sort(_sortScore);
      case 'confirmed':
        return all
            .where((a) => a.status == AssignmentStatus.acknowledged)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'critical':
        return all
            .where((a) =>
                a.notificationLevel == AlertLevel.critical &&
                a.status != AssignmentStatus.acknowledged)
            .toList()
          ..sort(_sortScore);
      case 'unread':
      default:
        return all
            .where((a) => a.status == AssignmentStatus.pending)
            .toList()
          ..sort(_sortScore);
    }
  }

  int _sortScore(MyAssignmentModel a, MyAssignmentModel b) {
    int lvl(AlertLevel l) => switch (l) {
      AlertLevel.critical => 0,
      AlertLevel.high => 1,
      AlertLevel.medium => 2,
      AlertLevel.low => 3,
    };
    int sta(AssignmentStatus s) => switch (s) {
      AssignmentStatus.overdue => 0,
      AssignmentStatus.pending => 1,
      AssignmentStatus.viewed => 2,
      AssignmentStatus.acknowledged => 3,
      AssignmentStatus.denied => 4,
    };
    final dl = lvl(a.notificationLevel).compareTo(lvl(b.notificationLevel));
    if (dl != 0) return dl;
    final ds = sta(a.status).compareTo(sta(b.status));
    if (ds != 0) return ds;
    return b.createdAt.compareTo(a.createdAt);
  }

  // ── Utils de texto ────────────────────────────────────────────────────────
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia,';
    if (h < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  String _firstName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return parts.isNotEmpty ? parts[0] : 'Usuário';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // ── Contagens ─────────────────────────────────────────────────────────────
  int _unreadCount(List<MyAssignmentModel> all) =>
      all.where((a) => a.status == AssignmentStatus.pending).length;

  int _criticalCount(List<MyAssignmentModel> all) => all
      .where((a) =>
          a.notificationLevel == AlertLevel.critical &&
          a.status != AssignmentStatus.acknowledged)
      .length;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final fullName = user?.name ?? 'Usuário';
    final assignments = widget.assignments;
    final filtered = _applyFilter(assignments);
    final pendingCount =
        assignments.where((a) => a.status != AssignmentStatus.acknowledged).length;
    final unreadCount = _unreadCount(assignments);
    final criticalCount = _criticalCount(assignments);
    final blockingList = assignments.where((a) => a.isBlocking).toList();
    final criticalBlocking = blockingList.isNotEmpty ? blockingList.first : null;

    final emptyLabels = {
      'unread': 'Nenhuma mensagem não lida',
      'all': 'Nenhuma notificação',
      'pending': 'Nenhuma notificação pendente',
      'overdue': 'Nenhum alerta atrasado',
      'confirmed': 'Nenhuma confirmação ainda',
      'critical': 'Nenhum alerta crítico ativo',
    };

    return Stack(
      children: [
        // ── Círculos decorativos (H8 – design minimalista e agradável) ─────
        Positioned(
          top: -60,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.14),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B4BF7).withValues(alpha: 0.10),
            ),
          ),
        ),

        // ── Conteúdo ──────────────────────────────────────────────────────
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          color: AppColors.accent,
          backgroundColor: const Color(0xFF1A2340),
          child: CustomScrollView(
            slivers: [
              // Cabeçalho (H1 – visibilidade do estado + H2 – linguagem real)
              SliverToBoxAdapter(
                child: _buildHeader(
                  widget.isSupervisor ? 'Painel de Alertas' : _firstName(fullName),
                  fullName,
                  pendingCount,
                ),
              ),

              // Banner de bloqueio ativo (H1 – visibilidade de estado crítico)
              if (widget.isBlocked && criticalBlocking == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _BlockingBanner(),
                  ),
                ),

              // Card crítico bloqueante (H5 – prevenção de erros)
              if (criticalBlocking != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _CriticalCard(
                      assignment: criticalBlocking,
                      onAcknowledge: criticalBlocking.status != AssignmentStatus.overdue
                          ? () => widget.onAcknowledge?.call(criticalBlocking.id)
                          : null,
                    ),
                  ),
                ),

              // Filtros (H7 – flexibilidade e eficiência de uso)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildFilterChips(unreadCount, criticalCount),
                ),
              ),

              // Label seção (H1 – visibilidade do estado)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CAIXA DE ENTRADA',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.65),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      // H1: mostra estado de atualização quando já há dados
                      if (widget.isLoading && assignments.isNotEmpty)
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            color: Colors.white.withValues(alpha: 0.55),
                            strokeWidth: 1.5,
                          ),
                        )
                      else
                        Text(
                          '${filtered.length} mensagem${filtered.length != 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Lista (H3 – controle do usuário sobre conteúdo)
              if (widget.isLoading && assignments.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: _buildEmpty(emptyLabels[_filter] ?? 'Nenhuma notificação'),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final a = filtered[i];
                        return _AssignmentCard(
                          key: ValueKey(a.id),
                          assignment: a,
                          onTap: () {
                            if (a.status == AssignmentStatus.pending ||
                                a.status == AssignmentStatus.viewed) {
                              ref
                                  .read(alertProvider.notifier)
                                  .markAsViewed(a.id);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AlertDetailsScreen(assignment: a),
                              ),
                            );
                          },
                          onAcknowledge: a.canAcknowledge
                              ? () => widget.onAcknowledge?.call(a.id)
                              : null,
                          onDeny: a.canDeny
                              ? () => widget.onDeny?.call(a.id)
                              : null,
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────────────────────
  Widget _buildHeader(String title, String fullName, int pendingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isSupervisor)
                  Text(
                    _greeting(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (pendingCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount alerta${pendingCount != 1 ? 's' : ''} pendente${pendingCount != 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Avatar com iniciais (H6 – reconhecimento, não memorização)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(fullName),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips(int unreadCount, int criticalCount) {
    final filters = [
      (
        'unread',
        'Não lidos${unreadCount > 0 ? ' ($unreadCount)' : ''}',
        null,
        null,
      ),
      ('all', 'Todos', null, null),
      (
        'critical',
        'Críticos${criticalCount > 0 ? ' ($criticalCount)' : ''}',
        const Color(0xFFDC2626),
        const Color(0xFF3D1515),
      ),
      ('pending', 'Pendente', null, null),
      ('overdue', 'Atrasado', null, null),
      ('confirmed', 'Confirmado', null, null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final (key, label, activeColor, activeBg) = filters[i];
          final isSelected = _filter == key;
          final isCritical = key == 'critical';

          // Chip crítico tem cor vermelha diferenciada
          final chipBg = isSelected
              ? (isCritical
                  ? const Color(0xFFDC2626).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.15))
              : (isCritical && criticalCount > 0
                  ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                  : Colors.transparent);

          final borderColor = isSelected
              ? (isCritical
                  ? const Color(0xFFDC2626).withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.40))
              : (isCritical && criticalCount > 0
                  ? const Color(0xFFDC2626).withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.14));

          final textColor = isSelected
              ? (isCritical ? const Color(0xFFFF6B6B) : Colors.white)
              : (isCritical && criticalCount > 0
                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.65));

          return Padding(
            padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: label,
              child: GestureDetector(
                onTap: () => setState(() => _filter = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCritical) ...[
                          Icon(
                            LucideIcons.alertOctagon,
                            size: 12,
                            color: textColor,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Estado vazio contextual (H9 – ajudar a reconhecer erros/estados) ──────
  Widget _buildEmpty(String label) {
    final isFiltered = _filter != 'all' && _filter != 'unread';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filter == 'confirmed'
                ? LucideIcons.checkCircle2
                : _filter == 'critical'
                    ? LucideIcons.shieldCheck
                    : LucideIcons.bellOff,
            size: 48,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isFiltered
                ? 'Tente mudar o filtro selecionado'
                : 'Puxe para baixo para atualizar',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.60),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blocking banner (H1 – visibilidade de estado)
// ─────────────────────────────────────────────────────────────────────────────

class _BlockingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.shieldOff,
                color: Color(0xFFFF6B6B), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ação necessária',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Você tem alertas críticos pendentes. Confirme a ciência para continuar.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.60),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Critical card (H5 – prevenção de erros graves)
// ─────────────────────────────────────────────────────────────────────────────

class _CriticalCard extends StatelessWidget {
  final MyAssignmentModel assignment;
  final VoidCallback? onAcknowledge;

  const _CriticalCard({required this.assignment, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keyword badge crítico
              _LevelKeyword(
                icon: LucideIcons.alertOctagon,
                label: 'URGENTE',
                color: const Color(0xFFFF6B6B),
                bg: const Color(0xFFDC2626).withValues(alpha: 0.20),
                borderColor: const Color(0xFFDC2626).withValues(alpha: 0.50),
                pulseDot: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.zap,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.notificationTitle ?? 'Alerta Crítico',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        // Remetente
                        if (assignment.authorName != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(LucideIcons.user,
                                  size: 11,
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.80)),
                              const SizedBox(width: 4),
                              Text(
                                assignment.authorName!,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.80),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Prazo
                        SlaCountdown(
                          dueAt: assignment.dueAt,
                          acknowledgedAt: assignment.acknowledgedAt,
                        ),
                        if (assignment.notificationMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            assignment.notificationMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAcknowledge,
                  icon: Icon(
                    onAcknowledge != null ? LucideIcons.check : LucideIcons.clock,
                    size: 16,
                  ),
                  label: Text(
                    onAcknowledge != null ? 'Estou ciente' : 'Prazo expirado',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onAcknowledge != null
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF374151),
                    foregroundColor: onAcknowledge != null
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                    disabledBackgroundColor: const Color(0xFF374151),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

// ─────────────────────────────────────────────────────────────────────────────
// Assignment card
// H4 – consistência (mesma cor/ícone por nível em todo o app)
// H6 – reconhecimento (keywords com ícone + label por nível)
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final MyAssignmentModel assignment;
  final VoidCallback onTap;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onDeny;

  const _AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    this.onAcknowledge,
    this.onDeny,
  });

  bool get _isQuest =>
      assignment.notificationRequiresAcknowledgment &&
      assignment.notificationLevel != AlertLevel.critical;

  IconData _contextualIcon() {
    final t = (assignment.notificationTitle ?? '').toLowerCase();
    if (t.contains('rede') || t.contains('network') || t.contains('wifi') || t.contains('internet')) return LucideIcons.wifi;
    if (t.contains('manut') || t.contains('reparo') || t.contains('conserto') || t.contains('reforma')) return LucideIcons.wrench;
    if (t.contains('seguran') || t.contains('security') || t.contains('permis')) return LucideIcons.shield;
    if (t.contains('servidor') || t.contains('server')) return LucideIcons.server;
    if (t.contains('banco de dados') || t.contains('database') || t.contains('dados')) return LucideIcons.database;
    if (t.contains('energia') || t.contains('elétric') || t.contains('eletric') || t.contains('power') || t.contains('corrente')) return LucideIcons.zap;
    if (t.contains('incêndio') || t.contains('incendio') || t.contains('fogo') || t.contains('fire')) return LucideIcons.flame;
    if (t.contains('saúde') || t.contains('saude') || t.contains('médic') || t.contains('medic') || t.contains('health') || t.contains('hospital')) return LucideIcons.heart;
    if (t.contains('treinamento') || t.contains('training') || t.contains('capacit') || t.contains('curso')) return LucideIcons.bookOpen;
    if (t.contains('reunião') || t.contains('reuniao') || t.contains('meeting') || t.contains('assembl')) return LucideIcons.users;
    if (t.contains('sistema') || t.contains('system') || t.contains('aplicat') || t.contains('software')) return LucideIcons.monitor;
    if (t.contains('email') || t.contains('e-mail') || t.contains('correio')) return LucideIcons.mail;
    if (t.contains('atualiz') || t.contains('update') || t.contains('versão') || t.contains('versao')) return LucideIcons.refreshCw;
    if (t.contains('acidente') || t.contains('accident') || t.contains('emergência') || t.contains('emergencia')) return LucideIcons.alertTriangle;
    if (t.contains('acesso') || t.contains('senha') || t.contains('login') || t.contains('chave')) return LucideIcons.key;
    if (t.contains('câmera') || t.contains('camera') || t.contains('vigilância') || t.contains('cftv')) return LucideIcons.camera;
    if (t.contains('document') || t.contains('relatorio') || t.contains('relatório') || t.contains('report')) return LucideIcons.fileText;
    if (t.contains('alarme') || t.contains('alarm')) return LucideIcons.bell;
    return assignment.notificationLevel.icon;
  }

  Widget _buildQuestHeader(AssignmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF6B4BF7).withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6B4BF7).withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.clipboardCheck, size: 12, color: Color(0xFFB9A8FF)),
          const SizedBox(width: 6),
          Text(
            'ALERTA COM RESPOSTA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB9A8FF),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _StatusBadge(status: status),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = assignment.notificationLevel;
    final status = assignment.status;
    final isDone = status == AssignmentStatus.acknowledged;
    final isUnread = status == AssignmentStatus.pending;

    final Color accentColor =
        _isQuest ? const Color(0xFF6B4BF7) : level.color;
    final Color avatarBg = accentColor.withValues(alpha: 0.25);

    final timeStr = DateFormatter.relative(assignment.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _isQuest
              ? (isDone ? const Color(0xFF0A1022) : const Color(0xFF0D1128))
              : (isDone ? const Color(0xFF0A1628) : const Color(0xFF0F1B2D)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isQuest
                ? const Color(0xFF6B4BF7).withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
            width: _isQuest ? 1.0 : 0.5,
          ),
        ),
        child: Semantics(
          button: true,
          label: _isQuest
              ? 'Alerta com resposta: ${assignment.notificationTitle ?? 'Notificação'}.'
                  '${(onAcknowledge != null || onDeny != null) ? ' Aguardando sua resposta.' : ''}'
              : 'Alerta: ${assignment.notificationTitle ?? 'Notificação'}',
          child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.05),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 3, color: accentColor),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isQuest) _buildQuestHeader(status),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(17, 14, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar com cor do nível ─────────────────────────
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: avatarBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.40),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    _isQuest
                                        ? LucideIcons.clipboardCheck
                                        : _contextualIcon(),
                                    size: 20,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              // Ponto de não lido com cor do accent
                              if (isUnread)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0D1421),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // ── Conteúdo ─────────────────────────────────────────
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tempo + remetente (H1 + H6)
                                Row(
                                  children: [
                                    Text(
                                      timeStr,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (assignment.authorName != null) ...[
                                      Text(
                                        ' · ',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      Icon(LucideIcons.user,
                                          size: 10,
                                          color: Colors.white.withValues(alpha: 0.45)),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          assignment.authorName!,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.55),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Título (H8 – minimalismo: só o essencial)
                                Text(
                                  assignment.notificationTitle ?? 'Notificação',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // SLA em tempo real
                                SlaCountdown(
                                  dueAt: assignment.dueAt,
                                  acknowledgedAt: assignment.acknowledgedAt,
                                ),

                                // Mensagem preview
                                if (assignment.notificationMessage != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    assignment.notificationMessage!,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.50),
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                if (!_isQuest) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _LevelKeyword(
                                        icon: level.icon,
                                        label: level.label.toUpperCase(),
                                        color: accentColor,
                                        bg: accentColor.withValues(alpha: 0.15),
                                        borderColor: accentColor.withValues(alpha: 0.35),
                                      ),
                                      _StatusBadge(status: status),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 10),

                                // Ações inline
                                if (_isQuest && (onAcknowledge != null || onDeny != null))
                                  _QuestActions(
                                    onConfirm: onAcknowledge,
                                    onDeny: onDeny,
                                  )
                                else
                                  Row(
                                    children: [
                                      Semantics(
                                        button: true,
                                        label: 'Ler mais',
                                        child: GestureDetector(
                                          onTap: onTap,
                                          child: ExcludeSemantics(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Ler mais',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF6B8BFF),
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                const Icon(
                                                  LucideIcons.chevronRight,
                                                  size: 13,
                                                  color: Color(0xFF6B8BFF),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (onAcknowledge != null) ...[
                                        const Spacer(),
                                        Semantics(
                                          button: true,
                                          label: 'Marcar como lido',
                                          child: GestureDetector(
                                            onTap: onAcknowledge,
                                            child: ExcludeSemantics(
                                              child: Row(
                                                children: [
                                                  const Icon(LucideIcons.check,
                                                      size: 13,
                                                      color: Color(0xFF10B981)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Marcar como lido',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF10B981),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level keyword badge (H6 – reconhecimento: ícone + label + cor do nível)
// ─────────────────────────────────────────────────────────────────────────────

class _LevelKeyword extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final Color borderColor;
  final bool pulseDot;

  const _LevelKeyword({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.borderColor,
    this.pulseDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulseDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ] else ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge — elemento visual dedicado ao status do alerta
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (status) {
      AssignmentStatus.pending => (
        const Color(0xFF94A3B8),
        LucideIcons.clock,
        'PENDENTE',
      ),
      AssignmentStatus.viewed => (
        const Color(0xFF3B82F6),
        LucideIcons.eye,
        'VISUALIZADO',
      ),
      AssignmentStatus.acknowledged => (
        const Color(0xFF10B981),
        LucideIcons.checkCircle2,
        'CONFIRMADO',
      ),
      AssignmentStatus.overdue => (
        const Color(0xFFDC2626),
        LucideIcons.alertCircle,
        'ATRASADO',
      ),
      AssignmentStatus.denied => (
        const Color(0xFF6B7280),
        LucideIcons.xCircle,
        'NEGADO',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ações do alerta com resposta — separador + dois botões full-width
// ─────────────────────────────────────────────────────────────────────────────

class _QuestActions extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onDeny;

  const _QuestActions({
    required this.onConfirm,
    required this.onDeny,
  });

  static const _purple = Color(0xFF6B4BF7);
  static const _purpleLight = Color(0xFFB9A8FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // H1: Visibilidade de estado — deixa claro que aguarda resposta
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Aguardando sua resposta',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _purpleLight.withValues(alpha: 0.80),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),

        // Botões de ação (H5: prevenção de erros — ações claramente distintas)
        Row(
          children: [
            // Recusar — ação secundária / destrutiva
            if (onDeny != null)
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Recusar este alerta',
                  child: Tooltip(
                    message: 'Indicar que não está ciente ou não concorda',
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onDeny,
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.white.withValues(alpha: 0.06),
                        highlightColor: Colors.white.withValues(alpha: 0.04),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.x,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Recusar',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (onDeny != null && onConfirm != null) const SizedBox(width: 8),

            // Confirmar — ação primária / positiva
            if (onConfirm != null)
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Confirmar ciência deste alerta',
                  child: Tooltip(
                    message: 'Confirmar que está ciente',
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onConfirm,
                        borderRadius: BorderRadius.circular(10),
                        splashColor: _purpleLight.withValues(alpha: 0.15),
                        highlightColor: _purpleLight.withValues(alpha: 0.08),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_purple, Color(0xFF8B5CF6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Confirmar',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

      ],
    );
  }
}
