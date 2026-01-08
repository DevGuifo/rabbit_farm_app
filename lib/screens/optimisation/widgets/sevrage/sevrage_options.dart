import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SevrageOptions extends StatelessWidget {
  final bool separerParSexe;
  final bool utiliserCagesCollectives;
  final ValueChanged<bool> onSeparateurChanged;
  final ValueChanged<bool> onCollectivesChanged;

  const SevrageOptions({
    super.key,
    required this.separerParSexe,
    required this.utiliserCagesCollectives,
    required this.onSeparateurChanged,
    required this.onCollectivesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textOnPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options de sevrage',
            style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: separerParSexe,
            onChanged: onSeparateurChanged,
            title: const Text(
              'Séparer par sexe',
              style: TextStyle(color: AppTheme.textOnPrimary),
            ),
            subtitle: const Text(
              'Recommandé pour éviter les accouplements précoces',
              style: TextStyle(color: AppTheme.textOnPrimary60, fontSize: 12),
            ),
            activeThumbColor: AppTheme.success,
          ),
          SwitchListTile(
            value: utiliserCagesCollectives,
            onChanged: onCollectivesChanged,
            title: const Text(
              'Utiliser des cages collectives',
              style: TextStyle(color: AppTheme.textOnPrimary),
            ),
            subtitle: const Text(
              'Grouper plusieurs lapereaux du même sexe',
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
