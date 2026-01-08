import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Carte KPI actionnable avec code couleur (vert/orange/rouge)
/// Permet une navigation rapide vers les écrans détaillés
class ActionableKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final KpiStatus status; // Définit la couleur
  final VoidCallback? onTap;
  final bool isDark;
  final String? subtitle; // Info complémentaire

  const ActionableKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.status,
    this.onTap,
    required this.isDark,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colors.backgroundColor.withValues(alpha: 0.15)
              : colors.backgroundColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isDark
                ? colors.borderColor.withValues(alpha: 0.4)
                : colors.borderColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icône en arrière-plan (effet visuel discret)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                icon,
                size: 48,
                color: colors.iconColor.withValues(alpha: 0.1),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône + Badge statut
                  Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: colors.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 20, color: colors.iconColor),
                      ),
                      const Spacer(),
                      if (status != KpiStatus.ok)
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: colors.iconColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Valeur principale (responsive)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Label
                  Text(
                    label,
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                              .withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Sous-titre optionnel
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTheme.caption.copyWith(
                        color: colors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Indicateur de navigation
                  if (onTap != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: colors.iconColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Voir détails',
                          style: AppTheme.caption.copyWith(
                            color: colors.iconColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne les couleurs selon le statut
  _StatusColors _getStatusColors() {
    switch (status) {
      case KpiStatus.ok:
        return _StatusColors(
          backgroundColor: AppTheme.success50,
          borderColor: AppTheme.success200,
          iconColor: AppTheme.success600,
          textColor: isDark ? AppTheme.success300 : AppTheme.success800,
        );
      case KpiStatus.attention:
        return _StatusColors(
          backgroundColor: AppTheme.warning50,
          borderColor: AppTheme.warning200,
          iconColor: AppTheme.warning600,
          textColor: isDark ? AppTheme.warning300 : AppTheme.warning800,
        );
      case KpiStatus.action:
        return _StatusColors(
          backgroundColor: AppTheme.error50,
          borderColor: AppTheme.error200,
          iconColor: AppTheme.error600,
          textColor: isDark ? AppTheme.error300 : AppTheme.error800,
        );
    }
  }
}

/// Statut du KPI (définit le code couleur)
enum KpiStatus {
  ok, // Vert : Tout va bien
  attention, // Orange : Nécessite surveillance
  action, // Rouge : Action immédiate requise
}

/// Classe privée pour les couleurs
class _StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
