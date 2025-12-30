import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class SevrageValidationButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onValidate;

  const SevrageValidationButton({
    super.key,
    required this.enabled,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onValidate : null,
        icon: const Icon(Icons.check_circle, size: 24),
        label: const Text('Valider le sevrage', style: AppTheme.titleSmall),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade700,
        ),
      ),
    );
  }
}
