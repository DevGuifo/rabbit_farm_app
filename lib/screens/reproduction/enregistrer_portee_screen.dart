import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/accouplement.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/database_helper.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

/// Écran Record New Litter - Design Stitch complet
class EnregistrerPorteeScreen extends StatefulWidget {
  final Accouplement? accouplement;

  const EnregistrerPorteeScreen({super.key, this.accouplement});

  @override
  State<EnregistrerPorteeScreen> createState() =>
      _EnregistrerPorteeScreenState();
}

class _EnregistrerPorteeScreenState extends State<EnregistrerPorteeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observationsController = TextEditingController();

  int? _accouplementIdSelectionne;
  DateTime _dateKindling = DateTime.now();
  int _totalBorn = 0;
  int _bornAlive = 0;

  Lapin? _male;
  Lapin? _femelle;
  bool _isLoading = true;
  final bool _creerLapereaux = true;

  List<Accouplement> _accouplements = [];

  @override
  void initState() {
    super.initState();
    _accouplementIdSelectionne = widget.accouplement?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    final reproProvider = Provider.of<ReproductionProvider>(
      context,
      listen: false,
    );

    await reproProvider.chargerAccouplements();

    // Filtrer les accouplements en attente ou confirmés
    final accouplementsActifs = reproProvider.accouplements.where((a) {
      return a.statut == 'en_attente' || a.statut == 'confirme';
    }).toList();

    setState(() {
      _accouplements = accouplementsActifs;
      _isLoading = false;
    });

    if (_accouplementIdSelectionne != null) {
      final acc = _accouplements.firstWhere(
        (a) => a.id == _accouplementIdSelectionne,
        orElse: () => _accouplements.first,
      );
      await _chargerLapins(acc);
    }
  }

  Future<void> _chargerLapins(Accouplement accouplement) async {
    final db = DatabaseHelper.instance;
    final male = await db.getLapinById(accouplement.maleId);
    final femelle = await db.getLapinById(accouplement.femelleId);

    setState(() {
      _male = male;
      _femelle = femelle;
    });
  }

  Future<void> _creerLapereausDansDB(int nombreVivants) async {
    if (!_creerLapereaux || nombreVivants == 0) return;

    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final db = DatabaseHelper.instance;

    for (int i = 1; i <= nombreVivants; i++) {
      final lapereau = Lapin(
        nom: '${_femelle!.nom} - Lapereau $i',
        race: _femelle!.race,
        sexe: 'Inconnu',
        dateNaissance: _dateKindling,
        statut: 'Jeune',
        localisation: _femelle!.localisation ?? 'Nid',
      );

      final lapereauAjoute = await lapinProvider.ajouterLapin(lapereau);

      if (lapereauAjoute.id != null &&
          _male?.id != null &&
          _femelle?.id != null) {
        await db.setParents(lapereauAjoute.id!, _male!.id!, _femelle!.id!);
      }
    }
  }

  Future<void> _enregistrerPortee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_accouplementIdSelectionne == null) {
      SnackbarHelper.showValidationError(
        context,
        'Veuillez sélectionner un accouplement',
      );
      return;
    }

    if (_totalBorn == 0) {
      SnackbarHelper.showValidationError(
        context,
        'Le nombre total de nés doit être supérieur à 0',
      );
      return;
    }

    if (_bornAlive > _totalBorn) {
      SnackbarHelper.showValidationError(
        context,
        'Le nombre de vivants ne peut pas dépasser le total',
      );
      return;
    }

    final nombreMorts = _totalBorn - _bornAlive;

    final accouplementSelectionne = _accouplements.firstWhere(
      (a) => a.id == _accouplementIdSelectionne,
    );

    final portee = Portee(
      accouplementId: accouplementSelectionne.id!,
      dateMiseBasReelle: _dateKindling,
      nombreNes: _totalBorn,
      nombreVivants: _bornAlive,
      nombreMorts: nombreMorts,
      notes: _observationsController.text.isNotEmpty
          ? _observationsController.text
          : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );

      await reproductionProvider.ajouterPortee(portee);
      await reproductionProvider.terminerAccouplement(
        accouplementSelectionne.id!,
      );

      await _creerLapereausDansDB(_bornAlive);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          _creerLapereaux
              ? 'Portée enregistrée et $_bornAlive lapereaux créés'
              : 'Portée enregistrée avec succès',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              (isDark ? AppTheme.backgroundDark : AppTheme.cardLight)
                  .withValues(alpha: 0.95),
          title: const Text('Record New Litter'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                          _buildDescription(isDark),
                          const SizedBox(height: 24),
                          _buildMatingPairSelector(isDark),
                          const SizedBox(height: 24),
                          _buildKindlingDatePicker(isDark),
                          const SizedBox(height: 24),
                          _buildNumberInputs(isDark),
                          const SizedBox(height: 16),
                          _buildInfoCard(isDark),
                          const SizedBox(height: 24),
                          _buildObservationsField(isDark),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildStickyBottomActions(isDark),
          ],
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
        'Record New Litter',
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
          onPressed: () => _chargerDonnees(),
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

  Widget _buildDescription(bool isDark) {
    return Text(
      'Enter the details of the new litter below. Accurate records help in tracking doe performance and kit survival rates.',
      style: AppTheme.bodyMedium.copyWith(
        color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildMatingPairSelector(bool isDark) {
    // Vérifier si l'ID sélectionné existe dans la liste
    final accouplementValide =
        _accouplementIdSelectionne != null &&
        _accouplements.any((a) => a.id == _accouplementIdSelectionne);

    // Réinitialiser si invalide
    if (!accouplementValide && _accouplementIdSelectionne != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _accouplementIdSelectionne = null;
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MATING PAIR',
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          child: DropdownButtonFormField<int>(
            initialValue: accouplementValide
                ? _accouplementIdSelectionne
                : null,
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.expand_more,
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Select active mating...',
              hintStyle: AppTheme.bodyLarge.copyWith(
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            dropdownColor: isDark
                ? AppTheme.backgroundDark
                : AppTheme.cardLight,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            items: _accouplements.map((acc) {
              return DropdownMenuItem<int>(
                value: acc.id,
                child: FutureBuilder<String>(
                  future: _getAccouplementLabel(acc),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                _accouplementIdSelectionne = value;
              });
              if (value != null) {
                final acc = _accouplements.firstWhere((a) => a.id == value);
                await _chargerLapins(acc);
              }
            },
            validator: (value) =>
                value == null ? 'Sélectionnez un accouplement' : null,
          ),
        ),
      ],
    );
  }

  Future<String> _getAccouplementLabel(Accouplement acc) async {
    final db = DatabaseHelper.instance;
    final male = await db.getLapinById(acc.maleId);
    final femelle = await db.getLapinById(acc.femelleId);
    final dateDue = DateFormat('MMM dd').format(acc.dateMiseBasPrevue);

    return 'Doe ${femelle?.nom ?? 'Unknown'} x Buck ${male?.nom ?? 'Unknown'} (Due $dateDue)';
  }

  Widget _buildKindlingDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KINDLING DATE',
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateKindling,
              firstDate: DateTime.now().subtract(const Duration(days: 60)),
              lastDate: DateTime.now().add(const Duration(days: 7)),
            );
            if (picked != null) {
              setState(() {
                _dateKindling = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
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
                    DateFormat('MM/dd/yyyy').format(_dateKindling),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildNumberInputs(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberInput(
            isDark: isDark,
            label: 'TOTAL BORN',
            value: _totalBorn,
            onIncrement: () => setState(() => _totalBorn++),
            onDecrement: () => setState(() {
              if (_totalBorn > 0) _totalBorn--;
            }),
            onChange: (val) => setState(() => _totalBorn = val),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNumberInput(
            isDark: isDark,
            label: 'BORN ALIVE',
            value: _bornAlive,
            onIncrement: () => setState(() => _bornAlive++),
            onDecrement: () => setState(() {
              if (_bornAlive > 0) _bornAlive--;
            }),
            onChange: (val) => setState(() => _bornAlive = val),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required bool isDark,
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Function(int) onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          child: Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove, size: 20),
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: AppTheme.titleLarge.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add, size: 20),
                color: AppTheme.primaryNeonGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark) {
    final stillborn = _totalBorn - _bornAlive;
    final survivalRate = _totalBorn > 0
        ? ((_bornAlive / _totalBorn) * 100).toStringAsFixed(1)
        : '0.0';

    if (_totalBorn == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.textSecondary.withValues(alpha: 0.5)
            : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            size: 20,
            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary,
                ),
                children: [
                  if (stillborn > 0) ...[
                    TextSpan(
                      text:
                          '$stillborn kit${stillborn > 1 ? 's' : ''} stillborn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '. '),
                  ],
                  const TextSpan(
                    text: 'The survival rate for this litter is currently ',
                  ),
                  TextSpan(
                    text: '$survivalRate%',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSERVATIONS',
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          child: TextFormField(
            controller: _observationsController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText:
                  'Note any specific characteristics, complications during birth, or kit conditions...',
              hintStyle: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomActions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
            .withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _enregistrerPortee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeonGreen,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 8,
                    shadowColor: AppTheme.primaryNeonGreen.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, size: 24),
                      SizedBox(width: 8),
                      Text('Record Litter', style: AppTheme.titleSmall),
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
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
