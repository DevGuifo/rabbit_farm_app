import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour la section hero avec l'image du lapin et l'overlay de stats
/// Affiche une grande image avec une carte flottante contenant les statistiques
class WelcomeHeroSection extends StatelessWidget {
  const WelcomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = 400.0;
        final aspectRatio = 4 / 5;
        final calculatedHeight = (constraints.maxWidth / aspectRatio).clamp(0.0, maxHeight);

        return SizedBox(
          width: double.infinity,
          height: calculatedHeight,
          child: Stack(
          children: [
            // Image de fond avec gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image du lapin (utilise une image réseau depuis Stitch)
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBuff226NJUjb7_rSSN1pJyyecbtfWq51vrdFJOLQfLP6If199frRsjquum3zKI8_mK4ASYF72od2Z2AAlBIcx_fxZwA9xa4sg-4wcJvZCFrvQoC0EEGJrc8nn9QxnzQkI8DWVVTmGZB_C3kEvIRgft9DGpA2yHFiwk0Umj23wwUrimK0SsIRhE3ZtS0MlWJM4ZyBefq7KFutaWqZ4-mqYFTe00uusWeqDC8DNwNuU-b5G_YoQv19014U6P5Q7L9753Zz3DZS-4kOY',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback : placeholder avec icône
                      return Container(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay (du bas vers le haut)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.textPrimary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carte flottante avec stats (bottom-left)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildStatsOverlay(isDark),
            ),
          ],
        ),
      );
      },
    );
  }

  /// Construit la carte overlay avec les statistiques
  Widget _buildStatsOverlay(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark
                ? AppTheme.surfaceDark
                : AppTheme.surfaceWhite)
            .withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textOnPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône de monitoring
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                  : AppTheme.backgroundGreenVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: isDark
                  ? AppTheme.primaryGreen
                  : AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Texte des stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Weekly Growth',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.stitchTextSecDark
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+12% Healthy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.stitchTextMainDark
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Icône de validation
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
        ],
      ),
    );
  }
}

