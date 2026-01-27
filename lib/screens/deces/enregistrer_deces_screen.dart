import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/deces.dart';
import '../../models/lapin.dart';
import '../../providers/deces_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../services/error_service.dart';

/// Écran pour enregistrer un décès
class EnregistrerDecesScreen extends StatefulWidget {
  final Lapin lapin;

  const EnregistrerDecesScreen({super.key, required this.lapin});

  @override
  State<EnregistrerDecesScreen> createState() => _EnregistrerDecesScreenState();
}

class _EnregistrerDecesScreenState extends State<EnregistrerDecesScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _dateDeces = DateTime.now();
  String _cause = CauseDeces.inconnu;
  final _circonstancesController = TextEditingController();
  bool _autopsieRealisee = false;
  final _resultatsAutopsieController = TextEditingController();
  final _mesuresPreventivesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _circonstancesController.dispose();
    _resultatsAutopsieController.dispose();
    _mesuresPreventivesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDeces,
      firstDate: widget.lapin.dateNaissance,
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null && picked != _dateDeces) {
      setState(() {
        _dateDeces = picked;
      });
    }
  }

  Future<void> _enregistrerDeces() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculer l'âge au décès en jours
      final ageAuDecesJours = _dateDeces
          .difference(widget.lapin.dateNaissance)
          .inDays;

      // Créer l'objet Deces
      final deces = Deces(
        lapinId: widget.lapin.id!,
        dateDeces: _dateDeces,
        ageAuDecesJours: ageAuDecesJours,
        cause: _cause,
        circonstancesDetailees: _circonstancesController.text,
        autopsieRealisee: _autopsieRealisee,
        resultatsAutopsie: _autopsieRealisee
            ? _resultatsAutopsieController.text
            : null,
        mesuresPreventives: _mesuresPreventivesController.text.isEmpty
            ? null
            : _mesuresPreventivesController.text,
      );

      // Enregistrer le décès
      final decesProvider = context.read<DecesProvider>();
      final lapinProvider = context.read<LapinProvider>();

      final result = await decesProvider.enregistrerDeces(
        deces,
        onLapinDecede: (lapinId) async {
          await lapinProvider.updateStatut(lapinId, 'decede');
        },
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).decesSucces(widget.lapin.nom),
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur lors de l\'enregistrement');
      }
    } catch (e) {
      if (!mounted) return;
      ErrorService.showError(context, e);
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
        title: AppLocalizations.of(context).decesEnregistrerDeces,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations du lapin
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text(widget.lapin.nom, style: AppTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context).decesRace}: ${widget.lapin.race}',
                      ),
                      Text(
                        '${AppLocalizations.of(context).decesSexe}: ${widget.lapin.sexe}',
                      ),
                      Text(
                        '${AppLocalizations.of(context).decesNeLe}: ${widget.lapin.dateNaissance.day}/${widget.lapin.dateNaissance.month}/${widget.lapin.dateNaissance.year}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date du décès
              Text(
                AppLocalizations.of(context).decesDateDeces,
                style: AppTheme.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.textSecondary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_dateDeces.day}/${_dateDeces.month}/${_dateDeces.year}',
                        style: AppTheme.bodyMedium.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cause du décès
              Text(
                AppLocalizations.of(context).decesCauseDeces,
                style: AppTheme.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _cause,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: CauseDeces.values.map((cause) {
                  return DropdownMenuItem(
                    value: cause,
                    child: Text(CauseDeces.getLabel(cause)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _cause = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Circonstances détaillées
              Text(
                AppLocalizations.of(context).decesCirconstancesDetaillees,
                style: AppTheme.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _circonstancesController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).decesHintCirconstances,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(
                      context,
                    ).decesValidationCirconstances;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Autopsie
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).decesAutopsieRealisee),
                value: _autopsieRealisee,
                onChanged: (value) {
                  setState(() {
                    _autopsieRealisee = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              // Résultats autopsie (si réalisée)
              if (_autopsieRealisee) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).decesResultatsAutopsie,
                  style: AppTheme.titleSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _resultatsAutopsieController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).decesHintResultatsAutopsie,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 16),

              // Mesures préventives
              Text(
                AppLocalizations.of(context).decesMesuresPreventives,
                style: AppTheme.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mesuresPreventivesController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).decesHintMesuresPreventives,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _enregistrerDeces,
                  style: AppTheme.dangerButtonStyle,
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
                      : Text(
                          AppLocalizations.of(context).decesBoutonEnregistrer,
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
