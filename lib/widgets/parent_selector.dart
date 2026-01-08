import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/lapin.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget pour sélectionner un parent (père ou mère)
class ParentSelector extends StatelessWidget {
  final String label;
  final Lapin? parentSelectionne;
  final List<Lapin> lapinsDisponibles;
  final Function(Lapin?) onChanged;
  final IconData icon;

  const ParentSelector({
    super.key,
    required this.label,
    required this.parentSelectionne,
    required this.lapinsDisponibles,
    required this.onChanged,
    this.icon = Icons.pets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showSelectionDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      parentSelectionne?.nom ??
                          AppLocalizations.of(context).widgetAucun,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: parentSelectionne != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        fontWeight: parentSelectionne != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (parentSelectionne != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${parentSelectionne!.race} • ${parentSelectionne!.ageFormate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Afficher le dialogue de sélection
  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).widgetSelectionner(label)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option "Aucun"
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: Text(AppLocalizations.of(context).widgetAucun),
                  selected: parentSelectionne == null,
                  onTap: () {
                    onChanged(null);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                // Liste des lapins disponibles
                Flexible(
                  child: lapinsDisponibles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).widgetAucunLapinDisponible,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: lapinsDisponibles.length,
                          itemBuilder: (context, index) {
                            final lapin = lapinsDisponibles[index];
                            final isSelected =
                                parentSelectionne?.id == lapin.id;
                            return ListTile(
                              leading: Icon(
                                lapin.sexe.toLowerCase() == 'mâle'
                                    ? Icons.male
                                    : Icons.female,
                                color: lapin.sexe.toLowerCase() == 'mâle'
                                    ? AppTheme.info
                                    : AppTheme.accentPink,
                              ),
                              title: Text(lapin.nom),
                              subtitle: Text(
                                '${lapin.race} • ${lapin.ageFormate}',
                              ),
                              selected: isSelected,
                              onTap: () {
                                onChanged(lapin);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
          ],
        );
      },
    );
  }
}
