import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'config/supabase_config.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/sync_provider.dart';
import 'services/notification_service.dart';
import 'services/notification_strings.dart';
import 'services/smart_notification_service.dart';
import 'services/coach_notification_service.dart';
import 'services/daily_summary_notification_service.dart';
import 'services/kpi_history_service.dart';
import 'core/services/navigation_service.dart';
import 'services/auth_service.dart';
import 'screens/onboarding/onboarding_main_screen.dart';
import 'screens/onboarding/presentation_screen.dart';
import 'screens/onboarding/type_elevage_screen.dart';
import 'screens/onboarding/informations_ferme_screen.dart';
import 'screens/onboarding/profil_utilisateur_screen.dart';
import 'screens/onboarding/synchronisation_screen.dart';
import 'screens/home_screen.dart';
import 'core/utils/logger.dart';
import 'theme/app_theme.dart';
import 'core/providers/app_providers.dart';

/// Point d'entrée de l'application BunnyManager
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le logger (mode production automatique en release)
  logger.initialize(isProduction: kReleaseMode);
  if (!kReleaseMode) {
    logger.info('🚀 Démarrage de BunnyManager');
  }

  // Initialiser le service d'authentification (offline-first)
  try {
    await AuthService().initialize();
    logger.info('✅ AuthService initialisé');
  } catch (e) {
    logger.error('❌ Erreur lors de l\'initialisation AuthService: $e');
  }

  // Initialiser Supabase (optionnel - l'app fonctionne sans)
  try {
    final supabaseInitialized = await supabaseConfig.initialize();
    if (supabaseInitialized) {
      logger.info('✅ Supabase initialisé');
    } else {
      logger.info('ℹ️ Supabase non configuré - mode offline uniquement');
    }
  } catch (e) {
    logger.warning('⚠️ Supabase non disponible: $e');
  }

  // Initialiser les chaînes de notification
  await NotificationStrings.initialize();

  // Initialiser le service de notifications
  await NotificationService().initialize();

  // Initialiser le service intelligent de notifications
  final smartNotificationService = SmartNotificationService();
  await smartNotificationService.initialize();

  // Scanner et planifier toutes les notifications au démarrage
  // (en arrière-plan pour ne pas bloquer le démarrage)
  smartNotificationService.scanAndScheduleAllNotifications().catchError((e) {
    logger.error('Erreur lors du scan initial des notifications: $e');
  });

  // Planifier le rituel du matin (coach quotidien)
  CoachNotificationService().planifierVerificationMatin().catchError((e) {
    logger.error(
      'Erreur lors de la planification de la vérification matin: $e',
    );
  });

  // Planifier le résumé quotidien 8h (Phase 2)
  DailySummaryNotificationService().planifierResumQuotidien().catchError((e) {
    logger.error('Erreur lors de la planification du résumé quotidien: $e');
  });

  // ✅ PHASE 4 : Enregistrer KPIs quotidiens (en arrière-plan)
  KpiHistoryService().enregistrerKpisQuotidiens().catchError((e) {
    logger.error('Erreur lors de l\'enregistrement des KPIs: $e');
  });

  // Initialiser historique rétroactif au premier lancement (optionnel)
  KpiHistoryService().initialiserHistoriqueRetroactif().catchError((e) {
    logger.error('Erreur lors de l\'initialisation historique rétroactif: $e');
  });

  // Créer et initialiser le theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Créer et initialiser les providers d'authentification
  final authProvider = AuthProvider();
  await authProvider.initialize();

  final connectivityProvider = ConnectivityProvider();
  await connectivityProvider.initialize();

  final syncProvider = SyncProvider();
  await syncProvider.initialize();

  // Créer et initialiser le locale provider
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(
    BunnyManagerApp(
      themeProvider: themeProvider,
      authProvider: authProvider,
      connectivityProvider: connectivityProvider,
      syncProvider: syncProvider,
      localeProvider: localeProvider,
    ),
  );
}

/// Widget racine de l'application BunnyManager
class BunnyManagerApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;
  final ConnectivityProvider connectivityProvider;
  final SyncProvider syncProvider;
  final LocaleProvider localeProvider;

  const BunnyManagerApp({
    super.key,
    required this.themeProvider,
    required this.authProvider,
    required this.connectivityProvider,
    required this.syncProvider,
    required this.localeProvider,
  });

  /// Construit la carte des routes de l'application
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/home': (context) => const HomeScreen(),
      '/onboarding': (context) => const OnboardingMainScreen(),
      '/onboarding/presentation': (context) =>
          const OnboardingPresentationScreen(),
      '/onboarding/type-elevage': (context) =>
          const OnboardingTypeElevageScreen(),
      '/onboarding/informations-ferme': (context) =>
          const OnboardingInformationsFermeScreen(),
      '/onboarding/profil-utilisateur': (context) =>
          const OnboardingProfilUtilisateurScreen(),
      '/onboarding/synchronisation': (context) =>
          const OnboardingSynchronisationScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getAppProviders(
        themeProvider: themeProvider,
        localeProvider: localeProvider,
        authProvider: authProvider,
        connectivityProvider: connectivityProvider,
        syncProvider: syncProvider,
      ),
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          // IMPORTANT: Ne pas utiliser AppLocalizations ici car context incomplet
          // Le titre est visible uniquement dans task manager, pas dans l'app
          const appTitle = 'BunnyManager'; // Nom commercial fixe

          return MaterialApp(
            key: ValueKey(
              localeProvider.locale.languageCode,
            ), // Force rebuild on locale change
            title: appTitle,
            debugShowCheckedModeBanner: false,
            navigatorKey:
                navigationService.navigatorKey, // Clé de navigation globale
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: localeProvider.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: _buildRoutes(),
          );
        },
      ),
    );
  }
}
