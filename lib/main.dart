import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/lapin_provider.dart';
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
import 'services/notification_service.dart';
import 'services/navigation_service.dart';
import 'utils/logger.dart';
import 'theme/app_theme.dart';

/// Point d'entrée de l'application BunnyManager
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le logger
  logger.initialize(isProduction: false);
  logger.info('🚀 Démarrage de BunnyManager');

  // Initialiser le service de notifications
  await NotificationService().initialize();

  // Créer et initialiser le theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(BunnyManagerApp(themeProvider: themeProvider));
}

/// Widget racine de l'application BunnyManager
class BunnyManagerApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const BunnyManagerApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(
          create: (_) {
            final provider = LapinProvider();
            // Initialiser les données de manière asynchrone
            provider.initialiserDonneesTest();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ReproductionProvider()),
        ChangeNotifierProvider(create: (_) => SanteProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = DecesProvider();
            provider.loadDeces();
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BunnyManager',
            debugShowCheckedModeBanner: false,
            navigatorKey:
                navigationService.navigatorKey, // Clé de navigation globale
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
            locale: const Locale('fr', 'FR'),
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
