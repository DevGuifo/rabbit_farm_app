import 'package:flutter/material.dart';
import '../../../models/lapin.dart';
import 'forms/soin_form_widgets.dart';

/// Widget d'organisation du formulaire de soin
class SoinFormLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Lapin lapin;
  final DateTime date;
  final VoidCallback onSelectDate;
  final String typeSoin;
  final ValueChanged<String> onTypeSoinChanged;
  final TextEditingController descriptionController;
  final List<String> typesSoins;
  final TextEditingController medicamentController;
  final TextEditingController dosageController;
  final String outcomeStatus;
  final ValueChanged<String> onOutcomeStatusChanged;
  final bool avecRappel;
  final ValueChanged<bool> onAvecRappelChanged;
  final DateTime? dateRappel;
  final VoidCallback onSelectRappelDate;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const SoinFormLayout({
    super.key,
    required this.formKey,
    required this.lapin,
    required this.date,
    required this.onSelectDate,
    required this.typeSoin,
    required this.onTypeSoinChanged,
    required this.descriptionController,
    required this.typesSoins,
    required this.medicamentController,
    required this.dosageController,
    required this.outcomeStatus,
    required this.onOutcomeStatusChanged,
    required this.avecRappel,
    required this.onAvecRappelChanged,
    required this.dateRappel,
    required this.onSelectRappelDate,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RabbitInfoCard(lapin: lapin),
          const SizedBox(height: 24),
          DateFieldWidget(label: 'Event Date', date: date, onTap: onSelectDate),
          const SizedBox(height: 20),
          EventTypeSelector(typeSoin: typeSoin, onChanged: onTypeSoinChanged),
          const SizedBox(height: 20),
          DescriptionField(controller: descriptionController),
          const SizedBox(height: 20),
          TypeSoinDropdown(
            typeSoin: typeSoin,
            onChanged: onTypeSoinChanged,
            typesSoins: typesSoins,
          ),
          const SizedBox(height: 20),
          MedicationField(controller: medicamentController),
          const SizedBox(height: 20),
          DosageField(controller: dosageController),
          const SizedBox(height: 20),
          OutcomeStatusSelector(
            outcomeStatus: outcomeStatus,
            onChanged: onOutcomeStatusChanged,
          ),
          const SizedBox(height: 20),
          ReminderCheckbox(
            avecRappel: avecRappel,
            onChanged: onAvecRappelChanged,
          ),
          if (avecRappel) ...[
            const SizedBox(height: 20),
            RappelDateFieldWidget(
              dateRappel: dateRappel,
              onTap: onSelectRappelDate,
            ),
          ],
          const SizedBox(height: 32),
          FormActionButtons(onSave: onSave, onCancel: onCancel),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
