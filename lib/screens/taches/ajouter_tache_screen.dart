import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../models/tache.dart';
import '../../models/lapin.dart';
import '../../providers/tache_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran d'ajout/édition de tâche
class AjouterTacheScreen extends StatefulWidget {
  final Tache? tache; // Si fourni, mode édition

  const AjouterTacheScreen({super.key, this.tache});

  @override
  State<AjouterTacheScreen> createState() => _AjouterTacheScreenState();
}

class _AjouterTacheScreenState extends State<AjouterTacheScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _datePlanification = DateTime.now();
  TimeOfDay _heurePlanification = TimeOfDay.now();
  String _priorite = 'normale';
  String _categorie = 'autre';
  String _statut = 'a_faire';
  Lapin? _lapinSelectionne;
  bool _estRecurrente = false;
  String? _frequenceRecurrence;

  @override
  void initState() {
    super.initState();
    if (widget.tache != null) {
      // Mode édition
      _titreController.text = widget.tache!.titre;
      _descriptionController.text = widget.tache!.description ?? '';
      _notesController.text = widget.tache!.notes ?? '';
      _datePlanification = widget.tache!.datePlanification;
      _heurePlanification = TimeOfDay.fromDateTime(
        widget.tache!.datePlanification,
      );
      _priorite = widget.tache!.priorite;
      _categorie = widget.tache!.categorie;
      _statut = widget.tache!.statut;
      _estRecurrente = widget.tache!.estRecurrente;
      _frequenceRecurrence = widget.tache!.frequenceRecurrence;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LapinProvider>(context, listen: false).chargerLapins();
      if (widget.tache?.lapinId != null) {
        _chargerLapin();
      }
    });
  }

  Future<void> _chargerLapin() async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final lapins = lapinProvider.lapins;
    final lapin = lapins.firstWhere(
      (l) => l.id == widget.tache!.lapinId,
      orElse: () => lapins.first,
    );
    setState(() => _lapinSelectionne = lapin);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerTache() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateComplete = DateTime(
      _datePlanification.year,
      _datePlanification.month,
      _datePlanification.day,
      _heurePlanification.hour,
      _heurePlanification.minute,
    );

    final tache = Tache(
      id: widget.tache?.id,
      titre: _titreController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      datePlanification: dateComplete,
      priorite: _priorite,
      categorie: _categorie,
      statut: _statut,
      lapinId: _lapinSelectionne?.id,
      estRecurrente: _estRecurrente,
      frequenceRecurrence: _frequenceRecurrence,
      dateCreation: widget.tache?.dateCreation ?? DateTime.now(),
      dateModification: DateTime.now(),
      dateCompletion: widget.tache?.dateCompletion,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      final tacheProvider = Provider.of<TacheProvider>(context, listen: false);
      if (widget.tache == null) {
        await tacheProvider.ajouterTache(tache);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Tâche créée avec succès');
        }
      } else {
        await tacheProvider.modifierTache(tache);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Tâche modifiée avec succès');
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: UniformAppBar(
        title: widget.tache == null
            ? AppLocalizations.of(context).tachesNouvelleTache
            : AppLocalizations.of(context).tachesModifierTache,
        icon: Icons.task_alt_rounded,
        iconColor: AppTheme.accentAmber,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitreField(isDark),
                    const SizedBox(height: 16),
                    _buildDescriptionField(isDark),
                    const SizedBox(height: 16),
                    _buildDateHeurePicker(isDark),
                    const SizedBox(height: 16),
                    _buildPrioriteSelector(isDark),
                    const SizedBox(height: 16),
                    _buildCategorieSelector(isDark),
                    const SizedBox(height: 16),
                    _buildLapinSelector(isDark),
                    const SizedBox(height: 16),
                    _buildRecurrenceSection(isDark),
                    const SizedBox(height: 16),
                    _buildNotesField(isDark),
                    const SizedBox(height: 24),
                    _buildActionButtons(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitreField(bool isDark) {
    return TextFormField(
      controller: _titreController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).tachesFormTitre,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.title_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context).validationTitreObligatoire;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).tachesFormDescription,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.description_rounded),
      ),
      maxLines: 3,
    );
  }

  Widget _buildDateHeurePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date et heure', style: AppTheme.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _datePlanification,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _datePlanification = date);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  DateFormat('dd/MM/yyyy').format(_datePlanification),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final heure = await showTimePicker(
                    context: context,
                    initialTime: _heurePlanification,
                  );
                  if (heure != null) {
                    setState(() => _heurePlanification = heure);
                  }
                },
                icon: const Icon(Icons.access_time_rounded),
                label: Text(_heurePlanification.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioriteSelector(bool isDark) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_priorite),
      initialValue: _priorite,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).tachesFormPriorite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.priority_high_rounded),
      ),
      items: [
        DropdownMenuItem(
          value: 'haute',
          child: Text(AppLocalizations.of(context).tachesPrioriteHaute),
        ),
        DropdownMenuItem(
          value: 'normale',
          child: Text(AppLocalizations.of(context).tachesPrioriteNormale),
        ),
        DropdownMenuItem(
          value: 'basse',
          child: Text(AppLocalizations.of(context).tachesPrioriteBasse),
        ),
      ],
      onChanged: (value) => setState(() => _priorite = value!),
    );
  }

  Widget _buildCategorieSelector(bool isDark) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_categorie),
      initialValue: _categorie,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).tachesFormCategorie,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.category_rounded),
      ),
      items: [
        DropdownMenuItem(
          value: 'reproduction',
          child: Text(AppLocalizations.of(context).catReproduction),
        ),
        DropdownMenuItem(
          value: 'sante',
          child: Text(AppLocalizations.of(context).catSante),
        ),
        DropdownMenuItem(
          value: 'alimentation',
          child: Text(AppLocalizations.of(context).catAlimentation),
        ),
        DropdownMenuItem(
          value: 'entretien',
          child: Text(AppLocalizations.of(context).catEntretien),
        ),
        DropdownMenuItem(
          value: 'administratif',
          child: Text(AppLocalizations.of(context).catAdministratif),
        ),
        DropdownMenuItem(
          value: 'autre',
          child: Text(AppLocalizations.of(context).typeAutre),
        ),
      ],
      onChanged: (value) => setState(() => _categorie = value!),
    );
  }

  Widget _buildLapinSelector(bool isDark) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, _) {
        final lapins = lapinProvider.lapins
            .where((l) => l.statut != 'vendu' && l.statut != 'decede')
            .toList();

        return DropdownButtonFormField<Lapin?>(
          key: ValueKey(_lapinSelectionne?.id ?? 'none'),
          initialValue: _lapinSelectionne,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).tachesFormLapinAssocie,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.pets_rounded),
          ),
          items: [
            DropdownMenuItem<Lapin?>(
              value: null,
              child: Text(AppLocalizations.of(context).commonAucun),
            ),
            ...lapins.map(
              (lapin) => DropdownMenuItem<Lapin?>(
                value: lapin,
                child: Text(lapin.nom),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _lapinSelectionne = value),
        );
      },
    );
  }

  Widget _buildRecurrenceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(AppLocalizations.of(context).tachesTacheRecurrente),
          value: _estRecurrente,
          onChanged: (value) => setState(() => _estRecurrente = value ?? false),
        ),
        if (_estRecurrente) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(_frequenceRecurrence ?? 'none'),
            initialValue: _frequenceRecurrence,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).tachesFormFrequence,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.repeat_rounded),
            ),
            items: [
              DropdownMenuItem(
                value: 'quotidienne',
                child: Text(
                  AppLocalizations.of(context).tachesFrequenceQuotidienne,
                ),
              ),
              DropdownMenuItem(
                value: 'hebdomadaire',
                child: Text(
                  AppLocalizations.of(context).tachesFrequenceHebdomadaire,
                ),
              ),
              DropdownMenuItem(
                value: 'mensuelle',
                child: Text(
                  AppLocalizations.of(context).tachesFrequenceMensuelle,
                ),
              ),
            ],
            onChanged: (value) => setState(() => _frequenceRecurrence = value),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).tachesNotes,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.note_rounded),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _enregistrerTache,
            style: AppTheme.primaryButtonStyle,
            child: Text(
              widget.tache == null
                  ? AppLocalizations.of(context).tachesCreer
                  : AppLocalizations.of(context).commonSave,
            ),
          ),
        ),
      ],
    );
  }
}
