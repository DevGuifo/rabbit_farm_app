import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/lapin_provider.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';

class LocalisationScreen extends StatefulWidget {
  const LocalisationScreen({super.key});

  @override
  State<LocalisationScreen> createState() => _LocalisationScreenState();
}

class _LocalisationScreenState extends State<LocalisationScreen> {
  String _batimentSelectionne = 'A';
  String? _zoneSelectionnee;

  final Map<String, List<String>> _batiments = {
    'A': ['Intérieur', 'Extérieur'],
    'B': ['Intérieur', 'Extérieur', 'Quarantaine'],
    'C': ['Intérieur'],
  };

  final Map<String, Map<String, List<CageInfo>>> _cages = {
    'A': {
      'Intérieur': [
        CageInfo(
          numero: 'A-INT-01',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(
          numero: 'A-INT-02',
          type: 'Individuelle',
          capacite: 1,
          occupants: 0,
        ),
        CageInfo(
          numero: 'A-INT-03',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(
          numero: 'A-INT-04',
          type: 'Collective',
          capacite: 4,
          occupants: 3,
        ),
        CageInfo(numero: 'A-INT-05', type: 'Nid', capacite: 1, occupants: 1),
      ],
      'Extérieur': [
        CageInfo(
          numero: 'A-EXT-01',
          type: 'Collective',
          capacite: 6,
          occupants: 4,
        ),
        CageInfo(
          numero: 'A-EXT-02',
          type: 'Collective',
          capacite: 6,
          occupants: 6,
        ),
      ],
    },
    'B': {
      'Intérieur': [
        CageInfo(
          numero: 'B-INT-01',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(
          numero: 'B-INT-02',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(numero: 'B-INT-03', type: 'Nid', capacite: 1, occupants: 1),
      ],
      'Quarantaine': [
        CageInfo(
          numero: 'B-QUA-01',
          type: 'Individuelle',
          capacite: 1,
          occupants: 0,
        ),
        CageInfo(
          numero: 'B-QUA-02',
          type: 'Individuelle',
          capacite: 1,
          occupants: 0,
        ),
      ],
      'Extérieur': [
        CageInfo(
          numero: 'B-EXT-01',
          type: 'Collective',
          capacite: 8,
          occupants: 5,
        ),
      ],
    },
    'C': {
      'Intérieur': [
        CageInfo(
          numero: 'C-INT-01',
          type: 'Individuelle',
          capacite: 1,
          occupants: 0,
        ),
        CageInfo(
          numero: 'C-INT-02',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(
          numero: 'C-INT-03',
          type: 'Individuelle',
          capacite: 1,
          occupants: 1,
        ),
        CageInfo(
          numero: 'C-INT-04',
          type: 'Collective',
          capacite: 4,
          occupants: 2,
        ),
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _zoneSelectionnee = _batiments[_batimentSelectionne]?.first;
  }

  List<CageInfo> _getCagesActuelles() {
    if (_zoneSelectionnee == null) return [];
    return _cages[_batimentSelectionne]?[_zoneSelectionnee!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Localisation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_outlined),
            onPressed: _ajouterBatiment,
            tooltip: 'Ajouter bâtiment',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de bâtiment horizontal
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              height: 100,
              color: Theme.of(context).colorScheme.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _batiments.keys.length,
                itemBuilder: (context, index) {
                  final batiment = _batiments.keys.elementAt(index);
                  final isSelected = _batimentSelectionne == batiment;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildBatimentCard(batiment, isSelected),
                  );
                },
              ),
            ),
          ),

          // Sélecteur de zone
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._batiments[_batimentSelectionne]!.map((zone) {
                      final isSelected = _zoneSelectionnee == zone;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildZoneChip(zone, isSelected),
                      );
                    }).toList(),
                    // Bouton ajouter zone
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Zone'),
                        onPressed: _ajouterZone,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Statistiques zone
          if (_zoneSelectionnee != null)
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: _buildStatistiquesZone(_getCagesActuelles()),
            ),

          // Liste des cages
          Expanded(child: _buildListeCages()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterCage,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter cage'),
      ),
    );
  }

