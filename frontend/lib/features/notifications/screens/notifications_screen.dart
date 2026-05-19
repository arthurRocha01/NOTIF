import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/utils/date_formatter.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alert_details_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'unread';

  List<AssignmentModel> _applyFilter(List<AssignmentModel> all) {
    switch (_filter) {
      case 'all':
        return all;
      case 'pending':
        return all
            .where((a) =>
                a.status == AssignmentStatus.pending ||
                a.status == AssignmentStatus.viewed)
            .toList();
      case 'overdue':
        return all.where((a) => a.status == AssignmentStatus.overdue).toList();
      case 'confirmed':
        return all
            .where((a) => a.status == AssignmentStatus.acknowledged)
            .toList();
      case 'unread':
      default:
        return all.where((a) => a.status == AssignmentStatus.pending).toList();
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia,';
    if (h < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertProvider);
    final user = ref.watch(authProvider);

    ref.listen<String?>(
      alertProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error,
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
    );

    final assignments = state.assignments;
    final pendingCount = assignments
        .where((a) => a.status != AssignmentStatus.acknowledged)
        .length;
    final unreadCount =
        assignments.where((a) => a.status == AssignmentStatus.pending).length;
    final criticalBlocking =
        assignments.where((a) => a.isBlocking).firstOrNull;
    final filtered = _applyFilter(assignments);
    final nameParts = (user?.name ?? 'Usuário').trim().split(' ');
    final displayName = nameParts.length >= 2
        ? '${nameParts[0]} ${nameParts[1]}'
        : nameParts[0];
    final fullName = user?.name ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: Stack(
        children: [
          // Círculos decorativos
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

          // Conteúdo
          RefreshIndicator(
            onRefresh: () =>
                ref.read(alertProvider.notifier).loadAssignments(),
            color: AppColors.accent,
            backgroundColor: const Color(0xFF1A2340),
            child: CustomScrollView(
              slivers: [
                // ── Cabeçalho ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(
                      displayName, fullName, pendingCount),
                ),

                // ── Card crítico bloqueante ──────────────────────────────────
                if (criticalBlocking != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _CriticalCard(
                        assignment: criticalBlocking,
                        onAcknowledge: () => ref
                            .read(alertProvider.notifier)
                            .acknowledge(
                                assignmentId: criticalBlocking.id),
                      ),
                    ),
                  ),

                // ── Filter chips ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildFilterChips(unreadCount),
                  ),
                ),

                // ── Label CAIXA DE ENTRADA ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('CAIXA DE ENTRADA',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.40),
                              letterSpacing: 0.8)),
                      const Spacer(),
                      Text(
                          '${filtered.length} mensagem${filtered.length != 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.35))),
                    ]),
                  ),
                ),

                // ── Lista ────────────────────────────────────────────────────
                if (state.isLoadingAssignments && assignments.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2.5)),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(child: _buildEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _AssignmentCard(
                          key: ValueKey(filtered[i].id),
                          assignment: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlertDetailsScreen(
                                  assignment: filtered[i]),
                            ),
                          ),
                          onAcknowledge: filtered[i].canAcknowledge
                              ? () => ref
                                  .read(alertProvider.notifier)
                                  .acknowledge(
                                      assignmentId: filtered[i].id)
                              : null,
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      String firstName, String fullName, int pendingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.50))),
              Text(firstName,
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              if (pendingCount > 0) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                      '$pendingCount alerta${pendingCount != 1 ? 's' : ''} pendente${pendingCount != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color:
                              Colors.white.withValues(alpha: 0.70))),
                ]),
              ],
            ],
          ),
        ),
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
                    color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Text(_initials(fullName),
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildFilterChips(int unreadCount) {
    final filters = [
      ('unread', 'Não lidos${unreadCount > 0 ? ' ($unreadCount)' : ''}'),
      ('all', 'Todos'),
      ('pending', 'Pendente'),
      ('overdue', 'Atrasado'),
      ('confirmed', 'Confirmado'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final f = filters[i];
          final isSelected = _filter == f.$1;
          return Padding(
            padding:
                EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.40)
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(f.$2,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.white
                                .withValues(alpha: 0.45))),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle2,
              size: 48, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Text('Nenhuma notificação',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.70))),
          const SizedBox(height: 4),
          Text('Puxe para baixo para atualizar',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

// ── Critical card ─────────────────────────────────────────────────────────────

class _CriticalCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onAcknowledge;

  const _CriticalCard(
      {required this.assignment, required this.onAcknowledge});

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
                color: const Color(0xFFDC2626).withValues(alpha: 0.40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFDC2626)
                            .withValues(alpha: 0.50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('URGENTE',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF6B6B),
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle),
                  child: const Icon(LucideIcons.zap,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          assignment.notificationTitle ??
                              'Alerta Crítico',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      if (assignment.notificationMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(assignment.notificationMessage!,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white
                                    .withValues(alpha: 0.65)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAcknowledge,
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: Text('Estou ciente',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

// ── Assignment card ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;
  final VoidCallback? onAcknowledge;

  const _AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    this.onAcknowledge,
  });

  String _avatarInitials() {
    final title = assignment.notificationTitle ?? '';
    final parts = title.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '!';
  }

  Color _avatarColor() {
    const palette = [
      Color(0xFF7C3AED),
      Color(0xFF0D9488),
      Color(0xFF2563EB),
      Color(0xFF059669),
      Color(0xFFDC2626),
      Color(0xFFD97706),
      Color(0xFF9333EA),
      Color(0xFF0891B2),
    ];
    final hash = assignment.id.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = assignment.status == AssignmentStatus.pending;
    final timeStr = DateFormatter.relative(assignment.createdAt);
    final levelLabel = assignment.notificationLevel.label.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _avatarColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(_avatarInitials(),
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white)),
                          ),
                        ),
                        if (isUnread)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF0D1421),
                                    width: 1.5),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('$levelLabel · $timeStr',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white
                                        .withValues(alpha: 0.40),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3)),
                            const SizedBox(height: 3),
                            Text(
                                assignment.notificationTitle ??
                                    'Notificação',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            if (assignment.notificationMessage !=
                                null) ...[
                              const SizedBox(height: 3),
                              Text(
                                  assignment.notificationMessage!,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(alpha: 0.55),
                                      height: 1.4),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              GestureDetector(
                                onTap: onTap,
                                child: Row(children: [
                                  Text('Ler mais',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentLight)),
                                  const SizedBox(width: 2),
                                  const Icon(LucideIcons.chevronRight,
                                      size: 13,
                                      color: AppColors.accentLight),
                                ]),
                              ),
                              if (onAcknowledge != null) ...[
                                const Spacer(),
                                GestureDetector(
                                  onTap: onAcknowledge,
                                  child: Row(children: [
                                    const Icon(LucideIcons.check,
                                        size: 13,
                                        color: Color(0xFF10B981)),
                                    const SizedBox(width: 4),
                                    Text('Marcar como lido',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                const Color(0xFF10B981))),
                                  ]),
                                ),
                              ],
                            ]),
                          ],
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
    );
  }
}
