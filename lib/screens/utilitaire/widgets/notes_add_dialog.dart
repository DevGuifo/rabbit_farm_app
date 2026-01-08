import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../l10n/app_localizations.dart';
import '../../../models/lapin.dart';
import '../../../theme/app_theme.dart';

class NotesAddDialog extends StatefulWidget {
  final Lapin? lapin; // pour affichage
  final String? initialTitre;
  final String? initialContenu;
  final List<String>? initialTags;
  final List<String>? initialPhotos;
  final void Function({
    required String titre,
    required String contenu,
    required List<String> tags,
    required List<String> photos,
  })
  onSave;

  const NotesAddDialog({
    super.key,
    this.lapin,
    this.initialTitre,
    this.initialContenu,
    this.initialTags,
    this.initialPhotos,
    required this.onSave,
  });

  @override
  State<NotesAddDialog> createState() => _NotesAddDialogState();
}

class _NotesAddDialogState extends State<NotesAddDialog> {
  late TextEditingController _titreController;
  late TextEditingController _contenuController;
  final List<String> _tagsSelectionnes = [];
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _tagsDisponibles = const [
    'Santé',
    'Comportement',
    'Reproduction',
    'Alimentation',
    'Génétique',
    'Administratif',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.initialTitre ?? '');
    _contenuController = TextEditingController(
      text: widget.initialContenu ?? '',
    );
    if (widget.initialTags != null) {
      _tagsSelectionnes.addAll(widget.initialTags!);
    }
    if (widget.initialPhotos != null) {
      _photos.addAll(widget.initialPhotos!);
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _ajouterPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _sauvegarder() {
    if (_titreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).msgVeuillezSaisirTitre),
        ),
      );
      return;
    }

    if (_contenuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).msgVeuillezSaisirObservation,
          ),
        ),
      );
      return;
    }

    widget.onSave(
      titre: _titreController.text,
      contenu: _contenuController.text,
      tags: List<String>.from(_tagsSelectionnes),
      photos: List<String>.from(_photos),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).msgNoteEnregistree)),
    );
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
                  const Icon(Icons.note_add, color: AppTheme.textOnPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (widget.initialTitre == null ||
                              widget.initialTitre!.isEmpty)
                          ? 'Nouvelle note'
                          : 'Modifier la note',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textOnPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textOnPrimary,
                    ),
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
                    // Lapin concerné
                    if (widget.lapin != null) ...[
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
                              '${widget.lapin!.nom} (ID: ${widget.lapin!.id})',
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

                    // Titre
                    TextField(
                      controller: _titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contenu
                    TextField(
                      controller: _contenuController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Observation',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    const Text(
                      'Catégories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tagsDisponibles.map((tag) {
                        final isSelected = _tagsSelectionnes.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _tagsSelectionnes.add(tag);
                              } else {
                                _tagsSelectionnes.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Photos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return ElevatedButton.icon(
                              onPressed: _ajouterPhoto,
                              icon: const Icon(Icons.add_a_photo, size: 18),
                              label: Text(l10n.ajouter),
                              style: AppTheme.primaryButtonStyle,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_photos.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.neutral200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Aucune photo ajoutée',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.neutral200,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(_photos[index])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _photos.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppTheme.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Actions
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.neutral200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.annuler),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sauvegarder,
                        child: Text(l10n.enregistrer),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
