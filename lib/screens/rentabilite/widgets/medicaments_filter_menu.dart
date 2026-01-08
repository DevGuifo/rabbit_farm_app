import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tous',
          child: Text(AppLocalizations.of(context).filterTous),
        ),
        PopupMenuItem(
          value: 'antibiotique',
          child: Text(AppLocalizations.of(context).typeAntibiotique),
        ),
        PopupMenuItem(
          value: 'antiparasitaire',
          child: Text(AppLocalizations.of(context).typeAntiparasitaire),
        ),
        PopupMenuItem(
          value: 'vaccin',
          child: Text(AppLocalizations.of(context).typeVaccin),
        ),
        PopupMenuItem(
          value: 'vitamine',
          child: Text(AppLocalizations.of(context).typeVitamine),
        ),
        PopupMenuItem(
          value: 'autre',
          child: Text(AppLocalizations.of(context).typeAutre),
        ),
      ],
    );
  }
}
