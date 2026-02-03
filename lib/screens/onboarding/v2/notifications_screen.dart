import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/onboarding/onboarding_scaffold.dart';
import '../../../widgets/onboarding/onboarding_button.dart';
import '../../../constants/preferences_keys.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/logger.dart';

/// Écran 5 : Notifications (Onboarding V2)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notifSante = PreferencesDefaults.defaultNotifSante;
  bool _notifReproduction = PreferencesDefaults.defaultNotifReproduction;
  bool _notifAlertes = PreferencesDefaults.defaultNotifAlertes;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: '🔔 Quand vous prévenir ?',
      subtitle: 'Activez les rappels qui vous aident',
      currentStep: 4,
      totalSteps: 6,
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Santé
          SwitchListTile(
            title: const Text('🩺 Santé'),
            subtitle: const Text('Vaccinations, traitements'),
            value: _notifSante,
            onChanged: (value) => setState(() => _notifSante = value),
            contentPadding: EdgeInsets.zero,
          ),
          
          const Divider(),
          
          // Reproduction
          SwitchListTile(
            title: const Text('🐣 Reproduction'),
            subtitle: const Text('Mises bas, sevrages à venir'),
            value: _notifReproduction,
            onChanged: (value) => setState(() => _notifReproduction = value),
            contentPadding: EdgeInsets.zero,
          ),
          
          const Divider(),
          
          // Alertes critiques
          SwitchListTile(
            title: const Text('⚠️ Alertes critiques'),
            subtitle: const Text('Mortalité, anomalies'),
            value: _notifAlertes,
            onChanged: (value) => setState(() => _notifAlertes = value),
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 24),
          
          // Conseil
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modifiable à tout moment dans Paramètres > Notifications',
                    style: TextStyle(
                      color: AppTheme.info,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Boutons navigation
          Row(
            children: [
              const OnboardingSkipButton(),
              const Spacer(),
              Consumer<OnboardingProvider>(
                builder: (context, provider, _) {
                  return OnboardingButton(
                    text: 'Suivant',
                    onPressed: _handleNext,
                    isLoading: provider.isLoading,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    
    final success = await provider.saveNotificationPreferences(
      sante: _notifSante,
      reproduction: _notifReproduction,
      alertes: _notifAlertes,
    );

    if (!success) {
      logger.warning('Échec sauvegarde notifications, continue');
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding/ready');
    }
  }
}
