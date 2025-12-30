import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lapin_provider.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';
import 'widgets/notes_search_bar.dart';
import 'widgets/note_card.dart';
import 'widgets/notes_detail_dialog.dart';
import 'widgets/notes_add_dialog.dart';

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
            // Barre de recherche + filtres (widget extrait)
            NotesSearchBar(
              searchQuery: _searchQuery,
              selectedTag: _selectedTag,
              tags: _tags,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onTagSelected: (tag) {
                setState(() {
                  _selectedTag = tag;
                });
              },
            ),

            const SizedBox(height: 8),

            // Liste des lapins avec notes
            Expanded(
              child: lapins.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun lapin trouvé',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
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
                                  ? AppTheme.info.withValues(alpha: 0.2)
                                  : AppTheme.accentPink.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.pets,
                                color: lapin.sexe == 'M'
                                    ? AppTheme.info
                                    : AppTheme.accentPink,
                              ),
                            ),
                            title: Text(
                              '${lapin.nom} (ID: ${lapin.id})',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${filteredNotes.length} note(s)',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _ajouterNote(lapin: lapin),
                            ),
                            children: filteredNotes.isEmpty
                                ? [
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Aucune note pour ce lapin',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
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
              fillColor: AppTheme.border,
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
              ? Center(
                  child: Text(
                    'Aucune note générale',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
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
                                  color: AppTheme.info,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateKey,
                                  style: AppTheme.titleSmall.copyWith(
                                    color: AppTheme.info,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...notesJour.map(
                            (note) => _buildNoteItem(note, null),
                          ),
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
    return NoteCard(
      note: note,
      onTap: () => _afficherDetailNote(note, lapin),
      onDelete: () {
        _supprimerNote(note);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note supprimée')));
      },
    );
  }

  void _ajouterNote({Lapin? lapin}) {
    showDialog(
      context: context,
      builder: (context) => NotesAddDialog(
        lapin: lapin,
        onSave:
            ({
              required String titre,
              required String contenu,
              required List<String> tags,
              required List<String> photos,
            }) {
              final note = NoteObservation(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                titre: titre,
                contenu: contenu,
                date: DateTime.now(),
                tags: tags,
                lapinId: lapin?.id,
                photos: photos,
              );
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
      builder: (context) => NotesDetailDialog(
        titre: note.titre,
        contenu: note.contenu,
        date: note.date,
        tags: note.tags,
        photos: note.photos,
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
      builder: (context) => NotesAddDialog(
        lapin: lapin,
        initialTitre: note.titre,
        initialContenu: note.contenu,
        initialTags: note.tags,
        initialPhotos: note.photos,
        onSave:
            ({
              required String titre,
              required String contenu,
              required List<String> tags,
              required List<String> photos,
            }) {
              final noteModifiee = NoteObservation(
                id: note.id,
                titre: titre,
                contenu: contenu,
                date: note.date,
                tags: tags,
                lapinId: lapin?.id,
                photos: photos,
              );
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

// Dialog d'ajout/modification remplacé par NotesAddDialog (widget public extrait)

// Dialog de détail remplacé par NotesDetailDialog (widget public extrait)
