import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../../login/providers/auth_provider.dart';
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

  Color get _accentColor {
    if (_level == AlertLevel.critical) return const Color(0xFFDC2626);
    if (_level == AlertLevel.low) return AppColors.accent;
    return _level.color;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(sectorProvider.notifier).loadSectors(),
    );
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

    final user = ref.read(authProvider);
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    final requiresAck = _level == AlertLevel.critical ? true : _requiresAcknowledgment;
    final authorId = user?.id ?? '';

    final bool ok;
    if (_sendToAll) {
      final sectorIds = ref.read(sectorProvider).sectors.map((s) => s.id).toList();
      ok = await ref.read(alertProvider.notifier).createNotificationForAllSectors(
            title: title,
            message: message,
            level: _level,
            slaMinutes: _slaMinutes,
            requiresAcknowledgment: requiresAck,
            authorId: authorId,
            sectorIds: sectorIds,
          );
    } else {
      ok = await ref.read(alertProvider.notifier).createNotification(
            title: title,
            message: message,
            level: _level,
            slaMinutes: _slaMinutes,
            requiresAcknowledgment: requiresAck,
            authorId: authorId,
            sectorId: _selectedSector!.id,
          );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context, ok);
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isCritical = _level == AlertLevel.critical;
    final sectorState = ref.watch(sectorProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF1A2340),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.megaphone,
                      color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Novo Alerta',
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
              ],
            ),
          ),

          Divider(
              height: 20,
              color: Colors.white.withValues(alpha: 0.10)),

          // Body
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
                      dark: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o título';
                        if (v.trim().length < 5) return 'Mínimo 5 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NotifInput(
                      controller: _messageCtrl,
                      label: 'Mensagem',
                      hint: 'Descreva o alerta com detalhes...',
                      maxLines: 3,
                      isRequired: true,
                      dark: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe a mensagem';
                        if (v.trim().length < 10) return 'Mínimo 10 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectorHeader(),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSectorSelector(sectorState),
                    const SizedBox(height: AppSpacing.lg),
                    UrgencySelector(
                      selected: _level,
                      onChanged: _onLevelChanged,
                      dark: true,
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
                      color: _accentColor,
                      icon: isCritical
                          ? LucideIcons.alertTriangle
                          : LucideIcons.send,
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
        Icon(LucideIcons.users,
            size: 18, color: Colors.white.withValues(alpha: 0.55)),
        const SizedBox(width: 8),
        Text(
          'Destinatários',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const Spacer(),
        Text(
          'Todos',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.50),
          ),
        ),
        const SizedBox(width: 4),
        Switch.adaptive(
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.accent,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Icon(Icons.all_inclusive,
              size: 16, color: AppColors.accentLight),
          const SizedBox(width: 8),
          Text(
            'Enviando para todos os setores',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ]),
      );
    }

    if (sectorState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2),
        ),
      );
    }

    if (sectorState.sectors.isEmpty) {
      return Text(
        sectorState.errorMessage ?? 'Nenhum setor disponível.',
        style: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 13,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: sectorState.sectors.map((sector) {
        final selected = _selectedSector?.id == sector.id;
        return GestureDetector(
          onTap: () => setState(
              () => _selectedSector = selected ? null : sector),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              sector.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.accentLight
                    : Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(LucideIcons.timer,
              size: 18, color: Colors.white.withValues(alpha: 0.55)),
          const SizedBox(width: 8),
          Text(
            'Prazo (SLA)',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _slaOptions.map((minutes) {
            final selected = _slaMinutes == minutes;
            final label =
                minutes < 60 ? '${minutes}min' : '${minutes ~/ 60}h';
            return GestureDetector(
              onTap: () => setState(() => _slaMinutes = minutes),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? _accentColor.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? _accentColor.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? _accentColor
                        : Colors.white.withValues(alpha: 0.60),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExtraConfigs(bool isCritical) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCritical
            ? const Color(0xFFDC2626).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFDC2626).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Exigir confirmação de ciência',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        subtitle: isCritical
            ? Text(
                'Obrigatório para alertas críticos',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFFFF6B6B),
                ),
              )
            : null,
        value: isCritical ? true : _requiresAcknowledgment,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.accent,
        onChanged: isCritical
            ? null
            : (v) => setState(() => _requiresAcknowledgment = v),
      ),
    );
  }
}