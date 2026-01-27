import 'package:flutter/material.dart';
import '../../../models/lot.dart';
import '../../../theme/app_theme.dart';

/// Vue tableau optimisée pour afficher les lots
///
/// Utilisée pour la gestion à grande échelle avec colonnes triables.
class LotTableView extends StatefulWidget {
  final List<Lot> lots;
  final Function(Lot) onTap;
  final Function(Lot)? onLongPress;

  const LotTableView({
    super.key,
    required this.lots,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<LotTableView> createState() => _LotTableViewState();
}

class _LotTableViewState extends State<LotTableView> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<Lot> _sortedLots;

  @override
  void initState() {
    super.initState();
    _sortedLots = List.from(widget.lots);
  }

  @override
  void didUpdateWidget(LotTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lots != oldWidget.lots) {
      _sortedLots = List.from(widget.lots);
      _sortData();
    }
  }

  void _sort<T>(
    Comparable<T> Function(Lot lot) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortData();
    });
  }

  void _sortData() {
    _sortedLots.sort((a, b) {
      Comparable valueA;
      Comparable valueB;

      switch (_sortColumnIndex) {
        case 0: // Identifiant
          valueA = a.identifiant;
          valueB = b.identifiant;
          break;
        case 1: // Type
          valueA = a.type.label;
          valueB = b.type.label;
          break;
        case 2: // Effectif
          valueA = a.effectifActuel;
          valueB = b.effectifActuel;
          break;
        case 3: // Age
          valueA = a.ageEnJours;
          valueB = b.ageEnJours;
          break;
        case 4: // Mortalite
          valueA = a.tauxMortalite;
          valueB = b.tauxMortalite;
          break;
        case 5: // Statut
          valueA = a.statut.label;
          valueB = b.statut.label;
          break;
        default:
          valueA = a.id ?? 0;
          valueB = b.id ?? 0;
      }

      final result = valueA.compareTo(valueB);
      return _sortAscending ? result : -result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun lot a afficher',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
          dataRowMinHeight: 52,
          dataRowMaxHeight: 60,
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: const Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.identifiant, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.type.label, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Effectif',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.effectifActuel, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Age',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.ageEnJours, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Mortalite',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.tauxMortalite, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Statut',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.statut.label, columnIndex, ascending),
            ),
          ],
          rows: _sortedLots.map((lot) {
            return DataRow(
              onSelectChanged: (_) => widget.onTap(lot),
              onLongPress: widget.onLongPress != null
                  ? () => widget.onLongPress!(lot)
                  : null,
              cells: [
                DataCell(
                  Text(
                    lot.identifiant,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(_buildTypeChip(lot.type)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lot.effectifActuel.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (lot.hasIndividus)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(Text(_formatAge(lot.ageEnJours))),
                DataCell(_buildMortaliteChip(lot.tauxMortalite)),
                DataCell(_buildStatutChip(lot.statut)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatAge(int jours) {
    if (jours < 7) return '$jours j';
    if (jours < 30) return '${(jours / 7).floor()} sem';
    return '${(jours / 30).floor()} mois';
  }

  Widget _buildTypeChip(TypeLot type) {
    Color chipColor;
    IconData icon;
    switch (type) {
      case TypeLot.engraissement:
        chipColor = Colors.orange;
        icon = Icons.restaurant;
        break;
      case TypeLot.reproduction:
        chipColor = Colors.pink;
        icon = Icons.favorite;
        break;
      case TypeLot.mixte:
        chipColor = Colors.purple;
        icon = Icons.blur_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(type.label, style: TextStyle(fontSize: 12, color: chipColor)),
        ],
      ),
    );
  }

  Widget _buildMortaliteChip(double taux) {
    Color color;
    if (taux <= 5) {
      color = Colors.green;
    } else if (taux <= 10) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${taux.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatutChip(StatutLot statut) {
    Color chipColor;
    switch (statut) {
      case StatutLot.actif:
        chipColor = Colors.green;
        break;
      case StatutLot.enAttente:
        chipColor = Colors.orange;
        break;
      case StatutLot.termine:
        chipColor = Colors.grey;
        break;
      case StatutLot.vendu:
        chipColor = Colors.blue;
        break;
      case StatutLot.reforme:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut.label,
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
