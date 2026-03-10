import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum AlertLevel {
  normal,
  critical;

  String get label {
    switch (this) {
      case AlertLevel.normal:
        return 'Normal';
      case AlertLevel.critical:
        return 'Crítico';
    }
  }

  Color get color {
    switch (this) {
      case AlertLevel.normal:
        return AppColors.normal;
      case AlertLevel.critical:
        return AppColors.critical;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertLevel.normal:
        return AppColors.normalLight;
      case AlertLevel.critical:
        return AppColors.criticalLight;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertLevel.normal:
        return Icons.notifications_outlined;
      case AlertLevel.critical:
        return Icons.warning_amber_rounded;
    }
  }
}

enum AlertStatus {
  active,
  resolved;

  String get label {
    switch (this) {
      case AlertStatus.active:
        return 'Ativo';
      case AlertStatus.resolved:
        return 'Resolvido';
    }
  }

  Color get color {
    switch (this) {
      case AlertStatus.active:
        return AppColors.warning;
      case AlertStatus.resolved:
        return AppColors.resolved;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertStatus.active:
        return const Color(0xFFFEF3C7);
      case AlertStatus.resolved:
        return AppColors.resolvedLight;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertStatus.active:
        return Icons.radio_button_checked;
      case AlertStatus.resolved:
        return Icons.check_circle_outline;
    }
  }
}