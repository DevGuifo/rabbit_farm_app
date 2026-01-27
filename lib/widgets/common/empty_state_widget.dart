import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un état vide attrayant
///
/// Ce widget affiche un message et une icône lorsqu'une liste est vide,
/// avec une option pour ajouter un premier élément.
///
/// ## Exemple d'utilisation
///
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.pets,
///   title: 'Aucun lapin',
///   subtitle: 'Ajoutez votre premier lapin pour commencer',
///   actionLabel: 'Ajouter un lapin',
///   onAction: () => Navigator.push(...),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Icône principale à afficher
  final IconData icon;

  /// Titre principal
  final String title;

  /// Sous-titre explicatif
  final String subtitle;

  /// Libellé du bouton d'action (optionnel)
  final String? actionLabel;

  /// Callback du bouton d'action (optionnel)
  final VoidCallback? onAction;

  /// Couleur de l'icône (utilise la couleur primaire par défaut)
  final Color? iconColor;

  /// Taille de l'icône
  final double iconSize;

  /// Image personnalisée (remplace l'icône si fournie)
  final String? imagePath;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône ou image
            _buildVisual(colorScheme),

            const SizedBox(height: 24),

            // Titre
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Sous-titre
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton d'action
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(ColorScheme colorScheme) {
    if (imagePath != null) {
      return Image.asset(imagePath!, width: iconSize, height: iconSize);
    }

    return Container(
      width: iconSize + 40,
      height: iconSize + 40,
      decoration: BoxDecoration(
        color: (iconColor ?? colorScheme.primary).withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? colorScheme.primary,
      ),
    );
  }
}

/// Variantes prédéfinies pour les cas courants
class EmptyStateVariants {
  /// État vide pour le cheptel
  static EmptyStateWidget cheptelVide({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.pets,
      title: 'Aucun lapin enregistré',
      subtitle:
          'Commencez par ajouter votre premier lapin pour suivre votre cheptel',
      actionLabel: 'Ajouter un lapin',
      onAction: onAction,
    );
  }

  /// État vide pour les accouplements
  static EmptyStateWidget accouplementsVide({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.favorite,
      title: 'Aucun accouplement',
      subtitle:
          'Planifiez votre premier accouplement pour suivre la reproduction',
      actionLabel: 'Planifier un accouplement',
      onAction: onAction,
    );
  }

  /// État vide pour les finances
  static EmptyStateWidget financesVide({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet,
      title: 'Aucune transaction',
      subtitle: 'Enregistrez vos recettes et dépenses pour suivre vos finances',
      actionLabel: 'Ajouter une transaction',
      onAction: onAction,
    );
  }

  /// État vide pour les alertes
  static EmptyStateWidget alertesVide() {
    return const EmptyStateWidget(
      icon: Icons.check_circle,
      title: 'Aucune alerte',
      subtitle: 'Tout va bien ! Vous n\'avez aucune tâche en attente',
      iconColor: Colors.green,
    );
  }

  /// État vide pour la santé
  static EmptyStateWidget santeVide({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.medical_services,
      title: 'Aucun suivi de santé',
      subtitle:
          'Enregistrez les pesées et soins pour suivre la santé de votre cheptel',
      actionLabel: 'Ajouter un suivi',
      onAction: onAction,
    );
  }

  /// État vide générique pour les recherches
  static EmptyStateWidget rechercheVide(String recherche) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      subtitle: 'Aucun élément ne correspond à "$recherche"',
    );
  }

  /// État d'erreur
  static EmptyStateWidget erreur({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Une erreur est survenue',
      subtitle:
          message ?? 'Impossible de charger les données. Réessayez plus tard.',
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }
}
