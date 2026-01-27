import 'package:flutter/material.dart';
import '../../../models/cage.dart';
import '../../../models/clapier.dart';
import '../../../models/batiment.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Liste des cages avec recherche et filtres
/// Design Stitch avec border-left coloré selon statut
class LocalisationCageList extends StatefulWidget {
  final List<Map<String, dynamic>> cagesData;
  final Map<int, Batiment> batimentsMap;
  final Map<int, Clapier> clapiersMap;
  final Function(Map<String, dynamic>) onCageTap;
  final Function(Cage) onCageMenu;

  const LocalisationCageList({
    super.key,
    required this.cagesData,
    required this.batimentsMap,
    required this.clapiersMap,
    required this.onCageTap,
    required this.onCageMenu,
  });

  @override
  State<LocalisationCageList> createState() => _LocalisationCageListState();
}

class _LocalisationCageListState extends State<LocalisationCageList> {
  String _searchQuery = '';
  String _filterStatus = 'All';

  List<Map<String, dynamic>> get _filteredCages {
    var filtered = widget.cagesData;

    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cageData) {
        final cage = cageData['cage'] as Cage;
        final clapier = widget.clapiersMap[cage.clapierId];
        final batiment = clapier != null
            ? widget.batimentsMap[clapier.batimentId]
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Cages',
            style: AppTheme.titleMedium.copyWith(
              color: isDark
                  ? AppTheme.textOnPrimary
                  : AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSearchBar(isDark),
        const SizedBox(height: 12),
        _buildFilterChips(isDark),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredCages.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCages.length,
                  itemBuilder: (context, index) {
                    final cageData = _filteredCages[index];
                    return _buildCageCard(context, cageData, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceDark
              : AppTheme.textOnPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.greyDarkAlt : AppTheme.greyMedium,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.divider,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppTheme.textOnPrimary
                      : AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).hintSearchCageLocation,
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.accentGreen
                        : AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'id': 'All', 'icon': Icons.check_rounded},
      {'id': 'Empty', 'icon': Icons.crop_square_rounded},
      {'id': 'Occupied', 'icon': Icons.pets_rounded},
      {'id': 'Cleaning', 'icon': Icons.warning_rounded},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == filter['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _filterStatus = filter['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryNeonGreen
                      : (isDark
                            ? AppTheme.surfaceDark
                            : AppTheme.textOnPrimary),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryNeonGreen
                        : (isDark ? AppTheme.greyDarkAlt : AppTheme.greyMedium),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? AppTheme.textPrimary
                          : (filter['id'] == 'Cleaning'
                                ? AppTheme.accentOrangeVivid
                                : (isDark
                                      ? AppTheme.accentGreen
                                      : AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['id'] as String,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.textPrimary
                            : (isDark
                                  ? AppTheme.textOnPrimary
                                  : AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCageCard(
    BuildContext context,
    Map<String, dynamic> cageData,
    bool isDark,
  ) {
    final cage = cageData['cage'] as Cage;
    final occupants = cageData['occupants'] as int;
    final statut = cageData['statut'] as String;
    final needsCleaning = cageData['needsCleaning'] == true;

    final clapier = widget.clapiersMap[cage.clapierId];
    final batiment = clapier != null
        ? widget.batimentsMap[clapier.batimentId]
        : null;

    return GestureDetector(
      onTap: () => widget.onCageTap(cageData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceDark
              : AppTheme.textOnPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.greyDarkest : AppTheme.greyE5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.divider,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Border-left coloré
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: needsCleaning
                      ? AppTheme.accentOrangeVivid
                      : (statut == 'vide'
                            ? AppTheme.grey9E
                            : AppTheme.primaryNeonGreen),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Thumbnail ou icône
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: statut == 'vide'
                          ? (isDark ? AppTheme.greyDark : AppTheme.greyE5)
                          : AppTheme.greySlate,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: statut == 'vide'
                        ? Icon(
                            Icons.cottage_rounded,
                            color: isDark
                                ? AppTheme.greyMuted
                                : AppTheme.grey999,
                            size: 28,
                          )
                        : const Icon(
                            Icons.pets_rounded,
                            color: AppTheme.textOnPrimary70,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Informations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cage ${cage.numero}',
                                style: AppTheme.titleMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.textOnPrimary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (needsCleaning)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warmLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFF97316,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  'Needs Cleaning',
                                  style: AppTheme.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                              )
                            else if (statut == 'vide')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.greyDark
                                      : AppTheme.lightF5,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF9E9E9E,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'Empty',
                                  style: AppTheme.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.accentGreen
                                        : AppTheme.greyMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${batiment?.nom ?? '?'} • ${statut == 'vide' ? 'Available' : 'Occupied'}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.accentGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (statut == 'vide')
                          Text(
                            'Ready for assignment',
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.primaryNeonGreen
                                  : AppTheme.successVivid,
                            ),
                          )
                        else if (occupants > 0)
                          Text(
                            occupants == 1
                                ? '1 Rabbit'
                                : occupants > cage.capacite
                                ? 'Doe + ${occupants - 1} Kits'
                                : '$occupants Rabbits',
                            style: AppTheme.caption.copyWith(
                              color: isDark
                                  ? const Color(
                                      0xFFE0E6E0,
                                    ).withValues(alpha: 0.8)
                                  : AppTheme.textPrimary.withValues(
                                      alpha: 0.8,
                                    ),
                            ),
                          ),
                        if (cageData['lastCleaned'] != null)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: isDark
                                    ? AppTheme.success400
                                    : AppTheme.success500,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  cageData['lastCleaned'] as String,
                                  style: AppTheme.caption.copyWith(
                                    color: isDark
                                        ? AppTheme.textPrimary80
                                        : AppTheme.textPrimary80,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Menu 3 points
                  IconButton(
                    onPressed: () => widget.onCageMenu(cage),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 24,
                      color: isDark
                          ? AppTheme.accentGreen
                          : AppTheme.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? AppTheme.greyDarkAlt : AppTheme.greyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'No cages found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: AppTheme.bodyMedium.copyWith(
              color: isDark
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
