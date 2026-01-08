import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/sevrage.dart';
import '../../providers/sevrage_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../l10n/app_localizations.dart';

/// Écran de modification d'un sevrage existant
class EditSevrageScreen extends StatefulWidget {
  final Sevrage sevrage;

  const EditSevrageScreen({super.key, required this.sevrage});

  @override
  State<EditSevrageScreen> createState() => _EditSevrageScreenState();
}

class _EditSevrageScreenState extends State<EditSevrageScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _poidsMoyenController;
  late final TextEditingController _cageController;
  late final TextEditingController _observationsController;
  late final TextEditingController _alimentationController;

  late DateTime _dateSevrage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(
      text: widget.sevrage.nombreLapereaux.toString(),
    );
    _poidsMoyenController = TextEditingController(
      text: widget.sevrage.poidsMoyenSevrage?.toString() ?? '',
    );
    _cageController = TextEditingController(
      text: widget.sevrage.nouvelleCage ?? '',
    );
    _observationsController = TextEditingController(
      text: widget.sevrage.observations ?? '',
    );
    _alimentationController = TextEditingController(
      text: widget.sevrage.alimentationPostSevrage ?? '',
    );
    _dateSevrage = widget.sevrage.dateSevrage;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _poidsMoyenController.dispose();
    _cageController.dispose();
    _observationsController.dispose();
    _alimentationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSevrage,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateSevrage) {
      setState(() {
        _dateSevrage = picked;
      });
    }
  }

  Future<void> _enregistrerModifications() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sevrageModifie = widget.sevrage.copyWith(
        dateSevrage: _dateSevrage,
        nombreLapereaux: int.parse(_nombreController.text),
        poidsMoyenSevrage: _poidsMoyenController.text.isEmpty
            ? null
            : double.parse(_poidsMoyenController.text),
        nouvelleCage: _cageController.text.isEmpty
            ? null
            : _cageController.text,
        observations: _observationsController.text.isEmpty
            ? null
            : _observationsController.text,
        alimentationPostSevrage: _alimentationController.text.isEmpty
            ? null
            : _alimentationController.text,
      );

      await Provider.of<SevrageProvider>(
        context,
        listen: false,
      ).modifierSevrage(sevrageModifie);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Sevrage modifié avec succès');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenModifierSevrage,
        icon: Icons.child_care_rounded,
        iconColor: AppTheme.primaryGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date du sevrage
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryGreen,
                        ),
                        title: Text(
                          AppLocalizations.of(context).titleDateSevrage,
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(_dateSevrage),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre de lapereaux
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).optimisationFormNombreLapereaux,
                        prefixIcon: const Icon(Icons.pets),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          ).validationChampObligatoire;
                        }
                        if (int.tryParse(value) == null) {
                          return AppLocalizations.of(
                            context,
                          ).validationNombreInvalide;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Poids moyen
                    TextFormField(
                      controller: _poidsMoyenController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).optimisationFormPoidsMoyen,
                        prefixIcon: const Icon(Icons.scale),
                        border: OutlineInputBorder(),
                        hintText: 'Optionnel',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Poids invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nouvelle cage
                    TextFormField(
                      controller: _cageController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).optimisationFormNouvelleCage,
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(),
                        hintText: 'Optionnel',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alimentation post-sevrage
                    TextFormField(
                      controller: _alimentationController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).optimisationFormAlimentationPost,
                        prefixIcon: const Icon(Icons.restaurant),
                        border: OutlineInputBorder(),
                        hintText: 'Optionnel',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Observations
                    TextFormField(
                      controller: _observationsController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).optimisationFormObservations,
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        hintText: 'Optionnel',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Bouton Enregistrer
                    ElevatedButton.icon(
                      onPressed: _enregistrerModifications,
                      icon: const Icon(Icons.save),
                      label: Text(AppLocalizations.of(context).commonSave),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
