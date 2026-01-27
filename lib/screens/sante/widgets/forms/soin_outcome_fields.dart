import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget de sélection du statut
class OutcomeStatusSelector extends StatelessWidget {
  final String outcomeStatus;
  final ValueChanged<String> onChanged;

  const OutcomeStatusSelector({
    super.key,
    required this.outcomeStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.success100
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? AppTheme.surfaceDarkElevated
        : AppTheme.surfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outcome Status',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        AppTheme.verticalSpace12,
        Container(
          padding: AppTheme.paddingAllMedium,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppTheme.borderRadiusMedium,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: [
              _RadioOption(
                value: 'recovered',
                label: AppLocalizations.of(context).statusRecovered,
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.santeSuccess,
                isSelected: outcomeStatus == 'recovered',
                onTap: onChanged,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              AppTheme.verticalSpace12,
              _RadioOption(
                value: 'ongoing',
                label: AppLocalizations.of(context).statusOngoing,
                icon: Icons.access_time,
                iconColor: AppTheme.santeWarning,
                isSelected: outcomeStatus == 'ongoing',
                onTap: onChanged,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              AppTheme.verticalSpace12,
              _RadioOption(
                value: 'critical',
                label: AppLocalizations.of(context).statusCritical,
                icon: Icons.warning_outlined,
                iconColor: AppTheme.santeError,
                isSelected: outcomeStatus == 'critical',
                onTap: onChanged,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final ValueChanged<String> onTap;
  final Color textPrimary;
  final Color textSecondary;

  const _RadioOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: AppTheme.borderRadiusSmall,
          border: Border.all(
            color: isSelected ? iconColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            AppTheme.horizontalSpace12,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? textPrimary : textSecondary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? iconColor
                      : textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: isSelected ? iconColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: AppTheme.cardLight)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
