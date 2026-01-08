import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';

/// Filtres de type (All Items, Treatments, Care Routine, Vaccines)
/// Design: Tabs horizontaux avec underline Stitch
class TreatmentsFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const TreatmentsFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : AppTheme.backgroundDark.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterTab(l10n.filtreTous, 'all'),
            const SizedBox(width: 24),
            _buildFilterTab(l10n.filtreTraitements, 'treatments'),
            const SizedBox(width: 24),
            _buildFilterTab(l10n.filtreRoutineSoins, 'care'),
            const SizedBox(width: 24),
            _buildFilterTab(l10n.filtreVaccins, 'vaccines'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? textPrimary : textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 2,
              width: label.length * 8.0,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
