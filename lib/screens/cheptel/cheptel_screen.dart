import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/quarantaine/quarantaine_quick_dialog.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import '../sante/ajouter_pesee_screen.dart';
import '../sante/ajouter_soin_screen.dart';
import '../sante/fiche_sante_screen.dart';
import 'add_lapin_screen_validated.dart';
import 'lapin_detail_screen.dart';
import '../../widgets/cheptel/rabbit_card.dart';
import '../../widgets/cheptel/rabbit_table_view.dart';
import '../../widgets/common/paginated_list_view.dart';

/// Écran Cheptel - Stitch Design "Mon Élevage"
/// Liste complète des lapins avec recherche et filtres
class CheptelScreen extends StatefulWidget {
  const CheptelScreen({super.key});

  @override
  State<CheptelScreen> createState() => _CheptelScreenState();
}

class _CheptelScreenState extends State<CheptelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = ''; // Vide par défaut = Tous
  bool _isTableView = false; // Toggle pour vue tableau

  List<String> _getFilters(BuildContext context) {
    return [
      AppLocalizations.of(context).cheptelTous,
      AppLocalizations.of(context).cheptelFemelles,
      AppLocalizations.of(context).cheptelMales,
      AppLocalizations.of(context).cheptelLapereaux,
      AppLocalizations.of(context).cheptelMalades,
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LapinProvider>().chargerLapins();
      // Charger les accouplements pour la détection des femelles gestantes
      context.read<ReproductionProvider>().chargerAccouplements();
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
    final filters = _getFilters(context);
    if (_selectedFilter.isEmpty) {
      _selectedFilter = filters[0]; // Tous
    }

    if (_selectedFilter == filters[1]) {
      // Femelles
      filtres = filtres
          .where(
            (l) =>
                l.sexe == Sexe.femelle &&
                (l.statut == 'Reproductrice' || l.statut == 'Reproducteur'),
          )
          .toList();
    } else if (_selectedFilter == filters[2]) {
      // Mâles
      filtres = filtres
          .where((l) => l.sexe == Sexe.male && l.statut == 'Reproducteur')
          .toList();
    } else if (_selectedFilter == filters[3]) {
      // Lapereaux
      // Lapins < 8 semaines
      filtres = filtres.where((l) {
        final age = l.ageEnJours;
        return age < 56; // 8 semaines = 56 jours
      }).toList();
    } else if (_selectedFilter == filters[4]) {
      // Malades
      // Filtrer les lapins malades via SanteProvider
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      final lapinsMalades = await santeProvider.getLapinsMalades();
      filtres = filtres.where((l) {
        return l.id != null && lapinsMalades.contains(l.id);
      }).toList();
    }

    return filtres;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          // Indicateur mode hors-ligne
          const OfflineBanner(),
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

  /// Header sticky "Mon Élevage" - Utilise StandardHeader unifié
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).monElevage,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        if (!mounted) return;
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
      hintText: AppLocalizations.of(context).cheptelRechercher,
    );
  }

  /// Pills de filtres horizontaux - Utilise FilterPill
  Widget _buildFilterPills(bool isDark) {
    final filters = _getFilters(context);

    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
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
        title: AppLocalizations.of(context).cheptelAucunLapinTrouve,
        subtitle: _searchQuery.isNotEmpty
            ? AppLocalizations.of(context).cheptelAutresTermes
            : AppLocalizations.of(context).cheptelAjouterPremier,
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
                AppLocalizations.of(context).cheptelActif,
                style: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${lapins.length} Lapins',
                style: AppTheme.bodyMedium.copyWith(
                  color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 12),
              // Toggle vue Cartes/Tableau
              IconButton(
                icon: Icon(
                  _isTableView ? Icons.grid_view : Icons.table_chart,
                  color: AppTheme.primaryGreen,
                ),
                onPressed: () => setState(() => _isTableView = !_isTableView),
                tooltip: _isTableView ? 'Vue Cartes' : 'Vue Tableau',
              ),
            ],
          ),
        ),

        // Liste ou Tableau selon le mode
        Expanded(
          child: _isTableView
              ? RabbitTableView(
                  lapins: lapins,
                  onTap: _navigateToDetail,
                  onLongPress: (lapin) => _showRabbitActions(context, lapin),
                  showLotColumn: true,
                )
              : lapins.length > 50
              // Pagination pour grandes listes (50+ elements)
              ? PaginatedListView<Lapin>(
                  items: lapins,
                  itemsPerPage: 50,
                  itemExtent: 100.0,
                  itemBuilder: (context, lapin, index) {
                    return RabbitCard(
                      lapin: lapin,
                      isDark: isDark,
                      onTap: () => _navigateToDetail(lapin),
                      onLongPress: () => _showRabbitActions(context, lapin),
                    );
                  },
                )
              // Liste simple pour petites listes
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: lapins.length,
                  itemExtent: 100.0,
                  cacheExtent: 250.0,
                  itemBuilder: (context, index) {
                    final lapin = lapins[index];
                    return RabbitCard(
                      lapin: lapin,
                      isDark: isDark,
                      onTap: () => _navigateToDetail(lapin),
                      onLongPress: () => _showRabbitActions(context, lapin),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Naviguer vers le détail d'un lapin
  void _navigateToDetail(Lapin lapin) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LapinDetailScreen(lapin: lapin)),
    );
  }

  /// Afficher le menu d'actions pour un lapin
  void _showRabbitActions(BuildContext context, Lapin lapin) {
    _showRabbitContextMenu(lapin);
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
                          style: AppTheme.headingSmall.copyWith(
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${lapin.race} • ${lapin.sexe}',
                          style: AppTheme.bodySmall.copyWith(
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
              title: Text(AppLocalizations.of(context).cheptelVoirFiche),
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
            // Actions rapides santé
            ListTile(
              leading: const Icon(
                Icons.monitor_weight,
                color: AppTheme.accentCyan,
              ),
              title: Text(AppLocalizations.of(context).cheptelActionPesee),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AjouterPeseeScreen(lapin: lapin),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.medical_services,
                color: AppTheme.neonGreen,
              ),
              title: Text(AppLocalizations.of(context).cheptelActionSoin),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AjouterSoinScreen(lapin: lapin),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppTheme.accentPink),
              title: Text(AppLocalizations.of(context).cheptelActionFicheSante),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FicheSanteScreen(lapin: lapin),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.health_and_safety,
                color: AppTheme.warning,
              ),
              title: Text(
                AppLocalizations.of(context).cheptelMettreQuarantaine,
              ),
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

  /// FAB standardisé pour ajouter un lapin
  Widget _buildFAB() {
    return UnifiedFAB(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddLapinScreenWithValidation(),
          ),
        );
      },
      tooltip: AppLocalizations.of(context).cheptelAjouterLapin,
    );
  }
}
