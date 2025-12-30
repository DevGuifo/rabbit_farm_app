import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

/// Provider pour gérer la connectivité réseau
/// 
/// Détecte si l'appareil est connecté à Internet
class ConnectivityProvider extends ChangeNotifier {
  static final ConnectivityProvider _instance = ConnectivityProvider._internal();
  factory ConnectivityProvider() => _instance;
  ConnectivityProvider._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _isInitialized = false;

  /// Initialiser le provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Vérifier l'état initial
      final result = await _connectivity.checkConnectivity();
      _isOnline = _isConnectedFromResult(result);
      _isInitialized = true;

      // Écouter les changements
      _connectivity.onConnectivityChanged.listen((result) {
        final wasOnline = _isOnline;
        _isOnline = _isConnectedFromResult(result);

        if (wasOnline != _isOnline) {
          logger.info(
            _isOnline ? '🌐 Connexion réseau rétablie' : '📴 Connexion réseau perdue',
          );
          notifyListeners();
        }
      });

      logger.info('✅ ConnectivityProvider initialisé (online: $_isOnline)');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation ConnectivityProvider: $e');
      // Par défaut, considérer comme online
      _isOnline = true;
      _isInitialized = true;
    }
  }

  /// Vérifier si le résultat de connectivité indique une connexion (pour List)
  bool _isConnectedFromList(List<ConnectivityResult> results) {
    // Si aucun résultat, considérer comme offline
    if (results.isEmpty) return false;

    // Vérifier si au moins un type de connexion est disponible
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }

    return false;
  }

  /// Vérifier si le résultat de connectivité indique une connexion (pour single result)
  bool _isConnectedFromResult(dynamic result) {
    // Gérer le cas où checkConnectivity retourne une List
    if (result is List<ConnectivityResult>) {
      return _isConnectedFromList(result);
    }
    // Gérer le cas où checkConnectivity retourne un ConnectivityResult unique
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }

  /// Vérifier manuellement la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = _isConnectedFromResult(result);

      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        notifyListeners();
      }

      return isConnected;
    } catch (e) {
      logger.error('❌ Erreur lors de la vérification de connectivité: $e');
      return _isOnline; // Retourner l'état actuel en cas d'erreur
    }
  }

  /// Vérifier si l'appareil est en ligne
  bool get isOnline => _isOnline;

  /// Vérifier si l'appareil est hors ligne
  bool get isOffline => !_isOnline;

  /// Disposer des ressources
  @override
  void dispose() {
    // Connectivity n'a pas besoin de dispose explicite
    super.dispose();
  }
}

