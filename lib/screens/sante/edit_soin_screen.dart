import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../models/soin.dart';
import '../../models/enums/type_soin.dart';
import '../../providers/sante_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

/// Écran pour modifier un soin existant
class EditSoinScreen extends StatefulWidget {
  final Lapin lapin;
  final Soin soin;

  const EditSoinScreen({super.key, required this.lapin, required this.soin});

  @override
  State<EditSoinScreen> createState() => _EditSoinScreenState();
}

class _EditSoinScreenState extends State<EditSoinScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _medicamentController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;

  late TypeSoin _typeSoin;
  late DateTime _date;
  DateTime? _dateRappel;
  late bool _avecRappel;

  final List<TypeSoin> _typesSoins = TypeSoin.values;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _descriptionController = TextEditingController(
      text: widget.soin.description,
    );
    _medicamentController = TextEditingController(
      text: '',
    );
    _dosageController = TextEditingController(text: widget.soin.dosage ?? '');
    _notesController = TextEditingController(text: widget.soin.notes ?? '');

    _typeSoin = widget.soin.type;
    _date = widget.soin.date;
    _dateRappel = widget.soin.dateRappel;
    _avecRappel = widget.soin.dateRappel != null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicamentController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectionnerDate(BuildContext context, bool isRappel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isRappel
          ? (_dateRappel ?? DateTime.now().add(const Duration(days: 30)))
          : _date,
      firstDate: isRappel ? DateTime.now() : widget.lapin.dateNaissance,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (isRappel) {
          _dateRappel = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _modifierSoin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final soinModifie = widget.soin.copyWith(
      date: _date,
      type: _typeSoin,
      description: _descriptionController.text,
      dosage: _dosageController.text.isNotEmpty ? _dosageController.text : null,
      dateRappel: _avecRappel ? _dateRappel : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.modifierSoin(soinModifie);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context).santeSoinModifieSucces,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          AppLocalizations.of(context).msgErreurOperationEchouee,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).santeModifierSoin,
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
                      backgroundColor: widget.lapin.sexe == Sexe.male
                          ? AppTheme.info.withValues(alpha: 0.2)
                          : AppTheme.accentPink.withValues(alpha: 0.2),
                      child: Icon(
                        widget.lapin.sexe == Sexe.male ? Icons.male : Icons.female,
                        color: widget.lapin.sexe == Sexe.male
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

            // Date du soin
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(AppLocalizations.of(context).santeDateSoin),
                subtitle: Text(dateFormat.format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context, false),
              ),
            ),
            AppTheme.verticalSpace16,

            // Type de soin
            DropdownButtonFormField<TypeSoin>(
              initialValue: _typeSoin,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeTypeSoin,
                prefixIcon: Icons.category,
              ),
              items: _typesSoins.map((type) {
                return DropdownMenuItem<TypeSoin>(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _typeSoin = value;
                  });
                }
              },
            ),
            AppTheme.verticalSpace16,

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeDescription,
                hint: AppLocalizations.of(context).hintDescriptionSoin,
                prefixIcon: Icons.description,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).erreurDescriptionRequise;
                }
                return null;
              },
            ),
            AppTheme.verticalSpace16,

            // Médicament
            TextFormField(
              controller: _medicamentController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeMedicament,
                hint: AppLocalizations.of(context).hintMedicamentSoin,
                prefixIcon: Icons.medication,
              ),
            ),
            AppTheme.verticalSpace16,

            // Dosage
            TextFormField(
              controller: _dosageController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeDosage,
                hint: AppLocalizations.of(context).hintDosageSoin,
                prefixIcon: Icons.medication_liquid,
              ),
            ),
            AppTheme.verticalSpace16,

            // Option rappel
            Card(
              child: SwitchListTile(
                title: Text(AppLocalizations.of(context).santePrevoirRappel),
                subtitle: _avecRappel && _dateRappel != null
                    ? Text(
                        '${AppLocalizations.of(context).santeRappelLe} ${dateFormat.format(_dateRappel!)}',
                      )
                    : Text(AppLocalizations.of(context).santeAucunRappel),
                value: _avecRappel,
                onChanged: (value) {
                  setState(() {
                    _avecRappel = value;
                    if (value && _dateRappel == null) {
                      _dateRappel = _date.add(const Duration(days: 30));
                    }
                  });
                },
                secondary: const Icon(Icons.notification_add),
              ),
            ),

            if (_avecRappel)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacing8),
                child: OutlinedButton.icon(
                  onPressed: () => _selectionnerDate(context, true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dateRappel != null
                        ? AppLocalizations.of(context).santeModifierDateRappel
                        : AppLocalizations.of(context).santeChoisirDateRappel,
                  ),
                ),
              ),
            AppTheme.verticalSpace16,

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).santeNotesOptionnelles,
                hint: AppLocalizations.of(
                  context,
                ).santeObservationsComplementaires,
                prefixIcon: Icons.notes,
              ),
              maxLines: 3,
            ),
            // Espace pour FormActionBar
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: FormActionBar(
        onCancel: () => Navigator.pop(context),
        onSave: _modifierSoin,
        saveText: AppLocalizations.of(context).commonSave,
      ),
    );
  }

}
