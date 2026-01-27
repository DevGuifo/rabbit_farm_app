import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../utils/navigation_helper.dart';
import '../parametres/parametres_screen.dart';
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
import '../taches/gestionnaire_taches_screen.dart';

/// Écran Utilitaire - Hub des fonctionnalités
class UtilitaireScreen extends StatelessWidget {
  const UtilitaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header - Utilise StandardHeader unifié
          StandardHeader(
            title: AppLocalizations.of(context).utilTitre,
            isDark: isDark,
            onSync: () async {
              // Synchroniser
              final syncProvider = context.read<SyncProvider>();
              await syncProvider.syncNow();
            },
            onNotifications: () {
              NavigationHelper.openModalWithHeight(
                context: context,
                child: const AlertesScreen(),
                maxHeight: 0.95,
              );
            },
            onSettings: () {
              NavigationHelper.openModalWithHeight(
                context: context,
                child: const ParametresScreen(),
                maxHeight: 0.95,
              );
            },
          ),
          HeroSection(
            title: AppLocalizations.of(context).utilOutilsGestion,
            subtitle: AppLocalizations.of(context).utilOutilsGestionDetail,
            isDark: isDark,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              children: [
                ActionCard(
                  isDark: isDark,
                  icon: Icons.account_balance_wallet_rounded,
                  title: AppLocalizations.of(context).utilFinances,
                  subtitle: AppLocalizations.of(context).utilFinancesDetail,
                  iconColor: AppTheme.primaryGreen,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const FinanceScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.grass_rounded,
                  title: AppLocalizations.of(context).utilAlimentation,
                  subtitle: AppLocalizations.of(context).utilAlimentationDetail,
                  iconColor: AppTheme.primaryGreenLight,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const InventaireAlimentsScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.notifications_active_rounded,
                  title: AppLocalizations.of(context).utilAlertes,
                  subtitle: AppLocalizations.of(context).utilAlertesDetail,
                  iconColor: AppTheme.error,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const AlertesScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                _buildSectionTitle('Optimisation', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.show_chart_rounded,
                  title: AppLocalizations.of(context).utilCourbesCroissance,
                  subtitle: AppLocalizations.of(
                    context,
                  ).utilCourbesCroissanceDetail,
                  iconColor: AppTheme.info,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const CourbesCroissanceScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                _buildSectionTitle('Rentabilité', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.eco_rounded,
                  title: AppLocalizations.of(context).utilFumierCompost,
                  subtitle: AppLocalizations.of(
                    context,
                  ).utilFumierCompostDetail,
                  iconColor: AppTheme.warning,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const FumierScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.trending_down_rounded,
                  title: AppLocalizations.of(context).screenReforme,
                  subtitle: AppLocalizations.of(context).labelGestionReformes,
                  iconColor: AppTheme.textSecondary,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const ReformeScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                _buildSectionTitle('Organisation', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.task_alt_rounded,
                  title: AppLocalizations.of(context).utilGestionnaireTaches,
                  subtitle: AppLocalizations.of(
                    context,
                  ).utilGestionnaireTachesDetail,
                  iconColor: AppTheme.primaryNeonGreen,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const GestionnaireTachesScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                _buildSectionTitle('Outils', isDark),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.calculate_rounded,
                  title: AppLocalizations.of(context).utilCalculatrice,
                  subtitle: AppLocalizations.of(context).utilCalculatriceDetail,
                  iconColor: AppTheme.info,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const CalculatriceScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.assessment_rounded,
                  title: AppLocalizations.of(context).utilRapports,
                  subtitle: AppLocalizations.of(context).utilRapportsDetail,
                  iconColor: AppTheme.accentPink,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const RapportsScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.calendar_today_rounded,
                  title: AppLocalizations.of(context).utilCalendrier,
                  subtitle: AppLocalizations.of(context).utilCalendrierDetail,
                  iconColor: AppTheme.accentTeal,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const CalendrierScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.note_rounded,
                  title: AppLocalizations.of(context).utilNotes,
                  subtitle: AppLocalizations.of(context).utilNotesDetail,
                  iconColor: AppTheme.error,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const NotesScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.import_export_rounded,
                  title: AppLocalizations.of(context).utilExportImport,
                  subtitle: AppLocalizations.of(context).utilExportImportDetail,
                  iconColor: AppTheme.info,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const ExportImportScreen(),
                    maxHeight: 0.95,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ActionCard(
                  isDark: isDark,
                  icon: Icons.location_on_rounded,
                  title: AppLocalizations.of(context).utilLocalisation,
                  subtitle: AppLocalizations.of(context).utilLocalisationDetail,
                  iconColor: AppTheme.accentTeal,
                  onTap: () => NavigationHelper.openModalWithHeight(
                    context: context,
                    child: const LocalisationScreen(),
                    maxHeight: 0.95,
                  ),
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
      padding: const EdgeInsets.only(
        top: AppTheme.spacing24,
        bottom: AppTheme.spacing16,
      ),
      child: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
    );
  }
}
