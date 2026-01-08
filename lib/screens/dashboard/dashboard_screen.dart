import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/rituel_provider.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import '../cheptel/add_lapin_screen.dart';
import '../../utils/logger.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../widgets/dashboard/critical_indicators_section.dart';
import '../../widgets/dashboard/performance_indicators_section.dart';
import '../../widgets/dashboard/discipline_section.dart';
import '../../widgets/rituel_card.dart';

/// Dashboard moderne Stitch Design - Farm Overview
/// Reconstruction complète UI selon design Stitch
class ModernDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ModernDashboardScreen({super.key, this.onNavigate});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    try {
      await Future.wait([
        context.read<LapinProvider>().chargerLapins(),
        context.read<ReproductionProvider>().chargerTout(),
        context.read<SanteProvider>().chargerTout(),
        context.read<RituelProvider>().chargerRituelsJour(),
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
      body: RefreshIndicator(
        onRefresh: _chargerDonnees,
        color: AppTheme.primaryYellow,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildStickyHeader(isDark),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(isDark),
                  const SizedBox(height: 16),

                  // 🌅 RITUELS QUOTIDIENS - Section prioritaire
                  const RituelCard(),
                  const SizedBox(height: 20),

                  // 📊 DISCIPLINE OPÉRATIONNELLE - Miroir de rigueur
                  DisciplineSection(isDark: isDark),
                  const SizedBox(height: 20),

                  _buildStatsCardsHorizontal(isDark),

                  if (_kpiData != null && !_isLoadingKpis) ...[
                    CriticalIndicatorsSection(kpis: _kpiData!, isDark: isDark),
                    const SizedBox(height: 24),

                    // ✅ NOUVELLE SECTION : Performance globale
                    PerformanceIndicatorsSection(
                      kpis: _kpiData!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Message de chargement
                  if (_isLoadingKpis)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  _buildUpcomingTasks(isDark),
                  const SizedBox(height: 100), // Space pour FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header sticky - Utilise StandardHeader unifié
  Widget _buildStickyHeader(bool isDark) {
    return SliverToBoxAdapter(
      child: StandardHeader(
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
      ),
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

  /// Stats cards horizontales scrollables
  Widget _buildStatsCardsHorizontal(bool isDark) {
    return Consumer3<LapinProvider, ReproductionProvider, SanteProvider>(
      builder: (context, lapinProv, reproProv, santeProv, _) {
        final stats = lapinProv.getStatistiquesCheptel(reproProv);

        final cardsData = [
          {
            'icon': Icons.cruelty_free,
            'label': AppLocalizations.of(context).dashTotalLapins,
            'value': '${stats['total'] ?? 0}',
          },
          {
            'icon': Icons.pets,
            'label': AppLocalizations.of(context).dashFemellesReproduction,
            'value': '${stats['femelles'] ?? 0}',
          },
          {
            'icon': Icons.child_care,
            'label': AppLocalizations.of(context).dashLapereaux,
            'value': '${stats['lapereaux'] ?? 0}',
          },
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 600 ? 180.0 : 150.0;

            return SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: cardsData.length,
                itemBuilder: (context, index) {
                  final card = cardsData[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(
                      right: index < cardsData.length - 1 ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.neutral800
                            : AppTheme.neutral100,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              card['icon'] as IconData,
                              size: 20,
                              color:
                                  (isDark
                                          ? AppTheme.textLight
                                          : AppTheme.textSecondary)
                                      .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                card['label'] as String,
                                style: AppTheme.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      (isDark
                                              ? AppTheme.textLight
                                              : AppTheme.textSecondary)
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            card['value'] as String,
                            style: AppTheme.titleLarge.copyWith(
                              fontSize: 30,
                              color: isDark
                                  ? AppTheme.textOnPrimary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Upcoming Tasks avec checkboxes
  Widget _buildUpcomingTasks(bool isDark) {
    return Consumer<ReproductionProvider>(
      builder: (context, reproProvider, _) {
        // Récupérer les accouplements prévus et les portées attendues
        final accouplementsPrevus = reproProvider.accouplements
            .where((acc) => acc.statut == 'en_attente')
            .take(3)
            .toList();

        if (accouplementsPrevus.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).dashTachesAVenir,
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 22,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Naviguer vers reproduction
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(2); // Index Reproduction
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).dashVoirTout,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(accouplementsPrevus.length, (index) {
                final accouplement = accouplementsPrevus[index];
                return _buildTaskCard(
                  accouplement,
                  isDark,
                  index,
                  accouplementsPrevus.length,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(
    dynamic accouplement,
    bool isDark,
    int index,
    int total,
  ) {
    // Calculer le statut
    final dateMiseBas = accouplement.dateMiseBasPrevue;
    final joursRestants = dateMiseBas.difference(DateTime.now()).inDays;

    String status;
    Color statusColor;
    IconData icon = Icons.family_restroom;

    if (joursRestants < 0) {
      status = AppLocalizations.of(context).dashEnRetard(-joursRestants);
      statusColor = AppTheme.error;
    } else if (joursRestants == 0) {
      status = AppLocalizations.of(context).dashAujourdhui;
      statusColor = AppTheme.warning;
    } else if (joursRestants <= 3) {
      status = joursRestants == 1
          ? AppLocalizations.of(context).dashDansJour(joursRestants)
          : AppLocalizations.of(context).dashDansJours(joursRestants);
      statusColor = AppTheme.warning;
    } else {
      status = AppLocalizations.of(context).dashDansJours(joursRestants);
      statusColor = AppTheme.neutral500;
    }

    return Container(
      margin: EdgeInsets.only(bottom: index < total - 1 ? 12 : 0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).dashMiseBasPrevue(accouplement.id!),
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark
                        ? AppTheme.textOnPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Icône
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// FAB jaune
  Widget _buildFAB() {
    return FloatingActionButton(
      heroTag: 'fab_dashboard',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddLapinScreen()),
        );
      },
      backgroundColor: AppTheme.primaryYellow,
      foregroundColor: AppTheme.textPrimary,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