  Widget _buildBatimentCard(String batiment, bool isSelected) {
    final zones = _batiments[batiment] ?? [];
    final totalCages = zones.fold<int>(
      0,
      (sum, zone) => sum + (_cages[batiment]?[zone]?.length ?? 0),
    );

    return InkWell(
      onTap: () {
        setState(() {
          _batimentSelectionne = batiment;
          _zoneSelectionnee = _batiments[batiment]?.first;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_rounded,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Bât. $batiment',
              style: AppTheme.labelMedium.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$totalCages cages',
              style: AppTheme.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneChip(String zone, bool isSelected) {
    final cages = _cages[_batimentSelectionne]?[zone] ?? [];

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconeZone(zone),
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(zone),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${cages.length}',
              style: AppTheme.labelSmall.copyWith(
                color: isSelected ? Colors.white : null,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      onSelected: (_) {
        setState(() {
          _zoneSelectionnee = zone;
        });
      },
    );
  }

  IconData _getIconeZone(String zone) {
    switch (zone.toLowerCase()) {
      case 'intérieur':
        return Icons.meeting_room_rounded;
      case 'extérieur':
        return Icons.grass_rounded;
      case 'quarantaine':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Widget _buildStatistiquesZone(List<CageInfo> cages) {
    final capaciteTotale = cages.fold(0, (sum, c) => sum + c.capacite);
    final occupantsTotaux = cages.fold(0, (sum, c) => sum + c.occupants);
    final tauxOccupation = capaciteTotale > 0
        ? (occupantsTotaux / capaciteTotale * 100).round()
        : 0;
    final cagesVides = cages.where((c) => c.occupants == 0).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.grid_view_rounded,
              '${cages.length}',
              'Cages',
              const Color(0xFF2196F3),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.pets_rounded,
              '$occupantsTotaux/$capaciteTotale',
              'Lapins',
              const Color(0xFF4CAF50),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.percent_rounded,
              '$tauxOccupation%',
              'Taux',
              tauxOccupation > 80
                  ? const Color(0xFFFF5722)
                  : const Color(0xFFFF9800),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_outline_rounded,
              '$cagesVides',
              'Vides',
              const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildListeCages() {
    final cages = _getCagesActuelles();

    if (cages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune cage dans cette zone',
              style: AppTheme.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cages.length,
          itemBuilder: (context, index) {
            final cage = cages[index];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (index * 50)),
              child: _buildCageCard(cage, lapinProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildCageCard(CageInfo cage, LapinProvider lapinProvider) {
    final estVide = cage.occupants == 0;
    final estPleine = cage.occupants >= cage.capacite;
    final estSurpeuplee = cage.occupants > cage.capacite;

    Color couleurStatut;
    Color couleurFond;
    IconData iconeStatut;

    if (estSurpeuplee) {
      couleurStatut = const Color(0xFFFF5722);
      couleurFond = const Color(0xFFFF5722);
      iconeStatut = Icons.warning_rounded;
    } else if (estPleine) {
      couleurStatut = const Color(0xFFFF9800);
      couleurFond = const Color(0xFFFF9800);
      iconeStatut = Icons.info_outline_rounded;
    } else if (estVide) {
      couleurStatut = const Color(0xFF9E9E9E);
      couleurFond = const Color(0xFF9E9E9E);
      iconeStatut = Icons.check_circle_outline_rounded;
    } else {
      couleurStatut = const Color(0xFF4CAF50);
      couleurFond = const Color(0xFF4CAF50);
      iconeStatut = Icons.check_circle_rounded;
    }

    final lapinsDansCage = lapinProvider.lapins
        .where((l) => l.localisation == cage.numero)
        .toList();
    final progression = cage.capacite > 0
        ? cage.occupants / cage.capacite
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: couleurStatut.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _afficherDetailsCage(cage, lapinsDansCage),
        onLongPress: () => _afficherMenuCage(cage),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: couleurFond.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: couleurStatut.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconeTypeCage(cage.type),
                      color: couleurStatut,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cage.numero,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cage.type,
                          style: AppTheme.labelSmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (estSurpeuplee)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: couleurStatut,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconeStatut, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),

            // Corps
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Occupation
                  Row(
                    children: [
                      Icon(
                        Icons.pets_rounded,
                        size: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Occupation : ',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${cage.occupants}/${cage.capacite}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: couleurStatut,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progression * 100).round()}%',
                        style: AppTheme.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: couleurStatut,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progression,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(couleurStatut),
                      minHeight: 8,
                    ),
                  ),

                  // Liste des lapins
                  if (lapinsDansCage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ...lapinsDansCage
                        .take(3)
                        .map(
                          (lapin) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  lapin.sexe == 'male'
                                      ? Icons.male
                                      : Icons.female,
                                  size: 16,
                                  color: lapin.sexe == 'male'
                                      ? const Color(0xFF2196F3)
                                      : const Color(0xFFFF6B9D),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    lapin.nom,
                                    style: AppTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (lapinsDansCage.length > 3)
                      Text(
                        '+ ${lapinsDansCage.length - 3} autre(s)',
                        style: AppTheme.labelSmall.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconeTypeCage(String type) {
    switch (type.toLowerCase()) {
      case 'individuelle':
        return Icons.person_rounded;
      case 'collective':
        return Icons.groups_rounded;
      case 'nid':
        return Icons.bed_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  void _afficherDetailsCage(CageInfo cage, List<Lapin> lapins) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLarge),
            topRight: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // En-tête
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconeTypeCage(cage.type),
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cage.numero,
                            style: AppTheme.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cage.type} • Capacité ${cage.capacite}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Liste des lapins
              if (lapins.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cage vide',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: lapins.length,
                    itemBuilder: (context, index) {
                      final lapin = lapins[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: lapin.sexe == 'male'
                                ? const Color(0xFF2196F3).withOpacity(0.1)
                                : const Color(0xFFFF6B9D).withOpacity(0.1),
                            child: Icon(
                              lapin.sexe == 'male' ? Icons.male : Icons.female,
                              color: lapin.sexe == 'male'
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFFFF6B9D),
                            ),
                          ),
                          title: Text(lapin.nom, style: AppTheme.bodyMedium),
                          subtitle: Text(
                            '${lapin.race} • ${lapin.statut ?? "Actif"}',
                            style: AppTheme.labelSmall,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Fermer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deplacerLapin(cage);
                        },
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Déplacer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ajouterZone() {
    final nomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.domain_add, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('Ajouter une zone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom de la zone',
                hintText: 'Ex: Quarantaine, Maternité, Salle B...',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La zone sera créée vide dans le bâtiment "$_batimentSelectionne"',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final nom = nomController.text.trim();
              if (nom.isEmpty) {
                SnackbarHelper.showError(context, 'Le nom est requis');
                return;
              }
              if (_batiments[_batimentSelectionne]!.contains(nom)) {
                SnackbarHelper.showError(context, 'Cette zone existe déjà');
                return;
              }

              setState(() {
                _batiments[_batimentSelectionne]!.add(nom);
                _cages[_batimentSelectionne]![nom] = [];
              });

              Navigator.pop(context);
              SnackbarHelper.showSuccess(
                context,
                '✅ Zone "$nom" créée avec succès',
              );

              // Sélectionner automatiquement la nouvelle zone
              setState(() {
                _zoneSelectionnee = nom;
              });
            },
            icon: const Icon(Icons.check),
            label: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _ajouterBatiment() {
    final nomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_home_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('Ajouter un bâtiment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom du bâtiment',
                hintText: 'Ex: D, E, Bâtiment Nord...',
                prefixIcon: const Icon(Icons.business_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Un bâtiment par défaut avec une zone "Intérieur" sera créé',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final nom = nomController.text.trim().toUpperCase();
              if (nom.isEmpty) {
                SnackbarHelper.showError(context, 'Le nom est requis');
                return;
              }
              if (_batiments.containsKey(nom)) {
                SnackbarHelper.showError(context, 'Ce bâtiment existe déjà');
                return;
              }

              setState(() {
                _batiments[nom] = ['Intérieur'];
                _cages[nom] = {'Intérieur': []};
              });

              Navigator.pop(context);
              SnackbarHelper.showSuccess(
                context,
                '✅ Bâtiment "$nom" créé avec succès',
              );

              // Sélectionner automatiquement le nouveau bâtiment
              setState(() {
                _batimentSelectionne = nom;
                _zoneSelectionnee = 'Intérieur';
              });
            },
            icon: const Icon(Icons.check),
            label: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _ajouterCage() {
    if (_zoneSelectionnee == null) {
      SnackbarHelper.showError(context, 'Sélectionnez une zone d\'abord');
      return;
    }

    final numeroController = TextEditingController();
    String typeSelectionne = 'Individuelle';
    int capacite = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.grid_on_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              const Text('Ajouter une cage'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: numeroController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de cage',
                    hintText:
                        'Ex: ${_batimentSelectionne}-${_zoneSelectionnee?.substring(0, 3).toUpperCase()}-XX',
                    prefixIcon: const Icon(Icons.tag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type de cage',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: typeSelectionne,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individuelle',
                      child: Text('Individuelle'),
                    ),
                    DropdownMenuItem(
                      value: 'Collective',
                      child: Text('Collective'),
                    ),
                    DropdownMenuItem(
                      value: 'Nid',
                      child: Text('Nid (Maternité)'),
                    ),
                    DropdownMenuItem(
                      value: 'Engraissement',
                      child: Text('Engraissement'),
                    ),
                    DropdownMenuItem(
                      value: 'Quarantaine',
                      child: Text('Quarantaine'),
                    ),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      typeSelectionne = value!;
                      // Ajuster capacité par défaut selon type
                      if (typeSelectionne == 'Individuelle' ||
                          typeSelectionne == 'Nid') {
                        capacite = 1;
                      } else if (typeSelectionne == 'Collective') {
                        capacite = 4;
                      } else if (typeSelectionne == 'Engraissement') {
                        capacite = 8;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Capacité: $capacite lapin${capacite > 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: capacite.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: capacite.toString(),
                  onChanged: (value) {
                    setStateDialog(() => capacite = value.toInt());
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final numero = numeroController.text.trim().toUpperCase();
                if (numero.isEmpty) {
                  SnackbarHelper.showError(context, 'Le numéro est requis');
                  return;
                }

                // Vérifier si cage existe déjà
                final cagesZone =
                    _cages[_batimentSelectionne]?[_zoneSelectionnee!] ?? [];
                if (cagesZone.any((c) => c.numero == numero)) {
                  SnackbarHelper.showError(context, 'Cette cage existe déjà');
                  return;
                }

                setState(() {
                  _cages[_batimentSelectionne]![_zoneSelectionnee!]!.add(
                    CageInfo(
                      numero: numero,
                      type: typeSelectionne,
                      capacite: capacite,
                      occupants: 0,
                    ),
                  );
                });

                Navigator.pop(context);
                SnackbarHelper.showSuccess(
                  context,
                  '✅ Cage "$numero" créée avec succès',
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _deplacerLapin(CageInfo cage) {
    final provider = Provider.of<LapinProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          String? lapinSelectionneId;
          String? cageDestination;

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text('Déplacer un lapin'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélection du lapin
                  const Text(
                    'Sélectionner le lapin à déplacer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                      hint: const Text('Choisir un lapin...'),
                      value: lapinSelectionneId,
                      items: provider.lapins.map((lapin) {
                        return DropdownMenuItem(
                          value: lapin.id.toString(),
                          child: Text('${lapin.nom} (${lapin.race})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() => lapinSelectionneId = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sélection cage destination
                  const Text(
                    'Cage de destination',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(Icons.grid_on),
                      ),
                      hint: const Text('Choisir une cage...'),
                      value: cageDestination,
                      items: _getAllCages()
                          .where(
                            (c) => c.occupants < c.capacite,
                          ) // Seulement cages disponibles
                          .map((cageInfo) {
                            return DropdownMenuItem(
                              value: cageInfo.numero,
                              child: Text(
                                '${cageInfo.numero} (${cageInfo.occupants}/${cageInfo.capacite})',
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() => cageDestination = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info
                  if (lapinSelectionneId != null && cageDestination != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Le déplacement sera enregistré dans l\'historique',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton.icon(
                onPressed:
                    (lapinSelectionneId != null && cageDestination != null)
                    ? () {
                        // Mettre à jour la localisation du lapin
                        final lapin = provider.lapins.firstWhere(
                          (l) => l.id.toString() == lapinSelectionneId,
                        );

                        // Trouver l'ancienne cage et diminuer occupants
                        _updateCageOccupants(lapin.localisation ?? '', -1);

                        // Augmenter occupants nouvelle cage
                        _updateCageOccupants(cageDestination!, 1);

                        // Mettre à jour localisation lapin
                        final lapinModifie = lapin.copyWith(
                          localisation: cageDestination,
                        );
                        provider.modifierLapin(lapinModifie);

                        Navigator.pop(context);
                        SnackbarHelper.showSuccess(
                          context,
                          '✅ ${lapin.nom} déplacé vers $cageDestination',
                        );
                        setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Déplacer'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<CageInfo> _getAllCages() {
    List<CageInfo> allCages = [];
    _cages.forEach((batiment, zones) {
      zones.forEach((zone, cages) {
        allCages.addAll(cages);
      });
    });
    return allCages;
  }

  void _updateCageOccupants(String numeroCage, int delta) {
    _cages.forEach((batiment, zones) {
      zones.forEach((zone, cages) {
        final index = cages.indexWhere((c) => c.numero == numeroCage);
        if (index != -1) {
          final cage = cages[index];
          cages[index] = CageInfo(
            numero: cage.numero,
            type: cage.type,
            capacite: cage.capacite,
            occupants: (cage.occupants + delta).clamp(0, cage.capacite),
          );
        }
      });
    });
  }

  void _afficherMenuCage(CageInfo cage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              cage.numero,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              cage.type,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white),
              ),
              title: const Text('Modifier'),
              subtitle: const Text('Changer le type ou la capacité'),
              onTap: () {
                Navigator.pop(context);
                _modifierCage(cage);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              title: const Text('Supprimer'),
              subtitle: const Text('Retirer cette cage'),
              onTap: () {
                Navigator.pop(context);
                _supprimerCage(cage);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _modifierCage(CageInfo cage) {
    String typeSelectionne = cage.type;
    int capacite = cage.capacite;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text('Modifier la cage'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cage: ${cage.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Type de cage',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeSelectionne,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Individuelle',
                    child: Text('Individuelle'),
                  ),
                  DropdownMenuItem(
                    value: 'Collective',
                    child: Text('Collective'),
                  ),
                  DropdownMenuItem(
                    value: 'Nid',
                    child: Text('Nid (Maternité)'),
                  ),
                  DropdownMenuItem(
                    value: 'Engraissement',
                    child: Text('Engraissement'),
                  ),
                  DropdownMenuItem(
                    value: 'Quarantaine',
                    child: Text('Quarantaine'),
                  ),
                ],
                onChanged: (value) {
                  setStateDialog(() => typeSelectionne = value!);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Capacité: $capacite lapin${capacite > 1 ? 's' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: capacite.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: capacite.toString(),
                onChanged: (value) {
                  setStateDialog(() => capacite = value.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Trouver et mettre à jour la cage
                  _cages.forEach((batiment, zones) {
                    zones.forEach((zone, cages) {
                      final index = cages.indexWhere(
                        (c) => c.numero == cage.numero,
                      );
                      if (index != -1) {
                        cages[index] = CageInfo(
                          numero: cage.numero,
                          type: typeSelectionne,
                          capacite: capacite,
                          occupants: cage.occupants.clamp(0, capacite),
                        );
                      }
                    });
                  });
                });

                Navigator.pop(context);
                SnackbarHelper.showSuccess(
                  context,
                  '✅ Cage modifiée avec succès',
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _supprimerCage(CageInfo cage) {
    if (cage.occupants > 0) {
      DialogHelper.showError(
        context: context,
        title: 'Suppression impossible',
        message:
            'Cette cage contient encore ${cage.occupants} lapin${cage.occupants > 1 ? 's' : ''}.\n\nVeuillez déplacer tous les occupants avant de supprimer la cage.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment supprimer la cage "${cage.numero}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                // Trouver et supprimer la cage
                _cages.forEach((batiment, zones) {
                  zones.forEach((zone, cages) {
                    cages.removeWhere((c) => c.numero == cage.numero);
                  });
                });
              });

              Navigator.pop(context);
              SnackbarHelper.showSuccess(context, '✅ Cage supprimée');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class CageInfo {
  final String numero;
  final String type;
  final int capacite;
  final int occupants;

  CageInfo({
    required this.numero,
    required this.type,
    required this.capacite,
    required this.occupants,
  });
}
