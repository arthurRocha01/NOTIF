import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definindo cores locais para evitar erro de import caso o AppColors falhe
class AppColorsLocal {
  static const Color navy = Color(0xFF0F172A);
  static const Color textDark = Color(0xFF1E293B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF8FAFC);
}

class NotifInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const NotifInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorsLocal.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsLocal.border),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: AppColorsLocal.textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}