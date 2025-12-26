import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../parametres/parametres_screen.dart';
import '../cheptel/add_lapin_screen.dart';
import '../reproduction/planifier_accouplement_screen.dart';

/// Dashboard moderne et futuriste - BunnyManager v2.0
class ModernDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ModernDashboardScreen({super.key, this.onNavigate});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<LapinProvider>().chargerLapins(),
        context.read<ReproductionProvider>().chargerTout(),
        context.read<SanteProvider>().chargerTout(),
      ]);
    } catch (e) {
      if (mounted) {
        debugPrint('Erreur chargement : $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _isLoading ? _buildSkeletonLoader() : _buildMainContent(),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade300,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _chargerDonnees,
      backgroundColor: Theme.of(context).colorScheme.surface,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTodayAlertsSection(),
                const SizedBox(height: 20),
                _buildStatisticsGrid(),
                const SizedBox(height: 20),
                _buildHealthScore(),
                const SizedBox(height: 20),
                _buildQuickActionsGrid(),
                const SizedBox(height: 20),
                _buildRecentActivityTimeline(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeInDown(
                    child: Row(
                      children: [
                        Text(
                          timeFormat.format(now),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.settings_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParametresScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInUp(
                    child: Text(
                      dateFormat.format(now),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAlertsSection() {
    return FadeInLeft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notification_important_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Aujourd\'hui',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child:
                Consumer3<LapinProvider, ReproductionProvider, SanteProvider>(
                  builder: (context, lapinProv, reproProv, santeProv, _) {
                    final alerts = _getTodayAlerts(reproProv, santeProv);

                    if (alerts.isEmpty) {
                      return _buildEmptyAlertCard();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _buildAlertCard(
                          alert['title']!,
                          alert['subtitle']!,
                          alert['icon'] as IconData,
                          alert['color'] as Color,
                          alert['urgency'] as int,
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTodayAlerts(
    ReproductionProvider reproProv,
    SanteProvider santeProv,
  ) {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Mises bas imminentes
    final misesBasImminentes = reproProv.accouplements.where((acc) {
      final diff = acc.dateMiseBasPrevue.difference(now).inDays;
      return diff >= 0 && diff <= 3 && acc.statut != 'termine';
    }).toList();

    if (misesBasImminentes.isNotEmpty) {
      alerts.add({
        'title': 'Mise bas',
        'subtitle': '${misesBasImminentes.length} prévue(s)',
        'icon': Icons.child_care_rounded,
        'color': const Color(0xFFFF6B6B),
        'urgency': 3,
      });
    }

    // Palpations à faire
    final palpations = reproProv.accouplements.where((acc) {
      final joursPasses = now.difference(acc.dateAccouplement).inDays;
      return joursPasses >= 10 &&
          joursPasses <= 12 &&
          acc.statut == 'en_attente';
    }).toList();

    if (palpations.isNotEmpty) {
      alerts.add({
        'title': 'Palpations',
        'subtitle': '${palpations.length} à effectuer',
        'icon': Icons.touch_app_rounded,
        'color': const Color(0xFFFFB84D),
        'urgency': 2,
      });
    }

    // Vaccinations en retard
    final vaccinationsRetard = santeProv.soins.where((soin) {
      return soin.dateRappel != null &&
          soin.dateRappel!.isBefore(now) &&
          soin.type.toLowerCase().contains('vaccin');
    }).toList();

    if (vaccinationsRetard.isNotEmpty) {
      alerts.add({
        'title': 'Vaccinations',
        'subtitle': '${vaccinationsRetard.length} en retard',
        'icon': Icons.vaccines_rounded,
        'color': const Color(0xFFE74C3C),
        'urgency': 3,
      });
    }

    // Sevrages prévus
    final sevrages = reproProv.portees.where((portee) {
      final semaines = now.difference(portee.dateMiseBasReelle).inDays ~/ 7;
      return semaines >= 5 && semaines <= 6 && portee.doitEtreSevres;
    }).toList();

    if (sevrages.isNotEmpty) {
      alerts.add({
        'title': 'Sevrages',
        'subtitle': '${sevrages.length} à planifier',
        'icon': Icons.bakery_dining_rounded,
        'color': const Color(0xFF4ECDC4),
        'urgency': 1,
      });
    }

    alerts.sort((a, b) => (b['urgency'] as int).compareTo(a['urgency'] as int));
    return alerts;
  }

  Widget _buildAlertCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int urgency,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(urgency).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getUrgencyLabel(urgency),
                    style: TextStyle(
                      color: _getUrgencyColor(urgency),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAlertCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: const Color(0xFF4ECDC4),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune tâche urgente',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Tout est sous contrôle !',
              style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 3:
        return const Color(0xFFE74C3C);
      case 2:
        return const Color(0xFFFFB84D);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  String _getUrgencyLabel(int urgency) {
    switch (urgency) {
      case 3:
        return 'URGENT';
      case 2:
        return 'Important';
      default:
        return 'Normal';
    }
  }

  Widget _buildStatisticsGrid() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Consumer3<LapinProvider, ReproductionProvider, SanteProvider>(
        builder: (context, lapinProv, reproProv, santeProv, _) {
          final stats = lapinProv.getStatistiquesCheptel(reproProv);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: [
                  _buildStatCard(
                    'Total lapins',
                    '${stats['total']}',
                    Icons.pets_rounded,
                    const Color(0xFF00F5FF),
                    lapinProv.getVariationStat('total', stats['total'] as int),
                  ),
                  _buildStatCard(
                    'Femelles',
                    '${stats['femelles']}',
                    Icons.female_rounded,
                    const Color(0xFFFF6B9D),
                    lapinProv.getVariationStat(
                      'femelles',
                      stats['femelles'] as int,
                    ),
                  ),
                  _buildStatCard(
                    'Gestantes',
                    '${stats['gestantes']}',
                    Icons.pregnant_woman_rounded,
                    const Color(0xFFFFB84D),
                    lapinProv.getVariationStat(
                      'gestantes',
                      stats['gestantes'] as int,
                    ),
                  ),
                  _buildStatCard(
                    'Lapereaux',
                    '${stats['lapereaux']}',
                    Icons.child_care_rounded,
                    const Color(0xFF4ECDC4),
                    lapinProv.getVariationStat(
                      'lapereaux',
                      stats['lapereaux'] as int,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String variation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Consumer<SanteProvider>(
        builder: (context, santeProvider, _) {
          return FutureBuilder<int>(
            future: santeProvider.calculerScoreSante(),
            builder: (context, snapshot) {
              final score = snapshot.data ?? 92;
              final scorePercent = score / 100;

              String etat;
              Color couleurEtat;
              if (score >= 90) {
                etat = 'Excellent état';
                couleurEtat = const Color(0xFF4CAF50);
              } else if (score >= 70) {
                etat = 'Bon état';
                couleurEtat = const Color(0xFFFFB84D);
              } else if (score >= 50) {
                etat = 'État moyen';
                couleurEtat = const Color(0xFFFF9800);
              } else {
                etat = 'Attention requise';
                couleurEtat = const Color(0xFFE74C3C);
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Santé du cheptel',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$score/100',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                score >= 90
                                    ? Icons.trending_up_rounded
                                    : Icons.info_outline_rounded,
                                color: couleurEtat,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                etat,
                                style: TextStyle(
                                  color: couleurEtat,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: scorePercent,
                              strokeWidth: 8,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                couleurEtat,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.favorite_rounded,
                            color: couleurEtat,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                'Ajouter un lapin',
                Icons.add_circle_rounded,
                const Color(0xFF00F5FF),
                () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddLapinScreen()),
                  );
                },
              ),
              _buildActionCard(
                'Planifier accouplement',
                Icons.favorite_rounded,
                const Color(0xFFFF6B9D),
                () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlanifierAccouplementScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                'Enregistrer soin',
                Icons.medical_services_rounded,
                const Color(0xFF4ECDC4),
                () {
                  HapticFeedback.mediumImpact();
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(3);
                  }
                },
              ),
              _buildActionCard(
                'Voir cheptel',
                Icons.pets_rounded,
                const Color(0xFFFFB84D),
                () {
                  HapticFeedback.mediumImpact();
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityTimeline() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Consumer3<LapinProvider, ReproductionProvider, SanteProvider>(
        builder: (context, lapinProv, reproProv, santeProv, _) {
          final activities = _getRecentActivities(
            lapinProv,
            reproProv,
            santeProv,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activité récente',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: activities.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Aucune activité récente',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: activities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final activity = entry.value;
                          return _buildTimelineItem(
                            activity['title']!,
                            activity['time']!,
                            activity['icon'] as IconData,
                            activity['color'] as Color,
                            isLast: index == activities.length - 1,
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentActivities(
    LapinProvider lapinProv,
    ReproductionProvider reproProv,
    SanteProvider santeProv,
  ) {
    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Derniers lapins ajoutés (maximum 2)
    final lapinsRecents = lapinProv.lapins.take(2).toList();
    for (final lapin in lapinsRecents) {
      final diff = now.difference(lapin.dateNaissance).inDays;
      String temps;
      if (diff == 0) {
        temps = 'Aujourd\'hui';
      } else if (diff == 1) {
        temps = 'Hier';
      } else if (diff < 7) {
        temps = 'Il y a $diff jours';
      } else {
        continue; // Ignorer si trop vieux
      }

      activities.add({
        'title': 'Ajout de ${lapin.nom}',
        'time': temps,
        'icon': Icons.add_circle_outline_rounded,
        'color': const Color(0xFF4CAF50),
        'date': lapin.dateNaissance,
      });
    }

    // Dernières portées enregistrées
    final porteesRecentes = reproProv.portees.take(2).toList();
    for (final portee in porteesRecentes) {
      final diff = now.difference(portee.dateMiseBasReelle).inDays;
      if (diff > 7) continue;

      String temps;
      if (diff == 0) {
        temps = 'Aujourd\'hui';
      } else if (diff == 1) {
        temps = 'Hier';
      } else {
        temps = 'Il y a $diff jours';
      }

      activities.add({
        'title': 'Mise bas (${portee.nombreVivants} vivants)',
        'time': temps,
        'icon': Icons.child_care_rounded,
        'color': const Color(0xFFFF6B9D),
        'date': portee.dateMiseBasReelle,
      });
    }

    // Derniers soins/vaccinations
    final soinsRecents = santeProv.soins.take(2).toList();
    for (final soin in soinsRecents) {
      final diff = now.difference(soin.date).inDays;
      if (diff > 7) continue;

      String temps;
      if (diff == 0) {
        temps = 'Aujourd\'hui';
      } else if (diff == 1) {
        temps = 'Hier';
      } else {
        temps = 'Il y a $diff jours';
      }

      activities.add({
        'title': soin.type,
        'time': temps,
        'icon': soin.type == 'Vaccination'
            ? Icons.vaccines_rounded
            : Icons.medical_services_rounded,
        'color': const Color(0xFF4ECDC4),
        'date': soin.date,
      });
    }

    // Trier par date décroissante et prendre les 5 plus récents
    activities.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return activities.take(5).toList();
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.3)),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 12),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
