import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lot.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../providers/lot_provider.dart';
import '../../theme/app_theme.dart';
import '../cheptel/lapin_detail_screen.dart';

/// Écran de détail d'un lot
///
/// Affiche les informations complètes du lot avec :
/// - Statistiques et indicateurs
/// - Actions groupées
/// - Liste des individus (si disponibles)
class LotDetailScreen extends StatefulWidget {
  final Lot lot;

  const LotDetailScreen({super.key, required this.lot});

  @override
  State<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends State<LotDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Lot _lot;
  List<Lapin> _individus = [];
  bool _isLoadingIndividus = false;

  @override
  void initState() {
    super.initState();
    _lot = widget.lot;
    _tabController = TabController(length: 3, vsync: this);
    _chargerIndividus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _chargerIndividus() async {
    if (_lot.id == null) return;

    setState(() => _isLoadingIndividus = true);

    try {
      final individus = await context.read<LotProvider>().getIndividusDuLot(
        _lot.id!,
      );
      setState(() {
        _individus = individus;
        _isLoadingIndividus = false;
      });
    } catch (e) {
      setState(() => _isLoadingIndividus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lot.identifiant),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: _modifierLot,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mortalite',
                child: ListTile(
                  leading: Icon(Icons.remove_circle_outline),
                  title: Text('Enregistrer mortalité'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'vente',
                child: ListTile(
                  leading: Icon(Icons.sell),
                  title: Text('Enregistrer vente'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'terminer',
                child: ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Terminer le lot'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'supprimer',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppTheme.error),
                  title: Text(
                    'Supprimer',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Résumé', icon: Icon(Icons.dashboard)),
            Tab(text: 'Individus', icon: Icon(Icons.pets)),
            Tab(text: 'Historique', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResumeTab(),
          _buildIndividusTab(),
          _buildHistoriqueTab(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton rapide: Enregistrer mortalité
        FloatingActionButton.small(
          heroTag: 'mortalite',
          onPressed: () => _showMortaliteDialog(),
          backgroundColor: AppTheme.error,
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: 8),
        // Bouton rapide: Enregistrer vente
        FloatingActionButton.small(
          heroTag: 'vente',
          onPressed: () => _showVenteDialog(),
          backgroundColor: AppTheme.success,
          child: const Icon(Icons.sell),
        ),
        const SizedBox(height: 8),
        // Bouton principal: Ajouter un individu
        FloatingActionButton.extended(
          heroTag: 'ajouter',
          onPressed: _ajouterIndividu,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter individu'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildResumeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte principale
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Identifiant et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lot.identifiant,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(_getTypeIcon(_lot.type), size: 16),
                              const SizedBox(width: 4),
                              Text(_lot.type.label),
                            ],
                          ),
                        ],
                      ),
                      _buildStatutChip(_lot.statut),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Effectif avec indicateur visuel
                  _buildEffectifIndicator(),
                  const SizedBox(height: 24),

                  // Infos rapides
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today,
                        'Âge du lot',
                        '${_lot.ageEnJours} jours',
                      ),
                      _buildInfoItem(
                        Icons.trending_down,
                        'Mortalité',
                        '${_lot.tauxMortalite.toStringAsFixed(1)}%',
                        color: _lot.tauxMortalite > 10 ? AppTheme.error : null,
                      ),
                      _buildInfoItem(
                        Icons.pets,
                        'Individus',
                        '${_individus.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Métadonnées
          if (_lot.metadata.race != null ||
              _lot.metadata.origine != null ||
              _lot.metadata.poidsEntree != null) ...[
            const Text(
              'Caractéristiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_lot.metadata.race != null)
                      _buildDetailRow('Race', _lot.metadata.race!),
                    if (_lot.metadata.origine != null)
                      _buildDetailRow('Origine', _lot.metadata.origine!),
                    if (_lot.metadata.poidsEntree != null)
                      _buildDetailRow(
                        'Poids entrée',
                        '${_lot.metadata.poidsEntree!.toStringAsFixed(2)} kg',
                      ),
                    if (_lot.metadata.ageMoyenJours != null)
                      _buildDetailRow(
                        'Âge moyen',
                        '${_lot.ageMoyenIndividus} jours',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notes
          if (_lot.metadata.notes != null) ...[
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_lot.metadata.notes!),
              ),
            ),
          ],

          // Actions rapides
          const SizedBox(height: 24),
          const Text(
            'Actions rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.remove_circle_outline, size: 18),
                label: const Text('Mortalité'),
                onPressed: _showMortaliteDialog,
              ),
              ActionChip(
                avatar: const Icon(Icons.sell, size: 18),
                label: const Text('Vente'),
                onPressed: _showVenteDialog,
              ),
              ActionChip(
                avatar: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Ajouter individu'),
                onPressed: _ajouterIndividu,
              ),
              ActionChip(
                avatar: const Icon(Icons.edit_note, size: 18),
                label: const Text('Mettre à jour effectif'),
                onPressed: _mettreAJourEffectif,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEffectifIndicator() {
    final pourcentageRestant = _lot.effectifInitial > 0
        ? (_lot.effectifActuel / _lot.effectifInitial)
        : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_lot.effectifActuel}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '/ ${_lot.effectifInitial}',
              style: TextStyle(fontSize: 24, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('sujets'),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: pourcentageRestant,
          backgroundColor: AppTheme.border,
          color: pourcentageRestant > 0.9
              ? AppTheme.success
              : pourcentageRestant > 0.7
              ? AppTheme.warning
              : AppTheme.error,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(pourcentageRestant * 100).toStringAsFixed(0)}% restant',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildIndividusTab() {
    if (_isLoadingIndividus) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_individus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Aucun individu détaillé',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce lot est géré de manière groupée.\n'
              'Ajoutez des individus pour un suivi spécifique.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _ajouterIndividu,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un individu'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerIndividus,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _individus.length,
        itemBuilder: (context, index) {
          final lapin = _individus[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: lapin.sexe == Sexe.male
                    ? AppTheme.info.withValues(alpha: 0.2)
                    : AppTheme.accentPink.withValues(alpha: 0.2),
                child: Icon(
                  Icons.pets,
                  color: lapin.sexe == Sexe.male
                      ? AppTheme.info
                      : AppTheme.accentPink,
                ),
              ),
              title: Text(lapin.nom),
              subtitle: Text('${lapin.race} • ${lapin.ageFormate}'),
              trailing: Text(
                lapin.statut ?? '',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LapinDetailScreen(lapin: lapin),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoriqueTab() {
    // TODO: Implémenter l'historique des événements du lot
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Historique',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'L\'historique des événements du lot\nsera affiché ici.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutChip(StatutLot statut) {
    Color color;
    switch (statut) {
      case StatutLot.actif:
        color = AppTheme.success;
        break;
      case StatutLot.enAttente:
        color = AppTheme.warning;
        break;
      case StatutLot.termine:
        color = AppTheme.textSecondary;
        break;
      case StatutLot.vendu:
        color = AppTheme.info;
        break;
      case StatutLot.reforme:
        color = AppTheme.error;
        break;
    }

    return Chip(
      label: Text(
        statut.label,
        style: const TextStyle(color: AppTheme.textOnPrimary, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mortalite':
        _showMortaliteDialog();
        break;
      case 'vente':
        _showVenteDialog();
        break;
      case 'terminer':
        _terminerLot();
        break;
      case 'supprimer':
        _confirmerSuppression();
        break;
    }
  }

  void _modifierLot() {
    // TODO: Écran de modification
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Modification à implémenter')));
  }

  void _ajouterIndividu() {
    // TODO: Naviguer vers l'écran d'ajout d'individu avec le lot pré-sélectionné
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajout d\'individu à implémenter')),
    );
  }

  void _showMortaliteDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mortalité - ${_lot.identifiant}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Effectif actuel: ${_lot.effectifActuel}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de décès',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = int.tryParse(controller.text);
              if (nombre != null &&
                  nombre > 0 &&
                  nombre <= _lot.effectifActuel) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(this.context);
                await this.context.read<LotProvider>().enregistrerMortalite(
                  _lot.id!,
                  nombre,
                );
                if (mounted) {
                  navigator.pop();
                  setState(() {
                    _lot = _lot.copyWith(
                      effectifActuel: _lot.effectifActuel - nombre,
                    );
                  });
                  messenger.showSnackBar(
                    SnackBar(content: Text('$nombre décès enregistré(s)')),
                  );
                }
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showVenteDialog() {
    final nombreController = TextEditingController();
    final prixController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vente - ${_lot.identifiant}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Effectif actuel: ${_lot.effectifActuel}'),
            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre vendus',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
            onPressed: () async {
              final nombre = int.tryParse(nombreController.text);
              final prix = double.tryParse(
                prixController.text.replaceAll(',', '.'),
              );
              if (nombre != null &&
                  nombre > 0 &&
                  nombre <= _lot.effectifActuel) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(this.context);
                await this.context.read<LotProvider>().enregistrerVente(
                  _lot.id!,
                  nombre,
                  prixTotal: prix,
                );
                if (mounted) {
                  navigator.pop();
                  setState(() {
                    _lot = _lot.copyWith(
                      effectifActuel: _lot.effectifActuel - nombre,
                    );
                  });
                  messenger.showSnackBar(
                    SnackBar(content: Text('$nombre sujet(s) vendu(s)')),
                  );
                }
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _mettreAJourEffectif() {
    final controller = TextEditingController(
      text: _lot.effectifActuel.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour l\'effectif'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nouvel effectif',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nouvelEffectif = int.tryParse(controller.text);
              if (nouvelEffectif != null && nouvelEffectif >= 0) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(this.context);
                await this.context.read<LotProvider>().mettreAJourEffectif(
                  _lot.id!,
                  nouvelEffectif,
                );
                if (mounted) {
                  navigator.pop();
                  setState(() {
                    _lot = _lot.copyWith(effectifActuel: nouvelEffectif);
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Effectif mis à jour: $nouvelEffectif'),
                    ),
                  );
                }
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _terminerLot() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer ce lot ?'),
        content: Text('Le lot ${_lot.identifiant} sera marqué comme terminé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await this.context.read<LotProvider>().terminerLot(_lot.id!);
              if (mounted) {
                navigator.pop();
                setState(() {
                  _lot = _lot.copyWith(statut: StatutLot.termine);
                });
              }
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  void _confirmerSuppression() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce lot ?'),
        content: Text(
          'Le lot ${_lot.identifiant} sera définitivement supprimé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final stateNavigator = Navigator.of(this.context);
              await this.context.read<LotProvider>().supprimerLot(_lot.id!);
              if (mounted) {
                navigator.pop(); // Fermer dialog
                stateNavigator.pop(); // Retour à la liste
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
