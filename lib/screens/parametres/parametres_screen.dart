import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/demo_data_loader.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glossaire/glossaire_cuniculture.dart';
import '../../widgets/common/common_widgets.dart';
import '../utilitaire/export_import_screen.dart';
import '../optimisation/sevrage_screen.dart';
import '../auth/auth_screen.dart';
import '../utilisateur/gestion_utilisateurs_screen.dart';
import '../utilisateur/editer_profil_screen.dart';
import '../alertes/alertes_screen.dart';
import 'widgets/settings_profile_section.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/settings_list_item.dart';
import 'widgets/settings_toggle_item.dart';

/// Écran des paramètres de l'application
/// Reconstruit selon le design Stitch avec sections Profile, General, Notifications, Data & Storage, Support
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final NotificationService _notificationService = NotificationService();

  // Préférences utilisateur (mock pour l'instant)
  String _unitsOfMeasurement = 'kg/cm';
  bool _breedingReminders = true;
  bool _vaccinationAlerts = true;
  final String _lastSyncTime = '2m ago'; // MOCK DATA

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  Future<void> _chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unitsOfMeasurement = prefs.getString('units_of_measurement') ?? 'kg/cm';
      _breedingReminders = prefs.getBool('breeding_reminders') ?? true;
      _vaccinationAlerts = prefs.getBool('vaccination_alerts') ?? true;
    });
  }

  Future<void> _sauvegarderPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.stitchBackgroundDark
          : AppTheme.stitchBackgroundLight,
      body: Column(
        children: [
          // Header sticky - Utilise StandardHeader unifié
          StandardHeader(
            title: AppLocalizations.of(context).navParametres,
            isDark: isDark,
            onSync: () async {
              // Synchroniser puis recharger
              final syncProvider = context.read<SyncProvider>();
              await syncProvider.syncNow();
            },
            onNotifications: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertesScreen()),
              );
            },
            onSettings: null, // Pas de settings dans l'écran settings
            showNotificationBadge: true,
            notificationCount: context
                .read<AlerteProvider>()
                .nombreAlertesNonLues,
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Section Profile
                  Consumer2<AuthProvider, UserProvider>(
                    builder: (context, authProvider, userProvider, child) {
                      // Essayer d'utiliser les données du UserProvider d'abord
                      String displayName = AppLocalizations.of(
                        context,
                      ).parametresNonConnecte;
                      String displayEmail = AppLocalizations.of(
                        context,
                      ).parametresNonConnecte;
                      String? avatarUrl;

                      if (userProvider.currentUser != null) {
                        // Utiliser les données du UserProvider
                        displayName = userProvider.currentUser!.nomComplet;
                        displayEmail = userProvider.currentUser!.email;
                        avatarUrl = userProvider.currentUser!.photoPath;
                      } else {
                        // Fallback sur AuthProvider
                        final supabaseAuthService = SupabaseAuthService();
                        final userEmail = supabaseAuthService.currentUserEmail;
                        final userId = authProvider.currentUserId;

                        displayName = userEmail != null
                            ? userEmail.split('@').first
                            : (userId != null
                                  ? AppLocalizations.of(
                                      context,
                                    ).parametresUtilisateur
                                  : AppLocalizations.of(
                                      context,
                                    ).parametresNonConnecte);
                        displayEmail =
                            userEmail ??
                            (userId != null
                                ? AppLocalizations.of(
                                    context,
                                  ).parametresCompteLocal
                                : AppLocalizations.of(
                                    context,
                                  ).parametresNonConnecte);
                      }

                      return SettingsProfileSection(
                        profileName: displayName,
                        profileEmail: displayEmail,
                        avatarUrl: avatarUrl,
                        onEditProfilePressed: _handleEditProfile,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section GENERAL
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramGeneral,
                    children: [
                      // Unités de mesure
                      SettingsListItem(
                        icon: Icons.straighten,
                        title: AppLocalizations.of(context).paramUnitesMesure,
                        trailingText: _unitsOfMeasurement,
                        onTap: _handleUnitsOfMeasurement,
                      ),
                      // Langue
                      Consumer<LocaleProvider>(
                        builder: (context, localeProvider, child) {
                          return SettingsListItem(
                            icon: Icons.translate,
                            title: AppLocalizations.of(context).paramLangue,
                            trailingText: localeProvider.languageName,
                            onTap: _handleLanguage,
                          );
                        },
                      ),
                      // Mode sombre
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SettingsToggleItem(
                            icon: Icons.dark_mode,
                            title: AppLocalizations.of(context).paramModeSombre,
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section NOTIFICATIONS
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramNotifications,
                    children: [
                      // Rappels reproduction
                      SettingsToggleItem(
                        icon: Icons.pets,
                        title: AppLocalizations.of(
                          context,
                        ).paramRappelsReproduction,
                        value: _breedingReminders,
                        onChanged: (value) {
                          setState(() {
                            _breedingReminders = value;
                          });
                          _sauvegarderPreference('breeding_reminders', value);
                        },
                      ),
                      // Alertes vaccination
                      SettingsToggleItem(
                        icon: Icons.vaccines,
                        title: AppLocalizations.of(
                          context,
                        ).paramAlertesVaccination,
                        value: _vaccinationAlerts,
                        onChanged: (value) {
                          setState(() {
                            _vaccinationAlerts = value;
                          });
                          _sauvegarderPreference('vaccination_alerts', value);
                        },
                      ),
                      // Tester les notifications
                      SettingsListItem(
                        icon: Icons.notification_add,
                        title: AppLocalizations.of(
                          context,
                        ).paramTesterNotifications,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramTesterNotificationsDetail,
                        onTap: _handleTestNotifications,
                      ),
                      // Annuler toutes les notifications
                      SettingsListItem(
                        icon: Icons.clear_all,
                        title: AppLocalizations.of(
                          context,
                        ).paramEffacerNotifications,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramEffacerNotificationsDetail,
                        onTap: _handleClearAllNotifications,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section DONNÉES & STOCKAGE
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramDonneesStockage,
                    children: [
                      // Charger données démo (UNIQUEMENT EN DEBUG)
                      if (kDebugMode)
                        SettingsListItem(
                          icon: Icons.science,
                          title: AppLocalizations.of(
                            context,
                          ).paramChargerDonneesDemo,
                          subtitle: AppLocalizations.of(
                            context,
                          ).paramChargerDonneesDemoDetail,
                          onTap: _handleLoadDemoData,
                        ),
                      // État synchronisation
                      SettingsListItem(
                        icon: Icons.cloud_sync,
                        title: AppLocalizations.of(
                          context,
                        ).paramEtatSynchronisation,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramEtatSynchronisationDetail(_lastSyncTime),
                        onTap: _handleSyncStatus,
                      ),
                      // Exporter données
                      SettingsListItem(
                        icon: Icons.download,
                        title: AppLocalizations.of(
                          context,
                        ).paramExporterDonnees,
                        onTap: _handleExportData,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section GESTION
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramGestion,
                    children: [
                      // Gestion du sevrage
                      SettingsListItem(
                        icon: Icons.cut,
                        title: AppLocalizations.of(
                          context,
                        ).paramGestionSevrages,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramGestionSevragesDetail,
                        onTap: _handleWeaningManagement,
                      ),
                      // Gestion des utilisateurs
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          if (!userProvider.canManageUsers()) {
                            return const SizedBox.shrink();
                          }
                          return SettingsListItem(
                            icon: Icons.people_rounded,
                            title: AppLocalizations.of(
                              context,
                            ).paramGestionUtilisateurs,
                            subtitle: AppLocalizations.of(
                              context,
                            ).paramGestionUtilisateursDetail,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GestionUtilisateursScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section AIDE
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramAide,
                    children: [
                      // Glossaire cuniculture
                      SettingsListItem(
                        icon: Icons.menu_book,
                        title: AppLocalizations.of(
                          context,
                        ).paramGlossaireCuniculture,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramGlossaireCunicultureDetail,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GlossaireScreen(),
                          ),
                        ),
                      ),
                      // Centre d'aide
                      SettingsListItem(
                        icon: Icons.help,
                        title: AppLocalizations.of(context).paramCentreAide,
                        trailingIcon: Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: isDark
                              ? AppTheme.neutral600
                              : AppTheme.neutral400,
                        ),
                        onTap: _handleHelpCenter,
                      ),
                      // Politique de confidentialité
                      SettingsListItem(
                        icon: Icons.lock,
                        title: AppLocalizations.of(
                          context,
                        ).paramPolitiqueConfidentialite,
                        onTap: _handlePrivacyPolicy,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section À PROPOS
                  SettingsSectionCard(
                    title: AppLocalizations.of(context).paramAPropos,
                    children: [
                      // Infos application
                      SettingsListItem(
                        icon: Icons.pest_control,
                        title: AppLocalizations.of(context).paramNomApp,
                        subtitle: AppLocalizations.of(context).paramVersion,
                        onTap: null,
                      ),
                      // Infos développeur
                      SettingsListItem(
                        icon: Icons.code,
                        title: AppLocalizations.of(context).paramDeveloppe,
                        subtitle: AppLocalizations.of(
                          context,
                        ).paramDeveloppeNom,
                        onTap: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bouton Log Out
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.stitchSurfaceDark
                          : AppTheme.stitchSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.textPrimary.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _handleLogOut,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: AppTheme.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).paramLogOut,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer avec version
                  Center(
                    child: Text(
                      AppLocalizations.of(context).parametresVersion,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.neutral600
                            : AppTheme.neutral400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HANDLERS
  // ============================================

  void _handleEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditerProfilScreen()),
    );
    if (result == true) {
      // Recharger les données si nécessaire
      setState(() {});
    }
  }

  void _handleUnitsOfMeasurement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).parametresUnitesMesure),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            String selectedValue = _unitsOfMeasurement;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).parametresUnitKgCm),
                  leading: Icon(
                    selectedValue == 'kg/cm'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    setStateDialog(() {
                      selectedValue = 'kg/cm';
                    });
                    setState(() {
                      _unitsOfMeasurement = 'kg/cm';
                    });
                    _sauvegarderPreference('units_of_measurement', 'kg/cm');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).parametresUnitLbIn),
                  leading: Icon(
                    selectedValue == 'lb/in'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    setStateDialog(() {
                      selectedValue = 'lb/in';
                    });
                    setState(() {
                      _unitsOfMeasurement = 'lb/in';
                    });
                    _sauvegarderPreference('units_of_measurement', 'lb/in');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleLanguage() {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).langue),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).parametresLanguageEnglish,
                  ),
                  leading: Icon(
                    localeProvider.locale.languageCode == 'en'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () async {
                    await localeProvider.setLocaleByName('English');
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).parametresLanguageFrancais,
                  ),
                  leading: Icon(
                    localeProvider.locale.languageCode == 'fr'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () async {
                    await localeProvider.setLocaleByName('Français');
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSyncStatus() {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    final lastSyncTime = syncProvider.lastSyncTime;
    final pendingChanges = syncProvider.pendingChanges;
    final isSyncing = syncProvider.isSyncing;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).parametresStatutSynchronisation,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSyncing)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).parametresSyncEnCours),
                ],
              )
            else
              Text(
                lastSyncTime != null
                    ? '${AppLocalizations.of(context).parametresDerniereSyncLabel} ${_formatDateTime(lastSyncTime)}'
                    : AppLocalizations.of(context).parametresAucuneSync,
              ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              ).parametresChangementsEnAttente(pendingChanges),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).fermer),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(
        context,
      ).parametresIlYaMin(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(
        context,
      ).parametresIlYaHeures(difference.inHours);
    } else {
      return AppLocalizations.of(
        context,
      ).parametresIlYaJours(difference.inDays);
    }
  }

  void _handleExportData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExportImportScreen()),
    );
  }

  void _handleHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).parametresCentreAide),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).msgQuestionAssistance),
            SizedBox(height: 8),
            Text('• Consultez la documentation dans l\'application'),
            Text('• Contactez le support via les paramètres'),
            SizedBox(height: 8),
            Text(
              'Le centre d\'aide complet sera disponible dans une prochaine version.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).fermer),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).parametresPolitiqueConfidentialite,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Votre vie privée est importante pour nous.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Données collectées :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Données d\'élevage (lapins, reproductions, santé)'),
              const Text('• Données financières (recettes, dépenses)'),
              const Text('• Photos des animaux'),
              const SizedBox(height: 16),
              const Text(
                'Stockage :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Données stockées localement sur votre appareil'),
              const Text(
                '• Synchronisation optionnelle avec Supabase (chiffrée)',
              ),
              const SizedBox(height: 16),
              const Text(
                'Sécurité :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Authentification sécurisée (Supabase)'),
              const Text('• PIN local pour accès offline'),
              const Text('• Chiffrement des données sensibles'),
              const SizedBox(height: 16),
              const Text(
                'Pour plus d\'informations, contactez le support.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).fermer),
          ),
        ],
      ),
    );
  }

  void _handleTestNotifications() async {
    await _notificationService.afficherNotificationTest();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).parametresNotificationTest),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _handleClearAllNotifications() {
    _confirmerAnnulationTout(context);
  }

  void _handleWeaningManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SevrageScreen()),
    );
  }

  Future<void> _handleLoadDemoData() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).parametresChargerDemo),
        content: Text(AppLocalizations.of(context).parametresDemoDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).annuler),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppTheme.primaryButtonStyle,
            child: Text(AppLocalizations.of(context).generer),
          ),
        ],
      ),
    );

    if (confirmer != true) return;

    // Afficher indicateur
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).msgGenerationDonnees),
          ],
        ),
      ),
    );

    try {
      // Générer données
      await DemoDataLoader.chargerDonnees();

      // Fermer dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Afficher succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Données chargées ! Redémarrez l\'app.'),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Fermer dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Afficher erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _confirmerAnnulationTout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmation),
        content: Text(
          AppLocalizations.of(context).parametresAnnulerNotifications,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).annuler),
          ),
          TextButton(
            onPressed: () async {
              await _notificationService.annulerToutesLesNotifications();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).parametresNotificationsAnnulees,
                  ),
                  backgroundColor: AppTheme.warning,
                ),
              );
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deconnexion),
        content: Text(AppLocalizations.of(context).confirmationDeconnexion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).annuler),
          ),
          TextButton(
            onPressed: () async {
              // Fermer le dialog de confirmation
              Navigator.pop(context);

              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              // Afficher un indicateur de chargement
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                // Déconnexion
                await authProvider.signOut();

                // Fermer le dialog de chargement
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                // Attendre un court délai pour s'assurer que le dialog est fermé
                await Future.delayed(const Duration(milliseconds: 150));

                // Naviguer vers l'écran d'authentification en utilisant le navigationService
                // pour éviter les problèmes de contexte après déconnexion
                final navigatorState =
                    navigationService.navigatorKey.currentState;
                if (navigatorState != null) {
                  navigatorState.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(initialIsSignUp: false),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                // En cas d'erreur, fermer le dialog
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                // Afficher l'erreur en utilisant le navigationService
                final navigatorState =
                    navigationService.navigatorKey.currentState;
                if (navigatorState != null) {
                  final navContext = navigatorState.context;
                  if (navContext.mounted) {
                    ScaffoldMessenger.of(navContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          ).msgErreurDeconnexion(e.toString()),
                        ),
                        backgroundColor: AppTheme.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
