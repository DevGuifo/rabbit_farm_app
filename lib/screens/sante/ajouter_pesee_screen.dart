import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../providers/sante_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';

/// Écran pour ajouter une pesée
class AjouterPeseeScreen extends StatefulWidget {
  final Lapin lapin;

  const AjouterPeseeScreen({super.key, required this.lapin});

  @override
  State<AjouterPeseeScreen> createState() => _AjouterPeseeScreenState();
}

class _AjouterPeseeScreenState extends State<AjouterPeseeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poidsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _poidsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectionnerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.lapin.dateNaissance,
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (!mounted) return;
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _enregistrerPesee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final poids = double.parse(_poidsController.text.replaceAll(',', '.'));

    final pesee = Pesee(
      lapinId: widget.lapin.id!,
      date: _date,
      poids: poids,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.ajouterPesee(pesee);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Pesée enregistrée avec succès');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Pesée de ${widget.lapin.nom}',
          style: AppTheme.titleLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations du lapin
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: widget.lapin.sexe == 'Mâle'
                          ? AppTheme.accentCyan.withValues(alpha: 0.2)
                          : AppTheme.accentPink.withValues(alpha: 0.2),
                      child: Icon(
                        widget.lapin.sexe == 'Mâle' ? Icons.male : Icons.female,
                        color: widget.lapin.sexe == 'Mâle'
                            ? AppTheme.accentCyan
                            : AppTheme.accentPink,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.lapin.nom, style: AppTheme.titleMedium),
                          Text(
                            '${widget.lapin.race} • ${widget.lapin.ageFormate}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de la pesée
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date de la pesée'),
                subtitle: Text(dateFormat.format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context),
              ),
            ),
            const SizedBox(height: 16),

            // Poids
            TextFormField(
              controller: _poidsController,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                hintText: 'Ex: 2.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le poids';
                }
                final poids = double.tryParse(value.replaceAll(',', '.'));
                if (poids == null || poids <= 0) {
                  return 'Veuillez entrer un poids valide';
                }
                if (poids > 10) {
                  return 'Le poids semble trop élevé';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Observations, état général...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton enregistrer
            FilledButton.icon(
              onPressed: _enregistrerPesee,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la pesée'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
