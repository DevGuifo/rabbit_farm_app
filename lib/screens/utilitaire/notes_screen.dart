import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/lapin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/lapin.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedTag = 'Tous';
  final List<String> _tags = [
    'Tous',
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Observations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: 'Notes par Lapin'),
            Tab(icon: Icon(Icons.book), text: 'Journal Général'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNotesLapinTab(), _buildJournalGeneralTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouterNote(),
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Note Lapin' : 'Note Générale'),
      ),
    );
  }

  Widget _buildNotesLapinTab() {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, child) {
        final lapins = lapinProvider.lapins.where((l) {
          if (_searchQuery.isEmpty) return true;
          return l.nom.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un lapin...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Filtre par tag
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  final isSelected = tag == _selectedTag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = tag;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Liste des lapins avec notes
            Expanded(
              child: lapins.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun lapin trouvé',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: lapins.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final lapin = lapins[index];
                        final notes = _getNotesForLapin(lapin.id!);
                        final filteredNotes = _selectedTag == 'Tous'
                            ? notes
                            : notes
                                  .where((n) => n.tags.contains(_selectedTag))
                                  .toList();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: lapin.sexe == 'M'
                                  ? Colors.blue[100]
                                  : Colors.pink[100],
                              child: Icon(
                                Icons.pets,
                                color: lapin.sexe == 'M'
                                    ? Colors.blue
                                    : Colors.pink,
                              ),
                            ),
                            title: Text(
                              '${lapin.nom} (ID: ${lapin.id})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${filteredNotes.length} note(s)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _ajouterNote(lapin: lapin),
                            ),
                            children: filteredNotes.isEmpty
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Aucune note pour ce lapin',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ]
                                : filteredNotes
                                      .map(
                                        (note) => _buildNoteItem(note, lapin),
                                      )
                                      .toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJournalGeneralTab() {
    final notes = _getNotesGenerales();
    final filteredNotes = _selectedTag == 'Tous'
        ? notes
        : notes.where((n) => n.tags.contains(_selectedTag)).toList();

    final notesParDate = <String, List<NoteObservation>>{};
    for (var note in filteredNotes) {
      final dateKey = DateFormat('dd MMMM yyyy', 'fr_FR').format(note.date);
      notesParDate.putIfAbsent(dateKey, () => []).add(note);
    }

    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher dans les notes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Filtre par tag
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              final tag = _tags[index];
              final isSelected = tag == _selectedTag;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Notes groupées par date
        Expanded(
          child: notesParDate.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune note générale',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...notesJour
                              .map((note) => _buildNoteItem(note, null))
                              .toList(),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(NoteObservation note, Lapin? lapin) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _supprimerNote(note);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note supprimée')));
      },
      child: InkWell(
        onTap: () => _afficherDetailNote(note, lapin),
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
                      children: note.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: _getTagColor(tag),
                          padding: const EdgeInsets.all(4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm', 'fr_FR').format(note.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.titre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.contenu,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (note.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.photos.length} photo(s)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Santé':
        return Colors.red[100]!;
      case 'Comportement':
        return Colors.orange[100]!;
      case 'Reproduction':
        return Colors.pink[100]!;
      case 'Alimentation':
        return Colors.green[100]!;
      case 'Génétique':
        return Colors.purple[100]!;
      case 'Administratif':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  void _ajouterNote({Lapin? lapin}) {
    showDialog(
      context: context,
      builder: (context) => _DialogueAjoutNote(
        lapin: lapin,
        onSave: (note) {
          setState(() {
            _notesSimulees.add(note);
          });
        },
      ),
    );
  }

  void _afficherDetailNote(NoteObservation note, Lapin? lapin) {
    showDialog(
      context: context,
      builder: (context) => _DialogueDetailNote(
        note: note,
        lapin: lapin,
        onEdit: () {
          Navigator.pop(context);
          _modifierNote(note, lapin);
        },
        onDelete: () {
          Navigator.pop(context);
          _supprimerNote(note);
        },
      ),
    );
  }

  void _modifierNote(NoteObservation note, Lapin? lapin) {
    showDialog(
      context: context,
      builder: (context) => _DialogueAjoutNote(
        lapin: lapin,
        noteExistante: note,
        onSave: (noteModifiee) {
          setState(() {
            final index = _notesSimulees.indexWhere((n) => n.id == note.id);
            if (index != -1) {
              _notesSimulees[index] = noteModifiee;
            }
          });
        },
      ),
    );
  }

  void _supprimerNote(NoteObservation note) {
    setState(() {
      _notesSimulees.removeWhere((n) => n.id == note.id);
    });
  }

  List<NoteObservation> _getNotesForLapin(int lapinId) {
    return _notesSimulees.where((n) => n.lapinId == lapinId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<NoteObservation> _getNotesGenerales() {
    return _notesSimulees.where((n) => n.lapinId == null).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Données simulées (à remplacer par une vraie base de données)
  final List<NoteObservation> _notesSimulees = [
    NoteObservation(
      id: '1',
      titre: 'Changement de comportement',
      contenu:
          'Semble moins actif que d\'habitude. À surveiller pendant quelques jours.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Comportement', 'Santé'],
      lapinId: 1,
      photos: [],
    ),
    NoteObservation(
      id: '2',
      titre: 'Nouvelle alimentation testée',
      contenu:
          'Introduction progressive du nouveau mélange de granulés. Bien accepté par l\'ensemble du cheptel.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Alimentation'],
      lapinId: null,
      photos: [],
    ),
    NoteObservation(
      id: '3',
      titre: 'Excellente portée',
      contenu:
          'Mise bas de 8 lapereaux, tous en bonne santé. La mère s\'en occupe parfaitement.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['Reproduction'],
      lapinId: 2,
      photos: [],
    ),
  ];
}

class NoteObservation {
  final String id;
  final String titre;
  final String contenu;
  final DateTime date;
  final List<String> tags;
  final int? lapinId; // null pour notes générales
  final List<String> photos; // chemins des photos

  NoteObservation({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.date,
    required this.tags,
    this.lapinId,
    required this.photos,
  });
}

class _DialogueAjoutNote extends StatefulWidget {
  final Lapin? lapin;
  final NoteObservation? noteExistante;
  final Function(NoteObservation) onSave;

  const _DialogueAjoutNote({
    this.lapin,
    this.noteExistante,
    required this.onSave,
  });

  @override
  State<_DialogueAjoutNote> createState() => _DialogueAjoutNoteState();
}

class _DialogueAjoutNoteState extends State<_DialogueAjoutNote> {
  late TextEditingController _titreController;
  late TextEditingController _contenuController;
  final List<String> _tagsSelectionnes = [];
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _tagsDisponibles = [
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
    _titreController = TextEditingController(
      text: widget.noteExistante?.titre ?? '',
    );
    _contenuController = TextEditingController(
      text: widget.noteExistante?.contenu ?? '',
    );
    if (widget.noteExistante != null) {
      _tagsSelectionnes.addAll(widget.noteExistante!.tags);
      _photos.addAll(widget.noteExistante!.photos);
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
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
                color: Colors.blue[700],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_add, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.noteExistante == null
                          ? 'Nouvelle note'
                          : 'Modifier la note',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
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
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pets, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.lapin!.nom} (ID: ${widget.lapin!.id})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
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
                        ElevatedButton.icon(
                          onPressed: _ajouterPhoto,
                          icon: const Icon(Icons.add_a_photo, size: 18),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_photos.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Aucune photo ajoutée',
                            style: TextStyle(color: Colors.grey),
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
                                      color: Colors.grey[300]!,
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
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sauvegarder,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }

    if (_contenuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir une observation')),
      );
      return;
    }

    final note = NoteObservation(
      id:
          widget.noteExistante?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titreController.text,
      contenu: _contenuController.text,
      date: widget.noteExistante?.date ?? DateTime.now(),
      tags: _tagsSelectionnes,
      lapinId: widget.lapin?.id,
      photos: _photos,
    );

    widget.onSave(note);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note enregistrée')));
  }
}

class _DialogueDetailNote extends StatelessWidget {
  final NoteObservation note;
  final Lapin? lapin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DialogueDetailNote({
    required this.note,
    this.lapin,
    required this.onEdit,
    required this.onDelete,
  });

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
                color: Colors.blue[700],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.titre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
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
                    icon: const Icon(Icons.close, color: Colors.white),
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
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pets, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${lapin!.nom} (ID: ${lapin!.id})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy à HH:mm',
                            'fr_FR',
                          ).format(note.date),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: note.tags.map((tag) {
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
                      note.contenu,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // Photos
                    if (note.photos.isNotEmpty) ...[
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
                        itemCount: note.photos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Afficher la photo en plein écran
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Image.file(File(note.photos[index])),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(note.photos[index])),
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

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Santé':
        return Colors.red[100]!;
      case 'Comportement':
        return Colors.orange[100]!;
      case 'Reproduction':
        return Colors.pink[100]!;
      case 'Alimentation':
        return Colors.green[100]!;
      case 'Génétique':
        return Colors.purple[100]!;
      case 'Administratif':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
