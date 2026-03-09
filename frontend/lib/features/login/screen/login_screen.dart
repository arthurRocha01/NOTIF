import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/home_screen.dart';
import 'package:notif_app/features/login/widgets/app_colors.dart';
import 'package:notif_app/features/login/widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: Column(
        children: [
          // 1. O Cabeçalho modularizado
          const AuthHeader(),

          // 2. O conteúdo principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildTitleSection(),
                  const SizedBox(height: 40),

                  // 3. Campos de input modularizados
                  const CustomInputField(
                    icon: LucideIcons.userCircle,
                    hint: 'Ex: joao@empresa.com',
                  ),
                  const SizedBox(height: 15),
                  
                  const CustomInputField(
                    icon: LucideIcons.lock,
                    hint: 'Senha:',
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),

                  // 4. Botão modularizado
                  PrimaryButton(
                    text: 'Entrar',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  _buildHelpLinks(),
                  const SizedBox(height: 60),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos privados menores para organizar os textos estáticos
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Portal de Segurança e\nCompliance.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Acesso restrito',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Insira sua matrícula ou Email corporativo',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inputBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Precisa de Ajuda? ', style: GoogleFonts.inter(fontSize: 12)),
        GestureDetector(
          onTap: () {
            // Adicionar lógica de suporte
          },
          child: Text(
            'Contate o Suporte',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Versão 1.0', style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey)),
        Text('Sistema Seguro', style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}