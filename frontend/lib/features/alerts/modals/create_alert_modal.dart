import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../widgets/urgency_selector.dart';
import '../../../shared/widgets/notif_input.dart';
import '../../../shared/widgets/notif_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../sectors/providers/sector_provider.dart';
import '../../sectors/models/sector_model.dart';

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
  final _messageCtrl = TextEditingController();

  AlertLevel _level = AlertLevel.low;
  bool _requiresAcknowledgment = false;
  bool _isLoading = false;
  bool _sendToAll = false;
  SectorModel? _selectedSector;
  int _slaMinutes = 60;

  static const _slaOptions = [15, 30, 60, 120, 240];

  Color get _currentThemeColor {
    if (_level == AlertLevel.critical) return Colors.redAccent;
    if (_level == AlertLevel.low) return const Color.fromARGB(255, 88, 123, 249);
    return AppColors.primary;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onLevelChanged(AlertLevel level) {
    setState(() {
      _level = level;
      _slaMinutes = level == AlertLevel.critical ? 30 : 60;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_sendToAll && _selectedSector == null) {
      _showError('Selecione um setor ou envie para todos');
      return;
    }

    setState(() => _isLoading = true);

    final ok = await ref.read(alertProvider.notifier).createNotification(
          title: _titleCtrl.text.trim(),
          message: _messageCtrl.text.trim(),
          level: _level,
          slaMinutes: _slaMinutes,
          requiresAcknowledgment:
              _level == AlertLevel.critical ? true : _requiresAcknowledgment,
          sectorId: _sendToAll ? null : _selectedSector?.id,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context, ok);
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isCritical = _level == AlertLevel.critical;
    final sectorState = ref.watch(sectorProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _currentThemeColor.withValues(alpha: 0.1),
                  child: Icon(Icons.campaign, color: _currentThemeColor),
                ),
                const SizedBox(width: 12),
                const Text('Novo Alerta Administrativo',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 32),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl + bottom),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotifInput(
                      controller: _titleCtrl,
                      label: 'Título',
                      hint: 'Ex: Manutenção do Servidor',
                      isRequired: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NotifInput(
                      controller: _messageCtrl,
                      label: 'Mensagem',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectorHeader(),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSectorSelector(sectorState),
                    const SizedBox(height: AppSpacing.lg),
                    UrgencySelector(
                      selected: _level,
                      onChanged: _onLevelChanged,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSlaSelector(),
                    const SizedBox(height: AppSpacing.md),
                    _buildExtraConfigs(isCritical),
                    const SizedBox(height: AppSpacing.xl),
                    NotifButton(
                      label: isCritical
                          ? 'ENVIAR ALERTA CRÍTICO'
                          : 'Enviar Alerta',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      color: _currentThemeColor,
                      icon: isCritical ? Icons.report_problem : Icons.send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorHeader() {
    return Row(
      children: [
        const Icon(Icons.groups_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        const Text('Destinatários',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        const Text('Todos', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Switch.adaptive(
          activeThumbColor: AppColors.primary,
          value: _sendToAll,
          onChanged: (v) => setState(() {
            _sendToAll = v;
            if (v) _selectedSector = null;
          }),
        ),
      ],
    );
  }

  Widget _buildSectorSelector(SectorState sectorState) {
    if (_sendToAll) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Icon(Icons.all_inclusive, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Text('Enviando para todos os setores'),
        ]),
      );
    }

    if (sectorState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (sectorState.sectors.isEmpty) {
      return Text(
        sectorState.errorMessage ?? 'Nenhum setor disponível.',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: sectorState.sectors.map((sector) {
        final selected = _selectedSector?.id == sector.id;
        return FilterChip(
          selected: selected,
          label: Text(sector.name),
          onSelected: (v) =>
              setState(() => _selectedSector = v ? sector : null),
        );
      }).toList(),
    );
  }

  Widget _buildSlaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text('Prazo (SLA)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _slaOptions.map((minutes) {
            final selected = _slaMinutes == minutes;
            final label = minutes < 60
                ? '${minutes}min'
                : '${minutes ~/ 60}h';
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setState(() => _slaMinutes = minutes),
              selectedColor:
                  _currentThemeColor.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: selected ? _currentThemeColor : Colors.grey.shade700,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExtraConfigs(bool isCritical) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical
            ? Colors.red.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCritical
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.transparent),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Exigir confirmação de ciência',
            style: TextStyle(fontSize: 14)),
        subtitle: isCritical
            ? const Text('Obrigatório para alertas críticos',
                style: TextStyle(fontSize: 11, color: Colors.red))
            : null,
        value: isCritical ? true : _requiresAcknowledgment,
        onChanged: isCritical
            ? null
            : (v) => setState(() => _requiresAcknowledgment = v),
      ),
    );
  }
}
