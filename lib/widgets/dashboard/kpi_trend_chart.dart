import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

/// Widget de graphique pour afficher les tendances KPI
/// Utilise fl_chart pour des courbes temps réel
class KpiTrendChart extends StatelessWidget {
  final String title;
  final List<FlSpot> dataPoints;
  final Color lineColor;
  final bool isDark;
  final String? unit;
  final double? minY;
  final double? maxY;

  const KpiTrendChart({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.lineColor,
    required this.isDark,
    this.unit,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                              .withValues(alpha: 0.3),
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}${unit ?? ''}',
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.neutral400
                                : AppTheme.neutral600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Afficher des labels temporels (ex: J-7, J-6, ...)
                        final day = value.toInt();
                        if (day % 2 == 0) {
                          // Afficher 1 label sur 2
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'J-$day',
                              style: AppTheme.caption.copyWith(
                                color: isDark
                                    ? AppTheme.neutral400
                                    : AppTheme.neutral600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                        .withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: isDark
                              ? AppTheme.cardDark
                              : AppTheme.cardLight,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        isDark ? AppTheme.neutral800 : AppTheme.backgroundLight,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}${unit ?? ''}',
                          TextStyle(
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: (isDark ? AppTheme.neutral600 : AppTheme.neutral300)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Pas encore de données',
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? AppTheme.neutral500 : AppTheme.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
