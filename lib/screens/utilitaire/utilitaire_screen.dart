import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Column(
        children: [
          StandardHeader(title: 'Utilitaires', isDark: isDark),
          HeroSection(
            title: 'Outils de gestion',
            subtitle: 'Accédez aux différentes fonctionnalités',
            isDark: isDark,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              children: [
                ActionCard(
                  isDark: isDark,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Finances',
                  subtitle: 'Gérez vos recettes et dépenses',
                  iconColor: AppTheme.primaryGreen,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.grass_rounded,
                  title: 'Alimentation',
                  subtitle: 'Inventaire et distribution',
                  iconColor: AppTheme.primaryGreenLight,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventaireAlimentsScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.notifications_active_rounded,
                  title: 'Alertes',
                  subtitle: 'Notifications et rappels',
                  iconColor: AppTheme.error,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertesScreen())),
                ),
                _buildSectionTitle('Optimisation', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.show_chart_rounded,
                  title: 'Courbes de croissance',
                  subtitle: 'Évolution du poids',
                  iconColor: AppTheme.info,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourbesCroissanceScreen())),
                ),
                _buildSectionTitle('Rentabilité', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.eco_rounded,
                  title: 'Fumier & Compost',
                  subtitle: 'Gestion et valorisation',
                  iconColor: AppTheme.warning,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FumierScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.trending_down_rounded,
                  title: 'Réforme',
                  subtitle: 'Gestion des réformes',
                  iconColor: AppTheme.textSecondary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReformeScreen())),
                ),
                _buildSectionTitle('Outils', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.calculate_rounded,
                  title: 'Calculatrice',
                  subtitle: 'Calculs et estimations',
                  iconColor: AppTheme.info,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatriceScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.assessment_rounded,
                  title: 'Rapports',
                  subtitle: 'Générez des rapports',
                  iconColor: AppTheme.accentPink,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RapportsScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.calendar_today_rounded,
                  title: 'Calendrier',
                  subtitle: 'Planifiez vos activités',
                  iconColor: AppTheme.accentTeal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendrierScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.note_rounded,
                  title: 'Notes',
                  subtitle: 'Prenez des notes',
                  iconColor: AppTheme.error,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.import_export_rounded,
                  title: 'Export / Import',
                  subtitle: 'Sauvegardez vos données',
                  iconColor: AppTheme.info,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportImportScreen())),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.location_on_rounded,
                  title: 'Localisation',
                  subtitle: 'Gérez vos emplacements',
                  iconColor: AppTheme.accentTeal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalisationScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing24, bottom: AppTheme.spacing16),
      child: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
    );
  }
}
