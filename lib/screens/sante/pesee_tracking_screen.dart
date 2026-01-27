import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../providers/sante_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'ajouter_pesee_screen.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

/// Écran de suivi des pesées avec graphique - Design Stitch "Weight Tracking"
class PeseeTrackingScreen extends StatefulWidget {
  final Lapin lapin;

  const PeseeTrackingScreen({super.key, required this.lapin});

  @override
  State<PeseeTrackingScreen> createState() => _PeseeTrackingScreenState();
}

class _PeseeTrackingScreenState extends State<PeseeTrackingScreen> {
  List<Pesee> _pesees = [];
  String _periodeActive =
      '1 Month'; // '1 Month', '3 Months', '6 Months', 'All Time'

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final pesees = await santeProvider.getPeseesByLapin(widget.lapin.id!);

    if (mounted) {
      setState(() {
        _pesees = pesees
          ..sort((a, b) => a.date.compareTo(b.date)); // Tri chronologique
      });
    }
  }

  List<Pesee> _getFilteredPesees() {
    if (_pesees.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_periodeActive) {
      case '1 Month':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 Months':
        cutoffDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6 Months':
        cutoffDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case 'All Time':
      default:
        return _pesees;
    }

    return _pesees.where((p) => p.date.isAfter(cutoffDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textMain = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSub = isDark ? AppTheme.textSecondary : AppTheme.textSecondary;

    final filteredPesees = _getFilteredPesees();
    final currentWeight = _pesees.isNotEmpty ? _pesees.last.poids : 0.0;
    double? lastMonthDiff;

    if (_pesees.length >= 2) {
      final lastMonth = DateTime.now().subtract(const Duration(days: 30));
      final previousWeight = _pesees
          .lastWhere(
            (p) => p.date.isBefore(lastMonth),
            orElse: () => _pesees.first,
          )
          .poids;
      lastMonthDiff = currentWeight - previousWeight;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _chargerDonnees,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header fixe
              SliverToBoxAdapter(child: _buildHeader(isDark, textMain)),
              // Contenu scrollable
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildRabbitSelector(
                      isDark,
                      surfaceColor,
                      textMain,
                      textSub,
                    ),
                    _buildChartCard(
                      isDark,
                      surfaceColor,
                      textMain,
                      textSub,
                      currentWeight,
                      lastMonthDiff,
                      filteredPesees,
                    ),
                    _buildPeriodFilters(
                      isDark,
                      surfaceColor,
                      textMain,
                      textSub,
                    ),
                    _buildHistory(
                      isDark,
                      surfaceColor,
                      textMain,
                      textSub,
                      filteredPesees,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(isDark),
    );
  }

  Widget _buildHeader(bool isDark, Color textMain) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textMain),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : AppTheme.backgroundDark.withValues(alpha: 0.05),
            ),
          ),
          AppTheme.horizontalSpace12,
          Expanded(
            child: Text(
              AppLocalizations.of(context).santeWeightTracking,
              style: AppTheme.titleLarge.copyWith(color: textMain),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sync, size: 22, color: textMain),
            onPressed: _chargerDonnees,
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : AppTheme.backgroundDark.withValues(alpha: 0.05),
            ),
          ),
          AppTheme.horizontalSpace4,
          IconButton(
            icon: Icon(Icons.notifications, size: 22, color: textMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertesScreen()),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : AppTheme.backgroundDark.withValues(alpha: 0.05),
            ),
          ),
          AppTheme.horizontalSpace4,
          IconButton(
            icon: Icon(Icons.settings, size: 22, color: textMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ParametresScreen()),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : AppTheme.backgroundDark.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRabbitSelector(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final lapin = widget.lapin;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: isDark ? 0 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(
                  alpha: isDark ? 0.4 : 0.2,
                ),
                width: 2,
              ),
            ),
            child: ClipOval(
              child:
                  lapin.photoPath != null && File(lapin.photoPath!).existsSync()
                  ? Image.file(File(lapin.photoPath!), fit: BoxFit.cover)
                  : Icon(Icons.pets, size: 28, color: AppTheme.textSecondary),
            ),
          ),
          AppTheme.horizontalSpace16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rabbit #${lapin.nom}',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lapin.race} • ${lapin.ageFormate}',
                  style: TextStyle(color: textSub, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more, color: textSub, size: 24),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
    double currentWeight,
    double? lastMonthDiff,
    List<Pesee> pesees,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.backgroundDark.withValues(alpha: isDark ? 0 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).santeCurrentWeight,
                    style: TextStyle(
                      color: textSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentWeight.toStringAsFixed(2),
                          style: TextStyle(
                            color: textMain,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kg',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (lastMonthDiff != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lastMonthDiff > 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 16,
                            color: isDark
                                ? AppTheme.primaryGreen.withValues(alpha: 0.8)
                                : AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${lastMonthDiff > 0 ? '+' : ''}${lastMonthDiff.toStringAsFixed(2)} kg',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.primaryGreen.withValues(
                                        alpha: 0.8,
                                      )
                                    : AppTheme.primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'vs. last month',
                      style: TextStyle(
                        color: textSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          AppTheme.verticalSpace24,
          SizedBox(height: 192, child: _buildChart(pesees, isDark)),
          AppTheme.verticalSpace12,
          if (pesees.length >= 2) _buildChartLabels(pesees, textSub),
        ],
      ),
    );
  }

  Widget _buildChart(List<Pesee> pesees, bool isDark) {
    if (pesees.isEmpty || pesees.length < 2) {
      return Center(
        child: Text(
          'Ajoutez au moins 2 pesées pour voir le graphique',
          style: TextStyle(
            color: isDark ? AppTheme.santeTextDark : AppTheme.santeTextLight,
            fontSize: 14,
          ),
        ),
      );
    }

    final spots = pesees.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.poids);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : AppTheme.neutral500.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (pesees.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.success400,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isLast = index == spots.length - 1;
                return FlDotCirclePainter(
                  radius: isLast ? 6 : 4,
                  color: isLast
                      ? AppTheme.success400
                      : (isDark ? AppTheme.santeChartDark : AppTheme.cardLight),
                  strokeWidth: 3,
                  strokeColor: isLast
                      ? (isDark ? AppTheme.santeChartDark : AppTheme.cardLight)
                      : AppTheme.success400,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.success400.withValues(alpha: 0.3),
                  AppTheme.success400.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLabels(List<Pesee> pesees, Color textSub) {
    final displayCount = pesees.length > 5 ? 5 : pesees.length;
    final step = pesees.length > 5 ? (pesees.length / 5).floor() : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(displayCount, (index) {
        final peseeIndex = index * step;
        if (peseeIndex >= pesees.length) return const SizedBox.shrink();

        final date = pesees[peseeIndex].date;
        return Text(
          DateFormat('MMM d', 'en_US').format(date),
          style: TextStyle(
            color: textSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      }),
    );
  }

  Widget _buildPeriodFilters(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final periods = ['1 Month', '3 Months', '6 Months', 'All Time'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((period) {
            final isActive = period == _periodeActive;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _periodeActive = period),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDark
                              ? AppTheme.success400.withValues(alpha: 0.9)
                              : AppTheme.success400)
                        : surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppTheme.cardLight.withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF84cc16,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isActive
                            ? (isDark
                                  ? AppTheme.textPrimary
                                  : AppTheme.cardLight)
                            : textSub,
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistory(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
    List<Pesee> pesees,
  ) {
    final reversedPesees = pesees.reversed.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Export CSV
                  },
                  child: Text(
                    'Export CSV',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.santeGreenLight
                          : AppTheme.success400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reversedPesees.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Aucune pesée enregistrée',
                  style: TextStyle(color: textSub, fontSize: 16),
                ),
              ),
            )
          else
            ...reversedPesees.asMap().entries.map((entry) {
              final index = entry.key;
              final pesee = entry.value;
              final nextIndex = pesees.length - 1 - index - 1;
              double? diff;

              if (nextIndex >= 0) {
                diff = pesee.poids - pesees[nextIndex].poids;
              }

              return _buildHistoryItem(
                pesee,
                diff,
                isDark,
                surfaceColor,
                textMain,
                textSub,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    Pesee pesee,
    double? diff,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy', 'en_US');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: isDark ? 0 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.santeChartAltDark
                  : AppTheme.santeChartLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today, size: 20, color: textSub),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(pesee.date),
                  style: TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pesee.notes?.isNotEmpty == true
                      ? 'Manual Entry'
                      : 'Routine Check',
                  style: TextStyle(color: textSub, fontSize: 12),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${pesee.poids.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (diff != null)
                  Text(
                    '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(2)} kg',
                    style: TextStyle(
                      color: diff > 0
                          ? (isDark
                                ? AppTheme.santeGreen400
                                : AppTheme.santeGreen600)
                          : (isDark
                                ? AppTheme.santeError
                                : AppTheme.santeErrorAlt),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    '--',
                    style: TextStyle(
                      color: isDark ? AppTheme.grey600 : AppTheme.grey500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(bool isDark) {
    return UnifiedFAB.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AjouterPeseeScreen(lapin: widget.lapin),
          ),
        ).then((_) => _chargerDonnees());
      },
      label: AppLocalizations.of(context).santeAjouterPesee,
      tooltip: AppLocalizations.of(context).santeAjouterPesee,
    );
  }
}
