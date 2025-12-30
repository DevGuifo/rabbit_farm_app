import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../models/soin.dart';
import '../../providers/sante_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'widgets/soin_form_layout.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

/// Écran pour ajouter un soin - Design Stitch "Add Health Record"
/// Palette: Primary #13ec25, BG #f6f8f6/#102212, Surface #ffffff/#1a2e1d
class AjouterSoinScreen extends StatefulWidget {
  final Lapin lapin;

  const AjouterSoinScreen({super.key, required this.lapin});

  @override
  State<AjouterSoinScreen> createState() => _AjouterSoinScreenState();
}

class _AjouterSoinScreenState extends State<AjouterSoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _medicamentController = TextEditingController();
  final _dosageController = TextEditingController();

  String _typeSoin = 'traitement';
  DateTime _date = DateTime.now();
  DateTime? _dateRappel;
  bool _avecRappel = false;
  String _outcomeStatus = 'recovered';

  final List<String> _typesSoins = [
    'vaccination',
    'traitement',
    'vermifuge',
    'autre',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicamentController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.lapin.dateNaissance,
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryNeonGreen,
              onPrimary: AppTheme.cardLight,
              surface: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _selectRappelDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateRappel ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryNeonGreen,
              onPrimary: AppTheme.cardLight,
              surface: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRappel = picked);
    }
  }

  Future<void> _saveSoin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String outcomeLabel = _outcomeStatus == 'recovered'
        ? 'Récupéré'
        : _outcomeStatus == 'ongoing'
        ? 'En cours'
        : 'Critique';

    String notes = 'Statut: $outcomeLabel';

    final soin = Soin(
      lapinId: widget.lapin.id!,
      date: _date,
      type: _typeSoin,
      description: _descriptionController.text,
      medicament: _medicamentController.text.isNotEmpty
          ? _medicamentController.text
          : null,
      dosage: _dosageController.text.isNotEmpty ? _dosageController.text : null,
      dateRappel: _avecRappel ? _dateRappel : null,
      notes: notes,
    );

    try {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.ajouterSoin(soin);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Soin enregistré avec succès');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundDark
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Health Record',
          style: AppTheme.titleLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: textSecondary, size: 22),
            onPressed: () {
              // Rafraîchir les données
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: textSecondary,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlertesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textSecondary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ParametresScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SoinFormLayout(
        formKey: _formKey,
        lapin: widget.lapin,
        date: _date,
        onSelectDate: _selectDate,
        typeSoin: _typeSoin,
        onTypeSoinChanged: (value) => setState(() => _typeSoin = value),
        descriptionController: _descriptionController,
        typesSoins: _typesSoins,
        medicamentController: _medicamentController,
        dosageController: _dosageController,
        outcomeStatus: _outcomeStatus,
        onOutcomeStatusChanged: (value) =>
            setState(() => _outcomeStatus = value),
        avecRappel: _avecRappel,
        onAvecRappelChanged: (value) {
          setState(() {
            _avecRappel = value;
            if (!value) {
              _dateRappel = null;
            }
          });
        },
        dateRappel: _dateRappel,
        onSelectRappelDate: _selectRappelDate,
        onSave: _saveSoin,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
