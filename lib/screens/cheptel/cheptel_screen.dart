import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/quarantaine/quarantaine_quick_dialog.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import 'add_lapin_screen.dart';
import 'lapin_detail_screen.dart';

/// Écran Cheptel - Stitch Design "My Herd"
/// Liste complète des lapins avec recherche et filtres
class CheptelScreen extends StatefulWidget {
  const CheptelScreen({super.key});

  @override
  State<CheptelScreen> createState() => _CheptelScreenState();
}

class _CheptelScreenState extends State<CheptelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Does, Bucks, Kits, Sick

  final List<String> _filters = ['All', 'Does', 'Bucks', 'Kits', 'Sick'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LapinProvider>().chargerLapins();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Lapin>> _appliquerFiltres(List<Lapin> lapins) async {
    var filtres = lapins.where((l) => l.statut != 'decede').toList();

    // Recherche
    if (_searchQuery.isNotEmpty) {
      filtres = filtres.where((l) {
        final query = _searchQuery.toLowerCase();
        return l.nom.toLowerCase().contains(query) ||
            l.race.toLowerCase().contains(query) ||
            (l.numeroIdentification?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtres par type
    switch (_selectedFilter) {
      case 'Does':
        filtres = filtres
            .where(
              (l) =>
                  l.sexe == 'Femelle' &&
                  (l.statut == 'Reproductrice' || l.statut == 'Reproducteur'),
            )
            .toList();
        break;
      case 'Bucks':
        filtres = filtres
            .where((l) => l.sexe == 'Mâle' && l.statut == 'Reproducteur')
            .toList();
        break;
      case 'Kits':
        // Lapins < 8 semaines
        filtres = filtres.where((l) {
          final age = l.ageEnJours;
          return age < 56; // 8 semaines = 56 jours
        }).toList();
        break;
      case 'Sick':
        // Filtrer les lapins malades via SanteProvider
        final santeProvider = Provider.of<SanteProvider>(
          context,
          listen: false,
        );
        final lapinsMalades = await santeProvider.getLapinsMalades();
        filtres = filtres.where((l) {
          return l.id != null && lapinsMalades.contains(l.id);
        }).toList();
        break;
    }

    return filtres;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildSearchBar(isDark),
          _buildFilterPills(isDark),
          Expanded(
            child: Consumer<LapinProvider>(
              builder: (context, provider, _) {
                return FutureBuilder<List<Lapin>>(
                  future: _appliquerFiltres(provider.lapins),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final lapinsFiltres = snapshot.data ?? [];
                    return _buildRabbitList(lapinsFiltres, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header sticky "My Herd" - Utilise StandardHeader
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: 'My Herd',
      isDark: isDark,
      onSync: () {
        context.read<LapinProvider>().chargerLapins();
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

  /// Barre de recherche ronde - Utilise SearchBarWidget
  Widget _buildSearchBar(bool isDark) {
    return SearchBarWidget(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      isDark: isDark,
      hintText: 'Search by ID, name or breed...',
    );
  }

  /// Pills de filtres horizontaux - Utilise FilterPill
  Widget _buildFilterPills(bool isDark) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? 8 : 0,
            ),
            child: FilterPill(
              label: filter,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  /// Liste des lapins - Utilise EmptyState
  Widget _buildRabbitList(List<Lapin> lapins, bool isDark) {
    if (lapins.isEmpty) {
      return EmptyState(
        isDark: isDark,
        icon: Icons.pets_outlined,
        title: 'Aucun lapin trouvé',
        subtitle: _searchQuery.isNotEmpty
            ? 'Essayez avec d\'autres termes'
            : 'Ajoutez votre premier lapin',
      );
    }

    return Column(
      children: [
        // En-tête section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE HERD',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${lapins.length} Rabbits',
                style: AppTheme.bodyMedium.copyWith(
                  color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: lapins.length,
            itemBuilder: (context, index) {
              return _buildRabbitCard(lapins[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  /// Card d'un lapin
  Widget _buildRabbitCard(Lapin lapin, bool isDark) {
    // Vérifier si le lapin est malade via SanteProvider
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);

    // Utiliser FutureBuilder pour vérifier de manière asynchrone
    return FutureBuilder<bool>(
      future: lapin.id != null
          ? santeProvider.estLapinMalade(lapin.id!)
          : Future.value(lapin.statut == 'Malade'),
      builder: (context, snapshot) {
        final bool isSick = snapshot.data ?? (lapin.statut == 'Malade');
        return _buildRabbitCardContent(lapin, isDark, isSick);
      },
    );
  }

  Widget _buildRabbitCardContent(Lapin lapin, bool isDark, bool isSick) {
    // Déterminer le badge statut
    String badgeText = 'Healthy';
    Color badgeBg = isDark
        ? AppTheme.success.withValues(alpha: 0.3)
        : AppTheme.success.withValues(alpha: 0.2);
    Color badgeTextColor = isDark ? AppTheme.success : AppTheme.success;

    if (isSick) {
      badgeText = 'Sick';
      badgeBg = isDark
          ? AppTheme.error.withValues(alpha: 0.3)
          : AppTheme.error.withValues(alpha: 0.2);
      badgeTextColor = isDark ? AppTheme.error : AppTheme.error;
    }
    // TODO: Ajouter logique gestante
    // else if (lapin.estGestante) {
    //   badgeText = 'Pregnant';
    //   badgeBg = isDark ? Colors.yellow.shade900 : Colors.yellow.shade100;
    //   badgeTextColor = isDark ? Colors.yellow.shade200 : Colors.yellow.shade800;
    // }

    // Badge sexe (ou medical si malade)
    IconData sexeIcon = Icons.female;
    Color sexeColor = AppTheme.primaryYellow;
    Color sexeBg = AppTheme.primaryYellow;

    if (isSick) {
      // Badge medical pour les lapins malades
      sexeIcon = Icons.medical_services;
      sexeColor = isDark ? AppTheme.error : AppTheme.error;
      sexeBg = isDark
          ? AppTheme.error.withValues(alpha: 0.3)
          : AppTheme.error.withValues(alpha: 0.2);
    } else if (lapin.sexe == 'Mâle') {
      sexeIcon = Icons.male;
      sexeColor = AppTheme.textSecondary;
      sexeBg = AppTheme.textSecondary.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(32),
        border: isSick
            ? Border(
                left: const BorderSide(color: AppTheme.error, width: 4),
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              )
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LapinDetailScreen(lapin: lapin),
              ),
            );
          },
          onLongPress: () => _showRabbitContextMenu(lapin),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Photo avec badge sexe
                Stack(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.border,
                        border: Border.all(
                          color: isDark
                              ? AppTheme.backgroundDarkMode
                              : AppTheme.cardLight,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: isSick
                              ? ColorFilter.mode(
                                  Colors.grey.withValues(alpha: 0.3),
                                  BlendMode.saturation,
                                )
                              : const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                ),
                          child:
                              lapin.photoPath != null &&
                                  File(lapin.photoPath!).existsSync()
                              ? Image.file(
                                  File(lapin.photoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.pets,
                                    size: 32,
                                    color: AppTheme.textSecondary,
                                  ),
                                )
                              : Icon(
                                  Icons.pets,
                                  size: 32,
                                  color: AppTheme.textSecondary,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: sexeBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.backgroundDarkMode
                                : AppTheme.cardLight,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          sexeIcon,
                          size: 14,
                          color: isSick
                              ? sexeColor
                              : (lapin.sexe == 'Mâle'
                                    ? sexeColor
                                    : AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lapin.nom,
                              style: AppTheme.titleMedium.copyWith(
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTheme.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lapin.race} • ${lapin.ageFormate}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${lapin.numeroIdentification ?? '#${lapin.id}'}',
                        style: AppTheme.caption.copyWith(
                          fontFamily: 'monospace',
                          color: isDark
                              ? AppTheme.textLight.withValues(alpha: 0.5)
                              : AppTheme.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menu contextuel pour actions rapides sur un lapin
  Future<void> _showRabbitContextMenu(Lapin lapin) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppTheme.textSecondary : AppTheme.border,
                    ),
                    child:
                        lapin.photoPath != null &&
                            File(lapin.photoPath!).existsSync()
                        ? ClipOval(
                            child: Image.file(
                              File(lapin.photoPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.pets, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lapin.nom,
                          style: AppTheme.titleSmall.copyWith(
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${lapin.race} • ${lapin.sexe}',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Actions
            ListTile(
              leading: const Icon(Icons.visibility, color: AppTheme.info),
              title: const Text('Voir la fiche'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LapinDetailScreen(lapin: lapin),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.health_and_safety,
                color: AppTheme.warning,
              ),
              title: const Text('Mettre en quarantaine'),
              onTap: () async {
                Navigator.pop(context);
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => QuarantaineQuickDialog(lapin: lapin),
                );
                if (!context.mounted) return;
                if (result == true) {
                  await context.read<LapinProvider>().chargerLapins();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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
