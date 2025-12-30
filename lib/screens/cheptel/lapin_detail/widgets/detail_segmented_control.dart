import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

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
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StitchTheme.radiusFull),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
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
          color: isSelected ? StitchTheme.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(StitchTheme.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: StitchTheme.primaryYellow.withValues(alpha: 0.2),
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
                  ? Colors.black
                  : (isDark ? StitchTheme.neutral400 : StitchTheme.neutral500),
            ),
          ),
        ),
      ),
    );
  }
}
