import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/constants/app_spacing.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/shared/widgets/notif_button.dart';
import 'package:notif_app/shared/widgets/notif_input.dart';

class CreateEditSectorModal extends ConsumerStatefulWidget {
  final SectorModel? sector;

  const CreateEditSectorModal({super.key, this.sector});

  static Future<bool?> show(BuildContext context, {SectorModel? sector}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateEditSectorModal(sector: sector),
    );
  }

  @override
  ConsumerState<CreateEditSectorModal> createState() =>
      _CreateEditSectorModalState();
}

class _CreateEditSectorModalState
    extends ConsumerState<CreateEditSectorModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  bool _isLoading = false;

  bool get _isEditing => widget.sector != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.sector?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(adminSectorProvider.notifier);
    try {
      if (_isEditing) {
        await notifier.updateSector(
          sectorId: widget.sector!.id,
          name: _nameCtrl.text.trim(),
        );
      } else {
        await notifier.createSector(name: _nameCtrl.text.trim());
      }

      final error = ref.read(adminSectorProvider).errorMessage;
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error,
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        setState(() => _isLoading = false);
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.building2,
                      color: AppColors.accentLight, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _isEditing ? 'Editar Setor' : 'Novo Setor',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.60)),
                  ),
                ),
              ]),

              Divider(
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.10)),

              NotifInput(
                controller: _nameCtrl,
                label: 'Nome do setor',
                hint: 'Ex: TI, RH, Produção',
                isRequired: true,
                dark: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              NotifButton(
                label: _isEditing ? 'Salvar' : 'Criar Setor',
                onPressed: _submit,
                isLoading: _isLoading,
                color: AppColors.accent,
                icon: _isEditing ? LucideIcons.check : LucideIcons.plus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}