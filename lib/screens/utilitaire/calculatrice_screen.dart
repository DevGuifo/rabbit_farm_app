import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../services/advanced_calculator_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

class CalculatriceScreen extends StatefulWidget {
  const CalculatriceScreen({super.key});

  @override
  State<CalculatriceScreen> createState() => _CalculatriceScreenState();
}

class _CalculatriceScreenState extends State<CalculatriceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).utilCalculatrice,
        icon: Icons.calculate_rounded,
        iconColor: AppTheme.info,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.medical_services_rounded),
              text: AppLocalizations.of(context).utilSante,
            ),
            Tab(
              icon: const Icon(Icons.restaurant_rounded),
              text: AppLocalizations.of(context).utilAlimentation,
            ),
            Tab(
              icon: const Icon(Icons.science_rounded),
              text: AppLocalizations.of(context).utilDosagesAvances,
            ),
            Tab(
              icon: const Icon(Icons.analytics_rounded),
              text: AppLocalizations.of(context).utilPerformance,
            ),
            Tab(
              icon: const Icon(Icons.euro_rounded),
              text: AppLocalizations.of(context).utilFinance,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _SanteTab(),
          const _AlimentationTab(),
          const _DosagesAvancesTab(),
          const _PerformanceTab(),
          const _FinanceTab(),
        ],
      ),
    );
  }
}

// ============================================
// ONGLET SANTÉ
// ============================================
class _SanteTab extends StatefulWidget {
  const _SanteTab();

  @override
  State<_SanteTab> createState() => _SanteTabState();
}

class _SanteTabState extends State<_SanteTab> {
  final _poidsController = TextEditingController();
  final _dosageKgController = TextEditingController();
  String _resultat = '';

  @override
  void dispose() {
    _poidsController.dispose();
    _dosageKgController.dispose();
    super.dispose();
  }

