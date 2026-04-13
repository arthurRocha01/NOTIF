import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';

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
          _SectionHeader(label: 'IDENTIFICAÇÃO'),
          const SizedBox(height: 8),
          _InfoCard(children: [
            _InfoRow(
              icon: LucideIcons.mail,
              label: 'Email da conta',
              value: user?.email ?? '—',
            ),
            _InfoRow(
              icon: LucideIcons.user,
              label: 'Nome',
              value: user?.name ?? '—',
            ),
            _InfoRow(
              icon: LucideIcons.building2,
              label: 'Setor',
              value: user?.sector ?? '—',
            ),
            _InfoRow(
              icon: LucideIcons.briefcase,
              label: 'Cargo',
              value: user?.roleLabel ?? '—',
              isLast: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Segurança ─────────────────────────────────────────────────
          _SectionHeader(label: 'SEGURANÇA'),
          const SizedBox(height: 8),
          _InfoCard(children: [
            _ActionRow(
              icon: LucideIcons.lock,
              label: 'Trocar senha',
              subtitle: 'Altere sua senha de acesso',
              onTap: () => _showChangePasswordModal(context),
            ),
            const Divider(height: 1, indent: 56),
            _ActionRow(
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

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // Desabilitado até PATCH /users/{id}/password estar disponível
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirmar'),
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

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.bold,
            letterSpacing: 1.2, color: Colors.black45));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          title: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          subtitle: Text(value,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B))),
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }
}
