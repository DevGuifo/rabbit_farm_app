import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_theme.dart';

/// Page 1 du formulaire d'ajout de lapin : Informations de base
class LapinFormPage1Identity extends StatefulWidget {
  final TextEditingController nomController;
  final TextEditingController numeroIdController;
  final String? photoPath;
  final VoidCallback onPhotoTap;
  final VoidCallback onPhotoRemove;
  final String raceSelectionnee;
  final Function(String) onRaceChanged;
  final String? couleurSelectionnee;
  final Function(String?) onCouleurChanged;
  final String sexeSelectionne;
  final Function(String) onSexeChanged;
  final DateTime dateNaissance;
  final Function(DateTime) onDateChanged;

  const LapinFormPage1Identity({
    super.key,
    required this.nomController,
    required this.numeroIdController,
    required this.photoPath,
    required this.onPhotoTap,
    required this.onPhotoRemove,
    required this.raceSelectionnee,
    required this.onRaceChanged,
    required this.couleurSelectionnee,
    required this.onCouleurChanged,
    required this.sexeSelectionne,
    required this.onSexeChanged,
    required this.dateNaissance,
    required this.onDateChanged,
  });

  @override
  State<LapinFormPage1Identity> createState() => _LapinFormPage1IdentityState();
}

class _LapinFormPage1IdentityState extends State<LapinFormPage1Identity> {
  final List<String> _races = [
    'Géant des Flandres',
    'Fauve de Bourgogne',
    'Bélier Nain',
    'Blanc de Hotot',
    'Néo-Zélandais',
    'Californien',
    'Rex',
    'Angora',
    'Papillon',
    'Argenté de Champagne',
  ];

  final List<String> _couleurs = [
    'Blanc',
    'Noir',
    'Gris',
    'Fauve',
    'Brun',
    'Argenté',
    'Chinchilla',
    'Papillon',
    'Tricolore',
    'Autre',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dateNaissance,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null && picked != widget.dateNaissance) {
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Informations de base',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Remplissez les informations essentielles du lapin',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Photo
        _buildPhotoSection(),
        const SizedBox(height: 32),

        // Nom
        _buildNameField(),
        const SizedBox(height: AppTheme.spacing16),

        // N° Identification
        _buildIdField(),
        const SizedBox(height: AppTheme.spacing16),

        // Race
        _buildRaceDropdown(),
        const SizedBox(height: AppTheme.spacing16),

        // Couleur
        _buildColorDropdown(),
        const SizedBox(height: AppTheme.spacing16),

        // Sexe
        _buildGenderSection(),
        const SizedBox(height: AppTheme.spacing16),

        // Date de naissance
        _buildBirthdateField(context),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: widget.onPhotoTap,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: widget.photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge - 2,
                        ),
                        child: Image.file(
                          File(widget.photoPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 48,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajouter une photo',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (widget.photoPath != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: widget.onPhotoRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Supprimer'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: widget.nomController,
        decoration: InputDecoration(
          labelText: 'Nom',
          hintText: 'Ex: Flocon, Caramel...',
          prefixIcon: const Icon(Icons.badge_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Widget _buildIdField() {
    return FadeInUp(
      delay: const Duration(milliseconds: 350),
      child: TextFormField(
        controller: widget.numeroIdController,
        decoration: InputDecoration(
          labelText: 'N° Identification *',
          hintText: 'Tatouage, puce...',
          prefixIcon: const Icon(Icons.qr_code_2),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        textCapitalization: TextCapitalization.characters,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Le numéro d\'identification est obligatoire';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRaceDropdown() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: DropdownButtonFormField<String>(
        initialValue: widget.raceSelectionnee,
        decoration: InputDecoration(
          labelText: 'Race *',
          prefixIcon: const Icon(Icons.pets),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: _races.map((race) {
          return DropdownMenuItem(value: race, child: Text(race));
        }).toList(),
        onChanged: (value) {
          if (value != null) widget.onRaceChanged(value);
        },
      ),
    );
  }

  Widget _buildColorDropdown() {
    return FadeInUp(
      delay: const Duration(milliseconds: 450),
      child: DropdownButtonFormField<String>(
        initialValue: widget.couleurSelectionnee,
        decoration: InputDecoration(
          labelText: 'Couleur',
          prefixIcon: const Icon(Icons.palette_outlined),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Non spécifié')),
          ..._couleurs.map((couleur) {
            return DropdownMenuItem(value: couleur, child: Text(couleur));
          }),
        ],
        onChanged: (value) {
          widget.onCouleurChanged(value);
        },
      ),
    );
  }

  Widget _buildGenderSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wc, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sexe *',
                    style: AppTheme.labelLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onSexeChanged('Mâle'),
                      icon: const Icon(Icons.male),
                      label: Text('Mâle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: widget.sexeSelectionne == 'Mâle'
                            ? AppTheme.accentCyan.withValues(alpha: 0.1)
                            : null,
                        foregroundColor: widget.sexeSelectionne == 'Mâle'
                            ? AppTheme.accentCyan
                            : null,
                        side: BorderSide(
                          color: widget.sexeSelectionne == 'Mâle'
                              ? AppTheme.accentCyan
                              : AppTheme.border,
                          width: widget.sexeSelectionne == 'Mâle' ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onSexeChanged('Femelle'),
                      icon: const Icon(Icons.female),
                      label: Text('Femelle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: widget.sexeSelectionne == 'Femelle'
                            ? AppTheme.accentPink.withValues(alpha: 0.1)
                            : null,
                        foregroundColor: widget.sexeSelectionne == 'Femelle'
                            ? AppTheme.accentPink
                            : null,
                        side: BorderSide(
                          color: widget.sexeSelectionne == 'Femelle'
                              ? AppTheme.accentPink
                              : AppTheme.border,
                          width: widget.sexeSelectionne == 'Femelle' ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdateField(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 550),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date de naissance *',
            prefixIcon: const Icon(Icons.cake_outlined),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.dateNaissance.day.toString().padLeft(2, '0')}/${widget.dateNaissance.month.toString().padLeft(2, '0')}/${widget.dateNaissance.year}',
                style: AppTheme.bodyLarge,
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
