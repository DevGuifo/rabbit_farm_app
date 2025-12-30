import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour le contenu textuel (titre + description)
/// Affiche "Smart Rabbit Farming" avec gradient et la description
class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Titre avec gradient
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
              color: isDark
                  ? AppTheme.stitchTextMainDark
                  : AppTheme.stitchTextMainLight,
            ),
            children: [
              const TextSpan(text: 'Smart Rabbit\n'),
              TextSpan(
                text: 'Farming',
                style: TextStyle(
                  color: AppTheme.primaryNeonGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Simplify your daily tasks. Track breeding schedules, medical records, and feed inventory with ease.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark
                  ? AppTheme.stitchTextSecDark
                  : AppTheme.stitchTextSecLight,
            ),
          ),
        ),
      ],
    );
  }
}

