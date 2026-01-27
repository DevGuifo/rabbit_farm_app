import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'ajouter_utilisateur_screen.dart';
import 'historique_actions_screen.dart';
import 'widgets/user_card.dart';

/// Écran de gestion des utilisateurs
class GestionUtilisateursScreen extends StatefulWidget {
  const GestionUtilisateursScreen({super.key});

  @override
  State<GestionUtilisateursScreen> createState() =>
      _GestionUtilisateursScreenState();
}

class _GestionUtilisateursScreenState extends State<GestionUtilisateursScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    final provider = context.read<UserProvider>();
    await provider.chargerUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();

    // Vérifier les permissions
    if (!userProvider.canManageUsers()) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDarkMode
            : AppTheme.backgroundLight,
        appBar: SimpleAppBar(
          title: AppLocalizations.of(context).utilisateursGestionTitre,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).utilisateursAccesRefuse,
                style: AppTheme.titleLarge.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                ).utilisateursPermissionsInsuffisantes,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark, userProvider),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _chargerDonnees,
              color: AppTheme.primaryNeonGreen,
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userProvider.users.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: userProvider.users.length,
                      itemBuilder: (context, index) {
                        final user = userProvider.users[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UserCard(
                            user: user,
                            isDark: isDark,
                            onTap: () => _editerUtilisateur(context, user),
                            onToggleActive: () => _toggleActive(user),
                            onDelete: () => _supprimerUtilisateur(user),
                            canManage: userProvider.canManageUsers(),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: UnifiedFAB.extended(
        onPressed: () => _ajouterUtilisateur(context),
        label: AppLocalizations.of(context).utilisateursAjouter,
        icon: Icons.add_rounded,
        tooltip: AppLocalizations.of(context).utilisateursAjouter,
      ),
    );
  }

  Widget _buildHeader(bool isDark, UserProvider userProvider) {
    return SimpleAppBar(
      title: AppLocalizations.of(context).utilisateursGestionTitre,
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _chargerDonnees,
          tooltip: AppLocalizations.of(context).utilisateursActualiser,
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriqueActionsScreen()),
          ),
          tooltip: AppLocalizations.of(context).utilisateursHistorique,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).utilisateursAucun,
            style: AppTheme.titleLarge.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).utilisateursCreerPremier,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _ajouterUtilisateur(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjouterUtilisateurScreen()),
    );
    if (result == true) {
      _chargerDonnees();
    }
  }

  void _editerUtilisateur(BuildContext context, User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AjouterUtilisateurScreen(user: user)),
    );
    if (result == true) {
      _chargerDonnees();
    }
  }

  void _toggleActive(User user) async {
    final provider = context.read<UserProvider>();
    if (user.isActive) {
      await provider.supprimerUser(user.id!);
    } else {
      await provider.activerUser(user.id!);
    }
  }

  void _supprimerUtilisateur(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).utilisateursDesactiverTitre),
        content: Text(
          AppLocalizations.of(
            context,
          ).utilisateursDesactiverConfirmation(user.nomComplet),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).quarantaineAnnuler),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(AppLocalizations.of(context).btnDesactiver),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<UserProvider>();
      await provider.supprimerUser(user.id!);
    }
  }
}
