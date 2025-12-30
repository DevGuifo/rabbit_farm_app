import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour l'en-tête de marque (Logo + BUNNYBASE)
/// Affiche le logo avec l'icône de lapin et le texte "BUNNYBASE"
class WelcomeBrandHeader extends StatelessWidget {
  const WelcomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo avec icône de lapin
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.cruelty_free,
            color: AppTheme.primaryNeonGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        // Texte BUNNYBASE
        Text(
          'BUNNYBASE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark
                ? AppTheme.stitchTextSecDark
                : AppTheme.stitchTextSecLight,
          ),
        ),
      ],
    );
  }
}

