import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget de boutons d'action du formulaire
class FormActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const FormActionButtons({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryNeonGreen;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: AppTheme.cardLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadiusMedium,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 22),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).santeSaveRecord,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppTheme.verticalSpace12,
        TextButton(
          onPressed: onCancel,
          child: Text(
            AppLocalizations.of(context).santeCancel,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
