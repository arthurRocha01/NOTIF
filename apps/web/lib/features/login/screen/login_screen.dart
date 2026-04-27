import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/widgets/login_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha o email e a senha.');
      return;
    }

    setState(() => _isLoading = true);

    final success =
        await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      final error =
          ref.read(authProvider.notifier).errorMessage ?? 'Falha no login.';
      _showError(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header editorial ────────────────────────────────────
                    const AuthHeader(),

                    // ── Formulário ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credenciais',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            controller: _emailController,
                            icon: LucideIcons.user,
                            hint: 'Email corporativo',
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 10),

                          CustomInputField(
                            controller: _passwordController,
                            icon: LucideIcons.lock,
                            hint: 'Senha',
                            isPassword: true,
                          ),

                          const SizedBox(height: 32),

                          if (_isLoading)
                            const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 1.5,
                                ),
                              ),
                            )
                          else
                            PrimaryButton(
                                text: 'Entrar', onPressed: _handleLogin),

                          const SizedBox(height: 24),

                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Precisa de ajuda? ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Contate o suporte',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Rodapé fixo ─────────────────────────────────────────────────
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

// ── Rodapé ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'v1.0',
            style: GoogleFonts.firaCode(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          Row(
            children: [
              const Icon(LucideIcons.shieldCheck,
                  size: 11, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Sistema seguro',
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
