import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../widgets/bunny_widgets.dart';
import '../../theme/app_theme.dart';
import 'fiche_sante_screen.dart';
import '../optimisation/protocoles_screen.dart';
import '../rentabilite/medicaments_screen.dart';
import '../rentabilite/quarantaine_screen.dart';

/// Écran de suivi sanitaire principal
class SanteScreen extends StatefulWidget {
  const SanteScreen({super.key});

  @override
  State<SanteScreen> createState() => _SanteScreenState();
}

class _SanteScreenState extends State<SanteScreen> {
  @override
  void initState() {
    super.initState();
    // Différer le chargement après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    await santeProvider.chargerTout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Santé'),
        actions: [
          Consumer<SanteProvider>(
            builder: (context, santeProvider, _) {
              return FutureBuilder(
                future: santeProvider.getSoinsAvecRappel(),
                builder: (context, snapshot) {
                  final hasRappels = snapshot.data?.isNotEmpty ?? false;
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: hasRappels,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () => _afficherRappels(),
                    tooltip: 'Rappels de soins',
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<LapinProvider>(
        builder: (context, lapinProvider, child) {
          if (lapinProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lapinProvider.lapins.isEmpty) {
            return const EmptyState(
              icon: Icons.health_and_safety_rounded,
              title: 'Aucun lapin à suivre',
              message:
                  'Ajoutez des lapins dans l\'onglet Cheptel pour démarrer le suivi sanitaire',
            );
          }

          return Column(
            children: [
              // Boutons rapides pour les 3 outils santé
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.medical_services_rounded,
                        label: 'Protocoles',
                        color: const Color(0xFF9C27B0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProtocolesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.medication_rounded,
                        label: 'Médicaments',
                        color: const Color(0xFFE91E63),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicamentsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.warning_rounded,
                        label: 'Quarantaine',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuarantaineScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des lapins
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _chargerDonnees,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    itemCount: lapinProvider.lapins.length,
                    itemBuilder: (context, index) {
                      final lapin = lapinProvider.lapins[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        child: _LapinSanteCard(
                          lapin: lapin,
                          onTap: () => _ouvrirFicheSante(lapin),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing12,
          horizontal: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirFicheSante(Lapin lapin) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FicheSanteScreen(lapin: lapin),
          ),
        )
        .then((_) => _chargerDonnees());
  }

  Future<void> _afficherRappels() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final rappels = await santeProvider.getSoinsAvecRappel();

    if (!mounted) return;

    if (rappels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucun rappel de soin en attente'),
          backgroundColor: AppTheme.success,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notification_important, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Rappels de soins (${rappels.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...rappels.map(
              (soin) => ListTile(
                leading: const Icon(Icons.medical_services),
                title: Text(soin.description),
                subtitle: Text(soin.type),
                trailing: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card affichant un lapin avec son état de santé
class _LapinSanteCard extends StatefulWidget {
  final Lapin lapin;
  final VoidCallback onTap;

  const _LapinSanteCard({required this.lapin, required this.onTap});

  @override
  State<_LapinSanteCard> createState() => _LapinSanteCardState();
}

class _LapinSanteCardState extends State<_LapinSanteCard> {
  int _nombrePesees = 0;
  int _nombreSoins = 0;

  @override
  void initState() {
    super.initState();
    // Différer le chargement après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerStatistiques();
    });
  }

  Future<void> _chargerStatistiques() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final pesees = await santeProvider.getPeseesByLapin(widget.lapin.id!);
    final soins = await santeProvider.getSoinsByLapin(widget.lapin.id!);

    if (mounted) {
      setState(() {
        _nombrePesees = pesees.length;
        _nombreSoins = soins.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: widget.lapin.sexe == 'Mâle'
                    ? Colors.blue.shade100
                    : Colors.pink.shade100,
                child: Icon(
                  widget.lapin.sexe == 'Mâle' ? Icons.male : Icons.female,
                  color: widget.lapin.sexe == 'Mâle'
                      ? Colors.blue
                      : Colors.pink,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lapin.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.lapin.race} • ${widget.lapin.ageFormate}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.monitor_weight,
                          '$_nombrePesees pesées',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.medical_services,
                          '$_nombreSoins soins',
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
