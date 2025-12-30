import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

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
        _buildSearchBar(isDark),
        const SizedBox(height: 12),
        _buildFilterChips(isDark),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A331D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              color: isDark ? const Color(0xFF8BA88E) : AppTheme.stitchTextSecLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? const Color(0xFFE0E6E0)
                      : AppTheme.stitchTextMainLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search cage ID or location...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF8BA88E)
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
              : (isDark ? const Color(0xFF1A331D) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryNeonGreen
                : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.black
                  : (isWarning
                        ? Colors.orange
                        : (isDark
                              ? const Color(0xFF8BA88E)
                              : AppTheme.stitchTextSecLight)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Colors.black
                    : (isDark
                          ? const Color(0xFFE0E6E0)
                          : AppTheme.stitchTextMainLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
