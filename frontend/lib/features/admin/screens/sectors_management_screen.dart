import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/admin/modals/create_edit_sector_modal.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
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

  Future<void> _confirmDelete(String sectorId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir setor'),
        content: Text('Deseja excluir "$name"? Esta ação não pode ser desfeita.'),
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

    ref.listen(adminSectorProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Setores'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await CreateEditSectorModal.show(context);
          if (ok == true && mounted) {
            ref.read(adminSectorProvider.notifier).loadSectors();
          }
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
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
                    padding: const EdgeInsets.all(16),
                    itemCount: state.sectors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final sector = state.sectors[i];
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
                            child: Icon(Icons.business,
                                color: AppColors.primary, size: 18),
                          ),
                          title: Text(sector.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                onPressed: () async {
                                  final ok =
                                      await CreateEditSectorModal.show(context,
                                          sector: sector);
                                  if (ok == true && mounted) {
                                    ref
                                        .read(adminSectorProvider.notifier)
                                        .loadSectors();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(sector.id, sector.name),
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
