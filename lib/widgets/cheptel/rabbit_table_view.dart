import 'package:flutter/material.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';

/// Vue tableau optimisée pour afficher des centaines de lapins
///
/// Utilisée pour la gestion à grande échelle (500-1000 lapins)
/// avec colonnes triables et sélection rapide.
class RabbitTableView extends StatefulWidget {
  final List<Lapin> lapins;
  final Function(Lapin) onTap;
  final Function(Lapin)? onLongPress;
  final bool showLotColumn;

  const RabbitTableView({
    super.key,
    required this.lapins,
    required this.onTap,
    this.onLongPress,
    this.showLotColumn = true,
  });

  @override
  State<RabbitTableView> createState() => _RabbitTableViewState();
}

class _RabbitTableViewState extends State<RabbitTableView> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<Lapin> _sortedLapins;

  @override
  void initState() {
    super.initState();
    _sortedLapins = List.from(widget.lapins);
  }

  @override
  void didUpdateWidget(RabbitTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lapins != oldWidget.lapins) {
      _sortedLapins = List.from(widget.lapins);
      _sortData();
    }
  }

  void _sort<T>(
    Comparable<T> Function(Lapin lapin) getField,
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
    _sortedLapins.sort((a, b) {
      Comparable valueA;
      Comparable valueB;

      switch (_sortColumnIndex) {
        case 0: // ID
          valueA = a.numeroIdentification ?? '';
          valueB = b.numeroIdentification ?? '';
          break;
        case 1: // Nom
          valueA = a.nom;
          valueB = b.nom;
          break;
        case 2: // Lot
          valueA = a.lotId ?? 0;
          valueB = b.lotId ?? 0;
          break;
        case 3: // Sexe
          valueA = a.sexe.index;
          valueB = b.sexe.index;
          break;
        case 4: // Âge
          valueA = a.ageEnJours;
          valueB = b.ageEnJours;
          break;
        case 5: // Poids
          valueA = a.poids ?? 0;
          valueB = b.poids ?? 0;
          break;
        case 6: // Statut
          valueA = a.statut ?? '';
          valueB = b.statut ?? '';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.lapins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun lapin à afficher',
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
            isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: const Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sort(
                (l) => l.numeroIdentification ?? '',
                columnIndex,
                ascending,
              ),
            ),
            DataColumn(
              label: const Text(
                'Nom',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.nom, columnIndex, ascending),
            ),
            if (widget.showLotColumn)
              DataColumn(
                label: const Text(
                  'Lot',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort((l) => l.lotId ?? 0, columnIndex, ascending),
              ),
            DataColumn(
              label: const Text(
                'Sexe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.sexe.index, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Âge',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.ageEnJours, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Poids',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.poids ?? 0, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Statut',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) =>
                  _sort((l) => l.statut ?? '', columnIndex, ascending),
            ),
          ],
          rows: _sortedLapins.map((lapin) {
            return DataRow(
              onSelectChanged: (_) => widget.onTap(lapin),
              onLongPress: widget.onLongPress != null
                  ? () => widget.onLongPress!(lapin)
                  : null,
              cells: [
                DataCell(
                  Text(
                    lapin.numeroIdentification ?? '-',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    lapin.nom.isNotEmpty ? lapin.nom : '-',
                    style: TextStyle(
                      fontStyle: lapin.nom.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: lapin.nom.isEmpty ? Colors.grey : null,
                    ),
                  ),
                ),
                if (widget.showLotColumn)
                  DataCell(Text(lapin.lotId?.toString() ?? '-')),
                DataCell(_buildSexeChip(lapin.sexe.label)),
                DataCell(Text(lapin.ageFormate)),
                DataCell(
                  Text(
                    lapin.poids != null
                        ? '${lapin.poids!.toStringAsFixed(2)} kg'
                        : '-',
                  ),
                ),
                DataCell(_buildStatutChip(lapin.statut)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSexeChip(String sexe) {
    final isMale = sexe.toLowerCase() == 'mâle' || sexe.toLowerCase() == 'male';
    final isFemale =
        sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'female';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMale
            ? Colors.blue.withValues(alpha: 0.15)
            : isFemale
            ? Colors.pink.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMale
                ? Icons.male
                : isFemale
                ? Icons.female
                : Icons.help_outline,
            size: 14,
            color: isMale
                ? Colors.blue
                : isFemale
                ? Colors.pink
                : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            sexe,
            style: TextStyle(
              fontSize: 12,
              color: isMale
                  ? Colors.blue
                  : isFemale
                  ? Colors.pink
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutChip(String? statut) {
    if (statut == null || statut.isEmpty) {
      return const Text('-');
    }

    Color chipColor;
    switch (statut.toLowerCase()) {
      case 'reproducteur':
      case 'reproductrice':
        chipColor = Colors.purple;
        break;
      case 'engraissement':
        chipColor = Colors.orange;
        break;
      case 'actif':
        chipColor = AppTheme.primaryGreen;
        break;
      case 'malade':
      case 'quarantaine':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut,
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget de toggle pour basculer entre vue cartes et vue tableau
class ViewModeToggle extends StatelessWidget {
  final bool isTableView;
  final ValueChanged<bool> onChanged;

  const ViewModeToggle({
    super.key,
    required this.isTableView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.grid_view),
          label: Text('Cartes'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.table_chart),
          label: Text('Tableau'),
        ),
      ],
      selected: {isTableView},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}
