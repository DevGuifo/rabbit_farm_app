import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Recommandé pour éviter les accouplements précoces',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            activeThumbColor: Colors.green,
          ),
          SwitchListTile(
            value: utiliserCagesCollectives,
            onChanged: onCollectivesChanged,
            title: const Text(
              'Utiliser des cages collectives',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Grouper plusieurs lapereaux du même sexe',
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            activeThumbColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}
