import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicament.dart';
import '../../providers/medicament_provider.dart';
import 'ajouter_medicament_screen.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../alertes/alertes_screen.dart';
import '../parametres/parametres_screen.dart';

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

    // Stitch Colors - Blue/Teal Theme for Pharmacy
    final primaryColor = AppTheme.info; // Blue
    final accentColor = AppTheme.accentTeal; // Teal
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.border : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.border : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(
            isDark,
            surfaceColor,
            primaryColor,
            textPrimary,
            textSecondary,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildStatsCards(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    accentColor,
                    textPrimary,
                    textSecondary,
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    textPrimary,
                    textSecondary,
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    textPrimary,
                    textSecondary,
                  ),
                  const SizedBox(height: 24),
                  _buildLowStockAlert(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    textPrimary,
                    textSecondary,
                  ),
                  const SizedBox(height: 16),
                  _buildMedicamentsList(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    accentColor,
                    textPrimary,
                    textSecondary,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(primaryColor),
    );
  }

  // Header
  Widget _buildHeader(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor(isDark).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
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
              Icon(Icons.medication, color: primaryColor, size: 28),
              const SizedBox(width: 8),
              Text(
                'Pharmacie',
                style: AppTheme.titleLarge.copyWith(color: textPrimary),
              ),
              const Spacer(),
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
  Widget _buildStatsCards(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color accentColor,
    Color textPrimary,
    Color textSecondary,
  ) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  icon: Icons.medication_liquid,
                  iconColor: primaryColor,
                  label: 'TOTAL',
                  value: totalItems.toString(),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  icon: Icons.warning_outlined,
                  iconColor: AppTheme.warning,
                  label: 'LOW STOCK',
                  value: lowStockItems.toString(),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isWarning: lowStockItems > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  icon: Icons.attach_money,
                  iconColor: accentColor,
                  label: 'VALUE',
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
    required Color surfaceColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
    bool isWarning = false,
    bool isSmallText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? AppTheme.warning.withValues(alpha: 0.3)
              : isDark
              ? AppTheme.cardLight.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
  Widget _buildSearchBar(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: AppTheme.bodyLarge.copyWith(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Rechercher un médicament...',
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
  Widget _buildFilterChips(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            'Tous',
            'all',
            isDark,
            surfaceColor,
            primaryColor,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            'Stock bas',
            'low_stock',
            isDark,
            surfaceColor,
            primaryColor,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            'Vaccins',
            'vaccines',
            isDark,
            surfaceColor,
            primaryColor,
            textPrimary,
            textSecondary,
          ),
          _buildFilterChip(
            'Traitements',
            'treatments',
            isDark,
            surfaceColor,
            primaryColor,
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
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark
                      ? AppTheme.cardLight.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? primaryColor : textSecondary,
          ),
        ),
      ),
    );
  }

  // Low Stock Alert Banner
  Widget _buildLowStockAlert(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Consumer<MedicamentProvider>(
      builder: (context, medicamentProvider, _) {
        final lowStockCount = medicamentProvider.medicaments
            .where((m) => m.quantiteStock < 10)
            .length;

        if (lowStockCount == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warning.withValues(alpha: 0.15),
                  Colors.deepOrange.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
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
                const SizedBox(width: 16),
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
  Widget _buildMedicamentsList(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color accentColor,
    Color textPrimary,
    Color textSecondary,
  ) {
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
                    m.type.toLowerCase().contains(
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
              .where((m) => m.type.toLowerCase().contains('vaccin'))
              .toList();
        } else if (_selectedFilter == 'treatments') {
          medicaments = medicaments
              .where(
                (m) =>
                    m.type.toLowerCase().contains('traitement') ||
                    m.type.toLowerCase().contains('antibio'),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventaire (${medicaments.length})',
                style: AppTheme.titleMedium.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 16),
              ...medicaments.map((medicament) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMedicamentCard(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    accentColor,
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
    Color surfaceColor,
    Color primaryColor,
    Color accentColor,
    Color textPrimary,
    Color textSecondary,
    Medicament medicament,
  ) {
    final isLowStock = medicament.quantiteStock < 10;
    final stockColor = isLowStock ? AppTheme.warning : accentColor;

    return GestureDetector(
      onTap: () => _afficherDetailsMedicament(medicament),
      onLongPress: () => _afficherMenuContextuel(context, medicament),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLowStock
                ? AppTheme.warning.withValues(alpha: 0.3)
                : isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                medicament.type.toLowerCase().contains('vaccin')
                    ? Icons.vaccines
                    : Icons.medication_liquid,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
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
                    medicament.type,
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                      const SizedBox(width: 8),
                      Text(
                        '${(medicament.prixUnitaire ?? 0).toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 13,
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
                  title: Text('Modifier', style: TextStyle(color: textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    _afficherDetailsMedicament(medicament);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.error),
                  title: const Text(
                    'Supprimer',
                    style: TextStyle(color: AppTheme.error),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${medicament.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
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
            const SnackBar(content: Text('Médicament supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  // FAB
  Widget _buildFAB(Color primaryColor) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AjouterMedicamentScreen()),
        ).then((_) {
          if (!mounted) return;
          _chargerDonnees();
        });
      },
      backgroundColor: primaryColor,
      elevation: 8,
      icon: Icon(Icons.add, color: AppTheme.cardLight, size: 26),
      label: Text(
        'Ajouter',
        style: AppTheme.titleSmall.copyWith(color: AppTheme.cardLight),
      ),
    );
  }

  Color backgroundColor(bool isDark) {
    return isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight;
  }
}
