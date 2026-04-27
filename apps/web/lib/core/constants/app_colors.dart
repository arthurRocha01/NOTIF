import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A2340);
  static const Color primaryLight = Color(0xFF2A3560);
  static const Color accent = Color(0xFF4A6CF7);
  static const Color accentLight = Color(0xFF6B8BFF);

  // Alerts
  static const Color critical = Color(0xFFE53935);
  static const Color criticalLight = Color(0xFFFFEBEE);
  static const Color normal = Color(0xFF1E3A8A);
  static const Color normalLight = Color(0xFFEFF6FF);
  static const Color resolved = Color(0xFF16A34A);
  static const Color resolvedLight = Color(0xFFF0FDF4);

  // Neutral
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FE);
  static const Color border = Color(0xFFE8EAF0);
  static const Color borderLight = Color(0xFFF0F2F8);

  // Text
  static const Color textPrimary = Color(0xFF1A2340);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Shadows
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
}