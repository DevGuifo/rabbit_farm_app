import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/lapin_provider.dart';
import '../../theme/app_theme.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        title: const Text('Calculatrice'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.medical_services_rounded), text: 'Santé'),
            Tab(icon: Icon(Icons.restaurant_rounded), text: 'Alimentation'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Performance'),
            Tab(icon: Icon(Icons.euro_rounded), text: 'Finance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SanteTab(),
          _AlimentationTab(),
          _PerformanceTab(),
          _FinanceTab(),
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
      setState(() => _resultat = 'Veuillez remplir tous les champs');
      return;
    }

    final doseTotal = poids * dosageKg;
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
                          color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          color: Color(0xFFE91E63),
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
                    decoration: const InputDecoration(
                      labelText: 'Poids du lapin (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageKgController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Dosage (ml/kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calculer'),
                    ),
                  ),
                  if (_resultat.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_rounded,
                            color: Color(0xFFE91E63),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dose à administrer',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: const Color(0xFFE91E63),
                                  ),
                                ),
                                Text(
                                  _resultat,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: const Color(0xFFE91E63),
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

    double gramulePourcentage;
    double foinMin;
    double foinMax;
    double eau;

    switch (_statut) {
      case 'lapereau':
        gramulePourcentage = 0.08;
        foinMin = 50;
        foinMax = 80;
        eau = poids * 120;
        break;
      case 'jeune':
        gramulePourcentage = 0.05;
        foinMin = 80;
        foinMax = 120;
        eau = poids * 100;
        break;
      case 'gestante':
        gramulePourcentage = 0.06;
        foinMin = 100;
        foinMax = 150;
        eau = poids * 150;
        break;
      case 'allaitante':
        gramulePourcentage = 0.08;
        foinMin = 150;
        foinMax = 200;
        eau = poids * 200;
        break;
      default:
        gramulePourcentage = 0.03;
        foinMin = 100;
        foinMax = 150;
        eau = poids * 100;
    }

    final granule = poids * 1000 * gramulePourcentage;

    setState(() {
      _resultat = {
        'granules': '${granule.toStringAsFixed(0)} g',
        'foin': '$foinMin-$foinMax g',
        'eau': '${eau.toStringAsFixed(0)} ml',
      };
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
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Color(0xFF4CAF50),
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
                    decoration: const InputDecoration(
                      labelText: 'Poids du lapin (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue:  _statut,
                    decoration: const InputDecoration(
                      labelText: 'Statut physiologique',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'lapereau',
                        child: Text('Lapereau (0-8 sem)'),
                      ),
                      DropdownMenuItem(
                        value: 'jeune',
                        child: Text('Jeune (8 sem - 5 mois)'),
                      ),
                      DropdownMenuItem(
                        value: 'adulte',
                        child: Text('Adulte (entretien)'),
                      ),
                      DropdownMenuItem(
                        value: 'gestante',
                        child: Text('Gestante'),
                      ),
                      DropdownMenuItem(
                        value: 'allaitante',
                        child: Text('Allaitante'),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calculer'),
                    ),
                  ),
                  if (_resultat != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ration quotidienne',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
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
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
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
                          color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFFFF9800),
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
                    decoration: const InputDecoration(
                      labelText: 'Poids initial (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _poidsFinalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Poids final (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _joursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de jours',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calculer GMQ'),
                    ),
                  ),
                  if (_resultat.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gain Moyen Quotidien',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                                Text(
                                  _resultat,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: const Color(0xFFFF9800),
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
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.euro_rounded,
                              color: Color(0xFF4CAF50),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
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
                              const Color(0xFF4CAF50),
                            ),
                            const Divider(height: 24),
                            _buildBesoinsRow(
                              context,
                              Icons.eco_rounded,
                              'Foin',
                              '${foinMois.toStringAsFixed(1)} kg',
                              '${coutFoin.toStringAsFixed(2)} €',
                              const Color(0xFFFF9800),
                            ),
                            const Divider(height: 24),
                            _buildBesoinsRow(
                              context,
                              Icons.account_balance_rounded,
                              'Total mensuel',
                              '',
                              '${coutTotal.toStringAsFixed(2)} €',
                              const Color(0xFF2196F3),
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
