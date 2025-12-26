import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Écran des paramètres de l'application
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final NotificationService _notificationService = NotificationService();
  List<PendingNotificationRequest> _notificationsEnAttente = [];

  @override
  void initState() {
    super.initState();
    _chargerNotifications();
  }

  Future<void> _chargerNotifications() async {
    final notifications = await _notificationService
        .getNotificationsEnAttente();
    setState(() {
      _notificationsEnAttente = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: ListView(
        children: [
          // Section Apparence
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text(
              'Apparence',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(themeProvider.themeModeIcon),
                title: const Text('Thème'),
                subtitle: Text('Actuellement: ${themeProvider.themeModeName}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Choisir un thème'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text('Clair'),
                            value: ThemeMode.light,
                            groupValue: themeProvider.themeMode,
                            onChanged: (value) {
                              themeProvider.setThemeMode(value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Sombre'),
                            value: ThemeMode.dark,
                            groupValue: themeProvider.themeMode,
                            onChanged: (value) {
                              themeProvider.setThemeMode(value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Système'),
                            value: ThemeMode.system,
                            groupValue: themeProvider.themeMode,
                            onChanged: (value) {
                              themeProvider.setThemeMode(value!);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Section Notifications
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Tester les notifications'),
            subtitle: const Text('Afficher une notification de test'),
            onTap: () async {
              await _notificationService.afficherNotificationTest();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification de test envoyée !'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('Notifications planifiées'),
            subtitle: Text('${_notificationsEnAttente.length} en attente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _afficherNotificationsPlanifiees(context),
          ),

          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Annuler toutes les notifications'),
            subtitle: const Text('Supprimer tous les rappels planifiés'),
            onTap: () => _confirmerAnnulationTout(context),
          ),

          const SizedBox(height: 20),

          // Section À propos
          const ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'À propos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.pest_control),
            title: Text('Mon Élevage Lapins'),
            subtitle: Text('Version 1.0.0'),
          ),

          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Développé avec GUIFO KAMTO ROSTAND Jr'),
            subtitle: Text('Application de gestion d\'élevage cunicole'),
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
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les notifications ont été annulées'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
