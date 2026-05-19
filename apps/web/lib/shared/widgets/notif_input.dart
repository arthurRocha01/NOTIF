import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';

class NotifInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final bool isRequired;
  final String? Function(String?)? validator;
  final bool dark;

  const NotifInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.isRequired = false,
    this.validator,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            isRequired ? '$label *' : label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: dark
                  ? Colors.white.withValues(alpha: 0.65)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: dark
              ? const TextStyle(color: Colors.white, fontSize: 14)
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: dark
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: dark
                  ? BorderSide(color: Colors.white.withValues(alpha: 0.14))
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: dark
                  ? BorderSide(color: Colors.white.withValues(alpha: 0.14))
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: dark ? AppColors.accent : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: dark ? const Color(0xFFFF6B6B) : Colors.red,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: dark ? const Color(0xFFFF6B6B) : Colors.red,
                width: 1.5,
              ),
            ),
            errorStyle: dark
                ? const TextStyle(color: Color(0xFFFF6B6B))
                : null,
          ),
        ),
      ],
    );
  }
}