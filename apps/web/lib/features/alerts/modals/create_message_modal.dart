import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Preencha todos os campos',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    setState(() => _isLoading = true);

    final sectorIds =
        ref.read(sectorProvider).sectors.map((s) => s.id).toList();
    final ok = await ref
        .read(alertProvider.notifier)
        .createNotificationForAllSectors(
          title: _titleCtrl.text.trim(),
          message: _contentCtrl.text.trim(),
          level: AlertLevel.low,
          slaMinutes: 60,
          requiresAcknowledgment: false,
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2340),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.megaphone,
                    color: AppColors.accentLight, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Novo Comunicado',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Fechar',
                child: GestureDetector(
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
                        semanticLabel: 'Fechar',
                        color: Colors.white.withValues(alpha: 0.60)),
                  ),
                ),
              ),
            ]),

            Divider(height: 28, color: Colors.white.withValues(alpha: 0.10)),

            NotifInput(
              controller: _titleCtrl,
              label: 'Título',
              hint: 'Ex: Manutenção do Ar-condicionado',
              isRequired: true,
              dark: true,
            ),
            const SizedBox(height: AppSpacing.md),
            NotifInput(
              controller: _contentCtrl,
              label: 'Mensagem',
              hint: 'Escreva os detalhes do aviso aqui...',
              maxLines: 5,
              isRequired: true,
              dark: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            NotifButton(
              label: 'Enviar Comunicado',
              onPressed: _submit,
              isLoading: _isLoading,
              color: AppColors.accent,
              icon: LucideIcons.send,
            ),
          ],
        ),
      ),
    );
  }
}