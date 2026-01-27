import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════════════
/// 📭 ANIMATED EMPTY STATES - États vides engageants et pédagogiques
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Ce fichier contient les widgets pour afficher des états vides de manière
/// engageante et pédagogique. Un état vide bien conçu guide l'utilisateur
/// vers l'action appropriée.
///
/// PRINCIPES :
/// - Icône ou illustration claire et amicale
/// - Message explicatif court
/// - Action suggérée (CTA = Call To Action)
/// - Animation subtile pour attirer l'œil
///
/// USAGE :
/// ```dart
/// AnimatedEmptyState(
///   icon: Icons.pets,
///   title: 'Aucun lapin',
///   message: 'Commencez par ajouter votre premier lapin',
///   actionLabel: 'Ajouter un lapin',
///   onAction: () => _ajouterLapin(),
/// )
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// 📭 ANIMATED EMPTY STATE - État vide générique animé
// ═══════════════════════════════════════════════════════════════════════════

/// Widget d'état vide animé et engageant
///
/// **Quand l'utiliser :**
/// - Liste vide
/// - Aucun résultat de recherche
/// - Première utilisation d'une fonctionnalité
///
/// **Exemple :**
/// ```dart
/// if (lapins.isEmpty)
///   AnimatedEmptyState(
///     icon: Icons.pets,
///     title: 'Votre cheptel est vide',
///     message: 'Ajoutez votre premier lapin pour commencer',
///     actionLabel: 'Ajouter un lapin',
///     onAction: () => _naviguerAjout(),
///   )
/// else
///   ListView.builder(...)
/// ```
class AnimatedEmptyState extends StatefulWidget {
  /// Icône principale
  final IconData icon;

  /// Titre court et clair
  final String title;

  /// Message explicatif (optionnel)
  final String? message;

  /// Label du bouton d'action (optionnel)
  final String? actionLabel;

  /// Callback du bouton d'action
  final VoidCallback? onAction;

  /// Couleur personnalisée (par défaut : primaryContainer)
  final Color? color;

  /// Afficher une animation flottante ?
  final bool animate;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color,
    this.animate = true,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation de flottement subtile
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade in au démarrage
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5; // Position neutre
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primaryContainer;
    final iconColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: widget.animate ? _fadeAnimation.value.clamp(0.0, 1.0) : 1.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône animée
                  Transform.translate(
                    offset: Offset(
                      0,
                      widget.animate ? _floatAnimation.value : 0,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, size: 48, color: iconColor),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titre
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Message
                  if (widget.message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.message!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Bouton d'action
                  if (widget.actionLabel != null &&
                      widget.onAction != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: widget.onAction,
                      icon: const Icon(Icons.add),
                      label: Text(widget.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🐰 EMPTY STATE VARIANTS - Variantes prédéfinies pour l'app
// ═══════════════════════════════════════════════════════════════════════════

/// État vide pour la liste des lapins
class EmptyLapinsList extends StatelessWidget {
  final VoidCallback? onAddLapin;

  const EmptyLapinsList({super.key, this.onAddLapin});

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.pets,
      title: 'Aucun lapin dans le cheptel',
      message:
          'Commencez par ajouter vos premiers lapins pour gérer votre élevage',
      actionLabel: 'Ajouter un lapin',
      onAction: onAddLapin,
    );
  }
}

/// État vide pour la liste des accouplements
class EmptyAccouplementsList extends StatelessWidget {
  final VoidCallback? onAddAccouplement;

  const EmptyAccouplementsList({super.key, this.onAddAccouplement});

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.favorite,
      title: 'Aucun accouplement enregistré',
      message: 'Planifiez vos accouplements pour suivre la reproduction',
      actionLabel: 'Nouvel accouplement',
      onAction: onAddAccouplement,
      color: Colors.pink.shade100,
    );
  }
}

/// État vide pour les soins
class EmptySoinsList extends StatelessWidget {
  final VoidCallback? onAddSoin;

  const EmptySoinsList({super.key, this.onAddSoin});

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.medical_services,
      title: 'Aucun soin enregistré',
      message: 'Enregistrez les soins et vaccinations de vos lapins',
      actionLabel: 'Ajouter un soin',
      onAction: onAddSoin,
      color: Colors.blue.shade100,
    );
  }
}

/// État vide pour les finances
class EmptyFinancesList extends StatelessWidget {
  final VoidCallback? onAddTransaction;

