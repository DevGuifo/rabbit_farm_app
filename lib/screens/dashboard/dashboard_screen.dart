import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../theme/app_theme.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import '../cheptel/add_lapin_screen.dart';
import '../../utils/logger.dart';

/// Dashboard moderne Stitch Design - Farm Overview
/// Reconstruction complète UI selon design Stitch
class ModernDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ModernDashboardScreen({super.key, this.onNavigate});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    try {
      await Future.wait([
        context.read<LapinProvider>().chargerLapins(),
        context.read<ReproductionProvider>().chargerTout(),
        context.read<SanteProvider>().chargerTout(),
      ]);
    } catch (e) {
      if (mounted) {
        logger.error('❌ Erreur chargement dashboard', e);
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
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildStickyHeader(isDark),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(isDark),
                  const SizedBox(height: 16),
                  _buildStatsCardsHorizontal(isDark),
                  const SizedBox(height: 20),
                  _buildHealthAlert(isDark),
                  const SizedBox(height: 20),
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

  /// Header sticky avec backdrop blur
  Widget _buildStickyHeader(bool isDark) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor:
          (isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight)
              .withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Text(
        'Farm Overview',
        style: AppTheme.titleLarge.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.sync,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: _chargerDonnees,
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertesScreen()),
                );
              },
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppTheme.backgroundDarkMode
                        : AppTheme.backgroundLight,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParametresScreen()),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Section greeting personnalisée
  Widget _buildGreetingSection(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = 'Bonjour';
    if (hour >= 12 && hour < 18) {
      greeting = 'Bon après-midi';
    } else if (hour >= 18) {
      greeting = 'Bonsoir';
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
            'Voici ce qui se passe dans votre élevage aujourd\'hui.',
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
            'label': 'Total Rabbits',
            'value': '${stats['total'] ?? 0}',
          },
          {
            'icon': Icons.pets,
            'label': 'Breeding Does',
            'value': '${stats['femelles'] ?? 0}',
          },
          {
            'icon': Icons.child_care,
            'label': 'Kits (0-8 wks)',
            'value': '${stats['lapereaux'] ?? 0}',
          },
        ];

        return SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: cardsData.length,
            itemBuilder: (context, index) {
              final card = cardsData[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  right: index < cardsData.length - 1 ? 16 : 0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                    Text(
                      card['value'] as String,
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 30,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
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
  }

  /// Health Alert card (orange)
  Widget _buildHealthAlert(bool isDark) {
    return Consumer<SanteProvider>(
      builder: (context, santeProvider, _) {
        // Compter les lapins nécessitant des soins urgents
        final soinsUrgents = santeProvider.soins
            .where(
              (soin) =>
                  soin.dateRappel != null &&
                  soin.dateRappel!.isBefore(
                    DateTime.now().add(const Duration(days: 3)),
                  ),
            )
            .length;

        if (soinsUrgents == 0) {
          // Pas d'alerte, retour vide
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.warning.withValues(alpha: 0.15)
                  : AppTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isDark
                    ? AppTheme.warning.withValues(alpha: 0.4)
                    : AppTheme.warning.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icône en arrière-plan
                Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(
                    Icons.medical_services,
                    size: 64,
                    color: Colors.orange.shade500.withValues(alpha: 0.1),
                  ),
                ),
                // Contenu
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.warning.withValues(alpha: 0.3)
                                  : AppTheme.warning.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.priority_high,
                              size: 18,
                              color: AppTheme.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alerte Santé',
                            style: AppTheme.titleMedium.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$soinsUrgents lapin${soinsUrgents > 1 ? 's' : ''} nécessite${soinsUrgents > 1 ? 'nt' : ''} un suivi de santé dans les prochains jours.',
                        style: AppTheme.titleSmall.copyWith(
                          color: isDark
                              ? Colors.grey.shade200
                              : Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigation vers Santé
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(3); // Index Santé
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.warning.withValues(alpha: 0.3)
                              : AppTheme.cardLight,
                          foregroundColor: isDark
                              ? AppTheme.warning
                              : AppTheme.warning,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusRound,
                            ),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.transparent
                                  : AppTheme.warning.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Voir détails',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    'Tâches à venir',
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
                      'Voir tout',
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
      status = 'En retard (${-joursRestants} jours)';
      statusColor = Colors.red;
    } else if (joursRestants == 0) {
      status = 'Aujourd\'hui';
      statusColor = Colors.orange;
    } else if (joursRestants <= 3) {
      status = 'Dans $joursRestants jour${joursRestants > 1 ? 's' : ''}';
      statusColor = Colors.orange;
    } else {
      status = 'Dans $joursRestants jours';
      statusColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: index < total - 1 ? 12 : 0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  'Mise bas prévue #${accouplement.id}',
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
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
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
