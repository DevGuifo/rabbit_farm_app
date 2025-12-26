import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/aliment.dart';
import '../../providers/alimentation_provider.dart';

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
          const SnackBar(
            content: Text('Aliment ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur lors de l\'ajout');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: const Text('Ajouter un aliment'),
        backgroundColor: theme.colorScheme.surface,
      ),
      backgroundColor: theme.colorScheme.background,
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
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'aliment *',
                  border: OutlineInputBorder(),
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
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Marque (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Conditionnement
              TextFormField(
                controller: _conditionnementController,
                decoration: const InputDecoration(
                  labelText: 'Conditionnement *',
                  hintText: 'Ex: Sac 25kg, vrac',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Quantité (kg) *',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Prix unitaire (€/kg) *',
                  border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Date d\'achat',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Date de péremption (optionnel)',
                    border: OutlineInputBorder(),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Ajouter l\'aliment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
