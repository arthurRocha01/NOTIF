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
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha o email e a senha.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .login(email, password);

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
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AuthHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  CustomInputField(
                    controller: _userController,
                    icon: LucideIcons.userCircle,
                    hint: 'Matrícula ou Email corporativo',
                  ),
                  const SizedBox(height: 15),
                  CustomInputField(
                    controller: _passwordController,
                    icon: LucideIcons.lock,
                    hint: 'Senha',
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : PrimaryButton(
                          text: 'Entrar',
                          onPressed: _handleLogin,
                        ),
                  const SizedBox(height: 30),
                  _buildHelpLinks(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Portal de Segurança e\nCompliance.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Acesso restrito a colaboradores',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHelpLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Precisa de Ajuda? ', style: GoogleFonts.inter(fontSize: 12)),
        Text(
          'Contate o Suporte',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