  const EmptyFinancesList({super.key, this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.account_balance_wallet,
      title: 'Aucune transaction',
      message: 'Suivez vos revenus et dépenses liés à l\'élevage',
      actionLabel: 'Ajouter une transaction',
      onAction: onAddTransaction,
      color: Colors.amber.shade100,
    );
  }
}

/// État vide pour les résultats de recherche
class EmptySearchResults extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchResults({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      message: 'Aucun élément ne correspond à "$searchQuery"',
      actionLabel: 'Effacer la recherche',
      onAction: onClearSearch,
      animate: false, // Pas d'animation pour les recherches
    );
  }
}

/// État vide pour les alertes
class EmptyAlertesList extends StatelessWidget {
  const EmptyAlertesList({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.notifications_none,
      title: 'Aucune alerte',
      message:
          'Tout est en ordre ! Vous n\'avez aucune notification en attente.',
      color: Colors.green.shade100,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ILLUSTRATED EMPTY STATE - Avec illustration personnalisée
// ═══════════════════════════════════════════════════════════════════════════

/// État vide avec illustration SVG ou asset
///
/// **Quand l'utiliser :**
/// - Écrans principaux (dashboard, première connexion)
/// - Onboarding
/// - Moments importants
///
/// **Exemple :**
/// ```dart
/// IllustratedEmptyState(
///   illustration: 'assets/images/empty_farm.png',
///   title: 'Bienvenue !',
///   message: 'Commencez à gérer votre élevage',
/// )
/// ```
class IllustratedEmptyState extends StatefulWidget {
  /// Chemin vers l'image d'illustration
  final String? illustrationPath;

  /// Widget d'illustration personnalisé
  final Widget? illustration;

  /// Titre
  final String title;

  /// Message
  final String? message;

  /// Label du bouton
  final String? actionLabel;

  /// Action du bouton
  final VoidCallback? onAction;

  /// Label du bouton secondaire
  final String? secondaryActionLabel;

  /// Action secondaire
  final VoidCallback? onSecondaryAction;

  const IllustratedEmptyState({
    super.key,
    this.illustrationPath,
    this.illustration,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  }) : assert(
         illustrationPath != null || illustration != null,
         'Provide either illustrationPath or illustration widget',
       );

  @override
  State<IllustratedEmptyState> createState() => _IllustratedEmptyStateState();
}

class _IllustratedEmptyStateState extends State<IllustratedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Illustration
                    SizedBox(
                      height: 180,
                      child:
                          widget.illustration ??
                          Image.asset(
                            widget.illustrationPath!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback si l'image n'existe pas
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            },
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Titre
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Message
                    if (widget.message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.message!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Actions
                    if (widget.actionLabel != null) ...[
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: widget.onAction,
                        child: Text(widget.actionLabel!),
                      ),
                    ],

                    if (widget.secondaryActionLabel != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onSecondaryAction,
                        child: Text(widget.secondaryActionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⏳ LOADING STATE - État de chargement
// ═══════════════════════════════════════════════════════════════════════════

/// État de chargement animé
///
/// **Quand l'utiliser :**
/// - Pendant le chargement initial de données
/// - En attente d'une opération longue
///
/// **Exemple :**
/// ```dart
/// if (isLoading)
///   LoadingState(message: 'Chargement des lapins...')
/// else
///   LapinsList(lapins: lapins)
/// ```
class LoadingState extends StatefulWidget {
  /// Message de chargement
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône de lapin qui saute
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final bounce = math.sin(_controller.value * math.pi * 2) * 10;
              return Transform.translate(
                offset: Offset(0, -bounce.abs()),
                child: Icon(
                  Icons.pets,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Indicateur de progression
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ❌ ERROR STATE - État d'erreur
// ═══════════════════════════════════════════════════════════════════════════

/// État d'erreur avec option de réessayer
///
/// **Quand l'utiliser :**
/// - Erreur de chargement de données
/// - Échec d'une opération
/// - Problème de connexion
///
/// **Exemple :**
/// ```dart
/// ErrorState(
///   message: 'Impossible de charger les données',
///   onRetry: () => _rechargerDonnees(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// Message d'erreur
  final String message;

  /// Détails techniques (optionnel, pour le debug)
  final String? details;

  /// Callback pour réessayer
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône d'erreur
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Détails (mode debug)
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Bouton réessayer
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
