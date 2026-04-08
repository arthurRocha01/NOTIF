import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notif_app/core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Altura reduzida para 25% para um visual muito mais equilibrado
    final double headerHeight = MediaQuery.of(context).size.height * 0.25;

    return SizedBox(
      width: double.infinity,
      height: headerHeight,
      child: Stack(
        children: [
          // Fundo com gradiente suave e moderno
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
            ),
          ),
          // Círculo decorativo futurista (Efeito de lente)
          Positioned(
            top: -50,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.3),
                    AppColors.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo minimalista
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.accent, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'NOTIF',
                      style: GoogleFonts.plusJakartaSans( // Fonte mais moderna que Montserrat
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnDark,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  width: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const CustomInputField({
    super.key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.transparent, // Fundo transparente para estilo clean
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? AppColors.accent : AppColors.border,
            width: _isFocused ? 2 : 1,
          ),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16, 
          color: AppColors.textPrimary, 
          fontWeight: FontWeight.w600
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: Icon(
            widget.icon, 
            color: _isFocused ? AppColors.accent : AppColors.textSecondary, 
            size: 20
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, 
              fontWeight: FontWeight.w700, 
              color: AppColors.textOnDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}