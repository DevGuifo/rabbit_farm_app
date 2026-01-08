import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'fiche_sante_screen.dart';
import '../optimisation/protocoles_screen.dart';
import 'ajouter_pesee_screen.dart';
import 'pesee_tracking_screen.dart';
import 'treatments_care_screen.dart';
import 'pharmacie_screen.dart';

/// Écran Santé Overview - Design Stitch "Centre de Santé"
class SanteScreen extends StatefulWidget {
  const SanteScreen({super.key});

  @override
  State<SanteScreen> createState() => _SanteScreenState();
}

class _SanteScreenState extends State<SanteScreen> {
  @override
  void initState() {
    super.initState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(isDark),
                  AppTheme.verticalSpace24,
                  _buildActionGrid(isDark),
                  AppTheme.verticalSpace24,
                  _buildUpcomingTasks(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header Stitch avec actions - Utilise StandardHeader unifié
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).suiviSante,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        _chargerDonnees();
      },
      onNotifications: () => _afficherRappels(),
      onSettings: () {
        // Navigation vers paramètres
      },
    );
  }

  /// Section héro "Centre de Santé" - Utilise HeroSection
  Widget _buildHeroSection(bool isDark) {
    return HeroSection(
      title: AppLocalizations.of(context).centreSante,
      subtitle: AppLocalizations.of(context).santeSubtitle,
      isDark: isDark,
    );
  }

  /// Grille 2x2 des cartes d'action
  Widget _buildActionGrid(bool isDark) {
    return Padding(
      padding: AppTheme.paddingHorizontal,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _buildActionCard(
            isDark: isDark,
            icon: Icons.monitor_heart,
            title: AppLocalizations.of(context).santeSuiviSante,
            subtitle: AppLocalizations.of(context).santeParametresVitaux,
            color: AppTheme.primaryGreen,
            onTap: () => _showRabbitSelector(context),
          ),
          _buildActionCard(
            isDark: isDark,
            icon: Icons.healing,
            title: AppLocalizations.of(context).santeSoinsTraitements,
            subtitle: AppLocalizations.of(context).santeActifsHistorique,
            color: AppTheme.success,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TreatmentsCareScreen()),
              );
            },
          ),
          _buildActionCard(
            isDark: isDark,
            icon: Icons.scale,
            title: AppLocalizations.of(context).santeSuiviPonderal,
            subtitle: AppLocalizations.of(context).santeCourbesCroissance,
            color: AppTheme.warning,
            onTap: () => _showWeightTracking(),
          ),
          _buildActionCard(
            isDark: isDark,
            icon: Icons.medication,
            title: AppLocalizations.of(context).santePharmacie,
            subtitle: AppLocalizations.of(context).santeGestionStock,
            color: AppTheme.info,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PharmacieScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionCard(
      isDark: isDark,
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: color,
      onTap: onTap,
    );
  }

  /// Section "Upcoming Tasks"
  Widget _buildUpcomingTasks(bool isDark) {
    return Padding(
      padding: AppTheme.paddingHorizontal,
      child: Consumer<SanteProvider>(
        builder: (context, santeProvider, _) {
          final rappels = santeProvider.soinsAvecRappel;
          final pendingCount = rappels.length;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: AppTheme.borderRadiusLarge,
              border: Border.all(
                color: isDark ? AppTheme.divider : AppTheme.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.backgroundDark.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.cardLight.withValues(alpha: 0.05)
                        : AppTheme.backgroundLight,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppTheme.divider : AppTheme.border,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).santeTachesVenir,
                        style: AppTheme.titleMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$pendingCount ${AppLocalizations.of(context).enAttente}',
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.primaryYellow
                                : AppTheme.backgroundDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingCount == 0)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).commonAucunRappel,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...rappels.take(3).map((soin) {
                    return Column(
                      children: [
                        _buildTaskItem(
                          isDark: isDark,
                          icon: Icons.medical_services,
                          color: AppTheme.accentTeal,
                          badge: 'RAPPEL',
                          title: soin.description,
                          subtitle: soin.type,
                          onTap: () {
                            // Naviguer vers la fiche santé du lapin concerné
                            final lapinProvider = Provider.of<LapinProvider>(
                              context,
                              listen: false,
                            );
                            final lapin = lapinProvider.getLapinById(
                              soin.lapinId,
                            );
                            if (lapin != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FicheSanteScreen(lapin: lapin),
                                ),
                              );
                            }
                          },
                        ),
                        if (soin != rappels.last) _buildTaskDivider(isDark),
                      ],
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskItem({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String badge,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            AppTheme.horizontalSpace16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge,
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textTertiary,
                    ),
                  ),
                  AppTheme.verticalSpace4,
                  Text(
                    title,
                    style: AppTheme.titleSmall.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppTheme.divider : AppTheme.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDivider(bool isDark) {
    return Container(
      height: 1,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 80, right: 16),
      color: isDark ? AppTheme.divider : AppTheme.border,
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cardLight, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryYellow.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, size: 32, color: AppTheme.backgroundDark),
        onPressed: () {
          // Menu contextuel : Ajouter pesée, soin, protocole
          _showAddMenu();
        },
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.monitor_weight,
                  color: AppTheme.accentCyan,
                ),
                title: Text(AppLocalizations.of(context).santeAjouterPesee),
                onTap: () {
                  Navigator.pop(context);
                  _showRabbitSelectorForPesee();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.medical_services,
                  color: AppTheme.neonGreen,
                ),
                title: Text(AppLocalizations.of(context).santeAjouterSoin),
                onTap: () {
                  Navigator.pop(context);
                  // Navigation vers ajout soin
                },
              ),
              ListTile(
                leading: const Icon(Icons.science, color: AppTheme.accentTeal),
                title: Text(AppLocalizations.of(context).santeProtocoleSoins),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProtocolesScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRabbitSelector(BuildContext parentContext) {
    final lapinProvider = Provider.of<LapinProvider>(
      parentContext,
      listen: false,
    );

    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).santeSelectionnerLapin,
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...lapinProvider.lapins.take(5).map((lapin) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lapin.sexe == 'Mâle'
                        ? AppTheme.accentCyan.withValues(alpha: 0.2)
                        : AppTheme.accentPink.withValues(alpha: 0.2),
                    child: Icon(
                      lapin.sexe == 'Mâle' ? Icons.male : Icons.female,
                      color: lapin.sexe == 'Mâle'
                          ? AppTheme.accentCyan
                          : AppTheme.accentPink,
                    ),
                  ),
                  title: Text(lapin.nom),
                  subtitle: Text(lapin.race),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => FicheSanteScreen(lapin: lapin),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showRabbitSelectorForPesee() {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).labelPeserLapin,
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...lapinProvider.lapins.take(5).map((lapin) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.warning.withValues(alpha: 0.2),
                    child: const Icon(Icons.scale, color: AppTheme.warning),
                  ),
                  title: Text(lapin.nom),
                  subtitle: Text('${lapin.poids ?? '?'} kg'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AjouterPeseeScreen(lapin: lapin),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeightTracking() {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);

    if (lapinProvider.lapins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).commonAucunLapinDisponible,
          ),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sélectionner un lapin pour le tracking',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...lapinProvider.lapins.take(10).map((lapin) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.warning.withValues(alpha: 0.2),
                    child: const Icon(Icons.scale, color: AppTheme.warning),
                  ),
                  title: Text(lapin.nom),
                  subtitle: Text(lapin.race),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PeseeTrackingScreen(lapin: lapin),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _afficherRappels() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final rappels = await santeProvider.getSoinsAvecRappel();

    if (!mounted) return;

    if (rappels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonAucunRappel),
          backgroundColor: AppTheme.success,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notification_important,
                    color: AppTheme.accentAmber,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Rappels de soins (${rappels.length})',
                    style: AppTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...rappels.map(
                (soin) => ListTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: AppTheme.neonGreen,
                  ),
                  title: Text(soin.description),
                  subtitle: Text(soin.type),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
