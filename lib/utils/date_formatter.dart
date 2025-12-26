import 'package:intl/intl.dart';

/// Helper pour formater les dates de manière cohérente dans l'application
class DateFormatter {
  // ============================================
  // FORMATTERS STATIQUES (réutilisables)
  // ============================================

  /// Format court : dd/MM/yyyy (ex: 16/11/2025)
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy');

  /// Format court avec heure : dd/MM/yyyy à HH:mm (ex: 16/11/2025 à 14:30)
  static final DateFormat _shortDateTime = DateFormat('dd/MM/yyyy à HH:mm');

  /// Format complet : EEEE d MMMM yyyy (ex: samedi 16 novembre 2025)
  static final DateFormat _fullDate = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

  /// Format complet avec heure : EEEE d MMMM yyyy à HH:mm
  static final DateFormat _fullDateTime = DateFormat(
    'EEEE d MMMM yyyy à HH:mm',
    'fr_FR',
  );

  /// Format mois seul : MMMM (ex: novembre)
  static final DateFormat _monthName = DateFormat('MMMM', 'fr_FR');

  /// Format mois et année : MMMM yyyy (ex: novembre 2025)
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'fr_FR');

  /// Format timestamp pour fichiers : yyyyMMdd_HHmmss (ex: 20251116_143000)
  static final DateFormat _timestamp = DateFormat('yyyyMMdd_HHmmss');

  /// Format heure seule : HH:mm (ex: 14:30)
  static final DateFormat _timeOnly = DateFormat('HH:mm', 'fr_FR');

  /// Format jour et mois : dd MMMM (ex: 16 novembre)
  static final DateFormat _dayMonth = DateFormat('dd MMMM', 'fr_FR');

  /// Format jour et mois avec année : dd MMMM yyyy (ex: 16 novembre 2025)
  static final DateFormat _dayMonthYear = DateFormat('dd MMMM yyyy', 'fr_FR');

  /// Format ISO 8601 : yyyy-MM-dd (ex: 2025-11-16)
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  // ============================================
  // MÉTHODES DE FORMATAGE
  // ============================================

  /// Formate en date courte : 16/11/2025
  static String toShortDate(DateTime date) => _shortDate.format(date);

  /// Formate en date courte avec heure : 16/11/2025 à 14:30
  static String toShortDateTime(DateTime date) => _shortDateTime.format(date);

  /// Formate en date complète : samedi 16 novembre 2025
  static String toFullDate(DateTime date) => _fullDate.format(date);

  /// Formate en date complète avec heure : samedi 16 novembre 2025 à 14:30
  static String toFullDateTime(DateTime date) => _fullDateTime.format(date);

  /// Formate en nom de mois : novembre
  static String toMonthName(int month) =>
      _monthName.format(DateTime(2024, month));

  /// Formate en mois et année : novembre 2025
  static String toMonthYear(DateTime date) => _monthYear.format(date);

  /// Formate en timestamp pour noms de fichiers : 20251116_143000
  static String toTimestamp(DateTime date) => _timestamp.format(date);

  /// Formate en heure seule : 14:30
  static String toTime(DateTime date) => _timeOnly.format(date);

  /// Formate en jour et mois : 16 novembre
  static String toDayMonth(DateTime date) => _dayMonth.format(date);

  /// Formate en jour, mois et année : 16 novembre 2025
  static String toDayMonthYear(DateTime date) => _dayMonthYear.format(date);

  /// Formate en ISO 8601 : 2025-11-16
  static String toIso(DateTime date) => _iso.format(date);

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  /// Retourne une date relative (Aujourd'hui, Hier, etc.)
  static String toRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else if (dateOnly == tomorrow) {
      return 'Demain';
    } else if (dateOnly.isAfter(today) &&
        dateOnly.isBefore(today.add(const Duration(days: 7)))) {
      // Dans les 7 prochains jours : afficher le jour de la semaine
      return DateFormat('EEEE', 'fr_FR').format(date);
    } else if (dateOnly.year == now.year) {
      // Même année : afficher jour et mois
      return toDayMonth(date);
    } else {
      // Année différente : afficher date complète courte
      return toShortDate(date);
    }
  }

  /// Retourne une durée relative (Il y a 2 jours, Dans 3 jours, etc.)
  static String toRelativeDuration(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final absDays = difference.inDays.abs();
    final absHours = difference.inHours.abs();
    final absMinutes = difference.inMinutes.abs();

    if (difference.isNegative) {
      // Passé
      if (absDays > 365) {
        final years = (absDays / 365).floor();
        return 'Il y a $years an${years > 1 ? 's' : ''}';
      } else if (absDays > 30) {
        final months = (absDays / 30).floor();
        return 'Il y a $months mois';
      } else if (absDays > 0) {
        return 'Il y a $absDays jour${absDays > 1 ? 's' : ''}';
      } else if (absHours > 0) {
        return 'Il y a $absHours heure${absHours > 1 ? 's' : ''}';
      } else if (absMinutes > 0) {
        return 'Il y a $absMinutes minute${absMinutes > 1 ? 's' : ''}';
      } else {
        return "À l'instant";
      }
    } else {
      // Futur
      if (absDays > 365) {
        final years = (absDays / 365).floor();
        return 'Dans $years an${years > 1 ? 's' : ''}';
      } else if (absDays > 30) {
        final months = (absDays / 30).floor();
        return 'Dans $months mois';
      } else if (absDays > 0) {
        return 'Dans $absDays jour${absDays > 1 ? 's' : ''}';
      } else if (absHours > 0) {
        return 'Dans $absHours heure${absHours > 1 ? 's' : ''}';
      } else if (absMinutes > 0) {
        return 'Dans $absMinutes minute${absMinutes > 1 ? 's' : ''}';
      } else {
        return 'Maintenant';
      }
    }
  }

  /// Calcule le nombre de jours entre deux dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Calcule l'âge à partir d'une date de naissance
  static int calculateAge(DateTime birthDate, {DateTime? referenceDate}) {
    final reference = referenceDate ?? DateTime.now();
    int age = reference.year - birthDate.year;
    if (reference.month < birthDate.month ||
        (reference.month == birthDate.month && reference.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Formate un âge en texte lisible
  static String formatAge(DateTime birthDate, {DateTime? referenceDate}) {
    final reference = referenceDate ?? DateTime.now();
    final difference = reference.difference(birthDate);

    if (difference.inDays < 7) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else {
      final years = calculateAge(birthDate, referenceDate: reference);
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      if (remainingMonths > 0) {
        return '$years an${years > 1 ? 's' : ''} et $remainingMonths mois';
      }
      return '$years an${years > 1 ? 's' : ''}';
    }
  }

  /// Génère un nom de fichier avec timestamp
  static String generateFileName(String prefix, {String extension = ''}) {
    final timestamp = toTimestamp(DateTime.now());
    return extension.isEmpty
        ? '${prefix}_$timestamp'
        : '${prefix}_$timestamp.$extension';
  }

  /// Parse une date depuis format dd/MM/yyyy
  static DateTime? parseShortDate(String dateString) {
    try {
      return _shortDate.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse une date depuis format ISO 8601
  static DateTime? parseIso(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifie si une date est dans le passé
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Vérifie si une date est dans le futur
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Retourne le début de la journée (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Retourne la fin de la journée (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Retourne le début du mois
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Retourne la fin du mois
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Retourne le début de l'année
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Retourne la fin de l'année
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }
}
