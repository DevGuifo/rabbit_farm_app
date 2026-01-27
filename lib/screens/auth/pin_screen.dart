import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import 'auth_screen.dart';
import '../../utils/onboarding_navigation_helper.dart';

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
        _errorMessage = AppLocalizations.of(context).authValidationEntrezPIN;
      });
      return;
    }

    if (pin.length < 4 || pin.length > 6) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).authValidationLongueurPIN;
      });
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).authValidationChiffresPIN;
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
      // PIN valide, navigation basée sur le statut d'onboarding
      OnboardingNavigationHelper.navigateBasedOnOnboardingStatus(context);
    } else {
      // PIN invalide
      _attempts++;
      if (_attempts >= _maxAttempts) {
        _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
        setState(() {
          _errorMessage = AppLocalizations.of(context).authTropTentatives;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(
            context,
          ).authPINIncorrect(_maxAttempts - _attempts);
        });
      }
      _pinController.clear();
    }
  }

  Future<void> _handleForgotPin() async {
    if (!mounted) return;

    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );

    // Vérifier la connectivité
    if (!connectivityProvider.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authConnexionRequise),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).authReinitialiserPIN),
        content: Text(
          AppLocalizations.of(context).authReinitialisationPINMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).quarantaineAnnuler),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).authContinuer),
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
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
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).authModeHorsLigne,
                          style: const TextStyle(
                            color: AppTheme.warning,
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
                AppLocalizations.of(context).authDeverrouiller,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // Sous-titre
              Text(
                AppLocalizations.of(context).authEntrezPIN,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary,
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
                  labelText: AppLocalizations.of(context).authPIN,
                  hintText: AppLocalizations.of(context).authHintPIN,
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
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppTheme.error),
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
                  onPressed: (_isLocked() || _isLoading)
                      ? null
                      : _handleValidatePin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeonGreen,
                    foregroundColor: AppTheme.authPrimary,
                    elevation: 0,
                    disabledBackgroundColor: AppTheme.neutral300,
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
                              AppTheme.authPrimary,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).authDeverrouiller,
                          style: const TextStyle(
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
                    child: Text(
                      AppLocalizations.of(context).authMotDePINOublie,
                      style: const TextStyle(
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
                      ? AppTheme.info.withValues(alpha: 0.3)
                      : AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).authNoteSecurite,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.info.withValues(alpha: 0.3)
                              : AppTheme.info,
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
