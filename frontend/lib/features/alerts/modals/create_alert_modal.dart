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

  AlertLevel _level = AlertLevel.low;
  bool _requiresConfirmation = false;
  bool _isLoading = false;
  bool _sendToAll = false;
  final List<String> _selectedSectors = [];

  List<String> get _availableSectors => [
        'TI', 'Operações', 'RH', 'Financeiro', 'Logística', 'Comercial',
      ];

  // Cor dinâmica baseada no nível de urgência
  Color get _currentThemeColor {
    if (_level == AlertLevel.critical) return Colors.redAccent;
    if (_level == AlertLevel.low) return const Color.fromARGB(255, 88, 123, 249);
    return AppColors.primary;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final sectorsToSend = _sendToAll ? _availableSectors : _selectedSectors;
    if (sectorsToSend.isEmpty) {
      _showError('Selecione ao menos um setor');
      return;
    }

    setState(() => _isLoading = true);
    
    // Se for crítico, forçamos a confirmação no envio
    final finalConfirmation = _level == AlertLevel.critical ? true : _requiresConfirmation;

// Dentro do _submit do CreateAlertModal
final ok = await ref.read(alertProvider.notifier).createAlert(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      level: _level,
      requiresConfirmation: finalConfirmation, // Certifique-se que este parâmetro existe no Notifier
      sectors: sectorsToSend,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context, ok);
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isCritical = _level == AlertLevel.critical;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Handle" de arrastar e cabeçalho colorido
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4, width: 40,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _currentThemeColor.withOpacity(0.1),
                  child: Icon(Icons.campaign, color: _currentThemeColor),
                ),
                const SizedBox(width: 12),
                const Text("Novo Alerta Administrativo", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const Divider(height: 32),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl + bottom),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotifInput(
                      controller: _titleCtrl,
                      label: "Título",
                      hint: "Ex: Manutenção do Servidor",
                      isRequired: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    NotifInput(
                      controller: _descCtrl,
                      label: "Descrição detalhada",
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Seleção de Setores com UI limpa
                    _buildSectorHeader(),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSectorChips(),

                    const SizedBox(height: AppSpacing.lg),
                    
                    UrgencySelector(
                      selected: _level,
                      onChanged: (v) => setState(() => _level = v),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),

                    // Card de Configurações Extras
                    _buildExtraConfigs(isCritical),

                    const SizedBox(height: AppSpacing.xl),
                    
                    NotifButton(
                      label: isCritical ? "ENVIAR ALERTA CRÍTICO" : "Enviar Alerta",
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
        const Text("Destinatários", style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        const Text("Todos", style: TextStyle(fontSize: 12, color: Colors.grey)),
        Switch.adaptive(
          activeColor: AppColors.primary,
          value: _sendToAll,
          onChanged: (v) => setState(() {
            _sendToAll = v;
            if (v) _selectedSectors.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildSectorChips() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _sendToAll 
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [Icon(Icons.all_inclusive, size: 16, color: Colors.blue), SizedBox(width: 8), Text("Enviando para todos os setores")]))
        : Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _availableSectors.map((s) {
              final sel = _selectedSectors.contains(s);
              return FilterChip(
                selected: sel,
                label: Text(s),
                onSelected: (v) => setState(() => v ? _selectedSectors.add(s) : _selectedSectors.remove(s)),
              );
            }).toList(),
          ),
    );
  }

  Widget _buildExtraConfigs(bool isCritical) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCritical ? Colors.red.withOpacity(0.2) : Colors.transparent),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Exigir confirmação de leitura", style: TextStyle(fontSize: 14)),
            subtitle: isCritical ? const Text("Obrigatório para alertas críticos", style: TextStyle(fontSize: 11, color: Colors.red)) : null,
            // Se for crítico, fica ligado e o usuário não pode desativar
            value: isCritical ? true : _requiresConfirmation,
            onChanged: isCritical ? null : (v) => setState(() => _requiresConfirmation = v),
          ),
        ],
      ),
    );
  }
}