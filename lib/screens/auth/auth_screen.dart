import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/supabase_auth_service.dart';
import '../home_screen.dart';
import 'pin_setup_screen.dart';
import 'widgets/auth_hero_section.dart';
import 'widgets/auth_toggle_tabs.dart';
import 'widgets/auth_form_fields.dart';
import 'widgets/auth_social_buttons.dart';
import 'widgets/auth_footer.dart';

/// Écran d'authentification (Sign In / Sign Up)
/// Affiche le design Stitch avec formulaire, toggle Sign In/Sign Up, et boutons sociaux
class AuthScreen extends StatefulWidget {
  /// Mode initial : true pour Sign Up, false pour Sign In
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // État du toggle Sign In / Sign Up
  late bool _isSignUp;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  // Controllers pour les champs du formulaire
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleToggle(bool isSignUp) {
    setState(() {
      _isSignUp = isSignUp;
    });
  }

  Future<void> _handleSignUp() async {
    if (!context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Note: On permet la création de compte même si Supabase n'est pas disponible
    // Un compte local sera créé en mode offline

    // Validation basique
    if (_isSignUp) {
      if (_fullNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le mot de passe doit contenir au moins 6 caractères'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Note: L'inscription fonctionne maintenant en mode offline
      // Si Supabase est disponible, on l'utilise, sinon on crée un compte local

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Inscription
      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop(); // Fermer le dialog de chargement

      if (success) {
        if (!mounted) return;
        // Navigation vers l'écran de configuration du PIN
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PinSetupScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        if (!mounted) return;
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Erreur lors de l\'inscription',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Sign In
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Note: La connexion fonctionne maintenant en mode offline
      // Si Supabase est disponible, on l'utilise, sinon on vérifie un compte local

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Connexion
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop(); // Fermer le dialog de chargement

      if (success) {
        // Vérifier si un PIN est configuré
        final hasPin = await authProvider.isPinSet();

        if (!mounted) return;
        if (hasPin) {
          // Navigation vers HomeScreen (le PIN sera demandé au démarrage)
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          // Navigation vers l'écran de configuration du PIN
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PinSetupScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      } else {
        if (!mounted) return;
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Erreur lors de la connexion',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    // Google Sign In nécessite une configuration supplémentaire (google_sign_in package)
    // Pour l'instant, désactivé - sera implémenté dans une version future
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign In sera disponible dans une prochaine version'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleAppleSignIn() {
    // Apple Sign In nécessite une configuration supplémentaire (sign_in_with_apple package)
    // Pour l'instant, désactivé - sera implémenté dans une version future
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign In sera disponible dans une prochaine version'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleTermsPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'En utilisant cette application, vous acceptez les conditions suivantes :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Utilisation :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('L\'application est destinée à la gestion d\'élevage de lapins.'),
              const SizedBox(height: 8),
              const Text(
                '2. Données :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Vous êtes responsable de la sauvegarde de vos données.'),
              const SizedBox(height: 8),
              const Text(
                '3. Responsabilité :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('L\'application est fournie "en l\'état" sans garantie.'),
              const SizedBox(height: 16),
              const Text(
                'Pour les conditions complètes, contactez le support.',
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

  void _handlePrivacyPressed() {
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
              const Text('• Synchronisation optionnelle avec Supabase (chiffrée)'),
              const SizedBox(height: 16),
              const Text(
                'Sécurité :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Authentification sécurisée (Supabase)'),
              const Text('• PIN local pour accès offline'),
              const Text('• Chiffrement des données sensibles'),
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

  void _handleForgotPassword() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'votre@email.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              
              if (email.isEmpty || !email.contains('@')) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer une adresse email valide'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Afficher un indicateur de chargement
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final authService = SupabaseAuthService();
                await authService.resetPassword(email);

                if (!context.mounted) return;
                Navigator.pop(context); // Fermer le dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Email de réinitialisation envoyé. Vérifiez votre boîte de réception.',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context); // Fermer le dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final isOnline = connectivityProvider.isOnline;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.stitchBackgroundDark
          : AppTheme.stitchBackgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message d'avertissement si offline
              if (!isOnline)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mode hors ligne',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Une connexion Internet est requise pour créer un compte ou vous connecter pour la première fois.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Hero Section
              const AuthHeroSection(),

              // Titre et sous-titre (dynamiques selon Sign In / Sign Up)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Join the\nCommunity' : 'Welcome to\nthe Hutch',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF111812),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Start your digital hutch today.'
                          : 'Manage your breeding program with ease.',
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
              ),

              // Toggle Sign In / Sign Up
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AuthToggleTabs(
                  isSignUp: _isSignUp,
                  onToggle: _handleToggle,
                ),
              ),

              // Formulaire
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AuthFormFields(
                  isSignUp: _isSignUp,
                  fullNameController:
                      _isSignUp ? _fullNameController : null,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController:
                      _isSignUp ? _confirmPasswordController : null,
                  onForgotPassword: _isSignUp
                      ? null
                      : () => _handleForgotPassword(),
                ),
              ),

              // Bouton principal
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeonGreen,
                      foregroundColor: const Color(0xFF052e0a),
                      elevation: 0,
                      shadowColor:
                          AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF052e0a),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Color(0xFF052e0a),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Boutons sociaux
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: AuthSocialButtons(
                  isSignUp: _isSignUp,
                  onGooglePressed: _handleGoogleSignIn,
                  onApplePressed: _handleAppleSignIn,
                ),
              ),

              // Footer (uniquement pour Sign Up)
              if (_isSignUp)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AuthFooter(
                    onTermsPressed: _handleTermsPressed,
                    onPrivacyPressed: _handlePrivacyPressed,
                  ),
                ),

              // Espace en bas
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

