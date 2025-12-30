import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/app_theme.dart';
import '../utilitaire/export_import_screen.dart';
import '../optimisation/sevrage_screen.dart';
import '../auth/auth_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'widgets/settings_header.dart';
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
  List<PendingNotificationRequest> _notificationsEnAttente = [];

  // Préférences utilisateur (mock pour l'instant)
  String _unitsOfMeasurement = 'kg/cm';
  String _language = 'English';
  bool _breedingReminders = true;
  bool _vaccinationAlerts = true;
  final String _lastSyncTime = '2m ago'; // MOCK DATA

  @override
  void initState() {
    super.initState();
    _chargerNotifications();
    _chargerPreferences();
  }

  Future<void> _chargerNotifications() async {
    final notifications = await _notificationService
        .getNotificationsEnAttente();
    setState(() {
      _notificationsEnAttente = notifications;
    });
  }

  Future<void> _chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unitsOfMeasurement = prefs.getString('units_of_measurement') ?? 'kg/cm';
      _language = prefs.getString('language') ?? 'English';
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
          // Header sticky
          SettingsHeader(
            onSyncPressed: _handleSync,
            onNotificationsPressed: _handleNotifications,
            notificationCount: _notificationsEnAttente.length,
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
                  SettingsProfileSection(
                    profileName: 'Green Valley Rabbits',
                    profileEmail: 'john@greenvalley.com',
                    onEditProfilePressed: _handleEditProfile,
                  ),

                  const SizedBox(height: 24),

                  // Section GENERAL
                  SettingsSectionCard(
                    title: 'GENERAL',
                    children: [
                      // Units of Measurement
                      SettingsListItem(
                        icon: Icons.straighten,
                        title: 'Units of Measurement',
                        trailingText: _unitsOfMeasurement,
                        onTap: _handleUnitsOfMeasurement,
                      ),
                      // Language
                      SettingsListItem(
                        icon: Icons.translate,
                        title: 'Language',
                        trailingText: _language,
                        onTap: _handleLanguage,
                      ),
                      // Dark Mode
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SettingsToggleItem(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
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
                    title: 'NOTIFICATIONS',
                    children: [
                      // Breeding Reminders
                      SettingsToggleItem(
                        icon: Icons.pets,
                        title: 'Breeding Reminders',
                        value: _breedingReminders,
                        onChanged: (value) {
                          setState(() {
                            _breedingReminders = value;
                          });
                          _sauvegarderPreference('breeding_reminders', value);
                        },
                      ),
                      // Vaccination Alerts
                      SettingsToggleItem(
                        icon: Icons.vaccines,
                        title: 'Vaccination Alerts',
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
                        title: 'Test Notifications',
                        subtitle: 'Afficher une notification de test',
                        onTap: _handleTestNotifications,
                      ),
                      // Annuler toutes les notifications
                      SettingsListItem(
                        icon: Icons.clear_all,
                        title: 'Clear All Notifications',
                        subtitle: 'Supprimer tous les rappels planifiés',
                        onTap: _handleClearAllNotifications,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section DATA & STORAGE
                  SettingsSectionCard(
                    title: 'DATA & STORAGE',
                    children: [
                      // Sync Status
                      SettingsListItem(
                        icon: Icons.cloud_sync,
                        title: 'Sync Status',
                        subtitle: 'Last synced: $_lastSyncTime',
                        onTap: _handleSyncStatus,
                      ),
                      // Export Data
                      SettingsListItem(
                        icon: Icons.download,
                        title: 'Export Data',
                        onTap: _handleExportData,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section MANAGEMENT
                  SettingsSectionCard(
                    title: 'MANAGEMENT',
                    children: [
                      // Gestion du sevrage
                      SettingsListItem(
                        icon: Icons.cut,
                        title: 'Weaning Management',
                        subtitle: 'Voir et gérer les portées à sevrer',
                        onTap: _handleWeaningManagement,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section SUPPORT
                  SettingsSectionCard(
                    title: 'SUPPORT',
                    children: [
                      // Help Center
                      SettingsListItem(
                        icon: Icons.help,
                        title: 'Help Center',
                        trailingIcon: Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        onTap: _handleHelpCenter,
                      ),
                      // Privacy Policy
                      SettingsListItem(
                        icon: Icons.lock,
                        title: 'Privacy Policy',
                        onTap: _handlePrivacyPolicy,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section ABOUT
                  SettingsSectionCard(
                    title: 'ABOUT',
                    children: [
                      // Application info
                      SettingsListItem(
                        icon: Icons.pest_control,
                        title: 'Rabbit Farm Manager',
                        subtitle: 'Version 1.1.0',
                        onTap: null,
                      ),
                      // Developer info
                      SettingsListItem(
                        icon: Icons.code,
                        title: 'Developed by',
                        subtitle: 'GUIFO KAMTO ROSTAND Jr',
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
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
                      'Rabbit Farm Manager v1.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
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

  Future<void> _handleSync() async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Vérifier l'authentification
    if (!authProvider.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour synchroniser'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier la connectivité
    if (!connectivityProvider.isOnline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune connexion internet disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Afficher un indicateur de chargement
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Lancer la synchronisation
    final success = await syncProvider.syncNow();

    if (!mounted) return;
    Navigator.pop(context); // Fermer le dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synchronisation réussie'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            syncProvider.errorMessage ?? 'Erreur lors de la synchronisation',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNotifications() {
    _afficherNotificationsPlanifiees(context);
  }

  void _handleEditProfile() {
    // Pour l'instant, afficher un dialog simple avec les informations du profil
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${userId ?? "Non disponible"}'),
            const SizedBox(height: 8),
            const Text(
              'L\'édition du profil sera disponible dans une prochaine version.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _handleUnitsOfMeasurement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Units of Measurement'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            String selectedValue = _unitsOfMeasurement;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('kg/cm'),
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
                  title: const Text('lb/in'),
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
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            String selectedValue = _language;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  leading: Icon(
                    selectedValue == 'English'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    setStateDialog(() {
                      selectedValue = 'English';
                    });
                    setState(() {
                      _language = 'English';
                    });
                    _sauvegarderPreference('language', 'English');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Français'),
                  leading: Icon(
                    selectedValue == 'Français'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    setStateDialog(() {
                      selectedValue = 'Français';
                    });
                    setState(() {
                      _language = 'Français';
                    });
                    _sauvegarderPreference('language', 'Français');
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

  void _handleSyncStatus() {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    final lastSyncTime = syncProvider.lastSyncTime;
    final pendingChanges = syncProvider.pendingChanges;
    final isSyncing = syncProvider.isSyncing;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statut de synchronisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSyncing)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Synchronisation en cours...'),
                ],
              )
            else
              Text(
                lastSyncTime != null
                    ? 'Dernière sync: ${_formatDateTime(lastSyncTime)}'
                    : 'Aucune synchronisation effectuée',
              ),
            const SizedBox(height: 8),
            Text('Changements en attente: $pendingChanges'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
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
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} jours';
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
        title: const Text('Centre d\'aide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pour toute question ou assistance :'),
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
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
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
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _handleTestNotifications() async {
    await _notificationService.afficherNotificationTest();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification de test envoyée !'),
        backgroundColor: Colors.green,
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

  void _confirmerAnnulationTout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text(
          'Voulez-vous vraiment annuler toutes les notifications planifiées ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _notificationService.annulerToutesLesNotifications();
              await _chargerNotifications();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications ont été annulées'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLogOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
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
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                // Naviguer vers l'écran d'authentification
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(initialIsSignUp: false),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                // En cas d'erreur, fermer le dialog et afficher un message
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _afficherNotificationsPlanifiees(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Text(
                  'Notifications planifiées',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _notificationsEnAttente.isEmpty
                  ? const Center(child: Text('Aucune notification planifiée'))
                  : ListView.builder(
                      itemCount: _notificationsEnAttente.length,
                      itemBuilder: (context, index) {
                        final notif = _notificationsEnAttente[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(notif.title ?? 'Sans titre'),
                          subtitle: Text(notif.body ?? 'Sans description'),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _chargerNotifications();
              },
              child: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}
