import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran pour modifier une portée existante
class EditPorteeScreen extends StatefulWidget {
  final Portee portee;

  const EditPorteeScreen({super.key, required this.portee});

  @override
  State<EditPorteeScreen> createState() => _EditPorteeScreenState();
}

class _EditPorteeScreenState extends State<EditPorteeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreNesController;
  late final TextEditingController _nombreVivantsController;
  late final TextEditingController _nombreMortsController;
  late final TextEditingController _notesController;

  late DateTime _dateMiseBasReelle;
  Lapin? _male;
  Lapin? _femelle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _nombreNesController = TextEditingController(
      text: widget.portee.nombreNes.toString(),
    );
    _nombreVivantsController = TextEditingController(
      text: widget.portee.nombreVivants.toString(),
    );
    _nombreMortsController = TextEditingController(
      text: widget.portee.nombreMorts.toString(),
    );
    _notesController = TextEditingController(text: widget.portee.notes ?? '');
    _dateMiseBasReelle = widget.portee.dateMiseBasReelle;

    _chargerLapins();
  }

  @override
  void dispose() {
    _nombreNesController.dispose();
    _nombreVivantsController.dispose();
    _nombreMortsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Charger les informations des parents
  Future<void> _chargerLapins() async {
    final db = DatabaseHelper.instance;
    final accouplement = await db.getAccouplementById(
      widget.portee.accouplementId,
    );

    if (accouplement != null) {
      final male = await db.getLapinById(accouplement.maleId);
      final femelle = await db.getLapinById(accouplement.femelleId);

      setState(() {
        _male = male;
        _femelle = femelle;
        _isLoading = false;
      });
    }
  }

  /// Calculer automatiquement le nombre de morts
  void _calculerMorts() {
    final nes = int.tryParse(_nombreNesController.text) ?? 0;
    final vivants = int.tryParse(_nombreVivantsController.text) ?? 0;
    final morts = (nes - vivants).clamp(0, nes);
    _nombreMortsController.text = morts.toString();
  }

  /// Sélectionner la date de mise bas
  Future<void> _selectionnerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateMiseBasReelle,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      locale: const Locale('fr', 'FR'),
    );
    if (!mounted) return;
    if (picked != null && picked != _dateMiseBasReelle) {
      setState(() {
        _dateMiseBasReelle = picked;
      });
    }
  }

  /// Modifier la portée
  Future<void> _modifierPortee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombreNes = int.parse(_nombreNesController.text);
    final nombreVivants = int.parse(_nombreVivantsController.text);
    final nombreMorts = int.parse(_nombreMortsController.text);

    if (nombreVivants + nombreMorts != nombreNes) {
      SnackbarHelper.showValidationError(
        context,
        'Le total vivants + morts doit être égal au nombre de nés',
      );
      return;
    }

    final porteeModifiee = widget.portee.copyWith(
      dateMiseBasReelle: _dateMiseBasReelle,
      nombreNes: nombreNes,
      nombreVivants: nombreVivants,
      nombreMorts: nombreMorts,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproductionProvider.modifierPortee(porteeModifiee);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context).reproPorteeModifiee,
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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).reproModifierPortee,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations parents
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).reproParents,
                      style: AppTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.male, color: AppTheme.info, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _male?.nom ?? 'Inconnu',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.female,
                          color: AppTheme.accentPink,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _femelle?.nom ?? 'Inconnue',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de mise bas
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  AppLocalizations.of(context).reproDateMiseBasReelle,
                ),
                subtitle: Text(dateFormat.format(_dateMiseBasReelle)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre de nés
            TextFormField(
              controller: _nombreNesController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).reproNombreLapereaux,
                prefixIcon: Icons.baby_changing_station,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _calculerMorts(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).reproVeuillezEntrerNes;
                }
                final nombre = int.tryParse(value);
                if (nombre == null || nombre < 0) {
                  return AppLocalizations.of(context).reproNombreInvalide;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de vivants
            TextFormField(
              controller: _nombreVivantsController,
              decoration:
                  AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).reproNombreVivants,
                    prefixIcon: Icons.favorite,
                  ).copyWith(
                    prefixIcon: const Icon(
                      Icons.favorite,
                      color: AppTheme.neonGreen,
                    ),
                  ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _calculerMorts(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(
                    context,
                  ).reproVeuillezEntrerVivants;
                }
                final nombre = int.tryParse(value);
                if (nombre == null || nombre < 0) {
                  return AppLocalizations.of(context).reproNombreInvalide;
                }
                final nes = int.tryParse(_nombreNesController.text) ?? 0;
                if (nombre > nes) {
                  return AppLocalizations.of(context).reproNombreSuperieurTotal;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de morts (calculé automatiquement)
            TextFormField(
              controller: _nombreMortsController,
              decoration:
                  AppTheme.inputDecoration(
                    label: AppLocalizations.of(context).reproNombreMorts,
                    prefixIcon: Icons.heart_broken,
                  ).copyWith(
                    prefixIcon: const Icon(
                      Icons.heart_broken,
                      color: AppTheme.error,
                    ),
                  ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Avertissement
            Card(
              color: AppTheme.warning.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warning),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note: La modification ne crée pas de nouveaux lapereaux. Gérez-les manuellement si nécessaire.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).reproNotesOptionnel,
                hint: 'Observations sur la mise bas...',
                prefixIcon: Icons.notes,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(AppLocalizations.of(context).actionAnnuler),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _modifierPortee,
                    icon: const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context).actionEnregistrer),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
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
