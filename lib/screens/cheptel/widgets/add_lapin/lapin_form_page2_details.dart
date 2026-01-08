import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/cage_selector.dart';
import '../../../../services/database_helper.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 2 du formulaire d'ajout de lapin : Détails complémentaires
class LapinFormPage2Details extends StatefulWidget {
  final TextEditingController poidsController;
  final TextEditingController localisationController;
  final TextEditingController prixAchatController;
  final TextEditingController caracteristiquesController;
  final TextEditingController notesController;
  final String? statutSelectionne;
  final Function(String?) onStatutChanged;
  final String? origineSelectionnee;
  final Function(String?) onOrigineChanged;
  final int? cageIdInitiale; // ID cage pour pré-sélection
  final Function(int?)? onCageIdChanged; // Callback quand cage sélectionnée

  const LapinFormPage2Details({
    super.key,
    required this.poidsController,
    required this.localisationController,
    required this.prixAchatController,
    required this.caracteristiquesController,
    required this.notesController,
    required this.statutSelectionne,
    required this.onStatutChanged,
    required this.origineSelectionnee,
    required this.onOrigineChanged,
    this.cageIdInitiale,
    this.onCageIdChanged,
  });

  @override
  State<LapinFormPage2Details> createState() => _LapinFormPage2DetailsState();
}

class _LapinFormPage2DetailsState extends State<LapinFormPage2Details> {
  final List<String> _statuts = [
    'Jeune',
    'Reproducteur',
    'Reproductrice',
    'Engraissement',
    'Quarantaine',
    'Retraite',
  ];

  final List<String> _origines = [
    'Naissance sur place',
    'Achat',
    'Don',
    'Échange',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Informations complémentaires',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Détails physiques et origine',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Poids
        _buildWeightField(),
        const SizedBox(height: AppTheme.spacing16),

        // Statut
        _buildStatusDropdown(),
        const SizedBox(height: AppTheme.spacing16),

        // Localisation
        _buildLocalisationField(),
        const SizedBox(height: AppTheme.spacing24),

        // Origine
        _buildOriginDropdown(),
        const SizedBox(height: AppTheme.spacing16),

        // Prix d'achat (si applicable)
        if (widget.origineSelectionnee == 'Achat') _buildPriceField(),
        const SizedBox(height: AppTheme.spacing24),

        // Caractéristiques
        _buildCharacteristicsField(),
        const SizedBox(height: AppTheme.spacing16),

        // Notes
        _buildNotesField(),
      ],
    );
  }

  Widget _buildWeightField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: TextFormField(
        controller: widget.poidsController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormPoids,
          hintText: AppLocalizations.of(context).hintExemple25,
          prefixIcon: const Icon(Icons.monitor_weight_outlined),
          suffixText: 'kg',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final poids = double.tryParse(value);
            if (poids == null || poids <= 0) {
              return 'Poids invalide';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return FadeInUp(
      delay: const Duration(milliseconds: 250),
      child: DropdownButtonFormField<String>(
        initialValue: widget.statutSelectionne,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormStatut,
          prefixIcon: const Icon(Icons.info_outline),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(AppLocalizations.of(context).commonNonDefini),
          ),
          ..._statuts.map((statut) {
            return DropdownMenuItem(value: statut, child: Text(statut));
          }),
        ],
        onChanged: (value) {
          widget.onStatutChanged(value);
        },
      ),
    );
  }

  Widget _buildLocalisationField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () async {
          final cageId = await showDialog<int>(
            context: context,
            builder: (context) =>
                CageSelector(cageIdInitiale: widget.cageIdInitiale),
          );
          if (cageId != null && mounted) {
            // Récupérer les infos de la cage pour afficher le texte
            final dbHelper = await DatabaseHelper.instance.database;
            final cageData = await dbHelper.query(
              'cages',
              where: 'id = ?',
              whereArgs: [cageId],
            );

            if (cageData.isNotEmpty) {
              final numero = cageData.first['numero'] as String;
              setState(() {
                widget.localisationController.text = numero;
              });

              // Notifier le parent avec le cage ID
              widget.onCageIdChanged?.call(cageId);
            }
          }
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: widget.localisationController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).cheptelFormLocalisation,
              hintText: AppLocalizations.of(context).hintSelectionnerCage,
              prefixIcon: const Icon(Icons.window_outlined),
              suffixIcon: widget.localisationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          widget.localisationController.clear();
                          widget.onCageIdChanged?.call(null);
                        });
                      },
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
      ),
    );
  }

  Widget _buildOriginDropdown() {
    return FadeInUp(
      delay: const Duration(milliseconds: 350),
      child: DropdownButtonFormField<String>(
        initialValue: widget.origineSelectionnee,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormOrigine,
          prefixIcon: const Icon(Icons.history_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(AppLocalizations.of(context).commonNonSpecifie),
          ),
          ..._origines.map((origine) {
            return DropdownMenuItem(value: origine, child: Text(origine));
          }),
        ],
        onChanged: (value) {
          widget.onOrigineChanged(value);
        },
      ),
    );
  }

  Widget _buildPriceField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: TextFormField(
        controller: widget.prixAchatController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormPrixAchat,
          hintText: AppLocalizations.of(context).hintExemple2500,
          prefixIcon: const Icon(Icons.euro_outlined),
          suffixText: '€',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 450),
      child: TextFormField(
        controller: widget.caracteristiquesController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormCaracteristiques,
          hintText: AppLocalizations.of(context).hintSignesDistinctifs,
          prefixIcon: const Icon(Icons.stars_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildNotesField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: TextFormField(
        controller: widget.notesController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).cheptelFormNotes,
          hintText: AppLocalizations.of(context).hintObservationsGenerales,
          prefixIcon: const Icon(Icons.note_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
