import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/utils/logger.dart';
import '../../models/batiment.dart';
import '../../models/clapier.dart';
import '../../models/cage.dart';
import '../../services/database_helper.dart';
import '../../services/localisation_service.dart';
import '../../widgets/common/common_widgets.dart';
import 'widgets/localisation_app_bar.dart';
import 'widgets/localisation_stats_cards.dart';
import 'widgets/localisation_building_cards.dart';
import 'widgets/localisation_search_filter.dart';
import 'widgets/cage_card_widget.dart';
import 'dialogs/add_cage_dialog.dart';
import 'dialogs/add_building_dialog.dart';
import 'dialogs/cage_details_dialog.dart';
import 'dialogs/edit_cage_dialog.dart';
import 'dialogs/edit_building_dialog.dart';
import 'localisation_manager_screen.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

/// Écran de gestion de localisation (Bâtiments → Clapiers → Cages)
/// Design: Google Stitch avec palette neon green #13ec25
class LocalisationScreen extends StatefulWidget {
  const LocalisationScreen({super.key});

  @override
  State<LocalisationScreen> createState() => _LocalisationScreenState();
}

class _LocalisationScreenState extends State<LocalisationScreen> {
  final _dbHelper = DatabaseHelper.instance;

  List<Batiment> _batiments = [];
  final List<Map<String, dynamic>> _allCagesData = [];
  final Map<int, Batiment> _batimentsMap = {};
  final Map<int, Clapier> _clapiersMap = {};
  final Map<int, int> _cagesCountPerBatiment = {};
  final Map<int, int> _emptyCagesPerBatiment = {};

  Batiment? _batimentSelectionne;
  bool _loading = true;
  final bool _hasUnreadNotifications = false;
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    setState(() => _loading = true);

    try {
      _batiments = await _dbHelper.getAllBatiments();

      if (_batiments.isEmpty) {
        // Initialiser avec un bâtiment par défaut
        await _dbHelper.ajouterBatiment(Batiment(nom: 'Bâtiment A'));
        _batiments = await _dbHelper.getAllBatiments();
      }

      if (_batiments.isNotEmpty && _batimentSelectionne == null) {
        _batimentSelectionne = _batiments.first;
      }

      await _chargerHierarchie();
    } catch (e) {
      logger.error('Erreur chargement localisation: $e');
    }

