import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/constants/app_spacing.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/shared/widgets/notif_button.dart';
import 'package:notif_app/shared/widgets/notif_input.dart';

class CreateEditUserModal extends ConsumerStatefulWidget {
  final UserModel? user;

  const CreateEditUserModal({super.key, this.user});

  static Future<bool?> show(BuildContext context, {UserModel? user}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateEditUserModal(user: user),
    );
  }

  @override
  ConsumerState<CreateEditUserModal> createState() =>
      _CreateEditUserModalState();
}

class _CreateEditUserModalState extends ConsumerState<CreateEditUserModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  String _role = 'EMPLOYEE';
  String? _sectorId;
  bool _isLoading = false;

  bool get _isEditing => widget.user != null;

  static const _roles = [
    ('EMPLOYEE', 'Colaborador'),
    ('SUPERVISOR', 'Supervisor'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _sectorId = widget.user?.sectorId.isNotEmpty == true
        ? widget.user!.sectorId
        : null;
    if (_isEditing) {
      _role = switch (widget.user!.role) {
        UserRole.supervisor => 'SUPERVISOR',
        _ => 'EMPLOYEE',
      };
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Selecione um setor',
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

    final notifier = ref.read(adminUserProvider.notifier);
    try {
      if (_isEditing) {
        await notifier.updateUser(
          userId: widget.user!.id,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          role: _role,
          sectorId: _sectorId,
        );
      } else {
        await notifier.createUser(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _role,
          sectorId: _sectorId!,
        );
      }

      final error = ref.read(adminUserProvider).errorMessage;
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error,
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        setState(() => _isLoading = false);
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final sectors = ref.watch(adminSectorProvider).sectors;
    final dropdownSectorId =
        sectors.any((s) => s.id == _sectorId) ? _sectorId : null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Header
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.userPlus,
                        color: AppColors.accentLight, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _isEditing ? 'Editar Usuário' : 'Novo Usuário',
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

                Divider(
                    height: 28,
                    color: Colors.white.withValues(alpha: 0.10)),

                NotifInput(
                  controller: _nameCtrl,
                  label: 'Nome',
                  hint: 'Nome completo',
                  isRequired: true,
                  dark: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                NotifInput(
                  controller: _emailCtrl,
                  label: 'E-mail',
                  hint: 'email@empresa.com',
                  isRequired: true,
                  dark: true,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'E-mail inválido'
                      : null,
                ),

                if (!_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DarkField(
                    label: 'Senha *',
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: _darkInputDecoration(
                          hint: 'Mínimo 6 caracteres'),
                      validator: (v) => v == null || v.length < 6
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                _DarkDropdown(
                  label: 'Cargo',
                  value: _role,
                  items: _roles
                      .map((r) => DropdownMenuItem(
                            value: r.$1,
                            child: Text(r.$2,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v ?? _role),
                ),
                const SizedBox(height: AppSpacing.md),
                _DarkDropdown(
                  label: 'Setor',
                  value: dropdownSectorId,
                  hint: 'Selecione um setor',
                  items: sectors
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _sectorId = v),
                ),
                const SizedBox(height: AppSpacing.xl),
                NotifButton(
                  label: _isEditing ? 'Salvar' : 'Criar Usuário',
                  onPressed: _submit,
                  isLoading: _isLoading,
                  color: AppColors.accent,
                  icon: _isEditing ? LucideIcons.check : LucideIcons.userPlus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers de estilo escuro ──────────────────────────────────────────────────

InputDecoration _darkInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.55), fontSize: 14),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.07),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: Colors.white.withValues(alpha: 0.14)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: Colors.white.withValues(alpha: 0.14)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
    ),
    errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
  );
}

class _DarkField extends StatelessWidget {
  final String label;
  final Widget child;
  const _DarkField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DarkDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  const _DarkDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            )),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: hint != null
              ? Text(hint!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.35),
                  ))
              : null,
          dropdownColor: const Color(0xFF1A2340),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.50)),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          items: items,
          onChanged: onChanged,
          decoration: _darkInputDecoration(),
        ),
      ],
    );
  }
}