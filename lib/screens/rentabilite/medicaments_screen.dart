import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'widgets/medicaments_alert_banner.dart';
import 'widgets/medicament_list_item.dart';
import 'widgets/medicament_dialogs.dart';

class MedicamentsScreen extends StatefulWidget {
  const MedicamentsScreen({super.key});

  @override
  State<MedicamentsScreen> createState() => _MedicamentsScreenState();
}

class _MedicamentsScreenState extends State<MedicamentsScreen> {
  String _filtreType = 'tous';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicamentProvider>().chargerMedicaments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header Standard
          StandardHeader(title: 'Pharmacie', isDark: isDark),

          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            isDark: isDark,
            hintText: 'Rechercher un médicament...',
          ),

          // Filtres
          _buildFiltres(isDark),

          Consumer<MedicamentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Filtrer les médicaments par type
              var medicamentsFiltres = _filtreType == 'tous'
                  ? provider.medicaments
                  : provider.medicaments
                        .where((m) => m.type == _filtreType)
                        .toList();

              // Filtrer par recherche
              if (_searchQuery.isNotEmpty) {
                medicamentsFiltres = medicamentsFiltres.where((m) {
                  return m.nom.toLowerCase().contains(_searchQuery) ||
                      m.type.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              // Alertes
              final alertes = provider.medicamentsEnAlerte;

              return Column(
                children: [
                  if (alertes.isNotEmpty)
                    MedicamentsAlertBanner(alertCount: alertes.length),
                  _buildStats(provider, isDark),
                  Expanded(
                    child: medicamentsFiltres.isEmpty
                        ? EmptyState(
                            isDark: isDark,
                            icon: Icons.medication_outlined,
                            title: _searchQuery.isNotEmpty
                                ? 'Aucun résultat'
                                : 'Aucun médicament',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'Essayez une autre recherche'
                                : 'Ajoutez votre premier médicament',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            itemCount: medicamentsFiltres.length,
                            itemBuilder: (context, index) {
                              final medicament = medicamentsFiltres[index];
                              return MedicamentListItem(
                                medicament: medicament,
                                onActionSelected: (action) async {
                                  switch (action) {
                                    case 'utiliser':
                                      await MedicamentDialogs.showUtiliserDialog(
                                        context,
                                        medicament,
                                      );
                                      break;
                                    case 'reapprovisionner':
                                      await MedicamentDialogs.showReapprovisionnerDialog(
                                        context,
                                        medicament,
                                      );
                                      break;
                                    case 'modifier':
                                      await MedicamentDialogs.showModifierMedicamentDialog(
                                        context,
                                        medicament,
                                      );
                                      break;
                                    case 'supprimer':
                                      await MedicamentDialogs.confirmerSuppression(
                                        context,
                                        medicament,
                                      );
                                      break;
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MedicamentDialogs.showAjouterMedicamentDialog(context),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltres(bool isDark) {
    final types = [
      {'value': 'tous', 'label': 'Tous'},
      {'value': 'antibiotique', 'label': 'Antibiotiques'},
      {'value': 'antiparasitaire', 'label': 'Antiparasitaires'},
      {'value': 'vaccin', 'label': 'Vaccins'},
      {'value': 'autre', 'label': 'Autres'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _filtreType == type['value'];

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing8),
            child: FilterPill(
              label: type['label']!,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _filtreType = type['value']!;
                });
              },
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(MedicamentProvider provider, bool isDark) {
    final valeurStock = provider.getValeurStockTotal();
    final alertes = provider.medicamentsEnAlerte.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              isDark: isDark,
              label: 'Stock total',
              value: '${provider.medicaments.length}',
              icon: Icons.inventory_2,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: StatsCard(
              isDark: isDark,
              label: 'Valeur',
              value: '${valeurStock.toStringAsFixed(0)}€',
              icon: Icons.euro,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: StatsCard(
              isDark: isDark,
              label: 'Alertes',
              value: '$alertes',
              icon: Icons.warning,
              color: alertes > 0 ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
