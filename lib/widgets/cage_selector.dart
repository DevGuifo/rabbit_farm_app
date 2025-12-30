import 'package:flutter/material.dart';
import '../models/batiment.dart';
import '../models/clapier.dart';
import '../models/cage.dart';
import '../services/database_helper.dart';
import '../services/localisation_service.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Sélecteur de cage avec navigation hiérarchique
class CageSelector extends StatefulWidget {
  final String? cageInitiale;

  const CageSelector({super.key, this.cageInitiale});

  @override
  State<CageSelector> createState() => _CageSelectorState();
}

class _CageSelectorState extends State<CageSelector> {
  final _dbHelper = DatabaseHelper.instance;

  List<Batiment> _batiments = [];
  List<Clapier> _clapiers = [];
  List<Map<String, dynamic>> _cages = [];

  Batiment? _batimentSelectionne;
  Clapier? _clapierSelectionne;

  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _loading = true);
    _batiments = await _dbHelper.getAllBatiments();

    if (widget.cageInitiale != null) {
      await _restaurerSelection(widget.cageInitiale!);
    }

    setState(() => _loading = false);
  }

  Future<void> _restaurerSelection(String numeroCage) async {
    final cage = await _dbHelper.getCageByNumero(numeroCage);
    if (cage == null) return;

    final clapier = await _dbHelper.getClapierById(cage.clapierId);
    if (clapier == null) return;

    final batiment = await _dbHelper.getBatimentById(clapier.batimentId);
    if (batiment == null) return;

    setState(() {
      _batimentSelectionne = batiment;
      _clapierSelectionne = clapier;
    });

    await _chargerClapiers(batiment.id!);
    await _chargerCages(clapier.id!);
  }

  Future<void> _chargerClapiers(int batimentId) async {
    _clapiers = await _dbHelper.getClapiersByBatiment(batimentId);
    setState(() {});
  }

  Future<void> _chargerCages(int clapierId) async {
    final cages = await _dbHelper.getCagesByClapier(clapierId);
    _cages = [];

    for (var cage in cages) {
      final occupants = await _dbHelper.getOccupantsCage(cage.id!);
      _cages.add({
        'cage': cage,
        'occupants': occupants,
        'disponible': cage.estDisponible(occupants),
        'statut': cage.getStatut(occupants),
        'couleur': cage.getCouleurStatut(occupants),
      });
    }

    setState(() {});
  }

  void _selectionnerBatiment(Batiment batiment) {
    setState(() {
      _batimentSelectionne = batiment;
      _clapierSelectionne = null;
      _clapiers = [];
      _cages = [];
    });
    _chargerClapiers(batiment.id!);
  }

  void _selectionnerClapier(Clapier clapier) {
    setState(() {
      _clapierSelectionne = clapier;
      _cages = [];
    });
    _chargerCages(clapier.id!);
  }

  void _selectionnerCage(Map<String, dynamic> cageData) {
    if (!cageData['disponible']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cette cage est ${cageData['statut']}'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final cage = cageData['cage'] as Cage;
    Navigator.pop(context, cage.numero);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            _buildBreadcrumb(isDark),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.info.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on, color: AppTheme.info),
        ),
        const SizedBox(width: 12),
        Text(
          'Sélectionner une cage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb(bool isDark) {
    return Wrap(
      spacing: 8,
      children: [
        _buildBreadcrumbItem('Bâtiments', _batimentSelectionne == null, isDark, () {
          setState(() {
            _batimentSelectionne = null;
            _clapierSelectionne = null;
            _clapiers = [];
            _cages = [];
          });
        }),
        if (_batimentSelectionne != null) ...[
          Icon(
            Icons.chevron_right,
            color: isDark ? AppTheme.textLight.withValues(alpha: 0.5) : AppTheme.textSecondary,
            size: 16,
          ),
          _buildBreadcrumbItem(
            _batimentSelectionne!.nom,
            _clapierSelectionne == null,
            isDark,
            () {
              setState(() {
                _clapierSelectionne = null;
                _cages = [];
              });
            },
          ),
        ],
        if (_clapierSelectionne != null) ...[
          Icon(
            Icons.chevron_right,
            color: isDark ? AppTheme.textLight.withValues(alpha: 0.5) : AppTheme.textSecondary,
            size: 16,
          ),
          _buildBreadcrumbItem(_clapierSelectionne!.nom, true, isDark, null),
        ],
      ],
    );
  }

  Widget _buildBreadcrumbItem(
    String label,
    bool isActive,
    bool isDark,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.info
              : (isDark ? AppTheme.stitchBorderDark : AppTheme.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive 
                ? Colors.white 
                : (isDark ? AppTheme.textLight : AppTheme.textSecondary),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_batimentSelectionne == null) {
      return _buildBatimentsList(isDark);
    } else if (_clapierSelectionne == null) {
      return _buildClapiersList(isDark);
    } else {
      return _buildCagesList(isDark);
    }
  }

  Widget _buildBatimentsList(bool isDark) {
    if (_batiments.isEmpty) {
      return _buildEmptyState('Aucun bâtiment', Icons.domain, isDark);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _batiments.length,
      itemBuilder: (context, index) {
        final batiment = _batiments[index];
        return _buildBatimentCard(batiment, isDark);
      },
    );
  }

  Widget _buildBatimentCard(Batiment batiment, bool isDark) {
    return GestureDetector(
      onTap: () => _selectionnerBatiment(batiment),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.domain, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              batiment.nom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (batiment.description != null)
              Text(
                batiment.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClapiersList(bool isDark) {
    if (_clapiers.isEmpty) {
      return _buildEmptyState('Aucun clapier', Icons.meeting_room, isDark);
    }

    return ListView.builder(
      itemCount: _clapiers.length,
      itemBuilder: (context, index) {
        final clapier = _clapiers[index];
        return _buildClapierCard(clapier, isDark);
      },
    );
  }

  Widget _buildClapierCard(Clapier clapier, bool isDark) {
    IconData icone = Icons.location_on;
    if (clapier.icone == 'meeting_room') icone = Icons.meeting_room;
    if (clapier.icone == 'grass') icone = Icons.grass;
    if (clapier.icone == 'health_and_safety') icone = Icons.health_and_safety;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.stitchBorderDark : AppTheme.border,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: ListTile(
        onTap: () => _selectionnerClapier(clapier),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: AppTheme.primaryGreen),
        ),
        title: Text(
          clapier.nom,
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          clapier.type.toUpperCase(),
          style: TextStyle(
            color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCagesList(bool isDark) {
    if (_cages.isEmpty) {
      return _buildEmptyState('Aucune cage', Icons.window, isDark);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _cages.length,
      itemBuilder: (context, index) {
        final cageData = _cages[index];
        return _buildCageCard(cageData, isDark);
      },
    );
  }

  Widget _buildCageCard(Map<String, dynamic> cageData, bool isDark) {
    final cage = cageData['cage'] as Cage;
    final occupants = cageData['occupants'] as int;
    final disponible = cageData['disponible'] as bool;
    final statut = cageData['statut'] as String;
    final couleur = Color(cageData['couleur'] as int);

    return GestureDetector(
      onTap: () => _selectionnerCage(cageData),
      child: Opacity(
        opacity: disponible ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: couleur, width: 2),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    disponible ? Icons.check_circle : Icons.block,
                    color: couleur,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cage.numero,
                      style: TextStyle(
                        color: couleur,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$occupants / ${cage.capacite}',
                style: TextStyle(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statut.toUpperCase(),
                style: TextStyle(
                  color: couleur,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icone, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icone,
            size: 64,
            color: isDark ? AppTheme.textLight.withValues(alpha: 0.5) : AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fonction helper pour afficher le sélecteur
Future<String?> showCageSelector(
  BuildContext context, {
  String? cageInitiale,
}) async {
  return await showDialog<String>(
    context: context,
    builder: (context) => CageSelector(cageInitiale: cageInitiale),
  );
}
