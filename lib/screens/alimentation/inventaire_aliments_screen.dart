import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/aliment.dart';
import '../../providers/alimentation_provider.dart';
import 'ajouter_aliment_screen.dart';
import 'distribuer_aliment_screen.dart';

/// Écran d'inventaire des aliments
class InventaireAlimentsScreen extends StatefulWidget {
  const InventaireAlimentsScreen({super.key});

  @override
  State<InventaireAlimentsScreen> createState() =>
      _InventaireAlimentsScreenState();
}

class _InventaireAlimentsScreenState extends State<InventaireAlimentsScreen> {
  String _filtreType = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlimentationProvider>().loadAliments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaire Alimentation'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjouterAlimentScreen(),
                ),
              );
              if (result == true && mounted) {
                context.read<AlimentationProvider>().loadAliments();
              }
            },
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Filtres par type
          _buildFiltres(theme),

          // Statistiques
          _buildStatistiques(theme),

          // Liste des aliments
          Expanded(
            child: Consumer<AlimentationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final aliments = _filtreType == 'Tous'
                    ? provider.alimentsEnStock
                    : provider
                          .getAlimentsByType(_filtreType)
                          .where((a) => a.quantiteRestante > 0)
                          .toList();

                if (aliments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun aliment en stock',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: aliments.length,
                  itemBuilder: (context, index) {
                    return _buildAlimentCard(aliments[index], theme, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltres(ThemeData theme) {
    final types = ['Tous', ...TypeAliment.values];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _filtreType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type == 'Tous' ? type : TypeAliment.getLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filtreType = type;
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: const Color(0xFF4CAF50),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistiques(ThemeData theme) {
    return Consumer<AlimentationProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<double>(
          future: provider.getValeurStock(),
          builder: (context, snapshot) {
            final valeurStock = snapshot.data ?? 0.0;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '📦',
                    '${provider.alimentsEnStock.length}',
                    'En stock',
                    theme,
                  ),
                  _buildStatItem(
                    '💰',
                    '${valeurStock.toStringAsFixed(0)} €',
                    'Valeur',
                    theme,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(
    String icon,
    String value,
    String label,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAlimentCard(
    Aliment aliment,
    ThemeData theme,
    AlimentationProvider provider,
  ) {
    final pourcentageStock =
        (aliment.quantiteRestante / aliment.quantiteAchetee * 100).clamp(
          0,
          100,
        );

    Color stockColor;
    if (pourcentageStock < 20) {
      stockColor = Colors.red;
    } else if (pourcentageStock < 50) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DistribuerAlimentScreen(aliment: aliment),
            ),
          );
          if (mounted) {
            provider.loadAliments();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grass,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aliment.nom,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          TypeAliment.getLabel(aliment.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${aliment.quantiteRestante.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Jauge de stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${pourcentageStock.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: stockColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pourcentageStock / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Informations supplémentaires
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.shopping_cart,
                      '${aliment.prixUnitaire.toStringAsFixed(2)} €/kg',
                      theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (aliment.datePeremption != null)
                    Expanded(
                      child: _buildInfoChip(
                        Icons.calendar_today,
                        '${aliment.datePeremption!.day}/${aliment.datePeremption!.month}/${aliment.datePeremption!.year}',
                        theme,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
