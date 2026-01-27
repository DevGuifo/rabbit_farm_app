import 'package:flutter/material.dart';
import '../../theme/theme_variations.dart';

/// Bouton d'icône thématique utilisant ThemeVariation
///
/// Applique automatiquement les couleurs et icônes du thème
/// Usage:
/// ```dart
/// ThemedIconButton(
///   variation: ThemeVariations.sante,
///   onPressed: () => _openHealth(),
///   tooltip: 'Ouvrir Santé',
/// )
/// ```
class ThemedIconButton extends StatelessWidget {
  final ThemeVariation variation;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final bool useAltIcon;
  final bool isDark;

  const ThemedIconButton({
    super.key,
    required this.variation,
    required this.onPressed,
    this.tooltip,
    this.size = 24,
    this.useAltIcon = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        useAltIcon && variation.iconAlt != null
            ? variation.iconAlt!
            : variation.icon,
        size: size,
      ),
      color: variation.accentColor,
      tooltip: tooltip,
    );
  }
}

/// Badge thématique avec icône et couleurs du thème
class ThemedBadge extends StatelessWidget {
  final ThemeVariation variation;
  final String label;
  final bool showIcon;

  const ThemedBadge({
    super.key,
    required this.variation,
    required this.label,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return variation.buildChip(label);
  }
}

/// Container d'icône circulaire thématique
class ThemedIconCircle extends StatelessWidget {
  final ThemeVariation variation;
  final double size;
  final bool isDark;
  final bool useAltIcon;

  const ThemedIconCircle({
    super.key,
    required this.variation,
    this.size = 48,
    this.isDark = false,
    this.useAltIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return variation.buildIconCircle(size: size, isDark: isDark);
  }
}
