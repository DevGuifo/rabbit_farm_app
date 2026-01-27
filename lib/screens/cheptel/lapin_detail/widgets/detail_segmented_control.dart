import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Contrôle de navigation par segments (Stitch Design)
class DetailSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const DetailSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs = const ['Identity', 'Statistics', 'Reproduction'],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Expanded(
            child: _buildSegmentButton(
              context: context,
              isDark: isDark,
              label: label,
              isSelected: selectedIndex == index,
              onTap: () => onTabChanged(index),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentButton({
    required BuildContext context,
    required bool isDark,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppTheme.textPrimary
                  : (isDark ? AppTheme.neutral400 : AppTheme.neutral500),
            ),
          ),
        ),
      ),
    );
  }
}
