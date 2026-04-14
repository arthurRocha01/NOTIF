import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/widgets/profile_widgets.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          'Dados da conta',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Identificação ─────────────────────────────────────────────
          ProfileSectionHeader(label: 'IDENTIFICAÇÃO'),
          const SizedBox(height: 8),
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
              value: user?.sector ?? '—',
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
          const SizedBox(height: 8),
          ProfileInfoCard(children: [
            ProfileActionRow(
              icon: LucideIcons.lock,
              label: 'Trocar senha',
              subtitle: 'Altere sua senha de acesso',
              onTap: () => _showChangePasswordModal(context),
            ),
            const Divider(height: 1, indent: 56),
            ProfileActionRow(
              icon: LucideIcons.keyRound,
              label: 'Recuperar senha',
              subtitle: 'Enviar link de redefinição por e-mail',
              onTap: () => _showRecoverPasswordModal(context, user?.email ?? ''),
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

  void _showRecoverPasswordModal(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecoverPasswordSheet(email: email),
    );
  }
}

// ── Modal de trocar senha ──────────────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
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

    setState(() { _error = null; _isLoading = true; });

    try {
      final user = ref.read(authProvider);
      await ApiClient.patch('/users/${user!.id}', {'password': newPassword});
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trocar senha',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _PasswordField(key: const Key('currentPassword'), label: 'Senha atual', controller: _currentCtrl),
            const SizedBox(height: 12),
            _PasswordField(key: const Key('newPassword'), label: 'Nova senha', controller: _newCtrl),
            const SizedBox(height: 12),
            _PasswordField(key: const Key('confirmPassword'), label: 'Confirmar nova senha', controller: _confirmCtrl),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: GoogleFonts.inter(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

// ── Modal de recuperar senha ───────────────────────────────────────────────

class _RecoverPasswordSheet extends StatelessWidget {
  final String email;
  const _RecoverPasswordSheet({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.mailCheck, size: 48, color: Color(0xFF0F172A)),
          const SizedBox(height: 16),
          Text('Recuperar senha',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Um link de redefinição será enviado para:',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  // Desabilitado até POST /auth/password-reset estar disponível
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Funcionalidade disponível em breve.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget campo de senha ──────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _PasswordField({super.key, required this.label, required this.controller});

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
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        isDense: true,
      ),
    );
  }
}

