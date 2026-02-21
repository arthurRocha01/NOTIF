import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Cores baseadas na imagem
  final Color darkNavy = const Color(0xFF0F172A);
  final Color lightBlueBg = const Color(0xFFF8FAFC);
  final Color inputBorder = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueBg,
      body: Column(
        children: [
          // Header escuro com a Logo
          Container(
            width: double.infinity,
            height: 100,
            color: darkNavy,
            child: SafeArea(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'N',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(LucideIcons.bell, color: Colors.white, size: 24),
                    ),
                    Text(
                      'TIF',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo do Portal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Portal de Segurança e\nCompliance.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: darkNavy,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Acesso restrito',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Insira sua matrícula ou Email corporativo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo E-mail
                  _buildInputField(
                    icon: LucideIcons.userCircle,
                    hint: 'Ex: joao@empresa.com',
                  ),
                  const SizedBox(height: 15),

                  // Campo Senha
                  _buildInputField(
                    icon: LucideIcons.lock,
                    hint: 'Senha:',
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),

                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Navegação para a Home sem o 'const'
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: Text(
                        'Entrar',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Links de Ajuda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Precisa de Ajuda? ', style: GoogleFonts.inter(fontSize: 12)),
                      GestureDetector(
                        onTap: () {},
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
                  ),
                  const SizedBox(height: 60),

                  // Rodapé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Versão 1.0', style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey)),
                      Text('Sistema Seguro', style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required IconData icon, required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: inputBorder.withOpacity(0.5)),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: darkNavy, size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}