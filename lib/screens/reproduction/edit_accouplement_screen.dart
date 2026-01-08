import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/accouplement.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran pour modifier un accouplement existant
class EditAccouplementScreen extends StatefulWidget {
  final Accouplement accouplement;

  const EditAccouplementScreen({super.key, required this.accouplement});

  @override
  State<EditAccouplementScreen> createState() => _EditAccouplementScreenState();
}

class _EditAccouplementScreenState extends State<EditAccouplementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;

  Lapin? _maleSelectionne;
  Lapin? _femelleSelectionnee;
  late DateTime _dateAccouplement;
  DateTime? _dateMiseBasPrevue;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _notesController = TextEditingController(
      text: widget.accouplement.notes ?? '',
    );
    _dateAccouplement = widget.accouplement.dateAccouplement;
    _dateMiseBasPrevue = widget.accouplement.dateMiseBasPrevue;

    _chargerLapins();
  }

  Future<void> _chargerLapins() async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    await lapinProvider.chargerLapins();

    final male = lapinProvider.lapins.firstWhere(
      (l) => l.id == widget.accouplement.maleId,
      orElse: () => lapinProvider.lapins.first,
    );

    final femelle = lapinProvider.lapins.firstWhere(
      (l) => l.id == widget.accouplement.femelleId,
      orElse: () => lapinProvider.lapins.first,
    );

    setState(() {
      _maleSelectionne = male;
      _femelleSelectionnee = femelle;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Calculer automatiquement la date de mise bas prévue (31 jours)
  void _calculerDateMiseBasPrevue() {
    setState(() {
      _dateMiseBasPrevue = Accouplement.calculerDateMiseBasPrevue(
        _dateAccouplement,
      );
    });
  }

  /// Sélectionner la date d'accouplement
  Future<void> _selectionnerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateAccouplement,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (!mounted) return;
    if (picked != null && picked != _dateAccouplement) {
      setState(() {
        _dateAccouplement = picked;
        _calculerDateMiseBasPrevue();
      });
    }
  }

  /// Sélectionner un mâle reproducteur
  Future<void> _selectionnerMale(BuildContext context) async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final males = lapinProvider.lapins.where((l) => l.sexe == 'Mâle').toList();

    if (males.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).erreurAucunMaleDisponible,
            ),
          ),
        );
      }
      return;
    }

    final Lapin? selected = await showDialog<Lapin>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).reproSelectionnerMale),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: males.length,
            itemBuilder: (context, index) {
              final male = males[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.male)),
                title: Text(male.nom),
                subtitle: Text('${male.race} - ${male.ageFormate}'),
                onTap: () => Navigator.of(context).pop(male),
              );
            },
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _maleSelectionne = selected;
      });
    }
  }

  /// Sélectionner une femelle reproductrice
  Future<void> _selectionnerFemelle(BuildContext context) async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final femelles = lapinProvider.lapins
        .where((l) => l.sexe == 'Femelle')
        .toList();

    if (femelles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).erreurAucuneFemelleDisponible,
            ),
          ),
        );
      }
      return;
    }

    final Lapin? selected = await showDialog<Lapin>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).reproSelectionnerFemelle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: femelles.length,
            itemBuilder: (context, index) {
              final femelle = femelles[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.female)),
                title: Text(femelle.nom),
                subtitle: Text('${femelle.race} - ${femelle.ageFormate}'),
                onTap: () => Navigator.of(context).pop(femelle),
              );
            },
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _femelleSelectionnee = selected;
      });
    }
  }

  /// Modifier l'accouplement
  Future<void> _modifierAccouplement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_maleSelectionne == null) {
      SnackbarHelper.showValidationError(
        context,
        AppLocalizations.of(context).reproSelectionnerMale,
      );
      return;
    }

    if (_femelleSelectionnee == null) {
      SnackbarHelper.showValidationError(
        context,
        AppLocalizations.of(context).reproSelectionnerFemelle,
      );
      return;
    }

    // Ne pas permettre la modification si l'accouplement est terminé
    if (widget.accouplement.statut == 'termine') {
      SnackbarHelper.showWarning(
        context,
        AppLocalizations.of(context).reproImpossibleModifier,
      );
      return;
    }

    final accouplementModifie = widget.accouplement.copyWith(
      maleId: _maleSelectionne!.id!,
      femelleId: _femelleSelectionnee!.id!,
      dateAccouplement: _dateAccouplement,
      dateMiseBasPrevue: _dateMiseBasPrevue!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproductionProvider.modifierAccouplement(accouplementModifie);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context).reproAccouplementModifie,
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
        title: AppLocalizations.of(context).reproModifierAccouplement,
        icon: Icons.favorite_rounded,
        iconColor: AppTheme.accentPink,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avertissement si terminé
            if (widget.accouplement.statut == 'termine')
              Card(
                color: AppTheme.warning.withValues(alpha: 0.2),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppTheme.warning),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cet accouplement est terminé et ne peut plus être modifié',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.accouplement.statut == 'termine')
              const SizedBox(height: 16),

            // Sélection du mâle
            Card(
              child: ListTile(
                leading: Icon(Icons.male, color: AppTheme.info),
                title: Text(
                  _maleSelectionne?.nom ?? 'Sélectionner un mâle',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: _maleSelectionne != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: _maleSelectionne != null
                    ? Text(
                        '${_maleSelectionne!.race} - ${_maleSelectionne!.ageFormate}',
                      )
                    : Text(
                        AppLocalizations.of(context).reproAppuyezSelectionner,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.accouplement.statut != 'termine'
                    ? () => _selectionnerMale(context)
                    : null,
              ),
            ),
            const SizedBox(height: 8),

            // Sélection de la femelle
            Card(
              child: ListTile(
                leading: Icon(Icons.female, color: AppTheme.accentPink),
                title: Text(
                  _femelleSelectionnee?.nom ?? 'Sélectionner une femelle',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: _femelleSelectionnee != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: _femelleSelectionnee != null
                    ? Text(
                        '${_femelleSelectionnee!.race} - ${_femelleSelectionnee!.ageFormate}',
                      )
                    : Text(
                        AppLocalizations.of(context).reproAppuyezSelectionner,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.accouplement.statut != 'termine'
                    ? () => _selectionnerFemelle(context)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Date d'accouplement
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(AppLocalizations.of(context).reproDateAccouplement),
                subtitle: Text(dateFormat.format(_dateAccouplement)),
                trailing: const Icon(Icons.edit),
                onTap: widget.accouplement.statut != 'termine'
                    ? () => _selectionnerDate(context)
                    : null,
              ),
            ),
            const SizedBox(height: 8),

            // Date de mise bas prévue (automatique)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: Text(AppLocalizations.of(context).reproMiseBasPrevue),
                subtitle: Text(
                  _dateMiseBasPrevue != null
                      ? dateFormat.format(_dateMiseBasPrevue!)
                      : 'Non calculée',
                ),
                trailing: Chip(
                  label: Text(AppLocalizations.of(context).reproAuto),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informations calculées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dates importantes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.healing,
                      'Palpation recommandée',
                      dateFormat.format(
                        _dateAccouplement.add(const Duration(days: 11)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.home,
                      'Préparation du nid',
                      _dateMiseBasPrevue != null
                          ? dateFormat.format(
                              _dateMiseBasPrevue!.subtract(
                                const Duration(days: 3),
                              ),
                            )
                          : '-',
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
                hint: 'Observations, conditions particulières...',
                prefixIcon: Icons.notes,
              ),
              maxLines: 3,
              enabled: widget.accouplement.statut != 'termine',
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            if (widget.accouplement.statut != 'termine')
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
                      onPressed: _modifierAccouplement,
                      icon: const Icon(Icons.save),
                      label: Text(
                        AppLocalizations.of(context).actionEnregistrer,
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
