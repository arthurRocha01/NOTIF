import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
// IMPORTS ATUALIZADOS
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';

import 'package:notif_app/features/login/widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  PrimaryButton(
                    text: 'Entrar',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
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