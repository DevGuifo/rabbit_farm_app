import 'package:pdf/pdf.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// 🎨 PDF DESIGN SYSTEM - BUNNYMANAGER
/// ════════════════════════════════════════════════════════════════════════════
///
/// Couleurs PDF correspondantes au Design System AppTheme
/// Pour utilisation dans les rapports PDF avec le package pdf/printing
/// ════════════════════════════════════════════════════════════════════════════

class PdfAppTheme {
  // NEUTRES (échelle de gris)
  static const PdfColor neutral50 = PdfColor.fromInt(0xFFFAFAFA);
  static const PdfColor neutral100 = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor neutral200 = PdfColor.fromInt(0xFFEEEEEE);
  static const PdfColor neutral300 = PdfColor.fromInt(0xFFE0E0E0);
  static const PdfColor neutral400 = PdfColor.fromInt(0xFFBDBDBD);
  static const PdfColor neutral500 = PdfColor.fromInt(0xFF9E9E9E);
  static const PdfColor neutral600 = PdfColor.fromInt(0xFF757575);
  static const PdfColor neutral700 = PdfColor.fromInt(0xFF616161);
  static const PdfColor neutral800 = PdfColor.fromInt(0xFF424242);
  static const PdfColor neutral900 = PdfColor.fromInt(0xFF212121);

  // Alias pour compatibilité avec les patterns neutral500XXX
  static const PdfColor neutral500100 = neutral100;
  static const PdfColor neutral500200 = neutral200;
  static const PdfColor neutral500300 = neutral300;
  static const PdfColor neutral500400 = neutral400;
  static const PdfColor neutral500500 = neutral500;
  static const PdfColor neutral500600 = neutral600;
  static const PdfColor neutral500700 = neutral700;
  static const PdfColor neutral500800 = neutral800;
  static const PdfColor neutral500900 = neutral900;

  // SUCCESS (vert)
  static const PdfColor success50 = PdfColor.fromInt(0xFFE8F5E9);
  static const PdfColor success100 = PdfColor.fromInt(0xFFC8E6C9);
  static const PdfColor success200 = PdfColor.fromInt(0xFFA5D6A7);
  static const PdfColor success300 = PdfColor.fromInt(0xFF81C784);
  static const PdfColor success600 = PdfColor.fromInt(0xFF43A047);
  static const PdfColor success700 = PdfColor.fromInt(0xFF388E3C);
  static const PdfColor success800 = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor success900 = PdfColor.fromInt(0xFF1B5E20);

  // WARNING (orange)
  static const PdfColor warning50 = PdfColor.fromInt(0xFFFFF3E0);
  static const PdfColor warning100 = PdfColor.fromInt(0xFFFFE0B2);
  static const PdfColor warning200 = PdfColor.fromInt(0xFFFFCC80);
  static const PdfColor warning300 = PdfColor.fromInt(0xFFFFB74D);
  static const PdfColor warning600 = PdfColor.fromInt(0xFFFB8C00);
  static const PdfColor warning700 = PdfColor.fromInt(0xFFF57C00);
  static const PdfColor warning800 = PdfColor.fromInt(0xFFEF6C00);
  static const PdfColor warning900 = PdfColor.fromInt(0xFFE65100);

  // ERROR (rouge)
  static const PdfColor error50 = PdfColor.fromInt(0xFFFFEBEE);
  static const PdfColor error100 = PdfColor.fromInt(0xFFFFCDD2);
  static const PdfColor error200 = PdfColor.fromInt(0xFFEF9A9A);
  static const PdfColor error300 = PdfColor.fromInt(0xFFE57373);
  static const PdfColor error600 = PdfColor.fromInt(0xFFE53935);
  static const PdfColor error700 = PdfColor.fromInt(0xFFD32F2F);
  static const PdfColor error800 = PdfColor.fromInt(0xFFC62828);
  static const PdfColor error900 = PdfColor.fromInt(0xFFB71C1C);

  // INFO (bleu)
  static const PdfColor info50 = PdfColor.fromInt(0xFFE1F5FE);
  static const PdfColor info100 = PdfColor.fromInt(0xFFB3E5FC);
  static const PdfColor info200 = PdfColor.fromInt(0xFF81D4FA);
  static const PdfColor info300 = PdfColor.fromInt(0xFF4FC3F7);
  static const PdfColor info600 = PdfColor.fromInt(0xFF039BE5);
  static const PdfColor info700 = PdfColor.fromInt(0xFF0288D1);
  static const PdfColor info800 = PdfColor.fromInt(0xFF0277BD);
  static const PdfColor info900 = PdfColor.fromInt(0xFF01579B);

  // ACCENT PURPLE (violet)
  static const PdfColor accentPurple50 = PdfColor.fromInt(0xFFF3E5F5);
  static const PdfColor accentPurple100 = PdfColor.fromInt(0xFFE1BEE7);
  static const PdfColor accentPurple200 = PdfColor.fromInt(0xFFCE93D8);
  static const PdfColor accentPurple700 = PdfColor.fromInt(0xFF7B1FA2);
  static const PdfColor accentPurple900 = PdfColor.fromInt(0xFF4A148C);

  // ACCENT PINK (rose)
  static const PdfColor accentPink50 = PdfColor.fromInt(0xFFFCE4EC);
  static const PdfColor accentPink100 = PdfColor.fromInt(0xFFF8BBD9);
  static const PdfColor accentPink200 = PdfColor.fromInt(0xFFF48FB1);
  static const PdfColor accentPink700 = PdfColor.fromInt(0xFFC2185B);
  static const PdfColor accentPink900 = PdfColor.fromInt(0xFF880E4F);

  // ACCENT ORANGE
  static const PdfColor accentOrange50 = PdfColor.fromInt(0xFFFFF3E0);
  static const PdfColor accentOrange100 = PdfColor.fromInt(0xFFFFE0B2);
  static const PdfColor accentOrange200 = PdfColor.fromInt(0xFFFFCC80);
  static const PdfColor accentOrange700 = PdfColor.fromInt(0xFFE65100);

  // PRIMARY GREEN
  static const PdfColor primaryGreen = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor primaryGreenLight = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor primaryGreenDark = PdfColor.fromInt(0xFF1B5E20);

  // TEXT
  static const PdfColor textPrimary = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor textSecondary = PdfColor.fromInt(0xFF5F6368);
  static const PdfColor textWhite = PdfColor.fromInt(0xFFFFFFFF);

  // BORDERS
  static const PdfColor borderLight = PdfColor.fromInt(0xFFE0E0E0);
}
