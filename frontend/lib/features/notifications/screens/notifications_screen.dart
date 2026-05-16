import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
            content: Text(error),
            backgroundColor: Colors.red.shade700,
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: () => ref.read(alertProvider.notifier).loadAssignments(),
        color: const Color(0xFF4A6CF7),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(displayName, fullName, pendingCount),
            ),
            if (criticalBlocking != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _CriticalCard(
                    assignment: criticalBlocking,
                    onAcknowledge: () => ref
                        .read(alertProvider.notifier)
                        .acknowledge(assignmentId: criticalBlocking.id),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildFilterChips(unreadCount),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(children: [
                  Text('CAIXA DE ENTRADA',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5)),
                  const Spacer(),
                  Text(
                      '${filtered.length} mensagem${filtered.length != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF94A3B8))),
                ]),
              ),
            ),
            if (state.isLoadingAssignments && assignments.isEmpty)
              const SliverFillRemaining(
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4A6CF7))),
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
                          builder: (_) =>
                              AlertDetailsScreen(assignment: filtered[i]),
                        ),
                      ),
                      onAcknowledge: filtered[i].canAcknowledge
                          ? () => ref
                              .read(alertProvider.notifier)
                              .acknowledge(assignmentId: filtered[i].id)
                          : null,
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, String fullName, int pendingCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2340), Color(0xFF4A3F8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8))),
              Text(firstName,
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              if (pendingCount > 0) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                      '$pendingCount alerta${pendingCount != 1 ? 's' : ''} pendente${pendingCount != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9))),
                ]),
              ],
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(_initials(fullName),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white)),
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
            padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A2340) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1A2340)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(f.$2,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B))),
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
          const Icon(LucideIcons.checkCircle2,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text('Nenhuma notificação',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('Puxe para baixo para atualizar',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

// ── Critical blocking card ────────────────────────────────────────────────────

class _CriticalCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onAcknowledge;

  const _CriticalCard(
      {required this.assignment, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDC2626)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFFDC2626), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('URGENTE',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDC2626),
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
                  color: Color(0xFFDC2626), shape: BoxShape.circle),
              child:
                  const Icon(LucideIcons.zap, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.notificationTitle ?? 'Alerta Crítico',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A))),
                  if (assignment.notificationMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(assignment.notificationMessage!,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: const Color(0xFF64748B)),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
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
      Color(0xFF7C3AED), // violet
      Color(0xFF0D9488), // teal
      Color(0xFF2563EB), // blue
      Color(0xFF059669), // emerald
      Color(0xFFDC2626), // red
      Color(0xFFD97706), // amber
      Color(0xFF9333EA), // purple
      Color(0xFF0891B2), // cyan
    ];
    final hash = assignment.id.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = assignment.status == AssignmentStatus.pending;
    final timeStr = DateFormatter.relative(assignment.createdAt);
    final levelLabel = assignment.notificationLevel.label.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
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
                          color: const Color(0xFF4A6CF7),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$levelLabel · $timeStr',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 3),
                      Text(assignment.notificationTitle ?? 'Notificação',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A))),
                      if (assignment.notificationMessage != null) ...[
                        const SizedBox(height: 3),
                        Text(assignment.notificationMessage!,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
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
                                    color: const Color(0xFF4A6CF7))),
                            const SizedBox(width: 2),
                            const Icon(LucideIcons.chevronRight,
                                size: 13, color: Color(0xFF4A6CF7)),
                          ]),
                        ),
                        if (onAcknowledge != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: onAcknowledge,
                            child: Row(children: [
                              const Icon(LucideIcons.check,
                                  size: 13, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text('Marcar como lido',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF10B981))),
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
    );
  }
}
