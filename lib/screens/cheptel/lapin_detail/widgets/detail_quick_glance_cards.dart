import 'package:flutter/material.dart';
import '../../../../models/lapin.dart';
import '../constants/stitch_theme_constants.dart';
import '../../../../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Cartes de statistiques rapides (Poids et Âge) - Stitch Design
class DetailQuickGlanceCards extends StatelessWidget {
  final Lapin lapin;
  final double? dernierPoids;
  final double? variationPoids; // MOCK DATA - % variation

  const DetailQuickGlanceCards({
    super.key,
    required this.lapin,
    this.dernierPoids,
    this.variationPoids,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildWeightCard(context, isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildAgeCard(context, isDark)),
        ],
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, bool isDark) {
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);
    final poids = dernierPoids ?? lapin.poids ?? 0.0;
    final variation = variationPoids ?? 2.4; // MOCK DATA

    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StitchTheme.radiusLarge),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Row(
            children: [
              Icon(
                Icons.scale,
                size: 16,
                color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
              ),
              const SizedBox(width: 5),
              Text(
                'WEIGHT',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark
                      ? StitchTheme.neutral400
                      : StitchTheme.neutral500,
                ),
              ),
            ],
          ),
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    poids.toStringAsFixed(1),
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 22,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'kg',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? StitchTheme.neutral400
                          : StitchTheme.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Variation (MOCK DATA)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? StitchTheme.green900.withValues(alpha: 0.2)
                      : StitchTheme.green50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '↗ ${variation.toStringAsFixed(1)}%',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? StitchTheme.green300 : StitchTheme.green600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCard(BuildContext context, bool isDark) {
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);

    // Calcul de l'âge
    final ageEnMois = lapin.ageEnMois;
    final years = ageEnMois ~/ 12;
    final months = ageEnMois % 12;
    final dateFormat = DateFormat('MMM dd, yyyy', 'en_US');
    final dateNaissanceFormatee = dateFormat.format(lapin.dateNaissance);

    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StitchTheme.radiusLarge),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Row(
            children: [
              Icon(
                Icons.cake,
                size: 16,
                color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
              ),
              const SizedBox(width: 5),
              Text(
                'AGE',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark
                      ? StitchTheme.neutral400
                      : StitchTheme.neutral500,
                ),
              ),
            ],
          ),
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    years.toString(),
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 22,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'yr',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? StitchTheme.neutral400
                          : StitchTheme.neutral500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    months.toString(),
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 22,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'mo',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? StitchTheme.neutral400
                          : StitchTheme.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Born $dateNaissanceFormatee',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? StitchTheme.neutral500
                      : StitchTheme.neutral400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
