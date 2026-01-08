import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/uniform_app_bar.dart';
import '../home_screen.dart';

/// Écran de configuration du PIN
///
/// Permet à l'utilisateur de configurer un PIN pour l'authentification offline
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();

  bool _isObscured = true;
  bool _isConfirmObscured = true;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleSetupPin() async {
    if (!mounted) return;

    _clearError();

    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    // Validation
    if (pin.isEmpty || confirmPin.isEmpty) {
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

    // Vérifier que ce sont uniquement des chiffres
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).authValidationChiffresPIN;
      });
      return;
    }

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).authValidationPINDifferent;
      });
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Configurer le PIN
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setupPin(pin);

    if (!mounted) return;
    Navigator.pop(context); // Fermer le dialog de chargement

    if (success) {
      // Navigation vers HomeScreen
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
      setState(() {
        _errorMessage =
            authProvider.errorMessage ??
            AppLocalizations.of(context).authErreurConfigurationPIN;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.stitchBackgroundDark
          : AppTheme.stitchBackgroundLight,
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).authConfigurationPIN,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Titre
              Text(
                AppLocalizations.of(context).authConfigurezPIN,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppTheme.textOnPrimary
                      : AppTheme.stitchTextDark,
                ),
              ),

              const SizedBox(height: 8),

              // Sous-titre
              Text(
                AppLocalizations.of(context).authCreezPINInstructions,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.neutral400 : AppTheme.neutral600,
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
                onSubmitted: (_) {
                  _confirmPinFocusNode.requestFocus();
                },
              ),

              const SizedBox(height: 20),

              // Champ confirmation PIN
              TextField(
                controller: _confirmPinController,
                focusNode: _confirmPinFocusNode,
                obscureText: _isConfirmObscured,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).authConfirmerPIN,
                  hintText: AppLocalizations.of(context).authHintConfirmerPIN,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmObscured = !_isConfirmObscured;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: '',
                ),
                onChanged: (_) => _clearError(),
                onSubmitted: (_) => _handleSetupPin(),
              ),

              // Message d'erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.error300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.error700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppTheme.error700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Bouton de configuration
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSetupPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeonGreen,
                    foregroundColor: AppTheme.authPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).authConfigurerPIN,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Note de sécurité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.info900.withValues(alpha: 0.3)
                      : AppTheme.info50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).authNotePINSecurite,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.info200 : AppTheme.info900,
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
