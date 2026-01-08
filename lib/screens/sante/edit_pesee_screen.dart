import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../providers/sante_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran pour modifier une pesée existante
class EditPeseeScreen extends StatefulWidget {
  final Lapin lapin;
  final Pesee pesee;

  const EditPeseeScreen({super.key, required this.lapin, required this.pesee});

  @override
  State<EditPeseeScreen> createState() => _EditPeseeScreenState();
}

class _EditPeseeScreenState extends State<EditPeseeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _poidsController;
  late final TextEditingController _notesController;

  late DateTime _date;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données existantes
    _poidsController = TextEditingController(
      text: widget.pesee.poids.toString(),
    );
    _notesController = TextEditingController(text: widget.pesee.notes ?? '');
    _date = widget.pesee.date;
  }

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

  Future<void> _modifierPesee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final poids = double.parse(_poidsController.text.replaceAll(',', '.'));

    final peseeModifiee = widget.pesee.copyWith(
      date: _date,
      poids: poids,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.modifierPesee(peseeModifiee);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context).santePeseeModifiee,
        );
        Navigator.of(context).pop(true);
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
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).santeModifierPesee,
        icon: Icons.monitor_weight_rounded,
        iconColor: AppTheme.info,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppTheme.paddingAllMedium,
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
                          ? AppTheme.info.withValues(alpha: 0.2)
                          : AppTheme.accentPink.withValues(alpha: 0.2),
                      child: Icon(
                        widget.lapin.sexe == 'Mâle' ? Icons.male : Icons.female,
                        color: widget.lapin.sexe == 'Mâle'
                            ? AppTheme.info
                            : AppTheme.accentPink,
                        size: 32,
                      ),
                    ),
                    AppTheme.horizontalSpace16,
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
            AppTheme.verticalSpace16,

            // Date de la pesée
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(AppLocalizations.of(context).santeDatePesee),
                subtitle: Text(dateFormat.format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context),
              ),
            ),
            AppTheme.verticalSpace16,

            // Poids
            TextFormField(
              controller: _poidsController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santePoids,
                hint: 'Ex: 2.5',
                prefixIcon: Icons.monitor_weight,
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
                  return AppLocalizations.of(context).erreurPoidsInvalide;
                }
                final poids = double.tryParse(value.replaceAll(',', '.'));
                if (poids == null || poids <= 0) {
                  return AppLocalizations.of(context).erreurPoidsInvalide;
                }
                if (poids > 10) {
                  return AppLocalizations.of(context).erreurPoidsInvalide;
                }
                return null;
              },
            ),
            AppTheme.verticalSpace16,

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeNotes,
                hint: 'Observations, état général...',
                prefixIcon: Icons.notes,
              ),
              maxLines: 3,
            ),
            AppTheme.verticalSpace24,

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(AppLocalizations.of(context).actionAnnuler),
                    style: OutlinedButton.styleFrom(
                      padding: AppTheme.paddingAllMedium,
                    ),
                  ),
                ),
                AppTheme.horizontalSpace16,
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _modifierPesee,
                    icon: const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context).actionEnregistrer),
                    style: FilledButton.styleFrom(
                      padding: AppTheme.paddingAllMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
