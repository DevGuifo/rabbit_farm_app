import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/lot_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/deces_provider.dart';
import '../../providers/alimentation_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/fumier_provider.dart';
import '../../providers/medicament_provider.dart';
import '../../providers/quarantaine_provider.dart';
import '../../providers/reforme_provider.dart';
import '../../providers/sevrage_provider.dart';
import '../../providers/palpation_provider.dart';
import '../../providers/preparation_nid_provider.dart';
import '../../providers/protocole_soin_provider.dart';
import '../../providers/evenement_personnalise_provider.dart';
import '../../providers/tache_provider.dart';
import '../../providers/tache_generique_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/onboarding_provider.dart';

/// Configuration centralisée des providers de l'application
///
/// Cette fonction retourne la liste complète des providers nécessaires
/// pour l'application, avec leurs initialisations respectives.
///
/// Les providers sont organisés par ordre de dépendance :
/// 1. Providers de base (theme, locale, auth, connectivity, sync)
/// 2. Providers métier (lapins, reproduction, santé, etc.)
/// 3. Providers utilitaires (tâches, rituels, journal, etc.)
/// 4. Providers dépendants (alerte)
List<SingleChildWidget> getAppProviders({
  required ThemeProvider themeProvider,
  required LocaleProvider localeProvider,
  required AuthProvider authProvider,
  required ConnectivityProvider connectivityProvider,
  required SyncProvider syncProvider,
}) {
  return [
    // Providers de base (singletons pré-initialisés)
    ChangeNotifierProvider.value(value: themeProvider),
    ChangeNotifierProvider.value(value: localeProvider),
    ChangeNotifierProvider.value(value: authProvider),
    ChangeNotifierProvider.value(value: connectivityProvider),
    ChangeNotifierProvider.value(value: syncProvider),

    // Providers métier - Cheptel
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

    // Providers métier - Lots (gestion par groupes)
    ChangeNotifierProvider(
      create: (_) {
        final provider = LotProvider();
        provider.chargerLots();
        return provider;
      },
    ),

    // Providers métier - Reproduction
    ChangeNotifierProvider(create: (_) => ReproductionProvider()),

    // Providers métier - Santé
    ChangeNotifierProvider(create: (_) => SanteProvider()),

    // Providers métier - Finances
    ChangeNotifierProvider(create: (_) => FinanceProvider()),

    // Providers métier - Décès
    ChangeNotifierProvider(
      create: (_) {
        final provider = DecesProvider();
        provider.chargerDeces();
        return provider;
      },
    ),

    // Providers métier - Alimentation
    ChangeNotifierProvider(
      create: (_) {
        final provider = AlimentationProvider();
        provider.loadAliments();
        provider.loadDistributions();
        return provider;
      },
    ),

    // Providers métier - Fumier
    ChangeNotifierProvider(
      create: (_) {
        final provider = FumierProvider();
        provider.chargerCollectes();
        return provider;
      },
    ),

    // Providers métier - Médicaments
    ChangeNotifierProvider(
      create: (_) {
        final provider = MedicamentProvider();
        provider.chargerMedicaments();
        provider.chargerUtilisations();
        return provider;
      },
    ),

    // Providers métier - Quarantaine
    ChangeNotifierProvider(
      create: (_) {
        final provider = QuarantaineProvider();
        provider.chargerQuarantaines();
        return provider;
      },
    ),

    // Providers métier - Réforme
    ChangeNotifierProvider(
      create: (_) {
        final provider = ReformeProvider();
        provider.chargerReformes();
        return provider;
      },
    ),

    // Providers métier - Sevrage
    ChangeNotifierProvider(
      create: (_) {
        final provider = SevrageProvider();
        provider.chargerSevrages();
        return provider;
      },
    ),

    // Providers métier - Palpation
    ChangeNotifierProvider(
      create: (_) {
        final provider = PalpationProvider();
        provider.chargerPalpations();
        return provider;
      },
    ),

    // Providers métier - Préparation nid
    ChangeNotifierProvider(
      create: (_) {
        final provider = PreparationNidProvider();
        provider.chargerPreparations();
        return provider;
      },
    ),

    // Providers métier - Protocole soin
    ChangeNotifierProvider(
      create: (_) {
        final provider = ProtocoleSoinProvider();
        provider.chargerProtocoles();
        return provider;
      },
    ),

    // Providers métier - Événements personnalisés
    ChangeNotifierProvider(
      create: (_) {
        final provider = EvenementPersonnaliseProvider();
        provider.chargerEvenements();
        return provider;
      },
    ),

    // Providers utilitaires - Tâches génériques
    ChangeNotifierProvider(
      create: (_) {
        final provider = TacheGeneriqueProvider();
        provider.chargerTaches();
        return provider;
      },
    ),

    // Providers utilitaires - Utilisateurs
    ChangeNotifierProvider(create: (_) => UserProvider()),

    // Providers utilitaires - Onboarding
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),

    // Providers utilitaires - Tâches quotidiennes
    ChangeNotifierProvider(
      create: (_) {
        final provider = TacheProvider();
        provider.chargerTaches();
        return provider;
      },
    ),

    // Providers utilitaires - Anomalies
    ChangeNotifierProvider(
      create: (_) {
        final provider = AnomalieProvider();
        provider.chargerTout();
        return provider;
      },
    ),

    // Providers utilitaires - Journal
    ChangeNotifierProvider(
      create: (_) {
        final provider = JournalProvider();
        provider.chargerJournal();
        return provider;
      },
    ),

    // Provider dépendant - Alertes (dépend de DecesProvider et AlimentationProvider)
    // Note: Ce provider doit être créé après DecesProvider et AlimentationProvider
    // Utilisation de ChangeNotifierProxyProvider2 pour gérer les dépendances
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
  ];
}
