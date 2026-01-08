import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour les indicateurs de pagination (3 dots)
/// Le premier dot est actif (vert), les autres sont inactifs (gris)
class WelcomePaginationDots extends StatelessWidget {
  const WelcomePaginationDots({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dot actif (premier)
        Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.primaryNeonGreen,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        // Dots inactifs
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.neutral700
                : AppTheme.borderLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.neutral700
                : AppTheme.borderLight,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

