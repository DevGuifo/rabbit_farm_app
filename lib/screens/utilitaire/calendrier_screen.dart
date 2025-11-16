import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../models/accouplement.dart';
import '../../models/lapin.dart';
import '../../services/database_helper.dart';
import '../cheptel/lapin_detail_screen.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EvenementCalendrier>> _evenements = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerEvenements();
    });
  }

  Future<void> _chargerEvenements() async {
    final reproProvider = context.read<ReproductionProvider>();
    final lapinProvider = context.read<LapinProvider>();
    final santeProvider = context.read<SanteProvider>();

    final evenements = <DateTime, List<EvenementCalendrier>>{};

    // 1. ÉVÉNEMENTS DE REPRODUCTION
    for (final accouplement in reproProvider.accouplements) {
      // Palpation (J10-12)
      final datePalpation = accouplement.datePalpation;
      final keyPalpation = DateTime(
        datePalpation.year,
        datePalpation.month,
        datePalpation.day,
      );
      evenements.putIfAbsent(keyPalpation, () => []);

      final femelle = lapinProvider.lapins.firstWhere(
        (l) => l.id == accouplement.femelleId,
        orElse: () => Lapin(
          nom: 'Inconnue',
          race: '',
          sexe: 'femelle',
          dateNaissance: DateTime.now(),
        ),
      );

      evenements[keyPalpation]!.add(
        EvenementCalendrier(
          titre: 'Palpation ${femelle.nom}',
          description: 'Vérifier gestation J10-12',
          type: TypeEvenement.palpation,
          heure: const TimeOfDay(hour: 10, minute: 0),
          lapinId: accouplement.femelleId,
        ),
      );

      // Préparation nid (J28)
      final dateNid = accouplement.datePreparationNid;
      final keyNid = DateTime(dateNid.year, dateNid.month, dateNid.day);
      evenements.putIfAbsent(keyNid, () => []);
      evenements[keyNid]!.add(
        EvenementCalendrier(
          titre: 'Préparer nid ${femelle.nom}',
          description: 'Installation boîte à nid + matériaux',
          type: TypeEvenement.preparationNid,
          heure: const TimeOfDay(hour: 9, minute: 0),
          lapinId: accouplement.femelleId,
        ),
      );

      // Mise bas prévue (J31)
      final dateMB = accouplement.dateMiseBasPrevue;
      final keyMB = DateTime(dateMB.year, dateMB.month, dateMB.day);
      evenements.putIfAbsent(keyMB, () => []);
      evenements[keyMB]!.add(
        EvenementCalendrier(
          titre: '🐰 Mise bas ${femelle.nom}',
          description: 'Naissance attendue (J31 ±2j)',
          type: TypeEvenement.miseBas,
          heure: null,
          lapinId: accouplement.femelleId,
          important: true,
        ),
      );

      // Sevrage prévu (J35-42)
      if (accouplement.statut == 'confirme') {
        final dateSevrage = dateMB.add(const Duration(days: 38));
        final keySevrage = DateTime(
          dateSevrage.year,
          dateSevrage.month,
          dateSevrage.day,
        );
        evenements.putIfAbsent(keySevrage, () => []);
        evenements[keySevrage]!.add(
          EvenementCalendrier(
            titre: 'Sevrage ${femelle.nom}',
            description: 'Séparer lapereaux de la mère',
            type: TypeEvenement.sevrage,
            heure: const TimeOfDay(hour: 14, minute: 0),
            lapinId: accouplement.femelleId,
          ),
        );
      }
    }

    // 2. ÉVÉNEMENTS DE SANTÉ (Vaccinations)
    for (final soin in santeProvider.soins) {
      if (soin.type == 'vaccination' && soin.dateRappel != null) {
        final dateRappel = soin.dateRappel!;
        final keyRappel = DateTime(
          dateRappel.year,
          dateRappel.month,
          dateRappel.day,
        );
        evenements.putIfAbsent(keyRappel, () => []);

        final lapin = lapinProvider.lapins.firstWhere(
          (l) => l.id == soin.lapinId,
          orElse: () => Lapin(
            nom: 'Inconnu',
            race: '',
            sexe: 'male',
            dateNaissance: DateTime.now(),
          ),
        );

        evenements[keyRappel]!.add(
          EvenementCalendrier(
            titre: '💉 Vaccination ${lapin.nom}',
            description: soin.description,
            type: TypeEvenement.vaccination,
            heure: const TimeOfDay(hour: 11, minute: 0),
            lapinId: soin.lapinId,
            important: true,
          ),
        );
      }
    }

    // 3. ÉVÉNEMENTS AUTOMATIQUES (Pesées hebdomadaires)
    final aujourdhui = DateTime.now();
    for (int i = 0; i < 90; i++) {
      final date = aujourdhui.add(Duration(days: i));
      if (date.weekday == DateTime.monday) {
        final key = DateTime(date.year, date.month, date.day);
        evenements.putIfAbsent(key, () => []);
        evenements[key]!.add(
          EvenementCalendrier(
            titre: '⚖️ Pesées hebdomadaires',
            description: 'Peser tous les lapereaux et jeunes',
            type: TypeEvenement.pesee,
            heure: const TimeOfDay(hour: 8, minute: 30),
            lapinId: null,
          ),
        );
      }
    }

    setState(() {
      _evenements = evenements;
    });
  }

  List<EvenementCalendrier> _getEvenementsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _evenements[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier & Planning'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerEvenements,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _ajouterEvenementPersonnalise,
            tooltip: 'Ajouter événement',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendrier
          TableCalendar<EvenementCalendrier>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEvenementsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: 'fr_FR',
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF9C27B0),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),

          const Divider(height: 1),

          // Liste des événements du jour sélectionné
          Expanded(child: _buildListeEvenements()),
        ],
      ),
    );
  }

  Widget _buildListeEvenements() {
    if (_selectedDay == null) {
      return const Center(child: Text('Sélectionnez une date'));
    }

    final evenements = _getEvenementsForDay(_selectedDay!);

    if (evenements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucun événement',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDay!),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDay!),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: evenements.length,
            itemBuilder: (context, index) {
              return _buildEvenementCard(evenements[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEvenementCard(EvenementCalendrier evenement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: evenement.important ? 4 : 2,
      color: evenement.important ? Colors.orange[50] : null,
      child: InkWell(
        onTap: () => _afficherDetailsEvenement(evenement),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icône + couleur selon type
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCouleurType(evenement.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconeType(evenement.type),
                  color: _getCouleurType(evenement.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (evenement.heure != null) ...[
                          Text(
                            evenement.heure!.format(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (evenement.important)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'IMPORTANT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evenement.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (evenement.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        evenement.description!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCouleurType(TypeEvenement type) {
    switch (type) {
      case TypeEvenement.palpation:
        return Colors.purple;
      case TypeEvenement.preparationNid:
        return Colors.brown;
      case TypeEvenement.miseBas:
        return Colors.pink;
      case TypeEvenement.sevrage:
        return Colors.blue;
      case TypeEvenement.vaccination:
        return Colors.red;
      case TypeEvenement.traitement:
        return Colors.orange;
      case TypeEvenement.pesee:
        return Colors.green;
      case TypeEvenement.personnalise:
        return Colors.teal;
    }
  }

  IconData _getIconeType(TypeEvenement type) {
    switch (type) {
      case TypeEvenement.palpation:
        return Icons.touch_app;
      case TypeEvenement.preparationNid:
        return Icons.nest_cam_wired_stand;
      case TypeEvenement.miseBas:
        return Icons.baby_changing_station;
      case TypeEvenement.sevrage:
        return Icons.cut;
      case TypeEvenement.vaccination:
        return Icons.vaccines;
      case TypeEvenement.traitement:
        return Icons.medication;
      case TypeEvenement.pesee:
        return Icons.scale;
      case TypeEvenement.personnalise:
        return Icons.event_note;
    }
  }

  void _afficherDetailsEvenement(EvenementCalendrier evenement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconeType(evenement.type),
              color: _getCouleurType(evenement.type),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(evenement.titre)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (evenement.heure != null)
              Text(
                '🕐 Heure : ${evenement.heure!.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (evenement.heure != null) const SizedBox(height: 8),
            if (evenement.description != null) Text(evenement.description!),
            if (evenement.important) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Événement important',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (evenement.lapinId != null)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);

                // Récupérer le lapin depuis la DB
                final lapin = await DatabaseHelper.instance.getLapinById(
                  evenement.lapinId!,
                );

                if (lapin != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LapinDetailScreen(lapin: lapin),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lapin introuvable'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.pets),
              label: const Text('Voir lapin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _ajouterEvenementPersonnalise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un événement'),
        content: const Text(
          'Fonctionnalité de création d\'événements personnalisés en cours de développement.\n\n'
          'Prochainement :\n'
          '• Tâches personnalisées\n'
          '• Rappels et notifications\n'
          '• Export vers calendrier externe',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// MODÈLES
// ============================================

enum TypeEvenement {
  palpation,
  preparationNid,
  miseBas,
  sevrage,
  vaccination,
  traitement,
  pesee,
  personnalise,
}

class EvenementCalendrier {
  final String titre;
  final String? description;
  final TypeEvenement type;
  final TimeOfDay? heure;
  final int? lapinId;
  final bool important;

  EvenementCalendrier({
    required this.titre,
    this.description,
    required this.type,
    this.heure,
    this.lapinId,
    this.important = false,
  });
}
