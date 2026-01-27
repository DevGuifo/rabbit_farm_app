import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../theme/app_theme.dart';

/// Widget optimisé pour une carte de lapin dans la liste
/// Utilise des widgets const et évite les rebuilds inutiles
class RabbitCard extends StatelessWidget {
  final Lapin lapin;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RabbitCard({
    super.key,
    required this.lapin,
    required this.isDark,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Utiliser Selector pour écouter uniquement les données nécessaires
    return Selector2<ReproductionProvider, SanteProvider, _RabbitCardData>(
      selector: (_, reproProv, santeProv) {
        final accouplements = reproProv.accouplements;
        final estGestante = lapin.estGestante(accouplements);
        // Note: estLapinMalade est async, on utilise le statut pour l'instant
        final isSick = lapin.statut == 'Malade';
        return _RabbitCardData(estGestante: estGestante, isSick: isSick);
      },
      shouldRebuild: (prev, next) =>
          prev.estGestante != next.estGestante || prev.isSick != next.isSick,
      builder: (context, data, _) {
        return _RabbitCardContent(
          lapin: lapin,
          isDark: isDark,
          estGestante: data.estGestante,
          isSick: data.isSick,
          onTap: onTap,
          onLongPress: onLongPress,
        );
      },
    );
  }
}

/// Données nécessaires pour la carte de lapin
class _RabbitCardData {
  final bool estGestante;
  final bool isSick;

  _RabbitCardData({required this.estGestante, required this.isSick});
}

/// Contenu de la carte de lapin (widget const quand possible)
class _RabbitCardContent extends StatelessWidget {
  final Lapin lapin;
  final bool isDark;
  final bool estGestante;
  final bool isSick;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _RabbitCardContent({
    required this.lapin,
    required this.isDark,
    required this.estGestante,
    required this.isSick,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer le badge statut
    String badgeText = AppLocalizations.of(context).cheptelSain;
    Color badgeBg = isDark
        ? AppTheme.success.withValues(alpha: 0.3)
        : AppTheme.success.withValues(alpha: 0.2);
    Color badgeTextColor = AppTheme.success;

    if (isSick) {
      badgeText = AppLocalizations.of(context).cheptelMalade;
      badgeBg = isDark
          ? AppTheme.error.withValues(alpha: 0.3)
          : AppTheme.error.withValues(alpha: 0.2);
      badgeTextColor = AppTheme.error;
    } else if (estGestante) {
      badgeText = AppLocalizations.of(context).cheptelGestante;
      badgeBg = isDark
          ? AppTheme.accentPink.withValues(alpha: 0.3)
          : AppTheme.accentPink.withValues(alpha: 0.1);
      badgeTextColor = AppTheme.accentPink;
    }

    // Badge sexe (ou medical si malade)
    IconData sexeIcon = Icons.female;
    Color sexeColor = AppTheme.accentGreen;

    if (isSick) {
      sexeIcon = Icons.medical_services;
      sexeColor = AppTheme.error;
    } else if (lapin.sexe == Sexe.male) {
      sexeIcon = Icons.male;
      sexeColor = AppTheme.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo ou avatar
                _buildAvatar(),
                const SizedBox(width: 16),
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lapin.nom,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Badge statut
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTheme.caption.copyWith(
                                color: badgeTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(sexeIcon, size: 16, color: sexeColor),
                          const SizedBox(width: 4),
                          Text(
                            '${lapin.race} • ${lapin.ageEnJours} jours',
                            style: AppTheme.caption.copyWith(
                              color:
                                  (isDark
                                          ? AppTheme.textLight
                                          : AppTheme.textSecondary)
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                      .withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (lapin.photoPath != null && lapin.photoPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          lapin.photoPath!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.pets,
        color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
            .withValues(alpha: 0.5),
      ),
    );
  }
}
