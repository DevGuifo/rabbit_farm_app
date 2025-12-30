import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_card.dart';
import '../../../theme/app_theme.dart';

class JournalGeneralTab extends StatelessWidget {
  final List<dynamic> notes;
  final Function(dynamic)? onEdit;
  final Function(dynamic)? onDelete;
  final Function(dynamic)? onTap;

  const JournalGeneralTab({
    super.key,
    required this.notes,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          'Aucune note générale',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final notesParDate = <String, List<dynamic>>{};
    for (var note in notes) {
      final dateKey = DateFormat('dd MMMM yyyy', 'fr_FR').format(note.date);
      notesParDate.putIfAbsent(dateKey, () => []).add(note);
    }

    return ListView.builder(
      itemCount: notesParDate.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final dateKey = notesParDate.keys.elementAt(index);
        final notesJour = notesParDate[dateKey]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateKey,
                      style: AppTheme.titleSmall.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...notesJour.map((note) {
                return NoteCard(
                  note: note,
                  onTap: onTap != null ? () => onTap!(note) : null,
                  onEdit: onEdit != null ? () => onEdit!(note) : null,
                  onDelete: onDelete != null ? () => onDelete!(note) : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
