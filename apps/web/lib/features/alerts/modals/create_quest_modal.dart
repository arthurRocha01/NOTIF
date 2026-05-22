import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/alert_provider.dart';
import '../models/alert_status.dart';
import '../widgets/urgency_selector.dart';
import '../../../shared/widgets/notif_input.dart';
import '../../../shared/widgets/notif_button.dart';
import '../../../core/constants/app_spacing.dart';
import '../../sectors/providers/sector_provider.dart';
import '../../sectors/models/sector_model.dart';

const _questLevels = [AlertLevel.low, AlertLevel.medium, AlertLevel.high];
const _questAccent = Color(0xFF6B4BF7);

class CreateQuestModal extends ConsumerStatefulWidget {
  const CreateQuestModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateQuestModal(),
    );
  }

  @override
  ConsumerState<CreateQuestModal> createState() => _CreateQuestModalState();
}

class _CreateQuestModalState extends ConsumerState<CreateQuestModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  AlertLevel _level = AlertLevel.low;
  bool _isLoading = false;
  bool _sendToAll = false;
  SectorModel? _selectedSector;
  int _slaMinutes = 60;

  static const _slaOptions = [15, 30, 60, 120, 240];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sectorProvider.notifier).loadSectors());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onLevelChanged(AlertLevel level) {
    setState(() => _level = level);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_sendToAll && _selectedSector == null) {
      _showError('Selecione um setor ou envie para todos');
      return;
    }

    setState(() => _isLoading = true);

    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    final bool ok;
    if (_sendToAll) {
      final sectorIds =
          ref.read(sectorProvider).sectors.map((s) => s.id).toList();
      ok = await ref.read(alertProvider.notifier).createNotificationForAllSectors(
            title: title,
            message: message,
            level: _level,
            slaMinutes: _slaMinutes,
            requiresAcknowledgment: true,
            sectorIds: sectorIds,
          );
    } else {
      ok = await ref.read(alertProvider.notifier).createNotification(
            title: title,
            message: message,
            level: _level,
            slaMinutes: _slaMinutes,
            requiresAcknowledgment: true,
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
                    color: _questAccent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.clipboardCheck,
                      color: _questAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerta com Resposta',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Requer confirmação dos destinatários',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
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
              ],
            ),
          ),

          Divider(height: 20, color: Colors.white.withValues(alpha: 0.10)),

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
                    _buildInfoBanner(),
                    const SizedBox(height: AppSpacing.md),
                    NotifInput(
                      controller: _titleCtrl,
                      label: 'Título',
                      hint: 'Ex: Confirme a presença na reunião',
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
                      hint: 'Descreva a quest com detalhes...',
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
                      levels: _questLevels,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSlaSelector(),
                    const SizedBox(height: AppSpacing.md),
                    _buildResponsePreview(),
                    const SizedBox(height: AppSpacing.xl),
                    NotifButton(
                      label: 'Enviar Alerta',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      color: _questAccent,
                      icon: LucideIcons.send,
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _questAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _questAccent.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.info, size: 14, color: _questAccent),
              const SizedBox(width: 8),
              Text(
                'Como funciona',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _questAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Os destinatários receberão uma notificação e deverão responder confirmando ou recusando. Diferente de alertas comuns, este tipo exige uma resposta explícita.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.5,
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
          activeTrackColor: _questAccent,
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
          color: _questAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _questAccent.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.all_inclusive, size: 16, color: _questAccent),
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
              color: _questAccent, strokeWidth: 2),
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
        return Semantics(
          button: true,
          selected: selected,
          label: sector.name,
          child: GestureDetector(
            onTap: () =>
                setState(() => _selectedSector = selected ? null : sector),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? _questAccent.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? _questAccent.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: ExcludeSemantics(
                child: Text(
                  sector.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFFB9A8FF)
                        : Colors.white.withValues(alpha: 0.70),
                  ),
                ),
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
            return Semantics(
              button: true,
              selected: selected,
              label: 'SLA: $label',
              child: GestureDetector(
                onTap: () => setState(() => _slaMinutes = minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? _questAccent.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? _questAccent.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? _questAccent
                            : Colors.white.withValues(alpha: 0.60),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResponsePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.layoutList,
                size: 14, color: Colors.white.withValues(alpha: 0.45)),
            const SizedBox(width: 6),
            Text(
              'O destinatário verá estas opções',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.50),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ResponseChip(
                  icon: LucideIcons.check,
                  label: 'Confirmar',
                  description: 'Ciente',
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResponseChip(
                  icon: LucideIcons.x,
                  label: 'Recusar',
                  description: 'Não confirma',
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final Color color;

  const _ResponseChip({
    required this.icon,
    required this.label,
    required this.color,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
