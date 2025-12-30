import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../home_screen.dart';
import 'auth_screen.dart';

/// Écran de déverrouillage PIN (offline)
/// 
/// Permet à l'utilisateur de déverrouiller l'application avec son PIN
/// sans nécessiter de connexion Internet
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isObscured = true;
  String? _errorMessage;
  int _attempts = 0;
  static const int _maxAttempts = 5;
  DateTime? _lockedUntil;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Focus automatique sur le champ PIN
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  bool _isLocked() {
    if (_lockedUntil == null) return false;
    return DateTime.now().isBefore(_lockedUntil!);
  }

  Duration _getRemainingLockoutTime() {
    if (_lockedUntil == null) return Duration.zero;
    final remaining = _lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _handleValidatePin() async {
    if (!mounted) return;

    // Vérifier si verrouillé
    if (_isLocked()) {
      final remaining = _getRemainingLockoutTime();
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      setState(() {
        _errorMessage =
            'Trop de tentatives. Réessayez dans ${minutes}m ${seconds}s';
      });
      return;
    }

    _clearError();

    final pin = _pinController.text;

    // Validation
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre PIN';
      });
      return;
    }

    if (pin.length < 4 || pin.length > 6) {
      setState(() {
        _errorMessage = 'Le PIN doit contenir entre 4 et 6 chiffres';
      });
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'Le PIN ne doit contenir que des chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Valider le PIN
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.validatePin(pin);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // PIN valide, navigation vers HomeScreen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      // PIN invalide
      _attempts++;
      if (_attempts >= _maxAttempts) {
        _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
        setState(() {
          _errorMessage =
              'Trop de tentatives. Réessayez dans 5 minutes';
        });
      } else {
        setState(() {
          _errorMessage =
              'PIN incorrect. Tentatives restantes: ${_maxAttempts - _attempts}';
        });
      }
      _pinController.clear();
    }
  }

  Future<void> _handleForgotPin() async {
    if (!mounted) return;

    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);

    // Vérifier la connectivité
    if (!connectivityProvider.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une connexion Internet est requise pour réinitialiser le PIN',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le PIN'),
        content: const Text(
          'Pour réinitialiser votre PIN, vous devrez vous reconnecter avec votre email et mot de passe. '
          'Souhaitez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Déconnecter et naviguer vers AuthScreen
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(initialIsSignUp: false),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.stitchBackgroundDark
          : AppTheme.stitchBackgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Indicateur de connexion
              if (!connectivityProvider.isOnline)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode hors ligne - Déverrouillage par PIN',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Logo ou icône
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.primaryNeonGreen,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: AppTheme.primaryNeonGreen,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Titre
              Text(
                'Déverrouiller',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111812),
                ),
              ),

              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'Entrez votre PIN pour accéder à l\'application',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Champ PIN
              TextField(
                controller: _pinController,
                focusNode: _pinFocusNode,
                obscureText: _isObscured,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enabled: !_isLocked() && !_isLoading,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  hintText: 'Entrez votre PIN',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: '',
                ),
                onChanged: (_) => _clearError(),
                onSubmitted: (_) => _handleValidatePin(),
              ),

              // Message d'erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Bouton de déverrouillage
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_isLocked() || _isLoading) ? null : _handleValidatePin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeonGreen,
                    foregroundColor: const Color(0xFF052e0a),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF052e0a),
                            ),
                          ),
                        )
                      : const Text(
                          'Déverrouiller',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Lien "Mot de PIN oublié"
              if (connectivityProvider.isOnline)
                Center(
                  child: TextButton(
                    onPressed: _handleForgotPin,
                    child: const Text(
                      'Mot de PIN oublié ?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Note de sécurité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.shade900.withValues(alpha: 0.3)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le PIN est stocké de manière sécurisée sur votre appareil. '
                        'Vous pouvez déverrouiller l\'application même sans Internet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.blue.shade200
                              : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

