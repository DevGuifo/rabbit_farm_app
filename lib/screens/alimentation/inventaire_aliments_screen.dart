import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/aliment.dart';
import '../../providers/alimentation_provider.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlimentationProvider>().loadAliments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Header - Utilise StandardHeader unifié
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).alimentationTitre,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        if (!mounted) return;
        context.read<AlimentationProvider>().loadAliments();
      },
      onNotifications: null,
      onSettings: null,
    );
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
          // Header Standard - Utilise StandardHeader unifié
          _buildHeader(isDark),

          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            isDark: isDark,
            hintText: AppLocalizations.of(context).alimentationRechercher,
          ),

          // Filtres par type
          _buildFiltres(isDark),

          // Statistiques
          _buildStatistiques(isDark),

          // Liste des aliments
          Expanded(
            child: Consumer<AlimentationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtrer par type
                var aliments = _filtreType.isEmpty
                    ? provider.alimentsEnStock
                    : provider
                          .getAlimentsByType(_filtreType)
                          .where((a) => a.quantiteRestante > 0)
                          .toList();

                // Filtrer par recherche
                if (_searchQuery.isNotEmpty) {
                  aliments = aliments.where((a) {
                    return a.nom.toLowerCase().contains(_searchQuery) ||
                        TypeAliment.getLabel(
                          a.type,
                        ).toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (aliments.isEmpty) {
                  return EmptyState(
                    isDark: isDark,
                    icon: Icons.inventory_2_outlined,
                    title: _searchQuery.isNotEmpty
                        ? AppLocalizations.of(context).alimentationAucunResultat
                        : AppLocalizations.of(context).alimentationAucunAliment,
                    subtitle: _searchQuery.isNotEmpty
                        ? AppLocalizations.of(
                            context,
                          ).alimentationAutreRecherche
                        : AppLocalizations.of(
                            context,
                          ).alimentationAjouterPremier,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  itemCount: aliments.length,
                  itemBuilder: (context, index) {
                    return _buildAlimentCard(aliments[index], isDark, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_aliment',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AjouterAlimentScreen(),
            ),
          );
          if (!context.mounted) return;
          if (result == true) {
            context.read<AlimentationProvider>().loadAliments();
          }
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltres(bool isDark) {
    final allLabel = AppLocalizations.of(context).alimentationTous;
    final types = [allLabel, ...TypeAliment.values];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final allLabel = AppLocalizations.of(context).alimentationTous;
          final isSelected = _filtreType == type;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing8),
            child: FilterPill(
              label: type == allLabel ? type : TypeAliment.getLabel(type),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _filtreType = type;
                });
              },
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistiques(bool isDark) {
    return Consumer<AlimentationProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<double>(
          future: provider.getValeurStock(),
          builder: (context, snapshot) {
            final valeurStock = snapshot.data ?? 0.0;

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
                      label: AppLocalizations.of(context).alimentationEnStock,
                      value: '${provider.alimentsEnStock.length}',
                      icon: Icons.inventory_2,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: StatsCard(
                      isDark: isDark,
                      label: AppLocalizations.of(context).alimentationValeur,
                      value: '${valeurStock.toStringAsFixed(0)} €',
                      icon: Icons.euro,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlimentCard(
    Aliment aliment,
    bool isDark,
    AlimentationProvider provider,
  ) {
    final pourcentageStock =
        (aliment.quantiteRestante / aliment.quantiteAchetee * 100).clamp(
          0,
          100,
        );

    Color stockColor;
    if (pourcentageStock < 20) {
      stockColor = AppTheme.error;
    } else if (pourcentageStock < 50) {
      stockColor = AppTheme.warning;
    } else {
      stockColor = AppTheme.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: AppTheme.cardDecoration(isDark: isDark),
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.grass,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aliment.nom,
                          style: AppTheme.titleSmall.copyWith(
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          TypeAliment.getLabel(aliment.type),
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.textLight.withValues(alpha: 0.7)
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Text(
                      '${aliment.quantiteRestante.toStringAsFixed(1)} kg',
                      style: AppTheme.bodyLarge.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Jauge de stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).alimentationStock,
                        style: AppTheme.caption.copyWith(
                          color: isDark
                              ? AppTheme.textLight.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${pourcentageStock.toStringAsFixed(0)}%',
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: stockColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: LinearProgressIndicator(
                      value: pourcentageStock / 100,
                      backgroundColor:
                          (isDark
                                  ? AppTheme.textOnPrimary
                                  : AppTheme.textPrimary)
                              .withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Informations supplémentaires
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.shopping_cart,
                      '${aliment.prixUnitaire.toStringAsFixed(2)} €/kg',
                      isDark,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  if (aliment.datePeremption != null)
                    Expanded(
                      child: _buildInfoChip(
                        Icons.calendar_today,
                        '${aliment.datePeremption!.day}/${aliment.datePeremption!.month}/${aliment.datePeremption!.year}',
                        isDark,
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

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.textOnPrimary : AppTheme.textPrimary)
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark
                ? AppTheme.textLight.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: AppTheme.caption.copyWith(
                color: isDark
                    ? AppTheme.textLight.withValues(alpha: 0.7)
                    : AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
