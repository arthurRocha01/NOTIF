import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_status.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_status_chip.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class CreateAlertModal extends StatefulWidget {
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
  State<CreateAlertModal> createState() => _CreateAlertModalState();
}

class _CreateAlertModalState extends State<CreateAlertModal> {
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

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ok = await context.read<AlertProvider>().createAlert(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          level: _level,
          requiresConfirmation: _requiresConfirmation,
          sectors: _selectedSectors,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Novo Alerta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            NotifInput(
              hint: 'Título do alerta',
              controller: _titleCtrl,
              prefixIcon: const Icon(Icons.title, size: 18),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            NotifInput(
              hint: 'Descrição detalhada do alerta...',
              controller: _descCtrl,
              maxLines: 3,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            UrgencySelector(
              selected: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Setores',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _availableSectors.map((sector) {
                final selected = _selectedSectors.contains(sector);
                return FilterChip(
                  label: Text(sector, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedSectors.add(sector);
                      } else {
                        _selectedSectors.remove(sector);
                      }
                    });
                  },
                  selectedColor: AppColors.normalLight,
                  checkmarkColor: AppColors.normal,
                  side: BorderSide(
                      color: selected ? AppColors.normal : AppColors.border),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              value: _requiresConfirmation,
              onChanged: (v) => setState(() => _requiresConfirmation = v),
              title: const Text('Exige confirmação de leitura',
                  style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: NotifButton(
                label: 'Enviar Alerta',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
                color: _level == AlertLevel.critical
                    ? AppColors.critical
                    : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}