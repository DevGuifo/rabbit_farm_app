import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran d'affichage des courbes de croissance
class CourbesCroissanceScreen extends StatefulWidget {
  const CourbesCroissanceScreen({super.key});

  @override
  State<CourbesCroissanceScreen> createState() =>
      _CourbesCroissanceScreenState();
}

class _CourbesCroissanceScreenState extends State<CourbesCroissanceScreen> {
  Lapin? _lapinSelectionne;
  String _periodeSelectionnee = '3mois'; // 1mois, 3mois, 6mois, 1an, tout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenCourbesCroissance,
        icon: Icons.show_chart_rounded,
        iconColor: AppTheme.info,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _afficherAide(context),
          ),
        ],
      ),
      body: Consumer2<LapinProvider, SanteProvider>(
        builder: (context, lapinProvider, santeProvider, child) {
          if (lapinProvider.lapins.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSelectionLapin(lapinProvider),
              _buildFiltrePeriode(),
              if (_lapinSelectionne != null)
                Expanded(child: _buildGraphique(santeProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun lapin disponible',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des lapins pour voir leurs courbes',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionLapin(LapinProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.info.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionner un lapin',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Lapin>(
            initialValue: _lapinSelectionne,
            decoration: AppTheme.inputDecoration(
              label: '',
              prefixIcon: Icons.pets,
            ).copyWith(filled: true, fillColor: AppTheme.cardLight),
            hint: const Text('Choisir un lapin...'),
            items: provider.lapins.map((lapin) {
              return DropdownMenuItem(
                value: lapin,
                child: Text('${lapin.nom} - ${lapin.race}'),
              );
            }).toList(),
            onChanged: (lapin) {
              setState(() => _lapinSelectionne = lapin);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrePeriode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Période : ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                _buildChipPeriode('1mois', '1 mois'),
                _buildChipPeriode('3mois', '3 mois'),
                _buildChipPeriode('6mois', '6 mois'),
                _buildChipPeriode('1an', '1 an'),
                _buildChipPeriode('tout', 'Tout'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipPeriode(String value, String label) {
    final isSelected = _periodeSelectionnee == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _periodeSelectionnee = value);
      },
      selectedColor: AppTheme.info.withValues(alpha: 0.6),
      labelStyle: AppTheme.bodyMedium.copyWith(
        color: isSelected ? AppTheme.textLight : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildGraphique(SanteProvider santeProvider) {
    if (_lapinSelectionne == null) {
      return const Center(child: Text('Sélectionnez un lapin'));
    }

    final pesees = _getPeseesFiltrees(santeProvider);

    if (pesees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.scale_outlined,
              size: 60,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune pesée enregistrée',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des pesées pour voir la courbe',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfosLapin(),
          const SizedBox(height: 16),
          _buildLineChart(pesees),
          const SizedBox(height: 16),
          _buildStatistiques(pesees),
          const SizedBox(height: 16),
          _buildListePesees(pesees),
        ],
      ),
    );
  }

  Widget _buildInfosLapin() {
    if (_lapinSelectionne == null) return const SizedBox();

    final lapin = _lapinSelectionne!;
    final age = _calculerAge(lapin.dateNaissance);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.info.withValues(alpha: 0.2),
            child: Text(
              lapin.nom[0].toUpperCase(),
              style: AppTheme.titleLarge.copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lapin.nom, style: AppTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Race: ${lapin.race}'),
                Text('Âge: $age'),
                if (lapin.poids != null)
                  Text('Poids actuel: ${lapin.poids!.toStringAsFixed(0)}g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Pesee> pesees) {
    // Trier par date
    pesees.sort((a, b) => a.date.compareTo(b.date));

    // Créer les points de données
    final spots = pesees.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.poids);
    }).toList();

    // Calculer min/max pour les axes
    final poidsMin = pesees.map((p) => p.poids).reduce((a, b) => a < b ? a : b);
    final poidsMax = pesees.map((p) => p.poids).reduce((a, b) => a > b ? a : b);
    final margin = (poidsMax - poidsMin) * 0.1;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 500,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= pesees.length) return const Text('');
                  final pesee = pesees[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(pesee.date),
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}g',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          minX: 0,
          maxX: (pesees.length - 1).toDouble(),
          minY: poidsMin - margin,
          maxY: poidsMax + margin,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.info,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.info,
                    strokeWidth: 2,
                    strokeColor: AppTheme.textLight,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.info.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final pesee = pesees[spot.x.toInt()];
                  return LineTooltipItem(
                    '${pesee.poids.toStringAsFixed(0)}g\n${DateFormat('dd/MM/yyyy').format(pesee.date)}',
                    AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistiques(List<Pesee> pesees) {
    final poidsMin = pesees.map((p) => p.poids).reduce((a, b) => a < b ? a : b);
    final poidsMax = pesees.map((p) => p.poids).reduce((a, b) => a > b ? a : b);
    final poidsMoyen =
        pesees.map((p) => p.poids).reduce((a, b) => a + b) / pesees.length;
    final gainTotal = poidsMax - poidsMin;

    // Calculer le gain quotidien moyen si plus d'une pesée
    double? gainQuotidien;
    if (pesees.length > 1) {
      final premierePesee = pesees.first;
      final dernierePesee = pesees.last;
      final jours = dernierePesee.date.difference(premierePesee.date).inDays;
      if (jours > 0) {
        gainQuotidien = (dernierePesee.poids - premierePesee.poids) / jours;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Nombre de pesées',
                  pesees.length.toString(),
                  Icons.scale,
                  AppTheme.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Poids moyen',
                  '${poidsMoyen.toStringAsFixed(0)}g',
                  Icons.trending_flat,
                  AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Poids min',
                  '${poidsMin.toStringAsFixed(0)}g',
                  Icons.arrow_downward,
                  AppTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Poids max',
                  '${poidsMax.toStringAsFixed(0)}g',
                  Icons.arrow_upward,
                  AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Gain total',
                  '${gainTotal.toStringAsFixed(0)}g',
                  Icons.trending_up,
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Gain/jour',
                  gainQuotidien != null
                      ? '${gainQuotidien.toStringAsFixed(1)}g'
                      : 'N/A',
                  Icons.calendar_today,
                  AppTheme.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTheme.titleMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListePesees(List<Pesee> pesees) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique des pesées',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...pesees.reversed.map((pesee) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.info.withValues(alpha: 0.2),
                  child: const Icon(Icons.scale, color: AppTheme.info),
                ),
                title: Text('${pesee.poids.toStringAsFixed(0)}g'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy', 'fr_FR').format(pesee.date),
                ),
                trailing: pesee.notes != null
                    ? IconButton(
                        icon: const Icon(Icons.note, color: AppTheme.warning),
                        onPressed: () {
                          _afficherNote(pesee.notes!);
                        },
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Pesee> _getPeseesFiltrees(SanteProvider provider) {
    if (_lapinSelectionne == null) return [];

    final pesees = provider.getPeseesParLapin(_lapinSelectionne!.id!);

    // Filtrer par période
    final maintenant = DateTime.now();
    DateTime? dateDebut;

    switch (_periodeSelectionnee) {
      case '1mois':
        dateDebut = maintenant.subtract(const Duration(days: 30));
        break;
      case '3mois':
        dateDebut = maintenant.subtract(const Duration(days: 90));
        break;
      case '6mois':
        dateDebut = maintenant.subtract(const Duration(days: 180));
        break;
      case '1an':
        dateDebut = maintenant.subtract(const Duration(days: 365));
        break;
      case 'tout':
      default:
        return pesees;
    }

    return pesees.where((p) => p.date.isAfter(dateDebut!)).toList();
  }

  String _calculerAge(DateTime dateNaissance) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateNaissance);

    if (difference.inDays < 30) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final mois = (difference.inDays / 30).floor();
      return '$mois mois';
    } else {
      final ans = (difference.inDays / 365).floor();
      final mois = ((difference.inDays % 365) / 30).floor();
      return '$ans an${ans > 1 ? 's' : ''}${mois > 0 ? ' et $mois mois' : ''}';
    }
  }

  void _afficherNote(String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleNotePesee),
        content: Text(note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _afficherAide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleAideCourbesCroissance),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Suivi de la croissance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Cette courbe permet de visualiser l\'évolution du poids de vos lapins dans le temps.',
              ),
              SizedBox(height: 16),
              Text(
                'Utilisation :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Sélectionnez un lapin dans la liste déroulante'),
              Text(
                '• Choisissez la période d\'affichage (1 mois à tout l\'historique)',
              ),
              Text('• Touchez un point sur la courbe pour voir les détails'),
              SizedBox(height: 16),
              Text(
                'Statistiques affichées :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Nombre total de pesées'),
              Text('• Poids minimum et maximum'),
              Text('• Poids moyen sur la période'),
              Text('• Gain de poids total et quotidien'),
              SizedBox(height: 16),
              Text(
                'Recommandations :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Pesez régulièrement (1x/semaine pour les jeunes)'),
              Text('• Un gain quotidien normal : 30-40g pour un lapereau'),
              Text('• Surveillez les stagnations ou pertes de poids'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
