import 'package:flutter/material.dart';

enum AlertLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case AlertLevel.low:      return 'Baixo';
      case AlertLevel.medium:   return 'Médio';
      case AlertLevel.high:     return 'Alto';
      case AlertLevel.critical: return 'Crítico';
    }
  }

  String get backendValue => name.toUpperCase();

  Color get color {
    switch (this) {
      case AlertLevel.low:      return const Color(0xFF10B981);
      case AlertLevel.medium:   return const Color(0xFFF59E0B);
      case AlertLevel.high:     return const Color(0xFFF97316);
      case AlertLevel.critical: return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertLevel.low:      return const Color(0xFFD1FAE5);
      case AlertLevel.medium:   return const Color(0xFFFEF3C7);
      case AlertLevel.high:     return const Color(0xFFFFEDD5);
      case AlertLevel.critical: return const Color(0xFFFEE2E2);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertLevel.low:      return Icons.notifications_outlined;
      case AlertLevel.medium:   return Icons.info_outline;
      case AlertLevel.high:     return Icons.warning_amber_rounded;
      case AlertLevel.critical: return Icons.report_problem;
    }
  }

  static AlertLevel fromBackend(String? value) {
    switch (value?.toUpperCase()) {
      case 'LOW':      return AlertLevel.low;
      case 'MEDIUM':   return AlertLevel.medium;
      case 'HIGH':     return AlertLevel.high;
      case 'CRITICAL': return AlertLevel.critical;
      default:         return AlertLevel.low;
    }
  }
}

enum AlertStatus {
  active,
  resolved;

  String get label {
    switch (this) {
      case AlertStatus.active:   return 'Ativo';
      case AlertStatus.resolved: return 'Resolvido';
    }
  }

  Color get color {
    switch (this) {
      case AlertStatus.active:   return const Color(0xFFF59E0B);
      case AlertStatus.resolved: return const Color(0xFF10B981);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertStatus.active:   return const Color(0xFFFEF3C7);
      case AlertStatus.resolved: return const Color(0xFFD1FAE5);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertStatus.active:   return Icons.radio_button_checked;
      case AlertStatus.resolved: return Icons.check_circle_outline;
    }
  }
}

enum AssignmentStatus {
  pending,
  viewed,
  acknowledged,
  overdue;

  String get label {
    switch (this) {
      case AssignmentStatus.pending:      return 'Pendente';
      case AssignmentStatus.viewed:       return 'Visualizado';
      case AssignmentStatus.acknowledged: return 'Confirmado';
      case AssignmentStatus.overdue:      return 'Atrasado';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentStatus.pending:      return const Color(0xFF94A3B8);
      case AssignmentStatus.viewed:       return const Color(0xFF3B82F6);
      case AssignmentStatus.acknowledged: return const Color(0xFF10B981);
      case AssignmentStatus.overdue:      return const Color(0xFFDC2626);
    }
  }

  static AssignmentStatus fromBackend(String? value) {
    switch (value?.toUpperCase()) {
      case 'VIEWED':       return AssignmentStatus.viewed;
      case 'ACKNOWLEDGED': return AssignmentStatus.acknowledged;
      case 'OVERDUE':      return AssignmentStatus.overdue;
      default:             return AssignmentStatus.pending;
    }
  }
}
