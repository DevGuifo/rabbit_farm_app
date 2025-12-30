import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../providers/sante_provider.dart';
import '../../providers/lapin_provider.dart';
import 'ajouter_soin_screen.dart';
import 'treatments_care/widgets/treatments_header.dart';
import 'treatments_care/widgets/treatments_stats_cards.dart';
import 'treatments_care/widgets/treatments_search_bar.dart';
import 'treatments_care/widgets/treatments_filter_tabs.dart';
import 'treatments_care/sections/active_treatments_section.dart';
import 'treatments_care/sections/scheduled_treatments_section.dart';
import 'treatments_care/sections/history_section.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Écran Treatments & Care - Design Stitch (Refactorisé)
/// Architecture: Orchestrateur léger utilisant composants modulaires
/// Palette: Primary #bef264, BG #f8f9f7/#1a1c18, Surface #ffffff/#252822
class TreatmentsCareScreen extends StatefulWidget {
  const TreatmentsCareScreen({super.key});

  @override
  State<TreatmentsCareScreen> createState() => _TreatmentsCareScreenState();
}

class _TreatmentsCareScreenState extends State<TreatmentsCareScreen> {
  String _selectedFilter = 'all'; // all, treatments, care, vaccines
  String _selectedTab = 'active'; // active, scheduled, history
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
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
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    await Future.wait([
      santeProvider.chargerTout(),
      lapinProvider.chargerLapins(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Stitch Colors
    final primaryColor = AppTheme.success;
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          TreatmentsHeader(
            onBack: () => Navigator.pop(context),
            onSync: _chargerDonnees,
            isDark: isDark,
            textPrimary: textPrimary,
            backgroundColor: backgroundColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TreatmentsStatsCards(
                    selectedTab: _selectedTab,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 16),
                  TreatmentsSearchBar(
                    controller: _searchController,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 12),
                  TreatmentsFilterTabs(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                    isDark: isDark,
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 24),
                  _buildContent(
                    isDark,
                    surfaceColor,
                    primaryColor,
                    textPrimary,
                    textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(primaryColor, textPrimary),
    );
  }

  /// Affiche la section appropriée selon le tab sélectionné
  Widget _buildContent(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    switch (_selectedTab) {
      case 'active':
        return ActiveTreatmentsSection(
          searchQuery: _searchController.text,
          selectedFilter: _selectedFilter,
          isDark: isDark,
          surfaceColor: surfaceColor,
          primaryColor: primaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      case 'scheduled':
        return ScheduledTreatmentsSection(
          searchQuery: _searchController.text,
          selectedFilter: _selectedFilter,
          isDark: isDark,
          surfaceColor: surfaceColor,
          primaryColor: primaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      case 'history':
        return HistorySection(
          searchQuery: _searchController.text,
          selectedFilter: _selectedFilter,
          isDark: isDark,
          surfaceColor: surfaceColor,
          primaryColor: primaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// FAB pour ajouter un nouveau traitement
  Widget _buildFAB(Color primaryColor, Color textPrimary) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, _) {
        return FloatingActionButton.extended(
          onPressed: () async {
            await lapinProvider.chargerLapins();
            final lapins = lapinProvider.lapins;
            if (lapins.isEmpty) return;
            _showRabbitSelectorForNewTreatment(lapins);
          },
          backgroundColor: textPrimary,
          elevation: 8,
          icon: Icon(Icons.add, color: primaryColor, size: 26),
          label: Text(
            'New Treatment',
            style: AppTheme.titleSmall.copyWith(
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }

  /// Modal pour sélectionner un lapin avant d'ajouter un traitement
  void _showRabbitSelectorForNewTreatment(List<Lapin> lapins) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Rabbit',
                style: AppTheme.titleMedium.copyWith(
                  color: isDark ? AppTheme.cardLight : Colors.black,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lapins.length,
                itemBuilder: (context, index) {
                  final lapin = lapins[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.success.withValues(alpha: 0.2),
                      child: Text(
                        lapin.nom[0].toUpperCase(),
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    title: Text(lapin.nom),
                    subtitle: Text('#${lapin.numeroIdentification}'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AjouterSoinScreen(lapin: lapin),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
