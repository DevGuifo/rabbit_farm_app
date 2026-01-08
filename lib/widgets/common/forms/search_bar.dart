import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Barre de recherche standardisée
/// 
/// Usage:
/// ```dart
/// SearchBarWidget(
///   controller: _searchController,
///   onChanged: (value) => _filter(value),
///   isDark: isDark,
///   hintText: 'Search by ID, name or breed...',
/// )
/// ```
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    this.hintText = 'Rechercher...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isDark
                ? AppTheme.textOnPrimary.withValues(alpha: 0.1)
                : AppTheme.textPrimary.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                  .withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
          ),
        ),
      ),
    );
  }
}

