import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/alert_status.dart';
import '../widgets/urgency_selector.dart';

class CreateAlertScreen extends StatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  _AlertType _type = _AlertType.alert;
  AlertLevel _level = AlertLevel.normal;
  bool _sendToAll = false;
  bool _requiresConfirmation = false;
  final List<String> _selectedSectors = [];

  static const _sectors = ['TI', 'Operações', 'RH', 'Financeiro', 'Logística', 'Comercial'];

  bool get _isCritical => _level == AlertLevel.critical;

  Color get _themeColor =>
      _isCritical ? AppColors.critical : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl,
                ),
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFormCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDestinatariosCard(),
                  const SizedBox(height: AppSpacing.lg),
                  if (_type == _AlertType.alert) ...[
                    UrgencySelector(
                      selected: _level,
                      onChanged: (v) => setState(() {
                        _level = v;
                        if (v == AlertLevel.critical) _requiresConfirmation = true;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildConfirmationCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _buildSendButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar Alerta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Notifique os setores em tempo real.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isCritical ? Icons.warning_amber_rounded : Icons.campaign_outlined,
              color: _themeColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _AlertType.values.map((t) {
          final selected = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t.icon,
                      size: 16,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Título', required: true),
          const SizedBox(height: AppSpacing.sm),
          _buildTextField(
            hint: _type == _AlertType.alert
                ? 'Ex: Manutenção do Servidor Principal'
                : 'Ex: Reunião Geral — Quinta-feira',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFieldLabel('Descrição'),
          const SizedBox(height: AppSpacing.sm),
          _buildTextField(
            hint: 'Descreva os detalhes do '
                '${_type == _AlertType.alert ? 'alerta' : 'comunicado'}...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinatariosCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Destinatários',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Text(
                'Todos',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Switch.adaptive(
                value: _sendToAll,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.accent,
                onChanged: (v) => setState(() {
                  _sendToAll = v;
                  if (v) _selectedSectors.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _sendToAll
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.all_inclusive, size: 16, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text(
                    'Enviando para todos os setores',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sectors.map((s) {
                final sel = _selectedSectors.contains(s);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selectedSectors.remove(s) : _selectedSectors.add(s)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent.withValues(alpha: 0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.accent : AppColors.border,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _isCritical
            ? AppColors.critical.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCritical
              ? AppColors.critical.withValues(alpha: 0.25)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 20,
            color: _isCritical ? AppColors.critical : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exigir confirmação de leitura',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_isCritical)
                  const Text(
                    'Obrigatório para alertas críticos',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.critical,
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isCritical ? true : _requiresConfirmation,
            activeThumbColor: Colors.white,
            activeTrackColor: _isCritical ? AppColors.critical : AppColors.accent,
            onChanged: _isCritical
                ? null
                : (v) => setState(() => _requiresConfirmation = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(
          _isCritical ? Icons.warning_amber_rounded : Icons.send_rounded,
          size: 18,
        ),
        label: Text(
          _type == _AlertType.alert
              ? (_isCritical ? 'ENVIAR ALERTA CRÍTICO' : 'Enviar Alerta')
              : 'Publicar Comunicado',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: AppColors.critical, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

enum _AlertType {
  alert,
  announcement;

  String get label => this == _AlertType.alert ? 'Alerta' : 'Comunicado';

  IconData get icon => this == _AlertType.alert
      ? Icons.warning_amber_rounded
      : Icons.campaign_outlined;
}
