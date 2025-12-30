import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MedicamentsAlertBanner extends StatelessWidget {
  final int alertCount;

  const MedicamentsAlertBanner({super.key, required this.alertCount});

  @override
  Widget build(BuildContext context) {
    if (alertCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.error),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              '⚠️ $alertCount médicament(s) en alerte',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