    setState(() => _loading = false);
  }

  Future<void> _chargerHierarchie() async {
    _batimentsMap.clear();
    _clapiersMap.clear();
    _allCagesData.clear();
    _cagesCountPerBatiment.clear();
    _emptyCagesPerBatiment.clear();

    for (var batiment in _batiments) {
      _batimentsMap[batiment.id!] = batiment;

      final clapiers = await _dbHelper.getClapiersByBatiment(batiment.id!);
      int totalCages = 0;
      int emptyCages = 0;

      for (var clapier in clapiers) {
        _clapiersMap[clapier.id!] = clapier;

        final cages = await _dbHelper.getCagesByClapier(clapier.id!);
        totalCages += cages.length;

        for (var cage in cages) {
          final occupants = await _dbHelper.getOccupantsCage(cage.id!);
          final statut = cage.getStatut(occupants);
          final couleur = cage.getCouleurStatut(occupants);
          final disponible = cage.estDisponible(occupants);

          if (statut == 'vide') emptyCages++;

          _allCagesData.add({
            'cage': cage,
            'occupants': occupants,
            'statut': statut,
            'couleur': couleur,
            'disponible': disponible,
            'needsCleaning': _needsCleaning(cage, occupants, statut),
            'lastCleaned': _getLastCleanedText(cage, occupants),
          });
        }
      }

      _cagesCountPerBatiment[batiment.id!] = totalCages;
      _emptyCagesPerBatiment[batiment.id!] = emptyCages;
    }
  }

  /// Détermine si une cage a besoin d'être nettoyée
  /// 
  /// Logique :
  /// - Si la cage est vide, pas besoin de nettoyage
  /// - Si la cage contient des lapins morts ou vendus, priorité de nettoyage
  /// - Si la cage est occupée, considérer qu'elle nécessite un nettoyage périodique
  bool _needsCleaning(Cage cage, int occupants, String statut) {
    // Si la cage est vide, pas besoin de nettoyage
    if (occupants == 0) return false;
    
    // Si la cage contient des lapins morts ou vendus, priorité de nettoyage
    if (statut.toLowerCase().contains('mort') || 
        statut.toLowerCase().contains('vendu') ||
        statut.toLowerCase().contains('décédé')) {
      return true;
    }
    
    // Pour l'instant, considérer qu'une cage avec occupants nécessite un nettoyage
    // si elle est surpeuplée ou pleine (logique simplifiée)
    // Dans une version future, on pourrait utiliser la date de dernière pesée
    // ou une table de suivi des nettoyages
    if (statut == 'surpeuplee' || statut == 'pleine') {
      return true;
    }
    
    // Par défaut, une cage occupée nécessite un nettoyage périodique
    return occupants > 0;
  }

  /// Obtient le texte de dernière date de nettoyage
  String? _getLastCleanedText(Cage cage, int occupants) {
    if (occupants == 0) return null;
    
    // Logique simplifiée : pour l'instant, retourner un texte générique
    // Dans une version future, on pourrait utiliser une vraie date de nettoyage
    // stockée dans une table de suivi des nettoyages
    return 'Nettoyage recommandé';
  }

  int get _totalCages => _allCagesData.length;
  int get _totalBatiments => _batiments.length;
  double get _cleanStatusPercent {
    if (_allCagesData.isEmpty) return 100.0;
    final cleanCount = _allCagesData
        .where((c) => c['needsCleaning'] != true)
        .length;
    return (cleanCount / _allCagesData.length * 100);
  }

  List<Map<String, dynamic>> get _filteredCages {
    var filtered = _allCagesData;

    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cageData) {
        final cage = cageData['cage'] as Cage;
        final clapier = _clapiersMap[cage.clapierId];
        final batiment = clapier != null
            ? _batimentsMap[clapier.batimentId]
            : null;

        return cage.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (clapier?.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            (batiment?.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Filtre statut
    if (_filterStatus != 'All') {
      filtered = filtered.where((cageData) {
        final statut = cageData['statut'] as String;
        final occupants = cageData['occupants'] as int;

        switch (_filterStatus) {
          case 'Empty':
            return statut == 'vide';
          case 'Occupied':
            return occupants > 0;
          case 'Cleaning':
            return cageData['needsCleaning'] == true;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme
                .stitchBackgroundDark // Stitch background-dark
          : AppTheme.stitchBackgroundLight, // Stitch background-light
      body: SafeArea(
        child: Column(
          children: [
            LocalisationAppBar(
              onBackPressed: () => Navigator.pop(context),
              onSyncPressed: _syncData,
              onNotificationsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlertesScreen(),
                  ),
                );
              },
              onSettingsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParametresScreen(),
                  ),
                );
              },
              hasUnreadNotifications: _hasUnreadNotifications,
            ),
            if (_loading)
              Expanded(
                child: LoadingState(isDark: isDark, message: 'Chargement...'),
              )
            else if (_batiments.isEmpty)
              Expanded(
                child: EmptyState(
                  isDark: isDark,
                  icon: Icons.location_city_outlined,
                  title: 'Aucun bâtiment',
                  subtitle: 'Ajoutez votre premier bâtiment',
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      LocalisationStatsCards(
                        totalCages: _totalCages,
                        totalBatiments: _totalBatiments,
                        cleanStatusPercent: _cleanStatusPercent,
                      ),
                      const SizedBox(height: 20),

                      // All Cages Section - Titre
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'All Cages',
                          style: AppTheme.titleLarge.copyWith(
                            color: isDark
                                ? const Color(0xFFE0E6E0)
                                : AppTheme.stitchTextMainLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search & Filter
                      LocalisationSearchFilter(
                        searchQuery: _searchQuery,
                        filterStatus: _filterStatus,
                        onSearchChanged: (value) =>
                            setState(() => _searchQuery = value),
                        onFilterChanged: (value) =>
                            setState(() => _filterStatus = value),
                      ),
                      const SizedBox(height: 20),

                      // Buildings Section
                      LocalisationBuildingCards(
                        batiments: _batiments,
                        cagesCountPerBatiment: _cagesCountPerBatiment,
                        emptyCagesPerBatiment: _emptyCagesPerBatiment,
                        selectedBatiment: _batimentSelectionne,
                        onBatimentSelected: (batiment) {
                          setState(() => _batimentSelectionne = batiment);
                        },
                        onBatimentMenu: _showBatimentMenu,
                        onAddBatiment: _ajouterBatiment,
                        onManage: _ouvrirGestionBatiments,
                      ),
                      const SizedBox(height: 24),

                      // Cages List
                      _buildCagesList(isDark),

                      // Bottom padding for FAB
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _batiments.isNotEmpty ? _buildFAB() : null,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _ajouterCage,
      backgroundColor: AppTheme.primaryNeonGreen,
      foregroundColor: Colors.black,
      elevation: 6,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  Widget _buildCagesList(bool isDark) {
    if (_filteredCages.isEmpty) {
      return EmptyState(
        isDark: isDark,
        icon: Icons.grid_view_outlined,
        title: 'Aucune cage trouvée',
        subtitle: 'Ajoutez une cage pour commencer',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredCages.length,
      itemBuilder: (context, index) {
        final cageData = _filteredCages[index];
        return CageCardWidget(
          cageData: cageData,
          batimentsMap: _batimentsMap,
          clapiersMap: _clapiersMap,
          onTap: () => _onCageTap(cageData),
          onMenuTap: () => _showCageMenu(cageData['cage'] as Cage),
        );
      },
    );
  }

  void _onCageTap(Map<String, dynamic> cageData) {
    final cage = cageData['cage'] as Cage;
    CageDetailsDialog.show(context, cageData, () async {
      final success = await EditCageDialog.show(context, cage);
      if (success) await _chargerDonnees();
    }, () => _supprimerCage(cage));
  }

  void _ouvrirGestionBatiments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocalisationManagerScreen()),
    );
  }

  Future<void> _syncData() async {
    logger.info('Synchronisation des données localisation');
    await _chargerDonnees();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Données synchronisées'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _ajouterBatiment() async {
    await showDialog(
      context: context,
      builder: (context) => AddBuildingDialog(onBuildingAdded: _chargerDonnees),
    );
  }

  Future<void> _ajouterCage() async {
    await showDialog(
      context: context,
      builder: (context) => AddCageDialog(
        batiments: _batiments,
        selectedBatimentId: _batimentSelectionne?.id,
        onCageAdded: _chargerDonnees,
      ),
    );
  }

  void _showBatimentMenu(Batiment batiment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF1A331D) // Stitch surface-dark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Modifier'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await EditBuildingDialog.show(
                    context,
                    batiment,
                  );
                  if (success) await _chargerDonnees();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red),
                title: Text(
                  'Supprimer',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _supprimerBatiment(batiment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCageMenu(Cage cage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF1A331D) // Stitch surface-dark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Modifier'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await EditCageDialog.show(context, cage);
                  if (success) await _chargerDonnees();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red),
                title: Text(
                  'Supprimer',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _supprimerCage(cage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _supprimerBatiment(Batiment batiment) async {
    final confirm = await _showConfirmDialog(
      'Supprimer le bâtiment',
      'Cette action supprimera également tous les clapiers et cages associés.',
    );
    if (confirm != true) return;

    try {
      final db = await _dbHelper.database;
      await db.delete('batiments', where: 'id = ?', whereArgs: [batiment.id]);
      await _chargerDonnees();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✓ Bâtiment supprimé')));
      }
    } catch (e) {
      logger.error('Erreur suppression bâtiment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _supprimerCage(Cage cage) async {
    final confirm = await _showConfirmDialog(
      'Supprimer la cage',
      'Voulez-vous vraiment supprimer la cage ${cage.numero} ?',
    );
    if (confirm != true) return;

    try {
      await _dbHelper.supprimerCage(cage.id!);
      await _chargerDonnees();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✓ Cage supprimée')));
      }
    } catch (e) {
      logger.error('Erreur suppression cage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2C1E)
            : Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
