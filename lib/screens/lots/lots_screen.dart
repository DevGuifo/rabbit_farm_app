import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lot.dart';
import '../../providers/lot_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import 'lot_detail_screen.dart';
import 'add_lot_screen.dart';
import 'widgets/lot_card.dart';
import 'widgets/lot_table_view.dart';

/// Écran principal de gestion des Lots
///
/// Affiche la liste de tous les lots avec :
/// - Recherche et filtres
/// - Statistiques globales
/// - Accès à la création et au détail
class LotsScreen extends StatefulWidget {
  const LotsScreen({super.key});

  @override
  State<LotsScreen> createState() => _LotsScreenState();
}

class _LotsScreenState extends State<LotsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TypeLot? _selectedType;
  StatutLot? _selectedStatut;
  bool _isTableView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LotProvider>().chargerLots();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Lot> _filtrerLots(List<Lot> lots) {
    var resultat = lots;

    // Recherche textuelle
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      resultat = resultat.where((lot) {
        return lot.identifiant.toLowerCase().contains(query) ||
            lot.type.label.toLowerCase().contains(query) ||
            (lot.metadata.race?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par type
    if (_selectedType != null) {
      resultat = resultat.where((lot) => lot.type == _selectedType).toList();
    }

    // Filtre par statut
    if (_selectedStatut != null) {
      resultat = resultat
          .where((lot) => lot.statut == _selectedStatut)
          .toList();
    }

    return resultat;
  }

  @override
  Widget build(BuildContext context) {
    // l10n et isDark disponibles pour les futures traductions
    // final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: UniformAppBar(
        title: 'Gestion des Lots',
        icon: Icons.inventory_2,
        showBackButton: false,
        actions: [
          // Toggle vue Cartes/Tableau
          IconButton(
            icon: Icon(_isTableView ? Icons.grid_view : Icons.table_chart),
            tooltip: _isTableView ? 'Vue Cartes' : 'Vue Tableau',
            onPressed: () => setState(() => _isTableView = !_isTableView),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Statistiques',
            onPressed: _showStatistiques,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () => context.read<LotProvider>().rafraichir(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchBar(context),

          // Résumé statistique
          _buildStatsHeader(context),

          // Liste des lots
          Expanded(
            child: Consumer<LotProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.chargerLots(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final lotsFiltres = _filtrerLots(provider.lots);

                if (lotsFiltres.isEmpty) {
                  return _buildEmptyState(context, provider.lots.isEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.rafraichir(),
                  child: _isTableView
                      ? LotTableView(
                          lots: lotsFiltres,
                          onTap: _ouvrirDetailLot,
                          onLongPress: _showActionsMenu,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: lotsFiltres.length,
                          itemBuilder: (context, index) {
                            final lot = lotsFiltres[index];
                            return LotCard(
                              lot: lot,
                              onTap: () => _ouvrirDetailLot(lot),
                              onLongPress: () => _showActionsMenu(lot),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterLot,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau lot'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Champ de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un lot (ID, type, race...)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtre Type
                FilterChip(
                  label: Text(_selectedType?.label ?? 'Tous types'),
                  selected: _selectedType != null,
                  onSelected: (_) => _showTypeFilter(),
                  avatar: const Icon(Icons.category, size: 18),
                ),
                const SizedBox(width: 8),

                // Filtre Statut
                FilterChip(
                  label: Text(_selectedStatut?.label ?? 'Tous statuts'),
                  selected: _selectedStatut != null,
                  onSelected: (_) => _showStatutFilter(),
                  avatar: const Icon(Icons.flag, size: 18),
                ),
                const SizedBox(width: 8),

                // Réinitialiser
                if (_selectedType != null || _selectedStatut != null)
                  ActionChip(
                    label: const Text('Réinitialiser'),
                    avatar: const Icon(Icons.clear_all, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedStatut = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    return Consumer<LotProvider>(
      builder: (context, provider, _) {
        final lotsActifs = provider.lotsActifs;
        final effectifTotal = provider.effectifTotal;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.inventory_2,
                value: lotsActifs.length.toString(),
                label: 'Lots actifs',
              ),
              Container(
                height: 40,
                width: 1,
                color: AppTheme.textOnPrimary.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                icon: Icons.pets,
                value: effectifTotal.toString(),
                label: 'Effectif total',
              ),
              Container(
                height: 40,
                width: 1,
                color: AppTheme.textOnPrimary.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                icon: Icons.warning_amber,
                value: provider.lotsASurveiller.length.toString(),
                label: 'À surveiller',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textOnPrimary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textOnPrimary),
        ),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool aucunLot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            aucunLot ? Icons.inventory_2_outlined : Icons.search_off,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            aucunLot
                ? 'Aucun lot créé'
                : 'Aucun lot ne correspond à la recherche',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            aucunLot
                ? 'Créez votre premier lot pour commencer'
                : 'Modifiez vos critères de recherche',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
          ),
          if (aucunLot) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _ajouterLot,
              icon: const Icon(Icons.add),
              label: const Text('Créer un lot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.textOnPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _ajouterLot() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddLotScreen()));
  }

  void _ouvrirDetailLot(Lot lot) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LotDetailScreen(lot: lot)));
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('Tous les types'),
            selected: _selectedType == null,
            onTap: () {
              setState(() => _selectedType = null);
              Navigator.pop(context);
            },
          ),
          ...TypeLot.values.map(
            (type) => ListTile(
              leading: Icon(_getTypeIcon(type)),
              title: Text(type.label),
              selected: _selectedType == type,
              onTap: () {
                setState(() => _selectedType = type);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatutFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('Tous les statuts'),
            selected: _selectedStatut == null,
            onTap: () {
              setState(() => _selectedStatut = null);
              Navigator.pop(context);
            },
          ),
          ...StatutLot.values.map(
            (statut) => ListTile(
              leading: Icon(_getStatutIcon(statut)),
              title: Text(statut.label),
              selected: _selectedStatut == statut,
              onTap: () {
                setState(() => _selectedStatut = statut);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(Lot lot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Voir détails'),
              onTap: () {
                Navigator.pop(context);
                _ouvrirDetailLot(lot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Écran modification
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Enregistrer mortalité'),
              onTap: () {
                Navigator.pop(context);
                _showMortaliteDialog(lot);
              },
            ),
            ListTile(
              leading: Icon(Icons.sell, color: AppTheme.success),
              title: const Text('Enregistrer vente'),
              onTap: () {
                Navigator.pop(context);
                _showVenteDialog(lot);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.error),
              title: const Text(
                'Supprimer',
                style: TextStyle(color: AppTheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmerSuppression(lot);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMortaliteDialog(Lot lot) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mortalité - ${lot.identifiant}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Effectif actuel: ${lot.effectifActuel}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de décès',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = int.tryParse(controller.text);
              if (nombre != null &&
                  nombre > 0 &&
                  nombre <= lot.effectifActuel) {
                context.read<LotProvider>().enregistrerMortalite(
                  lot.id!,
                  nombre,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$nombre décès enregistré(s)')),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showVenteDialog(Lot lot) {
    final nombreController = TextEditingController();
    final prixController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vente - ${lot.identifiant}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Effectif actuel: ${lot.effectifActuel}'),
            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre vendus',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix total (optionnel)',
                border: OutlineInputBorder(),
                suffixText: '€',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = int.tryParse(nombreController.text);
              final prix = double.tryParse(prixController.text);
              if (nombre != null &&
                  nombre > 0 &&
                  nombre <= lot.effectifActuel) {
                context.read<LotProvider>().enregistrerVente(
                  lot.id!,
                  nombre,
                  prixTotal: prix,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$nombre sujet(s) vendu(s)')),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _confirmerSuppression(Lot lot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce lot ?'),
        content: Text(
          'Le lot ${lot.identifiant} (${lot.effectifActuel} sujets) sera définitivement supprimé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LotProvider>().supprimerLot(lot.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showStatistiques() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            FutureBuilder<Map<String, dynamic>>(
              future: context.read<LotProvider>().getStatistiques(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Statistiques des Lots',
                      style: AppTheme.displayMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildStatCard(
                      'Effectif total',
                      '${stats['effectif_total'] ?? 0}',
                      Icons.pets,
                      AppTheme.success,
                    ),
                    const SizedBox(height: 16),
                    Text('Par statut', style: AppTheme.titleMedium),
                    ...(stats['lots_par_statut'] as Map? ?? {}).entries.map(
                      (e) => ListTile(
                        leading: Icon(
                          _getStatutIcon(StatutLot.fromString(e.key)),
                        ),
                        title: Text(StatutLot.fromString(e.key).label),
                        trailing: Text(
                          '${e.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Par type', style: AppTheme.titleMedium),
                    ...(stats['lots_par_type'] as Map? ?? {}).entries.map(
                      (e) => ListTile(
                        leading: Icon(_getTypeIcon(TypeLot.fromString(e.key))),
                        title: Text(TypeLot.fromString(e.key).label),
                        trailing: Text(
                          '${e.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(value, style: AppTheme.headingLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(TypeLot type) {
    switch (type) {
      case TypeLot.engraissement:
        return Icons.restaurant;
      case TypeLot.reproduction:
        return Icons.favorite;
      case TypeLot.mixte:
        return Icons.blur_on;
    }
  }

  IconData _getStatutIcon(StatutLot statut) {
    switch (statut) {
      case StatutLot.actif:
        return Icons.check_circle;
      case StatutLot.enAttente:
        return Icons.hourglass_empty;
      case StatutLot.termine:
        return Icons.done_all;
      case StatutLot.vendu:
        return Icons.sell;
      case StatutLot.reforme:
        return Icons.exit_to_app;
    }
  }
}
