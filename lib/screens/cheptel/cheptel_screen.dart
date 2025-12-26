import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../widgets/lapin_card.dart';
import '../../widgets/bunny_widgets.dart';
import '../../theme/app_theme.dart';
import 'add_lapin_screen.dart';
import 'edit_lapin_screen.dart';
import 'genealogie_screen.dart';
import 'lapin_detail_screen.dart';

/// Écran de gestion du cheptel
class CheptelScreen extends StatefulWidget {
  const CheptelScreen({super.key});

  @override
  State<CheptelScreen> createState() => _CheptelScreenState();
}

class _CheptelScreenState extends State<CheptelScreen> {
  bool _afficherDecedes = false;
  String _searchQuery = '';
  String? _filtreRace;
  String? _filtreStatut;
  String? _filtreLocalisation;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Cheptel'),
        actions: [
          // Toggle filtres
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary,
            ),
            tooltip: 'Filtres avancés',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          // Filtre décédés
          Consumer<LapinProvider>(
            builder: (context, lapinProvider, child) {
              final nbDecedes = lapinProvider.lapins
                  .where((l) => l.statut == 'decede')
                  .length;

              return IconButton(
                icon: Icon(
                  _afficherDecedes ? Icons.visibility_off : Icons.visibility,
                  color: _afficherDecedes
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
                tooltip: _afficherDecedes
                    ? 'Masquer les décédés ($nbDecedes)'
                    : 'Afficher les décédés ($nbDecedes)',
                onPressed: () {
                  setState(() {
                    _afficherDecedes = !_afficherDecedes;
                  });
                },
              );
            },
          ),
          // Compteur
          Consumer<LapinProvider>(
            builder: (context, lapinProvider, child) {
              final lapinsFiltres = _appliquerFiltres(lapinProvider.lapins);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacing16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      '${lapinsFiltres.length}',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<LapinProvider>(
        builder: (context, lapinProvider, child) {
          final lapinsFiltres = _appliquerFiltres(lapinProvider.lapins);

          return Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, race, localisation...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filtres avancés (pliable)
              if (_showFilters) _buildFilterChips(lapinProvider),

              // Badge résumé des filtres actifs
              if (_hasFiltresActifs()) _buildFiltresActifsBadge(),

              // Liste des lapins
              Expanded(
                child: lapinsFiltres.isEmpty
                    ? EmptyState(
                        icon: Icons.pets_rounded,
                        title: _hasFiltresActifs() || _searchQuery.isNotEmpty
                            ? 'Aucun résultat'
                            : 'Aucun lapin',
                        message: _hasFiltresActifs() || _searchQuery.isNotEmpty
                            ? 'Aucun lapin ne correspond à vos critères'
                            : _afficherDecedes
                            ? 'Aucun lapin décédé enregistré'
                            : 'Commencez par ajouter votre premier lapin',
                        actionLabel:
                            _hasFiltresActifs() || _searchQuery.isNotEmpty
                            ? 'Réinitialiser les filtres'
                            : _afficherDecedes
                            ? null
                            : 'Ajouter un lapin',
                        onAction: _hasFiltresActifs() || _searchQuery.isNotEmpty
                            ? _reinitialiserFiltres
                            : _afficherDecedes
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddLapinScreen(),
                                  ),
                                );
                              },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        itemCount: lapinsFiltres.length,
                        itemBuilder: (context, index) {
                          final lapin = lapinsFiltres[index];
                          return FadeInUp(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            child: LapinCard(
                              lapin: lapin,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.account_tree,
                                            ),
                                            title: const Text(
                                              'Voir la généalogie',
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      GenealogieScreen(
                                                        lapin: lapin,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.info),
                                            title: const Text(
                                              'Voir la fiche complète',
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LapinDetailScreen(
                                                        lapin: lapin,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: const Text('Modifier'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditLapinScreen(
                                                            lapin: lapin,
                                                          ),
                                                    ),
                                                  );
                                              // Recharger si modification réussie
                                              if (result == true &&
                                                  context.mounted) {
                                                await Provider.of<
                                                      LapinProvider
                                                    >(context, listen: false)
                                                    .chargerLapins();
                                              }
                                            },
                                          ),
                                          const Divider(),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            title: const Text(
                                              'Marquer comme décédé',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final confirm =
                                                  await DialogHelper.showConfirmation(
                                                    context: context,
                                                    title:
                                                        'Marquer comme décédé',
                                                    message:
                                                        'Voulez-vous marquer ${lapin.nom} comme décédé ?\n\nVous pourrez enregistrer les détails du décès ensuite.',
                                                    isDangerous: true,
                                                  );

                                              if (confirm == true &&
                                                  context.mounted) {
                                                try {
                                                  await lapinProvider
                                                      .updateStatut(
                                                        lapin.id!,
                                                        'decede',
                                                      );
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${lapin.nom} marqué comme décédé',
                                                        ),
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Erreur: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            title: const Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Supprimer le lapin',
                                                  ),
                                                  content: Text(
                                                    'Voulez-vous vraiment supprimer ${lapin.nom} ?\n\nCette action est irréversible.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Annuler',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Supprimer',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true &&
                                                  context.mounted) {
                                                try {
                                                  await lapinProvider
                                                      .supprimerLapin(
                                                        lapin.id!,
                                                      );
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${lapin.nom} supprimé avec succès',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Erreur: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLapinScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Appliquer tous les filtres
  List<Lapin> _appliquerFiltres(List<Lapin> lapins) {
    var resultat = lapins;

    // Filtre décédés
    if (!_afficherDecedes) {
      resultat = resultat.where((l) => l.statut != 'decede').toList();
    }

    // Recherche textuelle
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      resultat = resultat.where((l) {
        return l.nom.toLowerCase().contains(query) ||
            l.race.toLowerCase().contains(query) ||
            (l.localisation?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par race
    if (_filtreRace != null) {
      resultat = resultat.where((l) => l.race == _filtreRace).toList();
    }

    // Filtre par statut
    if (_filtreStatut != null) {
      resultat = resultat.where((l) => l.statut == _filtreStatut).toList();
    }

    // Filtre par localisation
    if (_filtreLocalisation != null) {
      resultat = resultat
          .where((l) => l.localisation == _filtreLocalisation)
          .toList();
    }

    return resultat;
  }

  /// Construire les chips de filtres
  Widget _buildFilterChips(LapinProvider lapinProvider) {
    // Récupérer les valeurs uniques
    final races = lapinProvider.lapins.map((l) => l.race).toSet().toList()
      ..sort();
    final statuts =
        lapinProvider.lapins
            .where((l) => l.statut != null)
            .map((l) => l.statut!)
            .toSet()
            .toList()
          ..sort();
    final localisations =
        lapinProvider.lapins
            .where((l) => l.localisation != null)
            .map((l) => l.localisation!)
            .toSet()
            .toList()
          ..sort();

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          border: Border(
            top: BorderSide(color: AppTheme.border.withOpacity(0.3)),
            bottom: BorderSide(color: AppTheme.border.withOpacity(0.3)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Race
            if (races.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Race',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: races.map((race) {
                  final isSelected = _filtreRace == race;
                  return FilterChip(
                    label: Text(race),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filtreRace = selected ? race : null;
                      });
                    },
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing12),
            ],

            // Statut
            if (statuts.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Statut',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: statuts.map((statut) {
                  final isSelected = _filtreStatut == statut;
                  return FilterChip(
                    label: Text(statut),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filtreStatut = selected ? statut : null;
                      });
                    },
                    selectedColor: AppTheme.accentPurple.withOpacity(0.2),
                    checkmarkColor: AppTheme.accentPurple,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing12),
            ],

            // Localisation
            if (localisations.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Localisation',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: localisations.map((localisation) {
                  final isSelected = _filtreLocalisation == localisation;
                  return FilterChip(
                    label: Text(localisation),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filtreLocalisation = selected ? localisation : null;
                      });
                    },
                    selectedColor: AppTheme.accentOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.accentOrange,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Badge résumé des filtres actifs
  Widget _buildFiltresActifsBadge() {
    final filtresActifs = <String>[];
    if (_filtreRace != null) filtresActifs.add(_filtreRace!);
    if (_filtreStatut != null) filtresActifs.add(_filtreStatut!);
    if (_filtreLocalisation != null) filtresActifs.add(_filtreLocalisation!);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: AppTheme.info),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              'Filtres actifs : ${filtresActifs.join(", ")}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: _reinitialiserFiltres,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing8,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.info,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                'Effacer',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vérifier si des filtres sont actifs
  bool _hasFiltresActifs() {
    return _filtreRace != null ||
        _filtreStatut != null ||
        _filtreLocalisation != null;
  }

  /// Réinitialiser tous les filtres
  void _reinitialiserFiltres() {
    setState(() {
      _searchQuery = '';
      _filtreRace = null;
      _filtreStatut = null;
      _filtreLocalisation = null;
    });
  }
}
