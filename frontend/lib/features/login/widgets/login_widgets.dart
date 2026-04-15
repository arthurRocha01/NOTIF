import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';

// ── Header ────────────────────────────────────────────────────────────────────

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Círculo decorativo sutil
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Logo centralizado
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        fontSize: 30,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        LucideIcons.bellRing,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Text(
                      'TIF',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 2,
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

// ── Input field ───────────────────────────────────────────────────────────────

class CustomInputField extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscure = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isFocused => _focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? AppColors.accent : AppColors.border,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword && _obscure,
        keyboardType: widget.keyboardType,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.inter(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              widget.icon,
              color: _isFocused ? AppColors.accent : AppColors.textTertiary,
              size: 19,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppColors.textTertiary,
                    size: 19,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }
}

// ── Botão principal ───────────────────────────────────────────────────────────

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
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
