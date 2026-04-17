import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ('EMPLOYEE', 'Funcionário'),
    ('SUPERVISOR', 'Supervisor'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _sectorId = widget.user?.sector.isNotEmpty == true
        ? widget.user!.sector
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um setor')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final notifier = ref.read(adminUserProvider.notifier);
    try {
      if (_isEditing) {
        await notifier.updateUser(
          userId: widget.user!.id,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
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
    final sectors = ref.watch(adminSectorProvider).sectors;
    // Guard against race condition: if sectors haven't loaded yet, the UUID stored
    // in _sectorId won't be found in the items list, causing a dropdown assertion.
    final dropdownSectorId = sectors.any((s) => s.id == _sectorId) ? _sectorId : null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxxl),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.person,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _isEditing ? 'Editar Usuário' : 'Novo Usuário',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 32),
                NotifInput(
                  controller: _nameCtrl,
                  label: 'Nome',
                  hint: 'Nome completo',
                  isRequired: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                NotifInput(
                  controller: _emailCtrl,
                  label: 'E-mail',
                  hint: 'email@empresa.com',
                  isRequired: true,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'E-mail inválido'
                      : null,
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Senha *',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 6 caracteres',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _DropdownField(
                  label: 'Cargo',
                  value: _role,
                  items: _roles
                      .map((r) => DropdownMenuItem(
                            value: r.$1,
                            child: Text(r.$2),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v ?? _role),
                ),
                const SizedBox(height: AppSpacing.md),
                _DropdownField(
                  label: 'Setor',
                  value: dropdownSectorId,
                  hint: 'Selecione um setor',
                  items: sectors
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _sectorId = v),
                ),
                const SizedBox(height: AppSpacing.xl),
                NotifButton(
                  label: _isEditing ? 'Salvar' : 'Criar Usuário',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  const _DropdownField({
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
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }
}
