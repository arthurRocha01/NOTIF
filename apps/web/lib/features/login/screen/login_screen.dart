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
    final success = await ref.read(authProvider.notifier).login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      final error = ref.read(authProvider.notifier).errorMessage ?? 'Falha no login.';
      _showError(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1421),
                    Color(0xFF1A2340),
                    Color(0xFF1E1B4B),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Círculo decorativo — topo direito
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.22),
              ),
            ),
          ),

          // Círculo decorativo — baixo esquerdo
          Positioned(
            bottom: -110,
            left: -90,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B4BF7).withValues(alpha: 0.18),
              ),
            ),
          ),

          // Círculo decorativo — meio direito
          Positioned(
            top: size.height * 0.40,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.10),
              ),
            ),
          ),

          // Conteúdo principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.09),

                  // Logo
                  const _LogoBrand(),

                  const SizedBox(height: 44),

                  // Card glass
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Entre na sua conta',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Insira suas credenciais para continuar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.50),
                              ),
                            ),
                            const SizedBox(height: 28),

                            GlassInputField(
                              controller: _emailController,
                              icon: LucideIcons.mail,
                              hint: 'Email corporativo',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            GlassInputField(
                              controller: _passwordController,
                              icon: LucideIcons.lock,
                              hint: 'Senha',
                              isPassword: true,
                            ),
                            const SizedBox(height: 28),

                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 2.5,
                                ),
                              )
                            else
                              GradientButton(
                                text: 'Entrar',
                                onPressed: _handleLogin,
                              ),

                            const SizedBox(height: 24),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Precisa de ajuda? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Contate o Suporte',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.accentLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _LogoBrand extends StatelessWidget {
  const _LogoBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'N',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 38,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                LucideIcons.bellRing,
                color: AppColors.accentLight,
                size: 30,
              ),
            ),
            Text(
              'TIF',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'SISTEMA DE NOTIFICAÇÕES',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.40),
            letterSpacing: 2.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}