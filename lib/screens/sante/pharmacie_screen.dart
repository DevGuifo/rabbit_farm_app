import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medicament.dart';
import '../../models/enums/medicament_enums.dart';
import '../../providers/medicament_provider.dart';
import 'ajouter_medicament_screen.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';
import '../../core/constants/error_messages.dart';

/// Écran Pharmacie - Gestion intelligente des médicaments
/// Connexion avec Treatments & Care pour suivre les stocks
class PharmacieScreen extends StatefulWidget {
  const PharmacieScreen({super.key});

  @override
  State<PharmacieScreen> createState() => _PharmacieScreenState();
}

class _PharmacieScreenState extends State<PharmacieScreen> {
  String _selectedFilter = 'all'; // all, low_stock, vaccines, treatments
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    final medicamentProvider = Provider.of<MedicamentProvider>(
      context,
      listen: false,
    );
    await medicamentProvider.chargerMedicaments();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header fixe
          SliverToBoxAdapter(child: _buildHeader(isDark)),
          // Contenu scrollable
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.verticalSpace16,
                  _buildStatsCards(isDark),
                  AppTheme.verticalSpace16,
                  _buildSearchBar(isDark),
                  AppTheme.verticalSpace12,
                  _buildFilterChips(isDark),
                  AppTheme.verticalSpace24,
                  _buildLowStockAlert(isDark),
                  AppTheme.verticalSpace16,
                  _buildMedicamentsList(isDark),
                  AppTheme.verticalSpace32,
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // Header
  Widget _buildHeader(bool isDark) {
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                .withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: textPrimary, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.medication, color: AppTheme.info, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).santePharmacie,
                  style: AppTheme.titleLarge.copyWith(color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.sync, color: textPrimary, size: 22),
                onPressed: _chargerDonnees,
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: textPrimary,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertesScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: textPrimary,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ParametresScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stats Cards
  Widget _buildStatsCards(bool isDark) {
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;

    return Consumer<MedicamentProvider>(
      builder: (context, medicamentProvider, _) {
        final medicaments = medicamentProvider.medicaments;
        final totalItems = medicaments.length;
        final lowStockItems = medicaments
            .where((m) => m.quantiteStock < 10)
            .length;
        final totalValue = medicaments.fold<double>(
          0,
          (sum, m) => sum + ((m.prixUnitaire ?? 0) * m.quantiteStock),
        );

        return Padding(
          padding: AppTheme.paddingHorizontal,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.medication_liquid,
                  iconColor: AppTheme.info,
                  label: AppLocalizations.of(context).labelTotal,
                  value: totalItems.toString(),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              AppTheme.horizontalSpace12,
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.warning_outlined,
                  iconColor: AppTheme.warning,
                  label: AppLocalizations.of(
                    context,
                  ).santeStockBas.toUpperCase(),
                  value: lowStockItems.toString(),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isWarning: lowStockItems > 0,
                ),
              ),
              AppTheme.horizontalSpace12,
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.attach_money,
                  iconColor: AppTheme.accentTeal,
                  label: AppLocalizations.of(context).labelValue,
                  value: '${totalValue.toStringAsFixed(0)} €',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isSmallText: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
    bool isWarning = false,
    bool isSmallText = false,
  }) {
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isWarning
              ? AppTheme.warning.withValues(alpha: 0.3)
              : (isDark ? AppTheme.neutral700 : AppTheme.neutral200).withValues(
                  alpha: 0.5,
                ),
        ),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: (isSmallText ? AppTheme.bodyLarge : AppTheme.titleLarge)
                .copyWith(fontWeight: FontWeight.bold, color: textPrimary),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(bool isDark) {
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow(isDark: isDark),
        ),
        child: TextField(
          controller: _searchController,
          style: AppTheme.bodyLarge.copyWith(color: textPrimary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintRechercherMedicament,
            hintStyle: AppTheme.bodyMedium.copyWith(color: textSecondary),
            prefixIcon: Icon(Icons.search, color: textSecondary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  // Filter Chips
  Widget _buildFilterChips(bool isDark) {
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;

    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Wrap(
        spacing: AppTheme.spacing8,
        runSpacing: AppTheme.spacing8,
        children: [
          _buildFilterChip(
            l10n.filtreTous,
            'all',
            isDark,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            l10n.filtreStockBas,
            'low_stock',
            isDark,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            l10n.filtreVaccins,
            'vaccines',
            isDark,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            l10n.filtreTraitements,
            'treatments',
            isDark,
            textPrimary,
            textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = _selectedFilter == value;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.info.withValues(alpha: 0.15)
              : surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isSelected
                ? AppTheme.info
                : (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                      .withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.info : textSecondary,
          ),
        ),
      ),
    );
  }

  // Low Stock Alert Banner
  Widget _buildLowStockAlert(bool isDark) {
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;

    return Consumer<MedicamentProvider>(
      builder: (context, medicamentProvider, _) {
        final lowStockCount = medicamentProvider.medicaments
            .where((m) => m.quantiteStock < 10)
            .length;

        if (lowStockCount == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warning.withValues(alpha: 0.15),
                  AppTheme.accentOrange.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: AppTheme.warning,
                    size: 24,
                  ),
                ),
                AppTheme.horizontalSpace16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerte Stock',
                        style: AppTheme.titleSmall.copyWith(color: textPrimary),
                      ),
                      Text(
                        '$lowStockCount médicament(s) en rupture de stock',
                        style: AppTheme.bodySmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.warning),
              ],
            ),
          ),
        );
      },
    );
  }

  // Medicaments List
  Widget _buildMedicamentsList(bool isDark) {
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;

    return Consumer<MedicamentProvider>(
      builder: (context, medicamentProvider, _) {
        var medicaments = medicamentProvider.medicaments;

        // Apply search filter
        if (_searchController.text.isNotEmpty) {
          medicaments = medicaments
              .where(
                (m) =>
                    m.nom.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ||
                    m.type.label.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
              )
              .toList();
        }

        // Apply category filter
        if (_selectedFilter == 'low_stock') {
          medicaments = medicaments.where((m) => m.quantiteStock < 10).toList();
        } else if (_selectedFilter == 'vaccines') {
          medicaments = medicaments
              .where((m) => m.type == TypeMedicament.vaccin)
              .toList();
        } else if (_selectedFilter == 'treatments') {
          medicaments = medicaments
              .where(
                (m) =>
                    m.type == TypeMedicament.antibiotique ||
                    m.type == TypeMedicament.antiparasitaire,
              )
              .toList();
        }

        if (medicaments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun médicament',
                    style: AppTheme.bodyLarge.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventaire (${medicaments.length})',
                style: AppTheme.titleMedium.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppTheme.spacing16),
              ...medicaments.map((medicament) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: _buildMedicamentCard(
                    isDark,
                    textPrimary,
                    textSecondary,
                    medicament,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicamentCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Medicament medicament,
  ) {
    final isLowStock = medicament.quantiteStock < 10;
    final stockColor = isLowStock ? AppTheme.warning : AppTheme.accentTeal;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return GestureDetector(
      onTap: () => _afficherDetailsMedicament(medicament),
      onLongPress: () => _afficherMenuContextuel(context, medicament),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isLowStock
                ? AppTheme.warning.withValues(alpha: 0.3)
                : (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                      .withValues(alpha: 0.5),
          ),
          boxShadow: AppTheme.cardShadow(isDark: isDark),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                medicament.type == TypeMedicament.vaccin
                    ? Icons.vaccines
                    : Icons.medication_liquid,
                color: AppTheme.info,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicament.nom,
                    style: AppTheme.titleSmall.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicament.type.label,
                    style: AppTheme.bodySmall.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLowStock
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                              size: 14,
                              color: stockColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${medicament.quantiteStock}',
                              style: AppTheme.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: stockColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        '${(medicament.prixUnitaire ?? 0).toStringAsFixed(2)} €',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // Actions
  void _afficherDetailsMedicament(Medicament medicament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterMedicamentScreen(medicament: medicament),
      ),
    ).then((_) {
      if (!mounted) return;
      _chargerDonnees();
    });
  }

  void _afficherMenuContextuel(BuildContext context, Medicament medicament) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
        final textPrimary = isDark ? AppTheme.border : AppTheme.textPrimary;

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.info),
                  title: Text(
                    AppLocalizations.of(context).actionModifier,
                    style: TextStyle(color: textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _afficherDetailsMedicament(medicament);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.error),
                  title: Text(
                    AppLocalizations.of(context).actionSupprimer,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmerSuppression(medicament);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmerSuppression(Medicament medicament) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.confirmerSuppression,
      message: '${l10n.actionSupprimer} "${medicament.nom}" ?',
      confirmText: l10n.actionSupprimer,
      cancelText: l10n.actionAnnuler,
      isDestructive: true,
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        final provider = Provider.of<MedicamentProvider>(
          context,
          listen: false,
        );
        await provider.supprimerMedicament(medicament.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).santeMedicamentSupprime,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.genericError),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  // FAB standardisé
  Widget _buildFAB() {
    return UnifiedFAB.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AjouterMedicamentScreen()),
        ).then((_) {
          if (!mounted) return;
          _chargerDonnees();
        });
      },
      icon: Icons.add,
      label: AppLocalizations.of(context).ajouter,
      tooltip: AppLocalizations.of(context).ajouter,
    );
  }
}
