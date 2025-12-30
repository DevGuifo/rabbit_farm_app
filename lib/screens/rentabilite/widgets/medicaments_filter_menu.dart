import 'package:flutter/material.dart';

class MedicamentsFilterMenu extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const MedicamentsFilterMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'tous', child: Text('Tous')),
        PopupMenuItem(value: 'antibiotique', child: Text('Antibiotiques')),
        PopupMenuItem(
          value: 'antiparasitaire',
          child: Text('Antiparasitaires'),
        ),
        PopupMenuItem(value: 'vaccin', child: Text('Vaccins')),
        PopupMenuItem(value: 'vitamine', child: Text('Vitamines')),
        PopupMenuItem(value: 'autre', child: Text('Autres')),
      ],
    );
  }
}
