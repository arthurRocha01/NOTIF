import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/modals/create_edit_user_modal.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/shared/widgets/empty_state.dart';
import 'package:notif_app/shared/widgets/loading_indicator.dart';

class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends ConsumerState<UsersManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter; // null = Todos

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminUserProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> users) {
    return users.where((u) {
      final matchesSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _roleFilter == null || u.role == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _confirmDelete(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            const Text('Excluir usuário'),
          ],
        ),
        content: Text('Deseja excluir "$name"?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminUserProvider.notifier).deleteUser(userId);
      final error = ref.read(adminUserProvider).errorMessage;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Color _roleColor(UserRole role) => switch (role) {
        UserRole.supervisor => AppColors.warning,
        UserRole.admin => AppColors.critical,
        _ => AppColors.textSecondary,
      };

  String _roleLabel(UserRole role) => switch (role) {
        UserRole.supervisor => 'Supervisor',
        UserRole.admin => 'Admin',
        _ => 'Colaborador',
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUserProvider);
    final filtered = _filtered(state.users);

    return Column(
      children: [
        // ── Barra de busca + filtros ────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou e-mail…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textTertiary),
                  prefixIcon: const Icon(LucideIcons.search,
                      size: 18, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x,
                              size: 16, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Role filter chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RoleChip(
                      label: 'Todos',
                      selected: _roleFilter == null,
                      onTap: () => setState(() => _roleFilter = null),
                    ),
                    const SizedBox(width: 6),
                    _RoleChip(
                      label: 'Colaborador',
                      selected: _roleFilter == UserRole.employee,
                      color: AppColors.textSecondary,
                      onTap: () => setState(() => _roleFilter == UserRole.employee
                          ? _roleFilter = null
                          : _roleFilter = UserRole.employee),
                    ),
                    const SizedBox(width: 6),
                    _RoleChip(
                      label: 'Supervisor',
                      selected: _roleFilter == UserRole.supervisor,
                      color: AppColors.warning,
                      onTap: () => setState(() => _roleFilter == UserRole.supervisor
                          ? _roleFilter = null
                          : _roleFilter = UserRole.supervisor),
                    ),
                    const SizedBox(width: 6),
                    _RoleChip(
                      label: 'Admin',
                      selected: _roleFilter == UserRole.admin,
                      color: AppColors.critical,
                      onTap: () => setState(() => _roleFilter == UserRole.admin
                          ? _roleFilter = null
                          : _roleFilter = UserRole.admin),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Lista ────────────────────────────────────────────────────────────
        Expanded(
          child: state.isLoading
              ? const LoadingIndicator()
              : filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.people_outline,
                      title: _searchQuery.isNotEmpty || _roleFilter != null
                          ? 'Nenhum resultado'
                          : 'Sem usuários',
                      message: _searchQuery.isNotEmpty || _roleFilter != null
                          ? 'Tente outros filtros'
                          : 'Nenhum usuário cadastrado',
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(adminUserProvider.notifier).loadUsers(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _UserTile(
                          user: filtered[i],
                          roleLabel: _roleLabel(filtered[i].role),
                          roleColor: _roleColor(filtered[i].role),
                          onEdit: () async {
                            final ok = await CreateEditUserModal.show(
                                context,
                                user: filtered[i]);
                            if (ok == true && mounted) {
                              ref
                                  .read(adminUserProvider.notifier)
                                  .loadUsers();
                            }
                          },
                          onDelete: () =>
                              _confirmDelete(filtered[i].id, filtered[i].name),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

// ── _RoleChip ─────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── _UserTile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final UserModel user;
  final String roleLabel;
  final Color roleColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.roleLabel,
    required this.roleColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: GoogleFonts.inter(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(user.email,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
            if (user.sector.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(LucideIcons.building2,
                      size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text(
                    user.sector,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                roleLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: roleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.pencil,
                  size: 17, color: AppColors.textSecondary),
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2,
                  size: 17, color: AppColors.error),
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}
