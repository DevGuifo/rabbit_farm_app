import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../models/lapin.dart';
import '../../../utils/dialog_helper.dart';
import '../../../theme/app_theme.dart';

class NotesDetailDialog extends StatelessWidget {
  final String titre;
  final String contenu;
  final DateTime date;
  final List<String> tags;
  final List<String> photos;
  final Lapin? lapin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NotesDetailDialog({
    super.key,
    required this.titre,
    required this.contenu,
    required this.date,
    required this.tags,
    required this.photos,
    this.lapin,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Santé':
        return AppTheme.error.withValues(alpha: 0.1);
      case 'Comportement':
        return AppTheme.warning.withValues(alpha: 0.1);
      case 'Reproduction':
        return AppTheme.accentPink50;
      case 'Alimentation':
        return AppTheme.success.withValues(alpha: 0.1);
      case 'Génétique':
        return AppTheme.purpleLight;
      case 'Administratif':
        return AppTheme.info.withValues(alpha: 0.1);
      default:
        return AppTheme.neutral100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.info,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: AppTheme.textOnPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titre,
                      style: AppTheme.titleLarge.copyWith(color: AppTheme.textOnPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.textOnPrimary),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.textOnPrimary),
                    onPressed: () async {
                      final confirm = await DialogHelper.showConfirmation(
                        context: context,
                        title: 'Confirmer la suppression',
                        message: 'Voulez-vous vraiment supprimer cette note ?',
                        isDangerous: true,
                      );
                      if (confirm == true && context.mounted) {
                        onDelete();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textOnPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lapin
                    if (lapin != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pets, color: AppTheme.info),
                            const SizedBox(width: 8),
                            Text(
                              '${lapin!.nom} (ID: ${lapin!.id})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy à HH:mm',
                            'fr_FR',
                          ).format(date),
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: _getTagColor(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Contenu
                    const Text(
                      'Observation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contenu,
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photos
                    if (photos.isNotEmpty) ...[
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Image.file(File(photos[index])),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.neutral200),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(photos[index])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
