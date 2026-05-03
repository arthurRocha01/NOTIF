import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/admin/modals/create_edit_sector_modal.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/shared/widgets/empty_state.dart';
import 'package:notif_app/shared/widgets/loading_indicator.dart';

class SectorsManagementScreen extends ConsumerStatefulWidget {
  const SectorsManagementScreen({super.key});

  @override
  ConsumerState<SectorsManagementScreen> createState() =>
      _SectorsManagementScreenState();
}

class _SectorsManagementScreenState
    extends ConsumerState<SectorsManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminSectorProvider.notifier).loadSectors());
  }

  int _userCountForSector(String sectorId) {
    return ref
        .watch(adminUserProvider)
        .users
        .where((u) => u.sectorId == sectorId)
        .length;
  }

  Future<void> _confirmDelete(String sectorId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            const Text('Excluir setor'),
          ],
        ),
        content: Text(
            'Deseja excluir "$name"?\n\nTodos os usuários e notificações vinculados a este setor também serão removidos. Esta ação não pode ser desfeita.'),
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
      await ref.read(adminSectorProvider.notifier).deleteSector(sectorId);
      final error = ref.read(adminSectorProvider).errorMessage;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSectorProvider);

    return state.isLoading
        ? const LoadingIndicator()
        : state.sectors.isEmpty
            ? const EmptyState(
                icon: Icons.business_outlined,
                title: 'Sem setores',
                message: 'Nenhum setor cadastrado',
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(adminSectorProvider.notifier).loadSectors(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.sectors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _SectorTile(
                    sector: state.sectors[i],
                    userCount: _userCountForSector(state.sectors[i].id),
                    onEdit: () async {
                      await CreateEditSectorModal.show(context,
                          sector: state.sectors[i]);
                    },
                    onDelete: () =>
                        _confirmDelete(state.sectors[i].id, state.sectors[i].name),
                  ),
                ),
              );
  }
}

// ── _SectorTile ───────────────────────────────────────────────────────────────

class _SectorTile extends StatelessWidget {
  final SectorModel sector;
  final int userCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectorTile({
    required this.sector,
    required this.userCount,
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
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.building2,
              color: AppColors.success, size: 20),
        ),
        title: Text(
          sector.name,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              const Icon(LucideIcons.users,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '$userCount ${userCount == 1 ? 'usuário' : 'usuários'}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.pencil,
                  size: 17, color: AppColors.textSecondary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2,
                  size: 17, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
