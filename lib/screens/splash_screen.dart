import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../providers/lapin_provider.dart';
import '../providers/reproduction_provider.dart';
import '../providers/sante_provider.dart';
import '../providers/finance_provider.dart';
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
  String _loadingMessage = 'Initialisation...';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Lancer l'initialisation de l'application
    _initializeApp();
  }

  /// Initialise tous les composants de l'application de manière progressive
  Future<void> _initializeApp() async {
    try {
      // Étape 1 : Initialisation de la base de données (20%)
      await _updateProgress(0.2, 'Initialisation de la base de données...');
      await DatabaseHelper.instance.database; // Force l'initialisation de la BD
      await Future.delayed(const Duration(milliseconds: 500));

      // Étape 2 : Chargement du cheptel (40%)
      await _updateProgress(0.4, 'Chargement du cheptel...');
      final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
      await lapinProvider.chargerLapins();
      await Future.delayed(const Duration(milliseconds: 400));

      // Étape 3 : Chargement des données de reproduction (60%)
      await _updateProgress(0.6, 'Chargement des reproductions...');
      final reproProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproProvider.chargerAccouplements();
      await reproProvider.chargerPortees();
      await Future.delayed(const Duration(milliseconds: 400));

      // Étape 4 : Chargement des données de santé (80%)
      await _updateProgress(0.8, 'Chargement des données de santé...');
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.chargerSoins();
      await Future.delayed(const Duration(milliseconds: 400));

      // Étape 5 : Chargement des finances (90%)
      await _updateProgress(0.9, 'Chargement des finances...');
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      await financeProvider.chargerTout();
      await Future.delayed(const Duration(milliseconds: 300));

      // Étape 6 : Finalisation (100%)
      await _updateProgress(1.0, 'Prêt !');
      await Future.delayed(const Duration(milliseconds: 500));

      // Marquer comme initialisé et naviguer
      setState(() => _isInitialized = true);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      // En cas d'erreur, afficher un message et continuer quand même
      await _updateProgress(1.0, 'Erreur de chargement, redirection...');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _navigateToHome();
    }
  }

  /// Met à jour la progression et le message affiché
  Future<void> _updateProgress(double progress, String message) async {
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _loadingMessage = message;
    });
  }

  /// Navigation vers HomeScreen avec animation fluide
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback : fond dégradé vert si l'image n'existe pas
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4CAF50),
                        const Color(0xFF2E7D32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Zone de progression en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barre de progression
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          width: MediaQuery.of(context).size.width * _progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pourcentage de progression
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_progress < 1.0)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        if (_progress >= 1.0 && _isInitialized)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Message de chargement
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingMessage,
                        key: ValueKey<String>(_loadingMessage),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Version de l'app
                    Text(
                      'Version 1.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
