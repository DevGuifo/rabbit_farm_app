import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final dynamic note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: AppTheme.textOnPrimary),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: onDelete != null
          ? (direction) async {
              final l10n = AppLocalizations.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.confirmer),
                  content: Text(l10n.supprimerCetteNote),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.annuler),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.supprimer),
                    ),
                  ],
                ),
              );
              if (confirm == true && onDelete != null) {
                onDelete!();
              }
              return confirm;
            }
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (note.tags as List<dynamic>).map((tag) {
                        return Chip(
                          label: Text(tag.toString(), style: AppTheme.caption),
                          backgroundColor: _getTagColor(tag.toString()),
                          padding: const EdgeInsets.all(4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm', 'fr_FR').format(note.date),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.titre.toString(),
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                note.contenu.toString(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              if (note.photos != null && (note.photos as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(note.photos as List).length} photo(s)',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
