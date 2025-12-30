import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/accouplement.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

/// Écran Plan New Mating - Design Stitch complet
class PlanifierAccouplementScreen extends StatefulWidget {
  const PlanifierAccouplementScreen({super.key});

  @override
  State<PlanifierAccouplementScreen> createState() =>
      _PlanifierAccouplementScreenState();
}

class _PlanifierAccouplementScreenState
    extends State<PlanifierAccouplementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Lapin? _femelleSelectionnee;
  Lapin? _maleSelectionne;
  DateTime _dateAccouplement = DateTime.now();
  DateTime? _dateMiseBasPrevue;

  @override
  void initState() {
    super.initState();
    _calculerDateMiseBasPrevue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LapinProvider>(context, listen: false).chargerLapins();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _calculerDateMiseBasPrevue() {
    setState(() {
      _dateMiseBasPrevue = Accouplement.calculerDateMiseBasPrevue(
        _dateAccouplement,
      );
    });
  }

  Future<void> _enregistrerAccouplement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_femelleSelectionnee == null) {
      SnackbarHelper.showValidationError(
        context,
        'Veuillez sélectionner une femelle',
      );
      return;
    }

    if (_maleSelectionne == null) {
      SnackbarHelper.showValidationError(
        context,
        'Veuillez sélectionner un mâle',
      );
      return;
    }

    final accouplement = Accouplement(
      maleId: _maleSelectionne!.id!,
      femelleId: _femelleSelectionnee!.id!,
      dateAccouplement: _dateAccouplement,
      dateMiseBasPrevue: _dateMiseBasPrevue!,
      statut: 'en_attente',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproductionProvider.ajouterAccouplement(accouplement);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Accouplement planifié avec succès',
        );
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

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildDoeSelector(isDark),
                    const SizedBox(height: 24),
                    _buildBuckSelector(isDark),
                    const SizedBox(height: 32),
                    _buildDivider(isDark),
                    const SizedBox(height: 32),
                    _buildDatePicker(isDark),
                    const SizedBox(height: 16),
                    _buildEstimatedKindling(isDark),
                    const SizedBox(height: 32),
                    _buildNotesField(isDark),
                    const SizedBox(height: 32),
                    _buildActionButtons(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: (isDark ? AppTheme.backgroundDark : AppTheme.cardLight)
          .withValues(alpha: 0.95),
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Plan New Mating',
        style: AppTheme.titleLarge.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.sync,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          onPressed: () {
            Provider.of<LapinProvider>(context, listen: false).chargerLapins();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
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
          icon: Icon(
            Icons.settings,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
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
    );
  }

  Widget _buildDoeSelector(bool isDark) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, _) {
        final femelles = lapinProvider.lapins
            .where((l) => l.sexe == 'Femelle')
            .toList();

        final hasNoFemelles = femelles.isEmpty;

        // Réinitialiser la sélection si elle n'est plus dans la liste
        if (_femelleSelectionnee != null &&
            !femelles.any((f) => f.id == _femelleSelectionnee!.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _femelleSelectionnee = null;
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Select Doe (Female) '),
                      TextSpan(
                        text: '*',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                        : AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ready',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: DropdownButtonFormField<Lapin>(
                initialValue: hasNoFemelles
                    ? null
                    : (femelles.any((f) => f.id == _femelleSelectionnee?.id)
                          ? _femelleSelectionnee
                          : null),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.female,
                    color: AppTheme.accentPink.withValues(alpha: 0.7),
                  ),
                  suffixIcon: Icon(
                    Icons.expand_more,
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  hintText: hasNoFemelles
                      ? 'Aucune femelle disponible'
                      : 'Select a doe...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
                dropdownColor: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.cardLight,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
                items: hasNoFemelles
                    ? null
                    : femelles.map((femelle) {
                        return DropdownMenuItem<Lapin>(
                          value: femelle,
                          child: Text(
                            '${femelle.nom} - ${femelle.race}',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                onChanged: hasNoFemelles
                    ? null
                    : (value) {
                        setState(() {
                          _femelleSelectionnee = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Sélectionnez une femelle' : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasNoFemelles
                  ? 'Ajoutez des femelles dans la section Cheptel avant de planifier un accouplement.'
                  : 'Only displaying does that are ready for breeding.',
              style: AppTheme.caption.copyWith(
                color: hasNoFemelles
                    ? AppTheme.error
                    : (isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBuckSelector(bool isDark) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, _) {
        final males = lapinProvider.lapins
            .where((l) => l.sexe == 'Mâle')
            .toList();

        final hasNoMales = males.isEmpty;

        // Réinitialiser la sélection si elle n'est plus dans la liste
        if (_maleSelectionne != null &&
            !males.any((m) => m.id == _maleSelectionne!.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _maleSelectionne = null;
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
                children: const [
                  TextSpan(text: 'Select Doe (Female) '),
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: DropdownButtonFormField<Lapin>(
                initialValue: hasNoMales
                    ? null
                    : (males.any((m) => m.id == _maleSelectionne?.id)
                          ? _maleSelectionne
                          : null),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.male,
                    color: AppTheme.info.withValues(alpha: 0.7),
                  ),
                  suffixIcon: Icon(
                    Icons.expand_more,
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  hintText: hasNoMales
                      ? 'Aucun mâle disponible'
                      : 'Select a buck...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
                dropdownColor: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.cardLight,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
                items: hasNoMales
                    ? null
                    : males.map((male) {
                        return DropdownMenuItem<Lapin>(
                          value: male,
                          child: Text(
                            '${male.nom} - ${male.race}',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                onChanged: hasNoMales
                    ? null
                    : (value) {
                        setState(() {
                          _maleSelectionne = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Sélectionnez un mâle' : null,
              ),
            ),
            if (hasNoMales) ...[
              const SizedBox(height: 6),
              Text(
                'Ajoutez des mâles dans la section Cheptel avant de planifier un accouplement.',
                style: AppTheme.caption.copyWith(color: AppTheme.error),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            children: const [
              TextSpan(text: 'Mating Date '),
              TextSpan(
                text: '*',
                style: TextStyle(color: AppTheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateAccouplement,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _dateAccouplement = picked;
                _calculerDateMiseBasPrevue();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MM/dd/yyyy').format(_dateAccouplement),
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedKindling(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryNeonGreen.withValues(alpha: 0.05)
            : AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: isDark ? AppTheme.primaryNeonGreen : AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED KINDLING',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateMiseBasPrevue != null
                      ? DateFormat('MMMM dd, yyyy').format(_dateMiseBasPrevue!)
                      : 'N/A',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  hintText:
                      'Add specific instructions, cage number changes, or health observations...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Icon(
                  Icons.edit_note,
                  size: 18,
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _enregistrerAccouplement,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeonGreen,
              foregroundColor: AppTheme.textPrimary,
              elevation: 8,
              shadowColor: AppTheme.primaryNeonGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task, size: 24),
                SizedBox(width: 8),
                Text('Plan Mating', style: AppTheme.titleSmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            'Cancel',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
