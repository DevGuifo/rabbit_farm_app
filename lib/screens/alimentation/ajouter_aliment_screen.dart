import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/aliment.dart';
import '../../providers/alimentation_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran pour ajouter un nouvel aliment
class AjouterAlimentScreen extends StatefulWidget {
  const AjouterAlimentScreen({super.key});

  @override
  State<AjouterAlimentScreen> createState() => _AjouterAlimentScreenState();
}

class _AjouterAlimentScreenState extends State<AjouterAlimentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String _type = TypeAliment.granules;
  final _marqueController = TextEditingController();
  final _conditionnementController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixUnitaireController = TextEditingController();
  DateTime _dateAchat = DateTime.now();
  DateTime? _datePeremption;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nomController.dispose();
    _marqueController.dispose();
    _conditionnementController.dispose();
    _quantiteController.dispose();
    _prixUnitaireController.dispose();
    super.dispose();
  }

  Future<void> _selectDateAchat() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateAchat,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _dateAchat = picked;
      });
    }
  }

  Future<void> _selectDatePeremption() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _datePeremption ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _datePeremption = picked;
      });
    }
  }

  Future<void> _ajouterAliment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final quantite = double.parse(_quantiteController.text);
      final prixUnitaire = double.parse(_prixUnitaireController.text);
      final prixTotal = quantite * prixUnitaire;

      final aliment = Aliment(
        nom: _nomController.text,
        type: _type,
        marque: _marqueController.text.isEmpty ? null : _marqueController.text,
        fournisseur: null,
        conditionnement: _conditionnementController.text,
        quantiteAchetee: quantite,
        quantiteRestante: quantite,
        prixUnitaire: prixUnitaire,
        prixTotal: prixTotal,
        dateAchat: _dateAchat,
        datePeremption: _datePeremption,
        composition: null,
        lieuStockage: null,
        photoPath: null,
      );

      final provider = context.read<AlimentationProvider>();
      final result = await provider.ajouterAliment(aliment);

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).alimentAjouteSucces),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur lors de l\'ajout');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).msgErrorPrefix(e.toString()),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).screenAjouterAliment,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelNomAliment,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelType,
                  border: const OutlineInputBorder(),
                ),
                items: TypeAliment.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(TypeAliment.getLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Marque
              TextFormField(
                controller: _marqueController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelMarque,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Conditionnement
              TextFormField(
                controller: _conditionnementController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelConditionnement,
                  hintText: AppLocalizations.of(context).hintExSac25kg,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le conditionnement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantité
              TextFormField(
                controller: _quantiteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelQuantiteKg,
                  border: const OutlineInputBorder(),
                  suffixText: 'kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valeur invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prix unitaire
              TextFormField(
                controller: _prixUnitaireController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelPrixUnitaire,
                  border: const OutlineInputBorder(),
                  suffixText: '€/kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valeur invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date d'achat
              InkWell(
                onTap: _selectDateAchat,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).labelDateAchat,
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_dateAchat.day}/${_dateAchat.month}/${_dateAchat.year}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date de péremption
              InkWell(
                onTap: _selectDatePeremption,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).labelDatePeremption,
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _datePeremption != null
                            ? '${_datePeremption!.day}/${_datePeremption!.month}/${_datePeremption!.year}'
                            : 'Non définie',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _ajouterAliment,
                  style: AppTheme.primaryButtonStyle,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.textLight,
                            ),
                          ),
                        )
                      : const Text(
                          'Ajouter l\'aliment',
                          style: AppTheme.titleSmall,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
