import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lot.dart';
import '../../providers/lot_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../repositories/localisation_repository.dart';

/// Écran d'ajout d'un nouveau lot
class AddLotScreen extends StatefulWidget {
  const AddLotScreen({super.key});

  @override
  State<AddLotScreen> createState() => _AddLotScreenState();
}

class _AddLotScreenState extends State<AddLotScreen> {
  final _formKey = GlobalKey<FormState>();

  // Champs du formulaire
  int _effectif = 1;
  TypeLot _type = TypeLot.engraissement;
  int? _cageId;
  String? _race;
  String? _origine;
  double? _poidsEntree;
  int? _ageMoyenJours;
  String? _notes;

  // Option de création de fiches individuelles
  bool _creerFichesIndividuelles = false;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniformAppBar(
        title: 'Nouveau Lot',
        icon: Icons.inventory_2,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info: Identifiant généré automatiquement
            Card(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'L\'identifiant du lot (LP-XXXX-XX-XXX) sera généré automatiquement.',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Informations principales
            const Text(
              'Informations principales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Type de lot
            DropdownButtonFormField<TypeLot>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type de lot *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: TypeLot.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getTypeIcon(type), size: 20),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),

            // Effectif
            TextFormField(
              initialValue: '1',
              decoration: const InputDecoration(
                labelText: 'Effectif initial *',
                prefixIcon: Icon(Icons.groups),
                border: OutlineInputBorder(),
                hintText: 'Nombre de sujets dans le lot',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'effectif est obligatoire';
                }
                final n = int.tryParse(value);
                if (n == null || n < 1) {
                  return 'Effectif invalide (minimum 1)';
                }
                return null;
              },
              onSaved: (value) => _effectif = int.parse(value!),
            ),
            const SizedBox(height: 24),

            // Section: Caractéristiques
            const Text(
              'Caractéristiques (optionnel)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Race
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Race',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
                hintText: 'Ex: Néo-Zélandais, Californien...',
              ),
              onSaved: (value) =>
                  _race = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),

            // Âge moyen
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Âge moyen (jours)',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                hintText: 'Âge moyen des sujets à l\'entrée',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final n = int.tryParse(value);
                  if (n == null || n < 0) {
                    return 'Âge invalide';
                  }
                }
                return null;
              },
              onSaved: (value) {
                _ageMoyenJours = value != null && value.isNotEmpty
                    ? int.tryParse(value)
                    : null;
              },
            ),
            const SizedBox(height: 16),

            // Poids d'entrée moyen
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Poids moyen à l\'entrée (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
                hintText: 'Poids moyen des sujets',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final n = double.tryParse(value.replaceAll(',', '.'));
                  if (n == null || n < 0) {
                    return 'Poids invalide';
                  }
                }
                return null;
              },
              onSaved: (value) {
                _poidsEntree = value != null && value.isNotEmpty
                    ? double.tryParse(value.replaceAll(',', '.'))
                    : null;
              },
            ),
            const SizedBox(height: 16),

            // Origine
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Origine',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
                hintText: 'Provenance du lot (fournisseur, élevage...)',
              ),
              onSaved: (value) =>
                  _origine = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 24),

            // Section: Localisation
            const Text(
              'Localisation (optionnel)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Sélecteur de cage
            FutureBuilder<List<Map<String, dynamic>>>(
              future: LocalisationRepository.instance.getCagesDisponibles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }

                final cages = snapshot.data!;
                if (cages.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Aucune cage disponible. Configurez vos cages dans Paramètres.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
                  initialValue: _cageId,
                  decoration: const InputDecoration(
                    labelText: 'Cage assignée',
                    prefixIcon: Icon(Icons.grid_view),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Aucune cage'),
                    ),
                    ...cages.map((cage) {
                      return DropdownMenuItem<int>(
                        value: cage['cageId'] as int,
                        child: Text(
                          '${cage['batimentNom']} > ${cage['clapierNom']} > Cage ${cage['cageNumero']}',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _cageId = value),
                );
              },
            ),
            const SizedBox(height: 24),

            // Section: Notes
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes additionnelles',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
                hintText: 'Observations, remarques...',
              ),
              maxLines: 3,
              onSaved: (value) =>
                  _notes = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 24),

            // Section: Fiches individuelles
            const Text(
              'Options avancées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Toggle création fiches individuelles
            Card(
              child: SwitchListTile(
                title: const Text('Créer fiches individuelles'),
                subtitle: Text(
                  _creerFichesIndividuelles
                      ? 'Génère $_effectif fiches avec IDs uniques (LP-XXXX-XX-XXX)'
                      : 'Seul le lot est créé, sans fiches par lapin',
                  style: TextStyle(
                    color: _creerFichesIndividuelles
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
                value: _creerFichesIndividuelles,
                onChanged: (value) {
                  setState(() => _creerFichesIndividuelles = value);
                },
                activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
                secondary: Icon(
                  _creerFichesIndividuelles ? Icons.person : Icons.groups,
                  color: _creerFichesIndividuelles
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ),

            // Info sur les IDs générés
            if (_creerFichesIndividuelles)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Card(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: AppTheme.info, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$_effectif identifiants uniques seront générés automatiquement. '
                            'Chaque lapin aura sa propre fiche pour le suivi individuel.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Bouton de validation
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _soumettre,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Création...' : 'Créer le lot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final provider = context.read<LotProvider>();

      final metadata = LotMetadata(
        race: _race,
        origine: _origine,
        poidsEntree: _poidsEntree,
        ageMoyenJours: _ageMoyenJours,
        notes: _notes,
      );

      final lot = await provider.ajouterLotAvecIndividus(
        effectif: _effectif,
        type: _type,
        creerFichesIndividuelles: _creerFichesIndividuelles,
        cageId: _cageId,
        metadata: metadata,
      );

      if (mounted) {
        final message = _creerFichesIndividuelles
            ? 'Lot ${lot.identifiant} créé avec $_effectif fiches !'
            : 'Lot ${lot.identifiant} créé avec succès !';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.success),
        );
        Navigator.of(context).pop(lot);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getTypeIcon(TypeLot type) {
    switch (type) {
      case TypeLot.engraissement:
        return Icons.restaurant;
      case TypeLot.reproduction:
        return Icons.favorite;
      case TypeLot.mixte:
        return Icons.blur_on;
    }
  }
}
