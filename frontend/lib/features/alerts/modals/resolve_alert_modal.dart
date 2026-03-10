import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_model.dart';
import '../providers/alert_provider.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class ResolveAlertModal extends StatefulWidget {
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
  State<ResolveAlertModal> createState() => _ResolveAlertModalState();
}

class _ResolveAlertModalState extends State<ResolveAlertModal> {
  final _formKey = GlobalKey<FormState>();
  final _msgCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ok = await context.read<AlertProvider>().resolveAlert(
          id: widget.alert.id,
          resolutionMessage: _msgCtrl.text.trim(),
        );

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.resolvedLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: AppColors.resolved, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resolver Alerta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.alert.title,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Instruções finais *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            NotifInput(
              hint:
                  'Descreva as ações tomadas e o status atual...\nEx: Serviço normalizado. Sistemas restabelecidos.',
              controller: _msgCtrl,
              maxLines: 4,
              validator: (v) => v == null || v.trim().length < 10
                  ? 'Mínimo 10 caracteres'
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: NotifButton(
                label: 'Confirmar Resolução',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.check_circle_outline,
                color: AppColors.resolved,
              ),
            ),
          ],
        ),
      ),
    );
  }
}