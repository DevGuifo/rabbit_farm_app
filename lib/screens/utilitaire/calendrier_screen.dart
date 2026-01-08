import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../models/lapin.dart';
import '../../services/database_helper.dart';
import '../../utils/logger.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
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
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).utilCalendrierPlanning,
        icon: Icons.calendar_month_rounded,
        iconColor: AppTheme.accentPink,
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
                color: AppTheme.info.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.accentPink,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.warning,
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
      return Center(
        child: Text(AppLocalizations.of(context).utilSelectionnezDate),
      );
    }

    final evenements = _getEvenementsForDay(_selectedDay!);

    if (evenements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun événement',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDay!),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
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
            style: AppTheme.titleMedium,
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
      color: evenement.important
          ? AppTheme.warning.withValues(alpha: 0.1)
          : null,
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
                  color: _getCouleurType(evenement.type).withValues(alpha: 0.1),
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
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
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
                              color: AppTheme.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'IMPORTANT',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.textLight,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(evenement.titre, style: AppTheme.titleSmall),
                    if (evenement.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        evenement.description!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCouleurType(TypeEvenement type) {
    switch (type) {
      case TypeEvenement.palpation:
        return AppTheme.accentPink;
      case TypeEvenement.preparationNid:
        return AppTheme.textSecondary;
      case TypeEvenement.miseBas:
        return AppTheme.accentPink;
      case TypeEvenement.sevrage:
        return AppTheme.info;
      case TypeEvenement.vaccination:
        return AppTheme.error;
      case TypeEvenement.traitement:
        return AppTheme.warning;
      case TypeEvenement.pesee:
        return AppTheme.success;
      case TypeEvenement.personnalise:
        return AppTheme.accentTeal;
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
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            if (evenement.heure != null) const SizedBox(height: 8),
            if (evenement.description != null) Text(evenement.description!),
            if (evenement.important) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Événement important',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
            child: Text(AppLocalizations.of(context).fermer),
          ),
          if (evenement.lapinId != null)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);

                // Récupérer le lapin depuis la DB
                final lapin = await DatabaseHelper.instance.getLapinById(
                  evenement.lapinId!,
                );

                if (!context.mounted) return;

                if (lapin != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LapinDetailScreen(lapin: lapin),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).utilLapinIntrouvable,
                      ),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.pets),
              label: Text(AppLocalizations.of(context).voirLapin),
              style: AppTheme.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(AppTheme.accentPink),
              ),
            ),
        ],
      ),
    );
  }

  void _ajouterEvenementPersonnalise() {
    final titreController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime dateSelectionnee = _selectedDay ?? DateTime.now();
    TimeOfDay? heureSelectionnee;
    String categorieSelectionnee = 'Tâche';
    bool important = false;
    bool notificationActive = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.event_note, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).nouvelEvenement),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                TextField(
                  controller: titreController,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).labelTitre,
                    hint: 'Ex: Vaccination lapins, Nettoyage...',
                    prefixIcon: Icons.title,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 50,
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).labelDescriptionOpt,
                    hint: 'Détails optionnels...',
                    prefixIcon: Icons.description,
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),

                // Catégorie
                DropdownButtonFormField<String>(
                  initialValue: categorieSelectionnee,
                  decoration: AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).labelCategorie,
                    prefixIcon: Icons.category,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Tâche',
                      child: Text(AppLocalizations.of(context).utilTache),
                    ),
                    DropdownMenuItem(
                      value: 'Rappel',
                      child: Text(AppLocalizations.of(context).utilRappel),
                    ),
                    DropdownMenuItem(
                      value: 'Rendez-vous',
                      child: Text(AppLocalizations.of(context).utilRendezVous),
                    ),
                    DropdownMenuItem(
                      value: 'Maintenance',
                      child: Text(AppLocalizations.of(context).utilMaintenance),
                    ),
                    DropdownMenuItem(
                      value: 'Contrôle',
                      child: Text(AppLocalizations.of(context).utilControle),
                    ),
                    DropdownMenuItem(
                      value: 'Autre',
                      child: Text(AppLocalizations.of(context).utilAutre),
                    ),
                  ],
                  onChanged: (value) {
                    setStateDialog(() => categorieSelectionnee = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context).date),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(dateSelectionnee),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateSelectionnee,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setStateDialog(() => dateSelectionnee = date);
                    }
                  },
                ),

                // Heure
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context).heureOptionnel),
                  subtitle: Text(
                    heureSelectionnee != null
                        ? heureSelectionnee!.format(context)
                        : 'Aucune',
                  ),
                  trailing: heureSelectionnee != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setStateDialog(() => heureSelectionnee = null);
                          },
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final heure = await showTimePicker(
                      context: context,
                      initialTime: heureSelectionnee ?? TimeOfDay.now(),
                    );
                    if (heure != null) {
                      setStateDialog(() => heureSelectionnee = heure);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Options
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLocalizations.of(context).important),
                  subtitle: Text(AppLocalizations.of(context).mettreEnEvidence),
                  secondary: Icon(
                    Icons.star,
                    color: important
                        ? AppTheme.accentAmber
                        : AppTheme.textSecondary,
                  ),
                  value: important,
                  onChanged: (value) {
                    setStateDialog(() => important = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLocalizations.of(context).notification),
                  subtitle: Text(AppLocalizations.of(context).recevoirRappel),
                  secondary: Icon(
                    Icons.notifications,
                    color: notificationActive
                        ? AppTheme.info
                        : AppTheme.textSecondary,
                  ),
                  value: notificationActive,
                  onChanged: (value) {
                    setStateDialog(() => notificationActive = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).annuler),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final titre = titreController.text.trim();
                if (titre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).utilTitreRequis,
                      ),
                    ),
                  );
                  return;
                }

                try {
                  // Sauvegarder dans la base de données
                  final db = await DatabaseHelper.instance.database;

                  // Construire DateTime complet avec heure
                  DateTime dateComplete = dateSelectionnee;
                  if (heureSelectionnee != null) {
                    dateComplete = DateTime(
                      dateSelectionnee.year,
                      dateSelectionnee.month,
                      dateSelectionnee.day,
                      heureSelectionnee!.hour,
                      heureSelectionnee!.minute,
                    );
                  }

                  await db.insert('evenements_personnalises', {
                    'titre': titre,
                    'description': descriptionController.text.trim(),
                    'date': dateComplete.toIso8601String(),
                    'heure': heureSelectionnee != null
                        ? '${heureSelectionnee!.hour}:${heureSelectionnee!.minute}'
                        : null,
                    'categorie': categorieSelectionnee,
                    'important': important ? 1 : 0,
                    'notificationActive': notificationActive ? 1 : 0,
                    'couleur': '#9C27B0', // Violet par défaut
                  });

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).utilAjouteCalendrier(titre),
                      ),
                      backgroundColor: AppTheme.success,
                    ),
                  );

                  // Recharger le calendrier
                  await _chargerEvenements();
                } catch (e) {
                  logger.error('❌ Erreur lors de l\'ajout de l\'événement', e);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).utilErreur(e.toString()),
                      ),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: Text(AppLocalizations.of(context).creer),
            ),
          ],
        ),
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
