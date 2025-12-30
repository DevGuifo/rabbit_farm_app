import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';

/// Widget de sélection de date de rappel (nullable)
class RappelDateFieldWidget extends StatelessWidget {
  final DateTime? dateRappel;
  final VoidCallback onTap;

  const RappelDateFieldWidget({
    super.key,
    required this.dateRappel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date du rappel',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.event_outlined, size: 20, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  dateRappel != null
                      ? DateFormat('MMMM dd, yyyy', 'fr_FR').format(dateRappel!)
                      : 'Sélectionner une date',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: dateRappel != null
                        ? textPrimary
                        : textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de checkbox pour le rappel
class ReminderCheckbox extends StatelessWidget {
  final bool avecRappel;
  final ValueChanged<bool> onChanged;

  const ReminderCheckbox({
    super.key,
    required this.avecRappel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Checkbox(
            value: avecRappel,
            onChanged: (value) => onChanged(value!),
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un rappel',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recevoir une notification pour le prochain soin',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

