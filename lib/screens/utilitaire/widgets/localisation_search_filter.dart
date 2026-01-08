import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Widget pour la barre de recherche et filtres de localisation
class LocalisationSearchFilter extends StatelessWidget {
  final String searchQuery;
  final String filterStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const LocalisationSearchFilter({
    super.key,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _buildSearchBar(context, isDark),
        const SizedBox(height: 12),
        _buildFilterChips(isDark),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.greyCard : AppTheme.textOnPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.greyCardDark : AppTheme.greyLight,
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
                  ? AppTheme.stitchGreen
                  : AppTheme.stitchTextSecLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppTheme.stitchTextLight
                      : AppTheme.stitchTextMainLight,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).hintSearchCageLocation,
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.stitchGreen
                        : AppTheme.stitchTextSecLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', Icons.check_rounded, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Empty', Icons.crop_square_rounded, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Occupied', Icons.pets_rounded, isDark),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Cleaning',
            Icons.warning_rounded,
            isDark,
            isWarning: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isDark, {
    bool isWarning = false,
  }) {
    final isActive = filterStatus == label;

    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryNeonGreen
              : (isDark ? AppTheme.greyCard : AppTheme.textOnPrimary),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryNeonGreen
                : (isDark ? AppTheme.greyCardDark : AppTheme.greyLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppTheme.textPrimary
                  : (isWarning
                        ? AppTheme.warning
                        : (isDark
                              ? AppTheme.stitchGreen
                              : AppTheme.stitchTextSecLight)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppTheme.textPrimary
                    : (isDark
                          ? AppTheme.stitchTextLight
                          : AppTheme.stitchTextMainLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
