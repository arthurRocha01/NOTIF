import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/shared/widgets/notif_button.dart';
import 'package:notif_app/shared/widgets/notif_input.dart';
import '../models/alert_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class ResolveAlertModal extends ConsumerStatefulWidget {
  final AlertModel alert;
  const ResolveAlertModal({super.key, required this.alert});

  static Future<bool?> show(BuildContext context, AlertModel alert) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResolveAlertModal(alert: alert),
    );
  }

  @override
  ConsumerState<ResolveAlertModal> createState() => _ResolveAlertModalState();
}

class _ResolveAlertModalState extends ConsumerState<ResolveAlertModal> {
  final _formKey = GlobalKey<FormState>();
  final _msgCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  // --- MÉTODO LIMPO E SEM ERROS ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (!mounted) return;

    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isCritical = widget.alert.level == AlertLevel.critical;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl + bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isCritical
                    ? Colors.red.withValues(alpha: 0.08)
                    : AppColors.resolvedLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    isCritical ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
                    color: isCritical ? Colors.red : AppColors.resolved,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alert.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCritical ? "Alerta CRÍTICO" : "Alerta normal",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isCritical ? Colors.red : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mensagem de resolução',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            NotifInput(
              controller: _msgCtrl,
              hint: 'Explique o que foi feito...',
              maxLines: 4,
              isRequired: true,
              validator: (v) => v == null || v.trim().length < 10
                  ? 'Mínimo 10 caracteres'
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: NotifButton(
                label: 'Finalizar alerta',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: LucideIcons.check,
                color: isCritical ? Colors.red : AppColors.resolved,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}