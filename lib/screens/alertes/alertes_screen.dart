import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alerte.dart';
import '../../providers/alerte_provider.dart';

/// Écran d'affichage des alertes
class AlertesScreen extends StatefulWidget {
  const AlertesScreen({super.key});

  @override
  State<AlertesScreen> createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  String _filtrePriorite = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerAlertes();
    });
  }

  Future<void> _chargerAlertes() async {
    final alerteProvider = context.read<AlerteProvider>();
    await alerteProvider.scannerAlertes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerAlertes,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Filtres par priorité
          _buildFiltres(theme),

          // Statistiques
          _buildStatistiques(theme),

          // Liste des alertes
          Expanded(
            child: Consumer<AlerteProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Alerte> alertes;
                if (_filtrePriorite == 'Tous') {
                  alertes = provider.alertes;
                } else {
                  final priorite = PrioriteAlerte.values.firstWhere(
                    (p) => p.label == _filtrePriorite,
                  );
                  alertes = provider.getAlertesByPriorite(priorite);
                }

                if (alertes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune alerte',
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
                  itemCount: alertes.length,
                  itemBuilder: (context, index) {
                    return _buildAlerteCard(alertes[index], theme, provider);
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
    final filtres = ['Tous', ...PrioriteAlerte.values.map((p) => p.label)];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtres.length,
        itemBuilder: (context, index) {
          final filtre = filtres[index];
          final isSelected = _filtrePriorite == filtre;

          Color chipColor;
          if (filtre == 'Urgent') {
            chipColor = const Color(0xFFF44336);
          } else if (filtre == 'Important') {
            chipColor = const Color(0xFFFF9800);
          } else if (filtre == 'Normal') {
            chipColor = const Color(0xFF00BCD4);
          } else {
            chipColor = const Color(0xFF4CAF50);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filtre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filtrePriorite = filtre;
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: chipColor,
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
    return Consumer<AlerteProvider>(
      builder: (context, provider, child) {
        final urgentes = provider
            .getAlertesByPriorite(PrioriteAlerte.urgent)
            .length;
        final importantes = provider
            .getAlertesByPriorite(PrioriteAlerte.important)
            .length;
        final normales = provider
            .getAlertesByPriorite(PrioriteAlerte.normal)
            .length;

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
                '🚨',
                '$urgentes',
                'Urgent',
                const Color(0xFFF44336),
                theme,
              ),
              _buildStatItem(
                '⚠️',
                '$importantes',
                'Important',
                const Color(0xFFFF9800),
                theme,
              ),
              _buildStatItem(
                'ℹ️',
                '$normales',
                'Normal',
                const Color(0xFF00BCD4),
                theme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String icon,
    String value,
    String label,
    Color color,
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
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAlerteCard(
    Alerte alerte,
    ThemeData theme,
    AlerteProvider provider,
  ) {
    final prioriteColor = _getPrioriteColor(alerte.priorite);

    return Dismissible(
      key: Key(alerte.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.supprimerAlerte(alerte.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            provider.marquerCommeLue(alerte.id);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: alerte.estLue
                    ? Colors.transparent
                    : prioriteColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    children: [
                      // Badge priorité
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: prioriteColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alerte.priorite.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Icône type
                      Text(
                        alerte.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      // Titre
                      Expanded(
                        child: Text(
                          alerte.titre,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Indicateur non lu
                      if (!alerte.estLue)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: prioriteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    alerte.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  // Lapin concerné
                  if (alerte.lapinNom != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.pets,
                          size: 14,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alerte.lapinNom!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Action suggérée
                  if (alerte.action != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: prioriteColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: prioriteColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alerte.action!,
                              style: TextStyle(
                                fontSize: 12,
                                color: prioriteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Date
                  const SizedBox(height: 8),
                  Text(
                    '${alerte.dateCreation.day}/${alerte.dateCreation.month}/${alerte.dateCreation.year} à ${alerte.dateCreation.hour}:${alerte.dateCreation.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPrioriteColor(PrioriteAlerte priorite) {
    switch (priorite) {
      case PrioriteAlerte.urgent:
        return const Color(0xFFF44336);
      case PrioriteAlerte.important:
        return const Color(0xFFFF9800);
      case PrioriteAlerte.normal:
        return const Color(0xFF00BCD4);
    }
  }
}
