import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../login/providers/auth_provider.dart';
import '../../sectors/providers/sector_provider.dart';
import '../../../shared/widgets/notif_input.dart';
import '../../../shared/widgets/notif_button.dart';

class CreateMessageModal extends ConsumerStatefulWidget {
  const CreateMessageModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateMessageModal(),
    );
  }

  @override
  ConsumerState<CreateMessageModal> createState() => _CreateMessageModalState();
}

class _CreateMessageModalState extends ConsumerState<CreateMessageModal> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos', style: GoogleFonts.inter()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authProvider);
    final sectorIds = ref.read(sectorProvider).sectors.map((s) => s.id).toList();
    final ok = await ref.read(alertProvider.notifier).createNotificationForAllSectors(
          title: _titleCtrl.text.trim(),
          message: _contentCtrl.text.trim(),
          level: AlertLevel.low,
          slaMinutes: 60,
          requiresAcknowledgment: false,
          authorId: user?.id ?? '',
          sectorIds: sectorIds,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(LucideIcons.megaphone, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Novo Comunicado',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            NotifInput(
              controller: _titleCtrl,
              label: 'Título',
              hint: 'Ex: Manutenção do Ar-condicionado',
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),
            NotifInput(
              controller: _contentCtrl,
              label: 'Mensagem',
              hint: 'Escreva os detalhes do aviso aqui...',
              maxLines: 5,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            NotifButton(
              label: 'Enviar Comunicado',
              onPressed: _submit,
              isLoading: _isLoading,
              color: AppColors.primary,
              icon: LucideIcons.send,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
