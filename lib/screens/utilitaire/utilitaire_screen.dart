import 'package:flutter/material.dart';
import '../finance/finance_screen.dart';
import '../alimentation/inventaire_aliments_screen.dart';
import '../alertes/alertes_screen.dart';
import '../rentabilite/fumier_screen.dart';
import '../rentabilite/reforme_screen.dart';
import '../optimisation/courbes_croissance_screen.dart';
import 'calculatrice_screen.dart';
import 'rapports_screen.dart';
import 'export_import_screen.dart';
import 'calendrier_screen.dart';
import 'localisation_screen.dart';
import 'notes_screen.dart';

/// Écran Utilitaire - Hub des fonctionnalités
class UtilitaireScreen extends StatelessWidget {
  const UtilitaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Utilitaires',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outils de gestion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accédez aux différentes fonctionnalités',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Carte Finances
          _buildUtilityCard(
            context: context,
            title: 'Finances',
            description: 'Gérez vos recettes et dépenses',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinanceScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Alimentation
          _buildUtilityCard(
            context: context,
            title: 'Alimentation',
            description: 'Inventaire et distribution d\'aliments',
            icon: Icons.grass_rounded,
            color: const Color(0xFF8BC34A),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventaireAlimentsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Alertes
          _buildUtilityCard(
            context: context,
            title: 'Alertes',
            description: 'Notifications et rappels importants',
            icon: Icons.notifications_active_rounded,
            color: const Color(0xFFFF5722),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertesScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Section Optimisation (Phase 3)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Optimisation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Carte Courbes de croissance
          _buildUtilityCard(
            context: context,
            title: 'Courbes de croissance',
            description: 'Visualisation de l\'évolution du poids',
            icon: Icons.show_chart_rounded,
            color: const Color(0xFF00BCD4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourbesCroissanceScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Section Rentabilité
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Rentabilité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Carte Fumier
          _buildUtilityCard(
            context: context,
            title: 'Fumier & Compost',
            description: 'Gestion et valorisation du fumier',
            icon: Icons.eco_rounded,
            color: const Color(0xFF795548),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FumierScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Réforme
          _buildUtilityCard(
            context: context,
            title: 'Réforme',
            description: 'Gestion des réformes et ventes',
            icon: Icons.trending_down_rounded,
            color: const Color(0xFF607D8B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReformeScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Section Outils
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Outils',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Carte Calculatrice
          _buildUtilityCard(
            context: context,
            title: 'Calculatrice',
            description: 'Calculs d\'alimentation et de santé',
            icon: Icons.calculate_rounded,
            color: const Color(0xFF2196F3),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculatriceScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Rapports
          _buildUtilityCard(
            context: context,
            title: 'Rapports',
            description: 'Générez des rapports détaillés',
            icon: Icons.assessment_rounded,
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RapportsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Calendrier
          _buildUtilityCard(
            context: context,
            title: 'Calendrier',
            description: 'Planifiez vos activités',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendrierScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Notes
          _buildUtilityCard(
            context: context,
            title: 'Notes',
            description: 'Prenez des notes importantes',
            icon: Icons.note_rounded,
            color: const Color(0xFFE91E63),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Export/Import
          _buildUtilityCard(
            context: context,
            title: 'Export / Import',
            description: 'Sauvegardez et restaurez vos données',
            icon: Icons.import_export_rounded,
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportImportScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Carte Localisation
          _buildUtilityCard(
            context: context,
            title: 'Localisation',
            description: 'Gérez bâtiments, zones et cages',
            icon: Icons.location_on_rounded,
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocalisationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
