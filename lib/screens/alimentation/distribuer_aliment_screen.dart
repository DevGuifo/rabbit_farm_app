import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/aliment.dart';
import '../../models/aliment.dart' as model;
import '../../providers/alimentation_provider.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran pour distribuer un aliment
class DistribuerAlimentScreen extends StatefulWidget {
  final Aliment aliment;

  const DistribuerAlimentScreen({super.key, required this.aliment});

  @override
  State<DistribuerAlimentScreen> createState() =>
      _DistribuerAlimentScreenState();
}

class _DistribuerAlimentScreenState extends State<DistribuerAlimentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _cagesController = TextEditingController();
  final _observationsController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantiteController.dispose();
    _cagesController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _distribuerAliment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final quantite = double.parse(_quantiteController.text);

      // Vérifier le stock disponible
      if (quantite > widget.aliment.quantiteRestante) {
        throw Exception(
          'Stock insuffisant (${widget.aliment.quantiteRestante.toStringAsFixed(1)} kg disponible)',
        );
      }

      final distribution = model.DistributionAliment(
        alimentId: widget.aliment.id!,
        date: _date,
        quantiteDistribuee: quantite,
        cagesConcernees: _cagesController.text.isEmpty
            ? null
            : _cagesController.text,
        observations: _observationsController.text.isEmpty
            ? null
            : _observationsController.text,
      );

      final provider = context.read<AlimentationProvider>();
      final result = await provider.distribuerAliment(distribution);

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).msgDistributionEnregistree,
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur lors de la distribution');
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
        title: AppLocalizations.of(context).screenDistribuerAliment,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations de l'aliment
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grass, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            widget.aliment.nom,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${TypeAliment.getLabel(widget.aliment.type)}',
                      ),
                      Text(
                        'Stock disponible: ${widget.aliment.quantiteRestante.toStringAsFixed(1)} kg',
                        style: AppTheme.bodyMedium.copyWith(
                          color: widget.aliment.quantiteRestante < 5
                              ? AppTheme.error
                              : AppTheme.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date de distribution
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).labelDateDistribution,
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Text('${_date.day}/${_date.month}/${_date.year}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quantité distribuée
              TextFormField(
                controller: _quantiteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  ).labelQuantiteDistribuee,
                  border: const OutlineInputBorder(),
                  suffixText: 'kg',
                  helperText:
                      'Stock: ${widget.aliment.quantiteRestante.toStringAsFixed(1)} kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité';
                  }
                  final quantite = double.tryParse(value);
                  if (quantite == null) {
                    return 'Valeur invalide';
                  }
                  if (quantite <= 0) {
                    return 'La quantité doit être positive';
                  }
                  if (quantite > widget.aliment.quantiteRestante) {
                    return 'Stock insuffisant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cages concernées
              TextFormField(
                controller: _cagesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelCagesConcernees,
                  hintText: AppLocalizations.of(context).hintExA1A2B3,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Observations
              TextFormField(
                controller: _observationsController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).labelObservations,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _distribuerAliment,
                  style: AppTheme.primaryButtonStyle,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.textOnPrimary,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).btnEnregistrer,
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
