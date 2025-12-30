import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Pastille de filtre sélectionnable
/// 
/// Usage:
/// ```dart
/// FilterPill(
///   label: 'All',
///   isSelected: _selectedFilter == 'All',
///   onTap: () => setState(() => _selectedFilter = 'All'),
///   isDark: isDark,
/// )
/// ```
class FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.textLight : AppTheme.textPrimary)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
          boxShadow: isSelected ? AppTheme.shadowSmall : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

