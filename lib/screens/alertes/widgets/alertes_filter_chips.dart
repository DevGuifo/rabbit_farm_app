import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Filter chips horizontaux - Design Stitch
class AlertesFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const AlertesFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;

    final filters = [
      {'label': 'Tous', 'value': 'Tous', 'icon': null},
      {
        'label': 'Health',
        'value': 'Urgent',
        'icon': Icons.medical_services_outlined,
      },
      {'label': 'Breeding', 'value': 'Important', 'icon': Icons.pets_outlined},
      {'label': 'Tasks', 'value': 'Normal', 'icon': Icons.check_circle_outline},
      {'label': 'Stock', 'value': 'Stock', 'icon': Icons.inventory_2_outlined},
    ];

    return Container(
      color: bgColor,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final label = filter['label'] as String;
            final value = filter['value'] as String;
            final icon = filter['icon'] as IconData?;
            final isSelected =
                selectedFilter == value ||
                (selectedFilter == 'Tous' && value == 'Tous');

            return _buildChip(
              context,
              label: label,
              value: value,
              icon: icon,
              isSelected: isSelected,
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData? icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final primaryColor = AppTheme.primaryGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.neutral700 : AppTheme.neutral200;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSubColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFilterChanged(value),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.2)
                : surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.2)
                  : borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppTheme.primaryGreen : textSubColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryGreen : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
