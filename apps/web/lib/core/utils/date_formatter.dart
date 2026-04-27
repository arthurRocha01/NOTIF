import 'package:intl/intl.dart';

abstract class DateFormatter {
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';

    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  static String full(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);

  static String dateOnly(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

  static String timeOnly(DateTime date) =>
      DateFormat('HH:mm', 'pt_BR').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'pt_BR').format(date);
}