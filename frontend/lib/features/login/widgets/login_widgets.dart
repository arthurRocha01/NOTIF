import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_colors.dart';  

// --- COMPONENTE: Cabeçalho com Logo ---
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: AppColors.darkNavy,
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
    );
  }
}

// --- COMPONENTE: Campo de Texto Customizado ---
class CustomInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  // Dica: Futuramente você pode adicionar um TextEditingController aqui

  const CustomInputField({
    super.key,
    required this.icon,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.5)),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.darkNavy, size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// --- COMPONENTE: Botão Principal ---
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}