import 'package:flutter/material.dart';
import '../../../models/lapin.dart';
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
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
              backgroundColor: lapin.sexe == 'male'
                  ? Colors.blue[100]
                  : Colors.pink[100],
              child: Icon(
                Icons.pets,
                color: lapin.sexe == 'male' ? Colors.blue : Colors.pink,
              ),
            ),
            title: Text(
              '${lapin.nom} (ID: ${lapin.id})',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$notes note(s)',
              style: AppTheme.caption.copyWith(color: Colors.grey[600]),
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
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '$notes note(s) enregistrée(s)',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }
}
