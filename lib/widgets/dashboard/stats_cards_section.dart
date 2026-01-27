import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../theme/app_theme.dart';

/// Widget optimisé pour les cartes de statistiques du dashboard
/// Utilise Selector pour éviter les rebuilds inutiles
class StatsCardsSection extends StatelessWidget {
  final bool isDark;

  const StatsCardsSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Selector2<LapinProvider, ReproductionProvider, Map<String, dynamic>>(
      selector: (_, lapinProv, reproProv) =>
          lapinProv.getStatistiquesCheptel(reproProv),
      builder: (context, stats, _) {
        final cardsData = [
          {
            'icon': Icons.cruelty_free,
            'label': AppLocalizations.of(context).dashTotalLapins,
            'value': '${stats['total'] ?? 0}',
          },
          {
            'icon': Icons.pets,
            'label': AppLocalizations.of(context).dashFemellesReproduction,
            'value': '${stats['femelles'] ?? 0}',
          },
          {
            'icon': Icons.child_care,
            'label': AppLocalizations.of(context).dashLapereaux,
            'value': '${stats['lapereaux'] ?? 0}',
          },
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 600 ? 180.0 : 150.0;

            return SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: cardsData.length,
                cacheExtent: 200.0, // Optimisation : cache les widgets hors écran
                itemBuilder: (context, index) {
                  final card = cardsData[index];
                  return _StatCard(
                    icon: card['icon'] as IconData,
                    label: card['label'] as String,
                    value: card['value'] as String,
                    width: cardWidth,
                    isDark: isDark,
                    isLast: index == cardsData.length - 1,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget const pour une carte de statistique individuelle
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double width;
  final bool isDark;
  final bool isLast;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.only(right: isLast ? 0 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                    .withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTheme.titleLarge.copyWith(
                fontSize: 30,
                color: isDark
                    ? AppTheme.textOnPrimary
                    : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
