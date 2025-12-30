import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/cage_selector.dart';

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
          labelText: 'Poids',
          hintText: 'Ex: 2.5',
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
        initialValue:  widget.statutSelectionne,
        decoration: InputDecoration(
          labelText: 'Statut',
          prefixIcon: const Icon(Icons.info_outline),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Non défini')),
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
          final cage = await showDialog<String>(
            context: context,
            builder: (context) => CageSelector(
              cageInitiale: widget.localisationController.text.isNotEmpty
                  ? widget.localisationController.text
                  : null,
            ),
          );
          if (cage != null) {
            setState(() {
              widget.localisationController.text = cage;
            });
          }
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: widget.localisationController,
            decoration: InputDecoration(
              labelText: 'Localisation (Cage)',
              hintText: 'Sélectionner une cage...',
              prefixIcon: const Icon(Icons.window_outlined),
              suffixIcon: widget.localisationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          widget.localisationController.clear();
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
        initialValue:  widget.origineSelectionnee,
        decoration: InputDecoration(
          labelText: 'Origine',
          prefixIcon: const Icon(Icons.history_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Non spécifié')),
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
          labelText: 'Prix d\'achat',
          hintText: 'Ex: 25.00',
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
          labelText: 'Caractéristiques particulières',
          hintText: 'Signes distinctifs, marques...',
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
          labelText: 'Notes',
          hintText: 'Observations générales...',
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
