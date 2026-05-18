import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  final VoidCallback onNavigateToUsers;
  final VoidCallback onNavigateToSectors;

  const AdminDashboardPage({
    super.key,
    required this.onNavigateToUsers,
    required this.onNavigateToSectors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final userState = ref.watch(adminUserProvider);
    final sectorState = ref.watch(adminSectorProvider);

    final users = userState.users;
    final total = users.length;
    final supervisors =
        users.where((u) => u.role == UserRole.supervisor).length;
    final employees = users.where((u) => u.role == UserRole.employee).length;
    final sectors = sectorState.sectors.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISÃO GERAL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatsGrid(total, supervisors, employees, sectors),
                const SizedBox(height: 28),
                Text(
                  'GERENCIAMENTO',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickAccessCard(
                  key: const Key('quick-users'),
                  icon: LucideIcons.users,
                  title: 'Usuários',
                  subtitle: 'Criar, editar e remover usuários do sistema',
                  count: total,
                  countLabel: 'cadastrados',
                  color: AppColors.accent,
                  onTap: onNavigateToUsers,
                ),
                const SizedBox(height: 10),
                _QuickAccessCard(
                  key: const Key('quick-sectors'),
                  icon: LucideIcons.building2,
                  title: 'Setores',
                  subtitle: 'Gerenciar unidades e departamentos',
                  count: sectors,
                  countLabel: 'ativos',
                  color: AppColors.success,
                  onTap: onNavigateToSectors,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    final now = DateTime.now();
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2340), Color(0xFF4A3F8F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'Administrador',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Olá, ${user?.name.split(' ').first ?? 'Admin'}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.calendar,
                  color: Colors.white54, size: 13),
              const SizedBox(width: 5),
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
      int total, int supervisors, int employees, int sectors) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          key: const Key('stat-total'),
          label: 'Usuários',
          value: total.toString(),
          icon: LucideIcons.users,
          color: AppColors.accent,
        ),
        _StatCard(
          key: const Key('stat-supervisors'),
          label: 'Supervisores',
          value: supervisors.toString(),
          icon: LucideIcons.userCog,
          color: AppColors.warning,
        ),
        _StatCard(
          key: const Key('stat-employees'),
          label: 'Colaboradores',
          value: employees.toString(),
          icon: LucideIcons.user,
          color: AppColors.info,
        ),
        _StatCard(
          key: const Key('stat-sectors'),
          label: 'Setores',
          value: sectors.toString(),
          icon: LucideIcons.building2,
          color: AppColors.success,
        ),
      ],
    );
  }
}

// ── _StatCard ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── _QuickAccessCard ──────────────────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final String countLabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.countLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  countLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
