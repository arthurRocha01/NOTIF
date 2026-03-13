import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../widgets/urgency_selector.dart';

import '../../../shared/widgets/notif_input.dart';
import '../../../shared/widgets/notif_button.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class CreateAlertModal extends ConsumerStatefulWidget {
  const CreateAlertModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateAlertModal(),
    );
  }

  @override
  ConsumerState<CreateAlertModal> createState() => _CreateAlertModalState();
}

class _CreateAlertModalState extends ConsumerState<CreateAlertModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  AlertLevel _level = AlertLevel.normal;
  bool _requiresConfirmation = false;
  bool _isLoading = false;

  final List<String> _selectedSectors = [];

  final List<String> _availableSectors = [
    'TI',
    'Operações',
    'RH',
    'Financeiro',
    'Jurídico',
    'Comercial',
    'Marketing',
    'Logística',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ok = await ref.read(alertProvider.notifier).createAlert(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          level: _level,
          requiresConfirmation: _requiresConfirmation,
          sectors: _selectedSectors,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context, ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
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
            NotifInput(
              controller: _titleCtrl,
              label: "Título do alerta",
              hint: "Digite o título do alerta",
              isRequired: true,
              validator: (v) =>
                  v == null || v.isEmpty ? "Campo obrigatório" : null,
            ),
            const SizedBox(height: AppSpacing.md),
            NotifInput(
              controller: _descCtrl,
              label: "Descrição",
              hint: "Descreva o alerta",
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            UrgencySelector(
              selected: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            NotifButton(
              label: "Enviar alerta",
              onPressed: _submit,
              isLoading: _isLoading,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}