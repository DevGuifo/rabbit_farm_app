import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class FicheSanteFilters extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onSort;

  const FicheSanteFilters({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textMain = isDark ? AppTheme.textLight : AppTheme.backgroundDarkMode;
    final textSub = isDark ? AppTheme.border : AppTheme.textSecondary;

    return Container(
      padding: AppTheme.paddingHorizontal.add(
        const EdgeInsets.symmetric(vertical: 8),
      ),
      color: isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.of(context).filterAll,
                    isActive: activeFilter == 'All',
                    onTap: () => onFilterChanged('All'),
                    isDark: isDark,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppLocalizations.of(context).filterMedical,
                    isActive: activeFilter == 'Medical',
                    onTap: () => onFilterChanged('Medical'),
                    isDark: isDark,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  AppTheme.horizontalSpace8,
                  _FilterChip(
                    label: AppLocalizations.of(context).filterWeight,
                    isActive: activeFilter == 'Weight',
                    onTap: () => onFilterChanged('Weight'),
                    isDark: isDark,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                ],
              ),
            ),
          ),
          if (onSort != null) ...[
            AppTheme.horizontalSpace8,
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: isDark
                    ? Border.all(
                        color: AppTheme.cardLight.withValues(alpha: 0.1),
                      )
                    : Border.all(
                        color: AppTheme.backgroundDark.withValues(alpha: 0.05),
                      ),
              ),
              child: IconButton(
                icon: Icon(Icons.sort, size: 18, color: textMain),
                padding: EdgeInsets.zero,
                onPressed: onSort,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final Color textMain;
  final Color textSub;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: AppTheme.paddingHorizontal,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppTheme.cardLight : AppTheme.backgroundDarkMode)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: AppTheme.borderRadiusLarge,
          border: isActive
              ? null
              : Border.all(
                  color: isDark
                      ? AppTheme.cardLight.withValues(alpha: 0.1)
                      : AppTheme.backgroundDark.withValues(alpha: 0.05),
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isDark ? AppTheme.backgroundDark : AppTheme.cardLight)
                  : textSub,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
