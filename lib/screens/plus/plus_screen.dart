import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/modern_app_card.dart';
import '../parametres/parametres_screen.dart';
import '../finance/finance_screen.dart';
import '../alimentation/inventaire_aliments_screen.dart';
import '../alertes/alertes_screen.dart';
import '../rentabilite/fumier_screen.dart';
import '../rentabilite/reforme_screen.dart';
import '../optimisation/courbes_croissance_screen.dart';
import '../utilitaire/calculatrice_screen.dart';
import '../utilitaire/rapports_screen.dart';
import '../utilitaire/export_import_screen.dart';
import '../utilitaire/calendrier_screen.dart';
import '../utilitaire/localisation_screen.dart';
import '../utilitaire/notes_screen.dart';
import '../taches/gestionnaire_taches_screen.dart';
import '../lots/lots_screen.dart';

/// Écran Plus - Sections secondaires et outils
/// Remplace l'ancien onglet Utilitaires pour libérer place à Finances
class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          // Fixed header
          StandardHeader(
            title: AppLocalizations.of(context).plusTitre,
            isDark: isDark,
            onSync: () async {
              final syncProvider = context.read<SyncProvider>();
              await syncProvider.syncNow();
            },
            onNotifications: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertesScreen()),
              );
            },
            onSettings: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ParametresScreen()),
              );
            },
          ),
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HeroSection(
                    title: AppLocalizations.of(context).plusSousTitre,
                    subtitle: AppLocalizations.of(context).plusDescription,
                    isDark: isDark,
                  ),
                ),

                // Section Gestion
                _buildSliverSectionTitle(
                  context,
                  AppLocalizations.of(context).plusGestion,
                  isDark,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      // NOUVEAU: Gestion par Lots
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilLots,
                        subtitle: AppLocalizations.of(context).utilLotsDetail,
                        icon: Icons.inventory_2_rounded,
                        iconColor: AppTheme.accentGreen,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LotsScreen()),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilAlimentation,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilAlimentationDetail,
                        icon: Icons.grass_rounded,
                        iconColor: AppTheme.primaryGreenLight,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventaireAlimentsScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilLocalisation,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilLocalisationDetail,
                        icon: Icons.location_on_rounded,
                        iconColor: AppTheme.info,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocalisationScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilTaches,
                        subtitle: AppLocalizations.of(context).utilTachesDetail,
                        icon: Icons.checklist_rounded,
                        iconColor: AppTheme.warning,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GestionnaireTachesScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilAlertes,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilAlertesDetail,
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppTheme.error,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AlertesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Rentabilité
                _buildSliverSectionTitle(
                  context,
                  AppLocalizations.of(context).plusRentabilite,
                  isDark,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      ModernAppCard(
                        title: AppLocalizations.of(context).navFinances,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilFinancesDetail,
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppTheme.success,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FinanceScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(
                          context,
                        ).utilCourbesCroissance,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilCourbesCroissanceDetail,
                        icon: Icons.show_chart_rounded,
                        iconColor: AppTheme.info,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CourbesCroissanceScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilFumierCompost,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilFumierCompostDetail,
                        icon: Icons.compost_rounded,
                        iconColor: AppTheme.warning,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FumierScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilReforme,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilReformeDetail,
                        icon: Icons.remove_circle_outline_rounded,
                        iconColor: AppTheme.error,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReformeScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Outils
                _buildSliverSectionTitle(
                  context,
                  AppLocalizations.of(context).plusOutils,
                  isDark,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilCalculatrice,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilCalculatriceDetail,
                        icon: Icons.calculate_rounded,
                        iconColor: AppTheme.accentTeal,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalculatriceScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilRapports,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilRapportsDetail,
                        icon: Icons.description_rounded,
                        iconColor: AppTheme.primaryGreen,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RapportsScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilExportImport,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilExportImportDetail,
                        icon: Icons.import_export_rounded,
                        iconColor: AppTheme.info,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExportImportScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilCalendrier,
                        subtitle: AppLocalizations.of(
                          context,
                        ).utilCalendrierDetail,
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppTheme.accentPink,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalendrierScreen(),
                          ),
                        ),
                      ),
                      ModernAppCard(
                        title: AppLocalizations.of(context).utilNotes,
                        subtitle: AppLocalizations.of(context).utilNotesDetail,
                        icon: Icons.sticky_note_2_rounded,
                        iconColor: AppTheme.warning,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverSectionTitle(
    BuildContext context,
    String title,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: 12,
        ),
        child: Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
