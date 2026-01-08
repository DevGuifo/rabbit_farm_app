import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/lapin_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/reproduction_provider.dart';
import 'providers/sante_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/deces_provider.dart';
import 'providers/alimentation_provider.dart';
import 'providers/alerte_provider.dart';
import 'providers/fumier_provider.dart';
import 'providers/medicament_provider.dart';
import 'providers/quarantaine_provider.dart';
import 'providers/reforme_provider.dart';
import 'providers/sevrage_provider.dart';
import 'providers/palpation_provider.dart';
import 'providers/preparation_nid_provider.dart';
import 'providers/protocole_soin_provider.dart';
import 'providers/evenement_personnalise_provider.dart';
import 'providers/tache_provider.dart';
import 'providers/rituel_provider.dart';
import 'providers/anomalie_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'services/notification_strings.dart';
import 'services/smart_notification_service.dart';
import 'services/coach_notification_service.dart';
import 'services/navigation_service.dart';
import 'services/supabase_auth_service.dart';
import 'utils/logger.dart';
import 'theme/app_theme.dart';

/// Point d'entrée de l'application BunnyManager
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le logger
  logger.initialize(isProduction: false);
  logger.info('🚀 Démarrage de BunnyManager');

  // Initialiser Supabase (doit être fait avant tout)
  try {
    await SupabaseAuthService().initialize();
  } catch (e) {
    logger.error('❌ Erreur lors de l\'initialisation Supabase: $e');
    // Continuer quand même si Supabase n'est pas configuré
    // (pour le développement local)
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
  CoachNotificationService().planifierRituelMatin().catchError((e) {
    logger.error('Erreur lors de la planification du rituel matin: $e');
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider.value(value: syncProvider),
        ChangeNotifierProvider(
          create: (_) {
            final provider = LapinProvider();
            // Initialiser les données de test uniquement en mode debug
            if (kDebugMode) {
              provider.initialiserDonneesTest();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ReproductionProvider()),
        ChangeNotifierProvider(create: (_) => SanteProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = DecesProvider();
            provider.chargerDeces();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AlimentationProvider();
            provider.loadAliments();
            provider.loadDistributions();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = FumierProvider();
            provider.chargerCollectes();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = MedicamentProvider();
            provider.chargerMedicaments();
            provider.chargerUtilisations();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = QuarantaineProvider();
            provider.chargerQuarantaines();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ReformeProvider();
            provider.chargerReformes();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SevrageProvider();
            provider.chargerSevrages();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = PalpationProvider();
            provider.chargerPalpations();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = PreparationNidProvider();
            provider.chargerPreparations();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ProtocoleSoinProvider();
            provider.chargerProtocoles();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = EvenementPersonnaliseProvider();
            provider.chargerEvenements();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = TacheProvider();
            provider.chargerTaches();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = RituelProvider();
            provider.chargerRituelsJour();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AnomalieProvider();
            provider.chargerTout();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = JournalProvider();
            provider.chargerJournal();
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<
          DecesProvider,
          AlimentationProvider,
          AlerteProvider
        >(
          create: (context) => AlerteProvider(
            decesProvider: context.read<DecesProvider>(),
            alimentationProvider: context.read<AlimentationProvider>(),
          ),
          update: (context, decesProvider, alimentationProvider, previous) =>
              previous ??
              AlerteProvider(
                decesProvider: decesProvider,
                alimentationProvider: alimentationProvider,
              ),
        ),
      ],
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
          );
        },
      ),
    );
  }
}
