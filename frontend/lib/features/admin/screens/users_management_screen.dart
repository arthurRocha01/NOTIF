import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/modals/create_edit_user_modal.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminUserProvider.notifier).loadUsers();
      ref.read(sectorProvider.notifier).loadSectors();
    });
  }

  Future<void> _confirmDelete(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir usuário'),
        content:
            Text('Deseja excluir "$name"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.red))),
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

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.supervisor => AppColors.accent,
      UserRole.admin => AppColors.critical,
      _ => Colors.grey,
    };
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.supervisor => 'Supervisor',
      UserRole.admin => 'Admin',
      _ => 'Funcionário',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await CreateEditUserModal.show(context);
          if (ok == true && mounted) {
            ref.read(adminUserProvider.notifier).loadUsers();
          }
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: state.isLoading
          ? const LoadingIndicator()
          : state.users.isEmpty
              ? const EmptyState(message: 'Nenhum usuário cadastrado')
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminUserProvider.notifier).loadUsers(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final user = state.users[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withOpacity(0.1),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(user.email,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _roleColor(user.role)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _roleLabel(user.role),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _roleColor(user.role),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                onPressed: () async {
                                  final ok =
                                      await CreateEditUserModal.show(context,
                                          user: user);
                                  if (ok == true && mounted) {
                                    ref
                                        .read(adminUserProvider.notifier)
                                        .loadUsers();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(user.id, user.name),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
