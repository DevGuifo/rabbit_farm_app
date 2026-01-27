import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/tache_provider.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import '../cheptel/add_lapin_screen_validated.dart';
import '../reproduction/planifier_accouplement_screen.dart';
import '../sante/sante_screen.dart';
import '../../utils/logger.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../widgets/dashboard/critical_indicators_section.dart';
import '../../widgets/dashboard/performance_indicators_section.dart';
import '../../widgets/dashboard/roi_performance_section.dart';
import '../../widgets/dashboard/discipline_section.dart';
import '../../widgets/dashboard/upcoming_tasks_section.dart';
import '../../widgets/tache_card.dart';
import '../../widgets/dashboard/dashboard_skeleton.dart';
import '../../widgets/animations/fade_in_slide.dart';

/// Dashboard moderne Stitch Design - Farm Overview
/// Reconstruction complète UI selon design Stitch
class ModernDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ModernDashboardScreen({super.key, this.onNavigate});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  final KpiService _kpiService = KpiService();
  KpiData? _kpiData;
  bool _isLoadingKpis = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    try {
      await Future.wait([
        context.read<LapinProvider>().chargerLapins(),
        context.read<ReproductionProvider>().chargerTout(),
        context.read<SanteProvider>().chargerTout(),
        context.read<TacheProvider>().chargerTaches(),
        context.read<AnomalieProvider>().chargerTout(),
      ]);

      // Charger les KPIs
      if (mounted) {
        setState(() => _isLoadingKpis = true);
        final kpis = await _kpiService.calculerTousLesKpis();
        if (mounted) {
          setState(() {
            _kpiData = kpis;
            _isLoadingKpis = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        logger.error('❌ Erreur chargement dashboard', e);
        setState(() => _isLoadingKpis = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: _isLoadingKpis
          ? const DashboardSkeleton() // 1. Skeleton Loading
          : Column(
              children: [
                // Fixed header (like cheptel_screen)
                _buildStickyHeader(isDark),
                // Scrollable content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _chargerDonnees,
                    color: AppTheme.accentGreen,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📡 INDICATEUR HORS LIGNE
                              const OfflineBanner(),

                              // 2. Animations en cascade (Staggered Animations)
                              FadeInSlide(
                                delay: const Duration(milliseconds: 100),
                                child: _buildGreetingSection(isDark),
                              ),
                              const SizedBox(height: 16),

                              FadeInSlide(
                                delay: const Duration(milliseconds: 200),
                                child: const TacheCard(),
                              ),
                              const SizedBox(height: 20),

                              FadeInSlide(
                                delay: const Duration(milliseconds: 300),
                                child: DisciplineSection(isDark: isDark),
                              ),
                              const SizedBox(height: 20),

                              // Note: StatsCardsSection supprimé car duplique PerformanceIndicatorsSection
                              if (_kpiData != null) ...[
                                FadeInSlide(
                                  delay: const Duration(milliseconds: 500),
                                  child: CriticalIndicatorsSection(
                                    kpis: _kpiData!,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                FadeInSlide(
                                  delay: const Duration(milliseconds: 600),
                                  child: PerformanceIndicatorsSection(
                                    kpis: _kpiData!,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                FadeInSlide(
                                  delay: const Duration(milliseconds: 700),
                                  child: RoiPerformanceSection(
                                    kpis: _kpiData!,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              FadeInSlide(
                                delay: const Duration(milliseconds: 800),
                                child: UpcomingTasksSection(
                                  isDark: isDark,
                                  onNavigateToReproduction: () {
                                    if (widget.onNavigate != null) {
                                      widget.onNavigate!(2);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header fixe - Utilise StandardHeader unifié
  Widget _buildStickyHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).dashFarmOverview,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        _chargerDonnees();
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
      showNotificationBadge: true,
      notificationCount: context.read<AlerteProvider>().nombreAlertesNonLues,
    );
  }

  /// Section greeting personnalisée
  Widget _buildGreetingSection(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = AppLocalizations.of(context).dashBonjour;
    if (hour >= 12 && hour < 18) {
      greeting = AppLocalizations.of(context).dashBonApresMidi;
    } else if (hour >= 18) {
      greeting = AppLocalizations.of(context).dashBonsoir;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 28,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).dashVoiciCeQuiSePasse,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// FAB Speed Dial avec actions rapides
  Widget _buildFAB() {
    return UnifiedFABSpeedDial(
      actions: [
        UnifiedFABAction(
          icon: Icons.warning_amber_rounded,
          label: AppLocalizations.of(context).dashActionNoterAnomalie,
          tooltip: AppLocalizations.of(context).dashActionNoterAnomalie,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
          backgroundColor: AppTheme.error,
        ),
        UnifiedFABAction(
          icon: Icons.monitor_weight_outlined,
          label: AppLocalizations.of(context).dashActionAjouterPesee,
          tooltip: AppLocalizations.of(context).dashActionAjouterPesee,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
          backgroundColor: AppTheme.info,
        ),
        UnifiedFABAction(
          icon: Icons.favorite_border,
          label: AppLocalizations.of(context).dashActionAccouplement,
          tooltip: AppLocalizations.of(context).dashActionAccouplement,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlanifierAccouplementScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.accentPink,
        ),
        UnifiedFABAction(
          icon: Icons.cruelty_free,
          label: AppLocalizations.of(context).dashActionNouveauLapin,
          tooltip: AppLocalizations.of(context).dashActionNouveauLapin,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddLapinScreenWithValidation(),
              ),
            );
          },
          backgroundColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }
}
