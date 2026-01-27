import 'package:flutter/material.dart';
import '../../../models/lapin.dart';
import '../../../models/enums/sexe.dart';
import '../../../theme/app_theme.dart';

class NotesLapinTab extends StatelessWidget {
  final List<Lapin> lapins;
  final Function(Lapin)? onLapinTap;
  final Function(Lapin, dynamic)? onNoteTap;
  final Function(Lapin)? onAddNote;
  final Function(int, String) getNotesForLapin;
  final String selectedTag;

  const NotesLapinTab({
    super.key,
    required this.lapins,
    this.onLapinTap,
    this.onNoteTap,
    this.onAddNote,
    required this.getNotesForLapin,
    this.selectedTag = 'Tous',
  });

  @override
  Widget build(BuildContext context) {
    if (lapins.isEmpty) {
      return const Center(
        child: Text(
          'Aucun lapin trouvé',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: lapins.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final lapin = lapins[index];
        final notes = getNotesForLapin(lapin.id!, selectedTag);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: lapin.sexe == Sexe.male
                  ? AppTheme.info.withValues(alpha: 0.1)
                  : AppTheme.accentPink50,
              child: Icon(
                Icons.pets,
                color: lapin.sexe == Sexe.male
                    ? AppTheme.info
                    : AppTheme.accentPink,
              ),
            ),
            title: Text(
              '${lapin.nom} (ID: ${lapin.id})',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$notes note(s)',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            trailing: onAddNote != null
                ? IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => onAddNote!(lapin),
                  )
                : null,
            children: notes == 0
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aucune note pour ce lapin',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '$notes note(s) enregistrée(s)',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }
}
