import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/batiment.dart';
import '../../models/clapier.dart';
import '../../models/cage.dart';
import '../../models/enums/localisation_enums.dart';
import '../../repositories/localisation_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class LocalisationManagerScreen extends StatefulWidget {
  const LocalisationManagerScreen({super.key});

  @override
  State<LocalisationManagerScreen> createState() =>
      _LocalisationManagerScreenState();
}

class _LocalisationManagerScreenState extends State<LocalisationManagerScreen> {
  final _repository = LocalisationRepository.instance;

  List<Batiment> _batiments = [];
  final Map<int, List<Clapier>> _clapiersParBatiment = {};
  final Map<int, List<Map<String, dynamic>>> _cagesParClapier = {};

  Batiment? _batimentSelectionne;
  String _filtreClapier = 'tous';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _loading = true);

    _batiments = await _repository.getAllBatiments();

    if (_batiments.isEmpty) {
      await _repository.initialiserLocalisationParDefaut();
      _batiments = await _repository.getAllBatiments();
    }

    if (_batiments.isNotEmpty && _batimentSelectionne == null) {
      _batimentSelectionne = _batiments.first;
    }

    await _chargerHierarchie();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _chargerHierarchie() async {
    _clapiersParBatiment.clear();
    _cagesParClapier.clear();

    for (var batiment in _batiments) {
      final clapiers = await _repository.getClapiersByBatiment(batiment.id!);
      _clapiersParBatiment[batiment.id!] = clapiers;

      for (var clapier in clapiers) {
        final cages = await _repository.getCagesByClapier(clapier.id!);
        List<Map<String, dynamic>> cagesData = [];

        for (var cage in cages) {
          final occupants = await _repository.getOccupantsCage(cage.id!);
          cagesData.add({
            'cage': cage,
            'occupants': occupants,
            'statut': cage.getStatut(occupants),
            'couleur': cage.getCouleurStatut(occupants),
            'disponible': cage.estDisponible(occupants),
          });
        }

        _cagesParClapier[clapier.id!] = cagesData;
      }
    }
  }

  List<Clapier> get _clapiersAffiches {
    if (_batimentSelectionne == null) return [];
    final clapiers = _clapiersParBatiment[_batimentSelectionne!.id!] ?? [];

    if (_filtreClapier == 'tous') return clapiers;
    return clapiers.where((c) => c.type.value == _filtreClapier).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              _buildBatimentSelector(),
              _buildTypeClapierFilter(),
              Expanded(child: _buildContent()),
            ],
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: AppTheme.primaryGreen),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppTheme.textLight),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_city, color: AppTheme.textLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des Localisations',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.textOnPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Bâtiments • Clapiers • Cages',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatimentSelector() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _batiments.length,
        itemBuilder: (context, index) {
          final batiment = _batiments[index];
          final isSelected = batiment.id == _batimentSelectionne?.id;

          return GestureDetector(
            onTap: () => setState(() => _batimentSelectionne = batiment),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.divider,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.domain,
                    color: isSelected
                        ? AppTheme.textLight
                        : AppTheme.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    batiment.nom,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.textLight
                          : AppTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeClapierFilter() {
    final types = [
      {'id': 'tous', 'label': 'Tous', 'icon': Icons.grid_view},
      {'id': 'interieur', 'label': 'Intérieur', 'icon': Icons.meeting_room},
      {'id': 'exterieur', 'label': 'Extérieur', 'icon': Icons.grass},
      {
        'id': 'quarantaine',
        'label': 'Quarantaine',
        'icon': Icons.health_and_safety,
      },
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _filtreClapier == type['id'];

          return GestureDetector(
            onTap: () => setState(() => _filtreClapier = type['id'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected
                        ? AppTheme.textLight
                        : AppTheme.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.textLight
                          : AppTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final clapiers = _clapiersAffiches;

    if (clapiers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun clapier',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _ajouterClapier(),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).ajouterClapier),
              style: AppTheme.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(AppTheme.accentPink),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: clapiers.length,
      itemBuilder: (context, index) {
        final clapier = clapiers[index];
        return _buildClapierSection(clapier);
      },
    );
  }

  Widget _buildClapierSection(Clapier clapier) {
    final cages = _cagesParClapier[clapier.id!] ?? [];

    IconData icone = Icons.location_on;
    if (clapier.icone == 'meeting_room') icone = Icons.meeting_room;
    if (clapier.icone == 'grass') icone = Icons.grass;
    if (clapier.icone == 'health_and_safety') icone = Icons.health_and_safety;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.divider,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du clapier
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icone, color: AppTheme.textLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clapier.nom,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cages.length} cage(s)',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _ajouterCage(clapier),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryGreen,
                  ),
                  tooltip: '${AppLocalizations.of(context).commonAjouter} cage',
                ),
              ],
            ),
          ),

          // Liste des cages
          if (cages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Aucune cage dans ce clapier',
                  style: TextStyle(color: AppTheme.textTertiary),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cages
                    .map((cageData) => _buildCageChip(cageData))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCageChip(Map<String, dynamic> cageData) {
    final cage = cageData['cage'] as Cage;
    final occupants = cageData['occupants'] as int;
    final couleur = Color(cageData['couleur'] as int);

    return GestureDetector(
      onTap: () => _afficherDetailsCage(cageData),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: couleur),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.window, color: couleur, size: 16),
            const SizedBox(width: 6),
            Text(
              cage.numero,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: couleur,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$occupants/${cage.capacite}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _afficherDetailsCage(Map<String, dynamic> cageData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final cage = cageData['cage'] as Cage;
        final occupants = cageData['occupants'] as int;
        final couleur = Color(cageData['couleur'] as int);

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.window, color: couleur, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cage.numero,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cage.getStatut(occupants).toUpperCase(),
                          style: TextStyle(color: couleur, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _modifierCage(cage);
                    },
                    icon: const Icon(Icons.edit, color: AppTheme.textSecondary),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _supprimerCage(cage);
                    },
                    icon: const Icon(Icons.delete, color: AppTheme.error),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Type', cage.type.label),
              _buildInfoRow('Capacité', '${cage.capacite} lapin(s)'),
              _buildInfoRow('Occupants', '$occupants lapin(s)'),
              _buildInfoRow(
                'Places disponibles',
                '${cage.capacite - occupants}',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return UnifiedFABSpeedDial(
      tooltip: AppLocalizations.of(context).commonAjouter,
      actions: [
        UnifiedFABAction(
          icon: Icons.domain,
          label: 'Bâtiment',
          tooltip: 'Ajouter un bâtiment',
          onPressed: _ajouterBatiment,
        ),
        UnifiedFABAction(
          icon: Icons.meeting_room,
          label: 'Clapier',
          tooltip: 'Ajouter un clapier',
          onPressed: _ajouterClapier,
        ),
      ],
    );
  }

  Future<void> _ajouterBatiment() async {
    final dialogTitle = AppLocalizations.of(context).commonAjouter;
    final nom = await _showInputDialog('$dialogTitle bâtiment', 'Nom');
    if (nom == null) return;

    await _repository.insertBatiment(Batiment(nom: nom));
    if (!mounted) return;
    _chargerDonnees();
  }

  Future<void> _ajouterClapier() async {
    if (_batimentSelectionne == null) return;

    final dialogTitle = AppLocalizations.of(context).commonAjouter;
    final nom = await _showInputDialog('$dialogTitle clapier', 'Nom');
    if (nom == null) return;

    await _repository.insertClapier(
      Clapier(
        batimentId: _batimentSelectionne!.id!,
        nom: nom,
        type: _filtreClapier == 'tous'
            ? TypeClapier.interieur
            : TypeClapier.fromString(_filtreClapier),
      ),
    );
    if (!mounted) return;
    _chargerDonnees();
  }

  Future<void> _ajouterCage(Clapier clapier) async {
    final numero = await _repository.genererNumeroCage(clapier.id!);

    await _repository.insertCage(
      Cage(
        clapierId: clapier.id!,
        numero: numero,
        type: TypeCage.individuelle,
        capacite: 1,
      ),
    );
    if (!mounted) return;
    _chargerDonnees();
  }

  Future<void> _modifierCage(Cage cage) async {
    final numeroController = TextEditingController(text: cage.numero);
    final capaciteController = TextEditingController(
      text: cage.capacite.toString(),
    );
    TypeCage typeSelectionne = cage.type;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).modifierCage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numeroController,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).hintNumeroCage,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TypeCage>(
                  initialValue: typeSelectionne,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).hintTypeCage,
                  ),
                  items: TypeCage.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => typeSelectionne = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capaciteController,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).labelCapaciteLapins,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.annuler),
                );
              },
            ),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return ElevatedButton(
                  onPressed: () {
                    if (numeroController.text.isEmpty ||
                        capaciteController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).msgTousChampsRequis,
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'numero': numeroController.text,
                      'type': typeSelectionne,
                      'capacite': int.tryParse(capaciteController.text) ?? 1,
                    });
                  },
                  child: Text(l10n.modifier),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final cageModifiee = Cage(
        id: cage.id,
        clapierId: cage.clapierId,
        numero: result['numero'] as String,
        type: result['type'] as TypeCage,
        capacite: result['capacite'] as int,
      );

      await _repository.updateCage(cageModifiee);
      if (!mounted) return;
      _chargerDonnees();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).msgCageModifiee)),
        );
      }
    }
  }

  Future<void> _supprimerCage(Cage cage) async {
    final l10nSuppression = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10nSuppression.confirmerSuppression),
        content: Text(
          'Voulez-vous vraiment supprimer la cage ${cage.numero} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10nSuppression.annuler),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(l10nSuppression.supprimer),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _repository.deleteCage(cage.id!);
      if (!mounted) return;
      _chargerDonnees();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgCageSupprimee)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).msgErrorPrefix(e.toString()),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<String?> _showInputDialog(String title, String hint) async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardLight,
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiary,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.info),
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.annuler),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}
