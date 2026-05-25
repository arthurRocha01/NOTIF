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
        backgroundColor: const Color(0xFF1A2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.trash2, color: Color(0xFFFF6B6B), size: 20),
            const SizedBox(width: 8),
            Text(
              'Excluir setor',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Deseja excluir "$name"?\nEsta ação não pode ser desfeita.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.60)),
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
              foregroundColor: const Color(0xFFFF6B6B),
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
                color: AppColors.accent,
                backgroundColor: const Color(0xFF1A2340),
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
                    onDelete: () => _confirmDelete(
                        state.sectors[i].id, state.sectors[i].name),
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
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.building2,
                  color: AppColors.success, size: 20,
                  semanticLabel: 'Setor'),
            ),
            title: Text(
              sector.name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                children: [
                  Icon(LucideIcons.users,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.40)),
                  const SizedBox(width: 4),
                  Text(
                    '$userCount ${userCount == 1 ? 'usuário' : 'usuários'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar setor',
                  icon: Icon(LucideIcons.pencil,
                      size: 17,
                      color: Colors.white.withValues(alpha: 0.50)),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Excluir setor',
                  icon: const Icon(LucideIcons.trash2,
                      size: 17, color: Color(0xFFFF6B6B)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        );
  }
}