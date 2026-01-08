import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class ProgressSection extends StatelessWidget {
  final bool isExporting;
  final bool isImporting;
  const ProgressSection({
    super.key,
    required this.isExporting,
    required this.isImporting,
  });

  @override
  Widget build(BuildContext context) {
    if (!isExporting && !isImporting) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              isExporting ? 'Export en cours...' : 'Import en cours...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
