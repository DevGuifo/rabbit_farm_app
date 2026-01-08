import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/quarantaine.dart';
import '../../providers/quarantaine_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Dialog simplifié pour mise en quarantaine rapide
/// Pré-remplit le lapin, propose les options essentielles
class QuarantaineQuickDialog extends StatefulWidget {
  final Lapin lapin;

  const QuarantaineQuickDialog({super.key, required this.lapin});

  @override
  State<QuarantaineQuickDialog> createState() => _QuarantaineQuickDialogState();
}

class _QuarantaineQuickDialogState extends State<QuarantaineQuickDialog> {
  String _motif = 'observation';
  DateTime _dateDebut = DateTime.now();
  final TextEditingController _symptomesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  static const Map<String, Map<String, dynamic>> _motifsInfo = {
    'nouveau': {'icon': Icons.fiber_new, 'color': AppTheme.info},
    'maladie': {'icon': Icons.sick, 'color': AppTheme.error},
    'isolement_sanitaire': {
      'icon': Icons.cleaning_services,
      'color': AppTheme.warning,
    },
    'observation': {'icon': Icons.visibility, 'color': AppTheme.accentPink},
  };

  @override
  void dispose() {
    _symptomesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getMotifLabel(BuildContext context, String motif) {
    final l10n = AppLocalizations.of(context);
    switch (motif) {
      case 'nouveau':
        return l10n.quarantaineNouveauLapin;
      case 'maladie':
        return l10n.quarantaineMaladie;
      case 'isolement_sanitaire':
        return l10n.quarantaineIsolementSanitaire;
      case 'observation':
        return l10n.quarantaineObservation;
      default:
        return motif;
    }
  }

  String _getMotifDescription(BuildContext context, String motif) {
    final l10n = AppLocalizations.of(context);
    switch (motif) {
      case 'nouveau':
        return l10n.quarantaineDescriptionNouveau;
      case 'maladie':
        return l10n.quarantaineDescriptionMaladie;
      case 'isolement_sanitaire':
        return l10n.quarantaineDescriptionIsolement;
      case 'observation':
        return l10n.quarantaineDescriptionObservation;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: AppTheme.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).quarantaineMiseEnQuarantaine,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.lapin.nom,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date de début
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppTheme.warning,
                ),
                title: Text(AppLocalizations.of(context).quarantaineDateDebut),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dateDebut)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectDate(context),
                ),
              ),
              const Divider(),

              // Motif
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppLocalizations.of(context).quarantaineMotifQuarantaine,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              ..._motifsInfo.entries.map((entry) {
                final motifData = entry.value;
                final isSelected = _motif == entry.key;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? motifData['color']
                          : (isDark
                                ? AppTheme.neutral700
                                : AppTheme.borderLight),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? motifData['color'].withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    onTap: () => setState(() => _motif = entry.key),
                    leading: Icon(
                      motifData['icon'],
                      color: motifData['color'],
                      size: 20,
                    ),
                    title: Text(
                      _getMotifLabel(context, entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _getMotifDescription(context, entry.key),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: motifData['color'])
                        : const Icon(Icons.circle_outlined),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Symptômes (optionnel)
              TextField(
                controller: _symptomesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).quarantaineSymptomes,
                  hintText: AppLocalizations.of(
                    context,
                  ).quarantaineHintSymptomes,
                  prefixIcon: const Icon(Icons.medical_information),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Notes (optionnel)
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  ).quarantaineNotesAdditionnelles,
                  hintText: AppLocalizations.of(context).quarantaineHintNotes,
                  prefixIcon: const Icon(Icons.note_alt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Info durée
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).quarantaineInfoDuree,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.info900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context).quarantaineAnnuler),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _confirmerQuarantaine,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.health_and_safety),
          label: Text(
            _isLoading
                ? AppLocalizations.of(context).quarantaineEnCours
                : AppLocalizations.of(context).quarantaineConfirmer,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warning,
            foregroundColor: AppTheme.textLight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      locale: const Locale('fr', 'FR'),
    );

    if (date != null) {
      setState(() => _dateDebut = date);
    }
  }

  Future<void> _confirmerQuarantaine() async {
    setState(() => _isLoading = true);

    try {
      final quarantaine = Quarantaine(
        lapinId: widget.lapin.id!,
        dateDebut: _dateDebut,
        motif: _motif,
        symptomes: _symptomesController.text.isNotEmpty
            ? _symptomesController.text
            : null,
        traitement: null, // Sera ajouté plus tard si besoin
        statut: 'en_cours',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        await context.read<QuarantaineProvider>().ajouterQuarantaine(
          quarantaine,
        );

        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            AppLocalizations.of(context).quarantaineSucces(widget.lapin.nom),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarHelper.showError(
          context,
          AppLocalizations.of(context).quarantaineErreur(e.toString()),
        );
      }
    }
  }
}
