import 'package:flutter/material.dart';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

/// Card "Basic Information" pour l'onglet Identity (Stitch Design)
class BasicInformationCard extends StatelessWidget {
  final Lapin lapin;

  const BasicInformationCard({super.key, required this.lapin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.textLight.withValues(alpha: 0.05)
                  : StitchTheme.neutral50.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(bottom: BorderSide(color: outlineColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Basic Information',
                  style: AppTheme.titleMedium.copyWith(
                    color: isDark
                        ? AppTheme.textLight
                        : AppTheme.stitchTextMainLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.textLight.withValues(alpha: 0.1)
                        : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(StitchTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 20,
                    color: StitchTheme.neutral400,
                  ),
                ),
              ],
            ),
          ),
          // Content Grid
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        isDark: isDark,
                        label: 'BREED',
                        value: lapin.race,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        isDark: isDark,
                        label: 'SEX',
                        value: lapin.sexe == 'Mâle' || lapin.sexe == 'male'
                            ? 'Buck'
                            : 'Doe',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildColorItem(
                        context: context,
                        isDark: isDark,
                        label: 'COLOR',
                        value: lapin.couleur ?? 'Blanc',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCageItem(
                        context: context,
                        isDark: isDark,
                        label: 'CAGE NUMBER',
                        value: 'N/A',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.titleSmall.copyWith(
            color: isDark ? StitchTheme.neutral100 : StitchTheme.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildColorItem({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCouleurFromString(value),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? StitchTheme.neutral600
                      : StitchTheme.neutral300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: AppTheme.titleSmall.copyWith(
                color: isDark ? StitchTheme.neutral100 : StitchTheme.neutral900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCageItem({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.grid_view, size: 18, color: StitchTheme.neutral400),
            const SizedBox(width: 8),
            Text(
              value,
              style: AppTheme.titleSmall.copyWith(
                color: isDark ? StitchTheme.neutral100 : StitchTheme.neutral900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCouleurFromString(String couleur) {
    final couleurLower = couleur.toLowerCase();
    if (couleurLower.contains('blanc') || couleurLower.contains('white')) {
      return AppTheme.textLight;
    } else if (couleurLower.contains('noir') ||
        couleurLower.contains('black')) {
      return Colors.black;
    } else if (couleurLower.contains('gris') || couleurLower.contains('gray')) {
      return AppTheme.textSecondary;
    } else if (couleurLower.contains('brun') ||
        couleurLower.contains('brown')) {
      return Colors.brown;
    } else if (couleurLower.contains('roux') ||
        couleurLower.contains('orange')) {
      return AppTheme.warning;
    }
    return AppTheme.textSecondary;
  }
}
