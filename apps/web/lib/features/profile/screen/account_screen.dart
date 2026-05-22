import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/widgets/profile_widgets.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1421),
        elevation: 0,
        title: Text(
          'Dados da conta',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Identificação ─────────────────────────────────────────────
          ProfileSectionHeader(label: 'IDENTIFICAÇÃO'),
          const SizedBox(height: 10),
          ProfileInfoCard(children: [
            ProfileInfoRow(
              icon: LucideIcons.mail,
              label: 'Email da conta',
              value: user?.email ?? '—',
            ),
            ProfileInfoRow(
              icon: LucideIcons.user,
              label: 'Nome',
              value: user?.name ?? '—',
            ),
            ProfileInfoRow(
              icon: LucideIcons.building2,
              label: 'Setor',
              value: user?.sectorName ?? '—',
            ),
            ProfileInfoRow(
              icon: LucideIcons.briefcase,
              label: 'Cargo',
              value: user?.roleLabel ?? '—',
              isLast: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Segurança ─────────────────────────────────────────────────
          ProfileSectionHeader(label: 'SEGURANÇA'),
          const SizedBox(height: 10),
          ProfileInfoCard(children: [
            ProfileActionRow(
              icon: LucideIcons.lock,
              label: 'Trocar senha',
              subtitle: 'Altere sua senha de acesso',
              onTap: () => _showChangePasswordModal(context),
            ),
            ProfileActionRow(
              icon: LucideIcons.keyRound,
              label: 'Recuperar senha',
              subtitle: 'Enviar link de redefinição por e-mail',
              onTap: () => _showRecoverPasswordModal(context),
              isLast: true,
            ),
          ]),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showRecoverPasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RecoverPasswordSheet(),
    );
  }
}

// ── Modal de trocar senha ──────────────────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (newPassword.length < 6) {
      setState(() => _error = 'A nova senha deve ter no mínimo 6 caracteres.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final user = ref.read(authProvider);
      await ApiClient.patch('/users/${user!.id}', {
        'currentPassword': _currentCtrl.text.trim(),
        'password': newPassword,
      });
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trocar senha',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              key: const Key('currentPassword'),
              label: 'Senha atual',
              controller: _currentCtrl,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              key: const Key('newPassword'),
              label: 'Nova senha',
              controller: _newCtrl,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              key: const Key('confirmPassword'),
              label: 'Confirmar nova senha',
              controller: _confirmCtrl,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF6B6B),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modal de recuperar senha ───────────────────────────────────────────────────

class _RecoverPasswordSheet extends ConsumerStatefulWidget {
  const _RecoverPasswordSheet();

  @override
  ConsumerState<_RecoverPasswordSheet> createState() =>
      _RecoverPasswordSheetState();
}

class _RecoverPasswordSheetState
    extends ConsumerState<_RecoverPasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _isLoading = false;
  bool _success = false;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (newPassword.length < 6) {
      setState(() => _error = 'A nova senha deve ter no mínimo 6 caracteres.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final user = ref.read(authProvider);
      await ApiClient.patch('/users/${user!.id}', {'password': newPassword});
      if (mounted) setState(() => _success = true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _success
            ? _buildSuccess(context)
            : _buildForm(context, user?.email ?? ''),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.checkCircle,
            size: 48, color: Color(0xFF4ADE80)),
        const SizedBox(height: 16),
        Text(
          'Senha alterada com sucesso!',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Fechar'),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, String email) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recuperar senha',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Defina uma nova senha para:',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _PasswordField(
          key: const Key('recoverNewPassword'),
          label: 'Nova senha',
          controller: _newCtrl,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          key: const Key('recoverConfirmPassword'),
          label: 'Confirmar nova senha',
          controller: _confirmCtrl,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: GoogleFonts.inter(
              color: const Color(0xFFFF6B6B),
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enviar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Campo de senha ─────────────────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _PasswordField(
      {super.key, required this.label, required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle:
            GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        isDense: true,
      ),
    );
  }
}