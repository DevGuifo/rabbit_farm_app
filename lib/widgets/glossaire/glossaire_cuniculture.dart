import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Définition d'un terme du glossaire cuniculture
class TermeGlossaire {
  final String terme;
  final String definition;
  final String? exempleUsage;
  final IconData? icone;

  const TermeGlossaire({
    required this.terme,
    required this.definition,
    this.exempleUsage,
    this.icone,
  });
}

/// Glossaire des termes techniques de cuniculture
/// Utilisé pour les tooltips explicatifs dans toute l'application
class GlossaireCuniculture {
  static const Map<String, TermeGlossaire> termes = {
    'saillie': TermeGlossaire(
      terme: 'Saillie',
      definition:
          'Accouplement entre un mâle et une femelle reproducteurs. '
          'La femelle est amenée dans la cage du mâle pour la reproduction.',
      exempleUsage: 'Planifier une saillie pour le 15 janvier',
      icone: Icons.favorite,
    ),
    'mise_bas': TermeGlossaire(
      terme: 'Mise bas',
      definition:
          'Moment où la lapine donne naissance aux lapereaux. '
          'Aussi appelé parturition. Durée moyenne de gestation: 31 jours.',
      exempleUsage: 'Mise bas prévue dans 10 jours',
      icone: Icons.child_care,
    ),
    'gestation': TermeGlossaire(
      terme: 'Gestation',
      definition:
          'Période de grossesse chez la lapine. '
          'Durée moyenne de 31 jours (28-34 jours). '
          'Vérifiable par palpation à partir du 10ème jour.',
      exempleUsage: 'La femelle est en gestation depuis 15 jours',
      icone: Icons.pregnant_woman,
    ),
    'lapereaux': TermeGlossaire(
      terme: 'Lapereaux',
      definition:
          'Jeunes lapins de la naissance jusqu\'au sevrage. '
          'Naissent aveugles et sans poils, deviennent autonomes vers 3-4 semaines.',
      exempleUsage: 'Portée de 8 lapereaux',
      icone: Icons.pets,
    ),
    'sevrage': TermeGlossaire(
      terme: 'Sevrage',
      definition:
          'Séparation des lapereaux de leur mère. '
          'Généralement entre 4 et 8 semaines selon le poids (minimum 800g). '
          'Marque la fin de l\'allaitement.',
      exempleUsage: 'Sevrage prévu à 5 semaines',
      icone: Icons.exit_to_app,
    ),
    'palpation': TermeGlossaire(
      terme: 'Palpation',
      definition:
          'Technique de diagnostic de gestation par toucher abdominal. '
          'Réalisable à partir du 10ème jour après la saillie. '
          'Permet de sentir les embryons de la taille d\'un pois.',
      exempleUsage: 'Palpation positive à J+12',
      icone: Icons.touch_app,
    ),
    'portee': TermeGlossaire(
      terme: 'Portée',
      definition:
          'Ensemble des lapereaux nés d\'une même mise bas. '
          'Taille moyenne: 6-12 lapereaux selon la race et l\'âge de la mère.',
      exempleUsage: 'Belle portée de 9 lapereaux vivants',
      icone: Icons.groups,
    ),
    'clapier': TermeGlossaire(
      terme: 'Clapier',
      definition:
          'Logement individuel ou collectif pour les lapins. '
          'Peut être en bois, métal ou grillage. Doit permettre hygiène et aération.',
      exempleUsage: 'Nettoyer le clapier chaque semaine',
      icone: Icons.home,
    ),
    'nid': TermeGlossaire(
      terme: 'Nid / Boîte à nid',
      definition:
          'Boîte de maternité préparée par la lapine avant la mise bas. '
          'La femelle y dépose ses poils pour créer un nid douillet. '
          'À mettre en place 3-5 jours avant la date prévue.',
      exempleUsage: 'Préparer le nid pour la mise bas',
      icone: Icons.home_work,
    ),
    'gmq': TermeGlossaire(
      terme: 'GMQ (Gain Moyen Quotidien)',
      definition:
          'Indicateur de croissance exprimé en grammes par jour. '
          'Calculé: (Poids actuel - Poids précédent) / Nombre de jours. '
          'Objectif typique: 35-45g/jour pour un lapin en croissance.',
      exempleUsage: 'GMQ de 42g/j cette semaine',
      icone: Icons.trending_up,
    ),
    'reforme': TermeGlossaire(
      terme: 'Réforme / Sortie d\'élevage',
      definition:
          'Sortie définitive d\'un animal du cheptel reproducteur. '
          'Raisons possibles: âge avancé, performances insuffisantes, problèmes de santé.',
      exempleUsage: 'Réforme pour baisse de fertilité',
      icone: Icons.logout,
    ),
    'consanguinite': TermeGlossaire(
      terme: 'Consanguinité',
      definition:
          'Taux de parenté génétique entre deux reproducteurs. '
          'À surveiller pour éviter les problèmes génétiques. '
          'Éviter les accouplements entre parents proches.',
      exempleUsage: 'Taux de consanguinité: 6.25%',
      icone: Icons.family_restroom,
    ),
    'lactation': TermeGlossaire(
      terme: 'Lactation',
      definition:
          'Période de production de lait par la lapine. '
          'Dure environ 4-6 semaines. La lapine allaite 1 fois par jour.',
      exempleUsage: 'En pleine lactation',
      icone: Icons.water_drop,
    ),
    'prolificite': TermeGlossaire(
      terme: 'Prolificité',
      definition:
          'Capacité d\'une femelle à produire de nombreux lapereaux. '
          'Indicateur clé de performance. Moyenne: 7-10 lapereaux/portée.',
      exempleUsage: 'Excellente prolificité: 10 nés vivants',
      icone: Icons.star,
    ),
    'quarantaine': TermeGlossaire(
      terme: 'Quarantaine',
      definition:
          'Période d\'isolement d\'un animal à l\'arrivée ou en cas de maladie. '
          'Durée recommandée: 2-4 semaines. Permet d\'éviter la propagation de maladies.',
      exempleUsage: 'Mise en quarantaine de 3 semaines',
      icone: Icons.shield,
    ),
  };