  void _calculer() {
    final poids = double.tryParse(_poidsController.text);
    final dosageKg = double.tryParse(_dosageKgController.text);

    if (poids == null || dosageKg == null) {
      setState(
        () => _resultat = AppLocalizations.of(context).utilRemplirChamps,
      );
      return;
    }

    final calculator = AdvancedCalculatorService();
    final doseTotal = calculator.calculerDose(
      poidsKg: poids,
      dosageParKg: dosageKg,
    );
    setState(() => _resultat = '${doseTotal.toStringAsFixed(2)} ml');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPinkMaterial.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          color: AppTheme.accentPinkMaterial,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dosage médicament',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Calcul selon le poids',
                              style: AppTheme.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _poidsController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelPoidsLapinKg,
                      prefixIcon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageKgController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilDosageKg,
                      prefixIcon: Icons.medication_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: AppTheme.primaryButtonStyle,
                      child: Text(AppLocalizations.of(context).calculer),
                    ),
                  ),
                  if (_resultat.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPinkMaterial.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppTheme.accentPinkMaterial.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_rounded,
                            color: AppTheme.accentPinkMaterial,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dose à administrer',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppTheme.accentPinkMaterial,
                                  ),
                                ),
                                Text(
                                  _resultat,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: AppTheme.accentPinkMaterial,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// ONGLET ALIMENTATION
// ============================================
class _AlimentationTab extends StatefulWidget {
  const _AlimentationTab();

  @override
  State<_AlimentationTab> createState() => _AlimentationTabState();
}

class _AlimentationTabState extends State<_AlimentationTab> {
  final _poidsController = TextEditingController();
  String _statut = 'adulte';
  Map<String, String>? _resultat;

  @override
  void dispose() {
    _poidsController.dispose();
    super.dispose();
  }

  void _calculer() {
    final poids = double.tryParse(_poidsController.text);
    if (poids == null) {
      setState(() => _resultat = null);
      return;
    }

    final calculator = AdvancedCalculatorService();
    final ration = calculator.calculerRation(
      poidsKg: poids,
      statutPhysiologique: _statut,
    );

    setState(() {
      _resultat = ration.toMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rations alimentaires',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Besoins quotidiens',
                              style: AppTheme.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _poidsController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilPoidsLapin,
                      prefixIcon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _statut,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(
                        context,
                      ).utilStatutPhysiologique,
                      prefixIcon: Icons.category_rounded,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'lapereau',
                        child: Text(AppLocalizations.of(context).utilLapereau),
                      ),
                      DropdownMenuItem(
                        value: 'jeune',
                        child: Text(AppLocalizations.of(context).utilJeune),
                      ),
                      DropdownMenuItem(
                        value: 'adulte',
                        child: Text(AppLocalizations.of(context).utilAdulte),
                      ),
                      DropdownMenuItem(
                        value: 'gestante',
                        child: Text(AppLocalizations.of(context).utilGestante),
                      ),
                      DropdownMenuItem(
                        value: 'allaitante',
                        child: Text(
                          AppLocalizations.of(context).utilAllaitante,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _statut = value!);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: AppTheme.primaryButtonStyle,
                      child: Text(AppLocalizations.of(context).calculer),
                    ),
                  ),
                  if (_resultat != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ration quotidienne',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            Icons.grass_rounded,
                            'Granulés',
                            _resultat!['granules']!,
                          ),
                          _buildResultRow(
                            Icons.eco_rounded,
                            'Foin',
                            _resultat!['foin']!,
                          ),
                          _buildResultRow(
                            Icons.water_drop_rounded,
                            'Eau',
                            _resultat!['eau']!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: AppTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ============================================
// ONGLET PERFORMANCE
// ============================================
class _PerformanceTab extends StatefulWidget {
  const _PerformanceTab();

  @override
  State<_PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<_PerformanceTab> {
  final _poidsInitialController = TextEditingController();
  final _poidsFinalController = TextEditingController();
  final _joursController = TextEditingController();
  String _resultat = '';

  @override
  void dispose() {
    _poidsInitialController.dispose();
    _poidsFinalController.dispose();
    _joursController.dispose();
    super.dispose();
  }

  void _calculer() {
    final poidsInitial = double.tryParse(_poidsInitialController.text);
    final poidsFinal = double.tryParse(_poidsFinalController.text);
    final jours = int.tryParse(_joursController.text);

    if (poidsInitial == null ||
        poidsFinal == null ||
        jours == null ||
        jours == 0) {
      setState(() => _resultat = 'Veuillez remplir tous les champs');
      return;
    }

    final gmq = ((poidsFinal - poidsInitial) * 1000) / jours;
    setState(() => _resultat = '${gmq.toStringAsFixed(1)} g/jour');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrangeMaterial.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: AppTheme.accentOrangeMaterial,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gain Moyen Quotidien',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'GMQ - Croissance',
                              style: AppTheme.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _poidsInitialController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilPoidsInitial,
                      prefixIcon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _poidsFinalController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilPoidsFinal,
                      prefixIcon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _joursController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilNombreJours,
                      prefixIcon: Icons.calendar_today_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: AppTheme.primaryButtonStyle,
                      child: Text(AppLocalizations.of(context).calculerGmq),
                    ),
                  ),
                  if (_resultat.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrangeMaterial.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppTheme.accentOrangeMaterial.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            color: AppTheme.accentOrangeMaterial,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gain Moyen Quotidien',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppTheme.accentOrangeMaterial,
                                  ),
                                ),
                                Text(
                                  _resultat,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: AppTheme.accentOrangeMaterial,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// ONGLET DOSAGES AVANCÉS
// ============================================
class _DosagesAvancesTab extends StatefulWidget {
  const _DosagesAvancesTab();

  @override
  State<_DosagesAvancesTab> createState() => _DosagesAvancesTabState();
}

class _DosagesAvancesTabState extends State<_DosagesAvancesTab> {
  final _poidsController = TextEditingController();
  final _dosageKgController = TextEditingController();
  final _concentrationController = TextEditingController();
  String _mode = 'simple'; // 'simple', 'dilution', 'groupe'
  Map<String, String>? _resultat;

  @override
  void dispose() {
    _poidsController.dispose();
    _dosageKgController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  void _calculer() {
    final calculator = AdvancedCalculatorService();

    switch (_mode) {
      case 'simple':
        final poids = double.tryParse(_poidsController.text);
        final dosageKg = double.tryParse(_dosageKgController.text);

        if (poids == null || dosageKg == null) {
          setState(() => _resultat = null);
          return;
        }

        final dose = calculator.calculerDose(
          poidsKg: poids,
          dosageParKg: dosageKg,
        );

        setState(() {
          _resultat = {
            'type': 'Dose simple',
            'dose': '${dose.toStringAsFixed(2)} ml',
            'details': 'Pour un lapin de ${poids.toStringAsFixed(2)} kg',
          };
        });
        break;

      case 'dilution':
        final poids = double.tryParse(_poidsController.text);
        final dosageKg = double.tryParse(_dosageKgController.text);
        final concentration = double.tryParse(_concentrationController.text);

        if (poids == null || dosageKg == null || concentration == null) {
          setState(() => _resultat = null);
          return;
        }

        final volume = calculator.calculerDoseAvecDilution(
          poidsKg: poids,
          dosageParKg: dosageKg,
          concentrationMere: concentration,
        );

        setState(() {
          _resultat = {
            'type': 'Dose avec dilution',
            'dose': '${volume.toStringAsFixed(2)} ml',
            'concentration': '${concentration.toStringAsFixed(2)} mg/ml',
            'details': 'Volume à prélever du produit mère',
          };
        });
        break;

      case 'groupe':
        final poidsTotal = double.tryParse(_poidsController.text);
        final dosageKg = double.tryParse(_dosageKgController.text);

        if (poidsTotal == null || dosageKg == null) {
          setState(() => _resultat = null);
          return;
        }

        final dose = calculator.calculerDoseGroupe(
          poidsTotal: poidsTotal,
          dosageParKg: dosageKg,
        );

        setState(() {
          _resultat = {
            'type': 'Dose pour groupe',
            'dose': '${dose.toStringAsFixed(2)} ml',
            'details':
                'Pour un poids total de ${poidsTotal.toStringAsFixed(2)} kg',
          };
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurpleMaterial.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: AppTheme.accentPurpleMaterial,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calculs de dosages avancés',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Dilution, concentration, groupe',
                              style: AppTheme.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).utilModeCalcul,
                      prefixIcon: Icons.tune_rounded,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'simple',
                        child: Text(
                          AppLocalizations.of(context).utilDosageSimple,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'dilution',
                        child: Text(
                          AppLocalizations.of(context).utilDosageDilution,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'groupe',
                        child: Text(
                          AppLocalizations.of(context).utilDosageGroupe,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _mode = value!;
                        _resultat = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _poidsController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: _mode == 'groupe'
                          ? 'Poids total du groupe (kg)'
                          : 'Poids du lapin (kg)',
                      prefixIcon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageKgController,
                    keyboardType: TextInputType.number,
                    decoration: AppTheme.inputDecoration(
                      label: _mode == 'dilution'
                          ? 'Dosage (mg/kg)'
                          : 'Dosage (ml/kg)',
                      prefixIcon: Icons.medication_rounded,
                    ),
                  ),
                  if (_mode == 'dilution') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _concentrationController,
                      keyboardType: TextInputType.number,
                      decoration: AppTheme.inputDecoration(
                        label: AppLocalizations.of(
                          context,
                        ).utilConcentrationProduit,
                        prefixIcon: Icons.water_drop_rounded,
                        hint: 'Concentration du médicament non dilué',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: AppTheme.primaryButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          AppTheme.accentPurpleMaterial,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context).calculer),
                    ),
                  ),
                  if (_resultat != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurpleMaterial.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppTheme.accentPurpleMaterial.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resultat!['type']!,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPurpleMaterial,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.medication_rounded,
                                color: AppTheme.accentPurpleMaterial,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dose à administrer',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: AppTheme.accentPurpleMaterial,
                                      ),
                                    ),
                                    Text(
                                      _resultat!['dose']!,
                                      style: AppTheme.headingSmall.copyWith(
                                        color: AppTheme.accentPurpleMaterial,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_resultat!['concentration'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Concentration: ${_resultat!['concentration']}',
                              style: AppTheme.labelSmall,
                            ),
                          ],
                          if (_resultat!['details'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _resultat!['details']!,
                              style: AppTheme.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// ONGLET FINANCE
// ============================================
class _FinanceTab extends StatelessWidget {
  const _FinanceTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, child) {
        final lapinsActifs = lapinProvider.lapins
            .where((l) => l.statut != 'vendu' && l.statut != 'decede')
            .toList();

        final nombreLapins = lapinsActifs.length;
        final granulesJour = nombreLapins * 4 * 0.03 * 1000;
        final granulesMois = granulesJour * 30 / 1000;
        final foinJour = nombreLapins * 150;
        final foinMois = foinJour * 30 / 1000;

        final coutGranules = granulesMois * 0.6;
        final coutFoin = foinMois * 0.3;
        final coutTotal = coutGranules + coutFoin;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.euro_rounded,
                              color: AppTheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Besoins mensuels',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$nombreLapins lapin(s) actif(s)',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBesoinsRow(
                              context,
                              Icons.grass_rounded,
                              'Granulés',
                              '${granulesMois.toStringAsFixed(1)} kg',
                              '${coutGranules.toStringAsFixed(2)} €',
                              AppTheme.primary,
                            ),
                            const Divider(height: 24),
                            _buildBesoinsRow(
                              context,
                              Icons.eco_rounded,
                              'Foin',
                              '${foinMois.toStringAsFixed(1)} kg',
                              '${coutFoin.toStringAsFixed(2)} €',
                              AppTheme.accentOrangeMaterial,
                            ),
                            const Divider(height: 24),
                            _buildBesoinsRow(
                              context,
                              Icons.account_balance_rounded,
                              'Total mensuel',
                              '',
                              '${coutTotal.toStringAsFixed(2)} €',
                              AppTheme.accentBlue500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBesoinsRow(
    BuildContext context,
    IconData icon,
    String label,
    String quantity,
    String cost,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodyMedium),
              if (quantity.isNotEmpty)
                Text(
                  quantity,
                  style: AppTheme.labelSmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
        Text(
          cost,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
