import 'package:intl/intl.dart';

/// Formateurs de dates et timestamps en français
class DateFormatterFr {
  /// Formater un timestamp en "Il y a X" en français
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Hier, ${hour}h$minute';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  /// Formater une date en "Lundi 17 janvier"
  static String formatDateLong(DateTime date) {
    final formatter = DateFormat('EEEE d MMMM', 'fr_FR');
    return formatter.format(date);
  }

  /// Formater une date en "17/01/2026"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formater une date en "17 janvier 2026"
  static String formatDateMedium(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formater heure en "14h30"
  static String formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Vérifier si deux dates sont le même jour
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Obtenir le label de section pour une date (Aujourd'hui, Hier, date)
  static String getSectionLabel(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (isSameDay(date, now)) {
      return 'Aujourd\'hui';
    } else if (isSameDay(date, yesterday)) {
      return 'Hier';
    } else {
      return formatDateLong(date);
    }
  }
}