  /// Obtenir la définition d'un terme
  static String? getDefinition(String terme) {
    final key = terme.toLowerCase().replaceAll(' ', '_');
    return termes[key]?.definition;
  }

  /// Obtenir un terme complet
  static TermeGlossaire? getTerme(String terme) {
    final key = terme.toLowerCase().replaceAll(' ', '_');
    return termes[key];
  }

  /// Liste de tous les termes pour affichage
  static List<TermeGlossaire> get listeTermes => termes.values.toList();
}

/// Widget Tooltip explicatif pour les termes techniques
/// Affiche une icône d'aide avec tooltip au survol/tap
class TooltipGlossaire extends StatelessWidget {
  final String terme;
  final Color? iconColor;
  final double iconSize;

  const TooltipGlossaire({
    super.key,
    required this.terme,
    this.iconColor,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final termeGlossaire = GlossaireCuniculture.getTerme(terme);
    if (termeGlossaire == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: termeGlossaire.definition,
      preferBelow: false,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        fontSize: 13,
      ),
      child: Icon(
        Icons.help_outline,
        size: iconSize,
        color:
            iconColor ??
            (isDark ? AppTheme.textSecondary : AppTheme.textSecondary),
      ),
    );
  }
}

/// Widget texte avec tooltip intégré
/// Combine le texte du terme avec un tooltip explicatif
class TexteAvecTooltip extends StatelessWidget {
  final String terme;
  final TextStyle? style;
  final bool showIcon;

  const TexteAvecTooltip({
    super.key,
    required this.terme,
    this.style,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final termeGlossaire = GlossaireCuniculture.getTerme(terme);
    final hasDefinition = termeGlossaire != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: hasDefinition
          ? () => _showDefinitionDialog(context, termeGlossaire)
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            termeGlossaire?.terme ?? terme,
            style: style?.copyWith(
              decoration: hasDefinition ? TextDecoration.underline : null,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          ),
          if (showIcon && hasDefinition) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline,
              size: 14,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  void _showDefinitionDialog(BuildContext context, TermeGlossaire terme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (terme.icone != null) ...[
              Icon(terme.icone, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                terme.terme,
                style: TextStyle(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              terme.definition,
              style: TextStyle(
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            if (terme.exempleUsage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ex: ${terme.exempleUsage}',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Compris',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Écran complet du glossaire cuniculture
class GlossaireScreen extends StatelessWidget {
  const GlossaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final termes = GlossaireCuniculture.listeTermes;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).widgetGlossaireCuniculture),
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.primaryGreen,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: termes.length,
        itemBuilder: (context, index) {
          final terme = termes[index];
          return Card(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: terme.icone != null
                  ? Icon(terme.icone, color: AppTheme.primaryGreen)
                  : null,
              title: Text(
                terme.terme,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        terme.definition,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      if (terme.exempleUsage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ex: ${terme.exempleUsage}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
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
          );
        },
      ),
    );
  }
}
