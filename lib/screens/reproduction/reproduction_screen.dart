import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/accouplement.dart';
import '../../models/lapin.dart';
import '../../providers/reproduction_provider.dart';
import '../../services/database_helper.dart';
import '../../widgets/bunny_widgets.dart';
import '../../theme/app_theme.dart';
import '../../utils/dialog_helper.dart';
import 'planifier_accouplement_screen.dart';
import 'enregistrer_portee_screen.dart';
import 'edit_accouplement_screen.dart';
import 'edit_portee_screen.dart';
import '../optimisation/palpation_screen.dart';
import '../optimisation/sevrage_screen.dart';
import '../optimisation/preparation_nid_screen.dart';

/// Écran de gestion de la reproduction
class ReproductionScreen extends StatefulWidget {
  const ReproductionScreen({super.key});

  @override
  State<ReproductionScreen> createState() => _ReproductionScreenState();
}

class _ReproductionScreenState extends State<ReproductionScreen> {
  @override
  void initState() {
    super.initState();
    // Différer le chargement après le build pour éviter setState pendant build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    final reproductionProvider = Provider.of<ReproductionProvider>(
      context,
      listen: false,
    );
    await reproductionProvider.chargerTout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Reproduction'),
        actions: [
          Consumer<ReproductionProvider>(
            builder: (context, reproProvider, _) {
              final enCours = reproProvider.accouplements
                  .where((a) => a.statut == 'en_cours')
                  .length;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacing16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      '$enCours',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReproductionProvider>(
        builder: (context, reproductionProvider, child) {
          if (reproductionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reproductionProvider.accouplements.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_rounded,
              title: 'Aucun accouplement',
              message:
                  'Planifiez votre premier accouplement pour démarrer la gestion de la reproduction',
              actionLabel: 'Planifier',
              onAction: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PlanifierAccouplementScreen(),
                      ),
                    )
                    .then((_) => _chargerDonnees());
              },
            );
          }

          return Column(
            children: [
              // Boutons rapides pour les 3 outils
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.pregnant_woman_rounded,
                        label: 'Palpation',
                        color: const Color(0xFFFF6B9D),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PalpationScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.grass_rounded,
                        label: 'Sevrage',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SevrageScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        icon: Icons.home_rounded,
                        label: 'Nid',
                        color: const Color(0xFF8D6E63),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PreparationNidScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des accouplements
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _chargerDonnees,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    itemCount: reproductionProvider.accouplements.length,
                    itemBuilder: (context, index) {
                      final accouplement =
                          reproductionProvider.accouplements[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        child: _AccouplementCard(
                          accouplement: accouplement,
                          onTap: () =>
                              _afficherDetailsAccouplement(accouplement),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const PlanifierAccouplementScreen(),
                ),
              )
              .then((_) => _chargerDonnees());
        },
        icon: const Icon(Icons.add),
        label: const Text('Planifier'),
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

  void _afficherDetailsAccouplement(Accouplement accouplement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DetailsAccouplementSheet(
        accouplement: accouplement,
        onRefresh: _chargerDonnees,
      ),
    );
  }
}

/// Card affichant un accouplement
class _AccouplementCard extends StatefulWidget {
  final Accouplement accouplement;
  final VoidCallback onTap;

  const _AccouplementCard({required this.accouplement, required this.onTap});

  @override
  State<_AccouplementCard> createState() => _AccouplementCardState();
}

class _AccouplementCardState extends State<_AccouplementCard> {
  Lapin? _male;
  Lapin? _femelle;

  @override
  void initState() {
    super.initState();
    _chargerLapins();
  }

  Future<void> _chargerLapins() async {
    final db = DatabaseHelper.instance;
    final male = await db.getLapinById(widget.accouplement.maleId);
    final femelle = await db.getLapinById(widget.accouplement.femelleId);
    if (mounted) {
      setState(() {
        _male = male;
        _femelle = femelle;
      });
    }
  }

  Color _getStatutColor() {
    switch (widget.accouplement.statut) {
      case 'en_attente':
        return Colors.orange;
      case 'confirme':
        return Colors.green;
      case 'echec':
        return Colors.red;
      case 'termine':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatutLibelle() {
    switch (widget.accouplement.statut) {
      case 'en_attente':
        return 'En attente';
      case 'confirme':
        return 'Confirmé';
      case 'echec':
        return 'Échec';
      case 'termine':
        return 'Terminé';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.male, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _male?.nom ?? 'Chargement...',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getStatutLibelle(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatutColor().withOpacity(0.2),
                    side: BorderSide(color: _getStatutColor()),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.female, size: 18, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text(_femelle?.nom ?? 'Chargement...'),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accouplement',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        dateFormat.format(widget.accouplement.dateAccouplement),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Mise bas prévue',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        dateFormat.format(
                          widget.accouplement.dateMiseBasPrevue,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.accouplement.statut == 'en_attente' &&
                  !widget.accouplement.estPasse)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '⏰ ${widget.accouplement.joursAvantMiseBas} jours restants',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
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

/// Bottom sheet avec les détails de l'accouplement
class _DetailsAccouplementSheet extends StatelessWidget {
  final Accouplement accouplement;
  final VoidCallback onRefresh;

  const _DetailsAccouplementSheet({
    required this.accouplement,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Poignée
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Détails de l\'accouplement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),

                    // Dates importantes
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date d\'accouplement',
                              dateFormat.format(accouplement.dateAccouplement),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.event_available,
                              'Mise bas prévue',
                              dateFormat.format(accouplement.dateMiseBasPrevue),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.healing,
                              'Date palpation',
                              dateFormat.format(accouplement.datePalpation),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.home,
                              'Préparation nid',
                              dateFormat.format(
                                accouplement.datePreparationNid,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    if (accouplement.notes != null &&
                        accouplement.notes!.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.notes, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(accouplement.notes!),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Actions
                    if (accouplement.statut == 'en_attente') ...[
                      FilledButton.icon(
                        onPressed: () async {
                          final reproductionProvider =
                              Provider.of<ReproductionProvider>(
                                context,
                                listen: false,
                              );
                          await reproductionProvider.confirmerAccouplement(
                            accouplement.id!,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onRefresh();
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmer (après palpation)'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final reproductionProvider =
                              Provider.of<ReproductionProvider>(
                                context,
                                listen: false,
                              );
                          await reproductionProvider.marquerEchec(
                            accouplement.id!,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onRefresh();
                          }
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Marquer comme échec'),
                      ),
                    ],

                    // Modifier l'accouplement (sauf si terminé)
                    if (accouplement.statut != 'termine') ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => EditAccouplementScreen(
                                    accouplement: accouplement,
                                  ),
                                ),
                              )
                              .then((modified) {
                                if (modified == true) {
                                  onRefresh();
                                }
                              });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier l\'accouplement'),
                      ),
                    ],

                    // Supprimer l'accouplement
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await DialogHelper.showConfirmation(
                          context: context,
                          title: 'Confirmer la suppression',
                          message:
                              'Êtes-vous sûr de vouloir supprimer cet accouplement ? Cette action est irréversible.',
                          confirmLabel: 'Supprimer',
                          isDangerous: true,
                        );

                        if (confirm == true && context.mounted) {
                          try {
                            final reproductionProvider =
                                Provider.of<ReproductionProvider>(
                                  context,
                                  listen: false,
                                );
                            await reproductionProvider.supprimerAccouplement(
                              accouplement.id!,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Accouplement supprimé'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              onRefresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur : $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Supprimer l\'accouplement',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),

                    if (accouplement.statut == 'confirme' ||
                        (accouplement.statut == 'en_attente' &&
                            accouplement.estPasse))
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => EnregistrerPorteeScreen(
                                    accouplement: accouplement,
                                  ),
                                ),
                              )
                              .then((_) => onRefresh());
                        },
                        icon: const Icon(Icons.baby_changing_station),
                        label: const Text('Enregistrer la portée'),
                      ),

                    if (accouplement.statut == 'termine')
                      FutureBuilder(
                        future: Provider.of<ReproductionProvider>(
                          context,
                          listen: false,
                        ).getPorteeByAccouplement(accouplement.id!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final portee = snapshot.data!;
                            return Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🐰 Portée enregistrée',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Nés: ${portee.nombreNes} | Vivants: ${portee.nombreVivants} | Morts: ${portee.nombreMorts}',
                                    ),
                                    Text(
                                      'Taux de survie: ${portee.tauxSurvie.toStringAsFixed(1)}%',
                                    ),
                                    Text(
                                      'Mise bas: ${dateFormat.format(portee.dateMiseBasReelle)}',
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditPorteeScreen(
                                                            portee: portee,
                                                          ),
                                                    ),
                                                  )
                                                  .then((modified) {
                                                    if (modified == true) {
                                                      onRefresh();
                                                    }
                                                  });
                                            },
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Modifier'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmer la suppression',
                                                  ),
                                                  content: const Text(
                                                    'Êtes-vous sûr de vouloir supprimer cette portée ? Cette action est irréversible.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Annuler',
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          FilledButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Supprimer',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true &&
                                                  context.mounted) {
                                                try {
                                                  final reproductionProvider =
                                                      Provider.of<
                                                        ReproductionProvider
                                                      >(context, listen: false);
                                                  await reproductionProvider
                                                      .supprimerPortee(
                                                        portee.id!,
                                                      );
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Portée supprimée',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                    onRefresh();
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Erreur : $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            label: const Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Colors.red,
                                              ),
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
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
