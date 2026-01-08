import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/lapin.dart';

/// Widget avec boutons d'actions rapides pour un lapin
///
/// Affiche des boutons contextuels selon le type de lapin :
/// - Femelle : Accoupler, Palpation, Préparer nid
/// - Mâle : Accoupler, Voir reproductions
/// - Lapereau : Sevrer
class QuickActionButtons extends StatelessWidget {
  final Lapin lapin;
  final VoidCallback? onMatingPressed;
  final VoidCallback? onPalpationPressed;
  final VoidCallback? onNestPrepPressed;
  final VoidCallback? onReproductionsPressed;
  final VoidCallback? onWeaningPressed;

  const QuickActionButtons({
    super.key,
    required this.lapin,
    this.onMatingPressed,
    this.onPalpationPressed,
    this.onNestPrepPressed,
    this.onReproductionsPressed,
    this.onWeaningPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFemelle = lapin.sexe.toLowerCase() == 'femelle';
    final isMale =
        lapin.sexe.toLowerCase() == 'mâle' ||
        lapin.sexe.toLowerCase() == 'male';
    final isLapereau = lapin.ageEnMois < 5;

    // Ne rien afficher si vendu ou décédé
    if (lapin.statut == 'vendu' || lapin.statut == 'decede') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 20,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Actions rapides',
                style: AppTheme.titleSmall.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isFemelle && !isLapereau) ..._buildFemelleActions(isDark),
          if (isMale && !isLapereau) ..._buildMaleActions(isDark),
          if (isLapereau) ..._buildLapereauActions(isDark),
        ],
      ),
    );
  }

  /// Actions pour une femelle adulte
  List<Widget> _buildFemelleActions(bool isDark) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconButton(
            icon: Icons.favorite_rounded,
            tooltip: 'Accoupler',
            color: AppTheme.accentPink,
            onPressed: onMatingPressed,
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.touch_app_rounded,
            tooltip: 'Palpation',
            color: AppTheme.warning,
            onPressed: onPalpationPressed,
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.nest_cam_wired_stand_rounded,
            tooltip: 'Préparer nid',
            color: AppTheme.accentBrown,
            onPressed: onNestPrepPressed,
          ),
        ],
      ),
    ];
  }

  /// Actions pour un mâle adulte
  List<Widget> _buildMaleActions(bool isDark) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconButton(
            icon: Icons.favorite_rounded,
            tooltip: 'Accoupler',
            color: AppTheme.primaryGreen,
            onPressed: onMatingPressed,
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.list_alt_rounded,
            tooltip: 'Voir reproductions',
            color: AppTheme.info,
            onPressed: onReproductionsPressed,
          ),
        ],
      ),
    ];
  }

  /// Actions pour un lapereau
  List<Widget> _buildLapereauActions(bool isDark) {
    return [
      _buildIconButton(
        icon: Icons.child_care_rounded,
        tooltip: 'Sevrer',
        color: AppTheme.primaryGreen,
        onPressed: onWeaningPressed,
      ),
    ];
  }

  /// Widget pour un bouton icône compact
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
