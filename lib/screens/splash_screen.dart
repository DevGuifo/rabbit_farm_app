import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';
import 'auth/auth_screen.dart';
import 'auth/pin_screen.dart';
import '../providers/lapin_provider.dart';
import '../theme/app_theme.dart';
import '../providers/reproduction_provider.dart';
import '../providers/sante_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../services/database_helper.dart';

/// Écran de chargement intelligent de BunnyManager
/// Effectue tous les chargements nécessaires (BD, providers, préférences)
/// et affiche la progression en temps réel avant de naviguer vers le Dashboard
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // État du chargement
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Lancer l'initialisation de l'application après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Initialise tous les composants de l'application de manière progressive
  Future<void> _initializeApp() async {
    try {
      // Récupérer les providers une seule fois au début
      if (!mounted) return;
      final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
      final reproProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );

      // Étape 1 : Initialisation de la base de données (20%)
      await _updateProgress(0.2, 'Initialisation de la base de données...');
      await DatabaseHelper.instance.database; // Force l'initialisation de la BD
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Étape 2 : Chargement du cheptel (40%)
      await _updateProgress(0.4, 'Chargement du cheptel...');
      await lapinProvider.chargerLapins();
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Étape 3 : Chargement des données de reproduction (60%)
      await _updateProgress(0.6, 'Chargement des reproductions...');
      await reproProvider.chargerAccouplements();
      await reproProvider.chargerPortees();
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Étape 4 : Chargement des données de santé (80%)
      await _updateProgress(0.8, 'Chargement des données de santé...');
      await santeProvider.chargerSoins();
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Étape 5 : Chargement des finances (90%)
      await _updateProgress(0.9, 'Chargement des finances...');
      await financeProvider.chargerTout();
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Étape 6 : Finalisation (100%)
      await _updateProgress(1.0, 'Prêt !');
      await Future.delayed(const Duration(milliseconds: 500));

      // Démarrer la synchronisation automatique si l'utilisateur est authentifié
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);

      if (authProvider.state != AuthState.unauthenticated) {
        syncProvider.startAutoSync(connectivityProvider);
      }

      // Naviguer vers le prochain écran
      if (!mounted) return;
      await _navigateToNextScreen();
    } catch (e) {
      // En cas d'erreur, afficher un message et continuer quand même
      if (mounted) {
        await _updateProgress(1.0, 'Erreur de chargement, redirection...');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          await _navigateToNextScreen();
        }
      }
    }
  }

  /// Met à jour la progression
  Future<void> _updateProgress(double progress, String message) async {
    if (!mounted) return;
    setState(() {
      _progress = progress;
    });
  }

  /// Navigation vers le prochain écran selon l'état d'authentification
  /// 
  /// Flux :
  /// 1. Vérifier l'état d'authentification
  /// 2. Si non authentifié → AuthScreen
  /// 3. Si authentifié avec PIN → PinScreen (offline) ou HomeScreen (online)
  /// 4. Si authentifié sans PIN → WelcomeScreen ou HomeScreen
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final connectivityProvider =
          Provider.of<ConnectivityProvider>(context, listen: false);

      // Attendre que les providers soient initialisés
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      final authState = authProvider.state;
      final isOnline = connectivityProvider.isOnline;
      final hasPin = await authProvider.isPinSet();

      Widget nextScreen;

      // Déterminer l'écran suivant selon l'état
      if (authState == AuthState.unauthenticated) {
        // Non authentifié → Vérifier si on peut créer/se connecter
        if (isOnline) {
          // Online → AuthScreen pour créer/se connecter
          nextScreen = const AuthScreen(initialIsSignUp: false);
        } else {
          // Offline et pas de compte → Message d'erreur ou AuthScreen avec message
          // On affiche quand même AuthScreen mais avec un message indiquant qu'une connexion est nécessaire
          nextScreen = const AuthScreen(initialIsSignUp: false);
        }
      } else if (authState == AuthState.authenticatedWithPin || hasPin) {
        // Authentifié avec PIN configuré (online ou offline)
        if (isOnline) {
          // Online → HomeScreen directement (pas besoin de PIN si session Supabase active)
          // Mais on peut quand même demander le PIN pour sécurité
          nextScreen = const PinScreen();
        } else {
          // Offline → PinScreen pour déverrouillage
          nextScreen = const PinScreen();
        }
      } else if (authState == AuthState.authenticatedNoPin) {
        // Authentifié mais PIN non configuré
        // Vérifier si WelcomeScreen a été vu
        final hasSeenWelcome = await WelcomeScreen.hasSeenWelcome();
        nextScreen = hasSeenWelcome
            ? const HomeScreen()
            : const WelcomeScreen();
      } else {
        // État initial ou erreur → Vérifier WelcomeScreen
        final hasSeenWelcome = await WelcomeScreen.hasSeenWelcome();
        nextScreen = hasSeenWelcome
            ? const AuthScreen(initialIsSignUp: false)
            : const WelcomeScreen();
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      // En cas d'erreur, naviguer vers AuthScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AuthScreen(initialIsSignUp: false),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.stitchBackgroundDark
          : AppTheme.stitchBackgroundLight,
      body: Stack(
        children: [
          // Dégradé radial en arrière-plan
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.stitchBackgroundDark
                    : AppTheme.stitchBackgroundLight,
              ),
              child: Stack(
                children: [
                  // Cercle radial en haut à gauche
                  Positioned(
                    top: -MediaQuery.of(context).size.height * 0.1,
                    left: -MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: MediaQuery.of(context).size.height * 0.5,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Cercle radial en bas à droite
                  Positioned(
                    bottom: -MediaQuery.of(context).size.height * 0.1,
                    right: -MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: MediaQuery.of(context).size.height * 0.5,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Espaceur en haut
                const Spacer(),

                // Logo et branding central
                Column(
                  children: [
                    // Logo avec glow effect
                    _buildLogoWithGlow(isDark),
                    const SizedBox(height: 32),

                    // Titre et sous-titre
                    Column(
                      children: [
                        Text(
                          'RabbitManager',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDark
                                ? AppTheme.stitchTextMainDark
                                : AppTheme.stitchTextMainLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Smart Farm Management',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Espaceur au milieu
                const Spacer(),

                // Zone de progression en bas
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                  child: Column(
                    children: [
                      // Barre de progression avec labels
                      _buildProgressBar(isDark),
                      const SizedBox(height: 24),

                      // Version
                      Text(
                        'v1.1.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le logo avec effet de glow
  Widget _buildLogoWithGlow(bool isDark) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? AppTheme.stitchSurfaceDark
              : AppTheme.stitchSurfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.cruelty_free,
            size: 64,
            color: AppTheme.primaryNeonGreen,
          ),
        ),
      ),
    );
  }

  /// Construit la barre de progression avec labels
  Widget _buildProgressBar(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels (LOADING et pourcentage)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LOADING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.primaryNeonGreen,
              ),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.grey.shade500
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Barre de progression
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDark
                ? AppTheme.stitchSurfaceDark
                : const Color(0xFFcfe7d1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Fond
                Container(
                  width: double.infinity,
                  height: 8,
                  color: isDark
                      ? AppTheme.stitchSurfaceDark
                      : const Color(0xFFcfe7d1),
                ),
                // Barre de progression
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: constraints.maxWidth * _progress,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppTheme.primaryNeonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryNeonGreen.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildShimmerEffect(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Effet shimmer sur la barre de progression
  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.linear,
      onEnd: () {
        if (mounted && _progress < 1.0) {
          setState(() {});
        }
      },
      builder: (context, value, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.primaryNeonGreen,
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(value * 200, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
