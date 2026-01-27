import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../config/supabase_config.dart';
import '../providers/connectivity_provider.dart';
import '../utils/logger.dart';

/// État de synchronisation
enum SyncState {
  /// Aucune synchronisation en cours
  idle,

  /// Synchronisation en cours
  syncing,

  /// Synchronisation réussie
  success,

  /// Erreur de synchronisation
  error,

  /// Synchronisation non disponible (onboarding non terminé ou Supabase non configuré)
  unavailable,

  /// En attente de connexion réseau
  waitingForNetwork,
}

/// Provider pour gérer la synchronisation (offline-first avec Supabase)
///
/// Gère :
/// - L'état de synchronisation
/// - Le comptage des éléments en attente
/// - La synchronisation automatique après onboarding
/// - L'intégration avec Supabase
///
/// IMPORTANT: La sync ne démarre QUE si :
/// 1. L'onboarding est terminé (synchronisationAutorisee = true)
/// 2. Supabase est configuré
/// 3. Une connexion réseau est disponible
class SyncProvider extends ChangeNotifier {
  static final SyncProvider _instance = SyncProvider._internal();
  factory SyncProvider() => _instance;
  SyncProvider._internal();

  final SyncService _syncService = SyncService();
  StreamSubscription<int>? _pendingCountSubscription;

  SyncState _state = SyncState.unavailable;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  bool _isAutoSyncActive = false;
  bool _onboardingCompleted = false;
  bool _syncAuthorized = false;

  // ============= GETTERS =============

  SyncState get state => _state;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime ?? _syncService.lastSyncTime;
  int get pendingChanges => _pendingChanges;
  bool get isSyncing => _state == SyncState.syncing;
  bool get hasError => _state == SyncState.error;
  bool get isAutoSyncActive => _isAutoSyncActive;

  /// Indique si la sync est possible (toutes conditions remplies)
  bool get canSync =>
      _onboardingCompleted && _syncAuthorized && supabaseConfig.isInitialized;

  /// Message explicatif de l'état actuel
  String get statusMessage {
    switch (_state) {
      case SyncState.idle:
        return _pendingChanges > 0
            ? '$_pendingChanges modification(s) en attente'
            : 'Tout est synchronisé';
      case SyncState.syncing:
        return 'Synchronisation en cours...';
      case SyncState.success:
        return 'Synchronisation réussie';
      case SyncState.error:
        return _errorMessage ?? 'Erreur de synchronisation';
      case SyncState.unavailable:
        if (!_onboardingCompleted) {
          return 'Terminez l\'onboarding pour activer la sync';
        }
        if (!supabaseConfig.isInitialized) {
          return 'Mode hors ligne (Supabase non configuré)';
        }
        return 'Synchronisation non disponible';
      case SyncState.waitingForNetwork:
        return 'En attente de connexion...';
    }
  }

  // ============= INITIALISATION =============

  /// Initialiser le provider
  Future<void> initialize() async {
    try {
      await _syncService.initialize();

      // Écouter les changements de pending count
      _pendingCountSubscription = _syncService.pendingCountStream.listen((
        count,
      ) {
        _pendingChanges = count;
        notifyListeners();
      });

      // Charger le nombre de changements en attente
      await _refreshPendingCount();

      // Déterminer l'état initial
      _updateState();

      logger.info('✅ SyncProvider initialisé (pending: $_pendingChanges)');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation SyncProvider: $e');
      _setState(SyncState.error);
      _errorMessage = e.toString();
    }
  }

  /// Mettre à jour l'état du provider après onboarding
  ///
  /// Appelé par OnboardingProvider quand l'onboarding est terminé
  void onOnboardingCompleted({bool syncAuthorized = true}) {
    _onboardingCompleted = true;
    _syncAuthorized = syncAuthorized;
    _updateState();

    if (canSync) {
      logger.info('🎉 Onboarding terminé, synchronisation activée');
      // Démarrer auto-sync si autorisé
      if (_syncAuthorized && !_isAutoSyncActive) {
        _syncService.startAutoSync();
        _isAutoSyncActive = true;
      }
    } else {
      logger.info('ℹ️ Onboarding terminé, sync désactivée par l\'utilisateur');
    }

    notifyListeners();
  }

  /// Charger l'état d'onboarding existant (au démarrage de l'app)
  void setOnboardingState({
    required bool completed,
    required bool syncAuthorized,
  }) {
    _onboardingCompleted = completed;
    _syncAuthorized = syncAuthorized;
    _updateState();
    notifyListeners();
  }

  /// Met à jour l'état en fonction des conditions
  void _updateState() {
    if (!_onboardingCompleted || !_syncAuthorized) {
      _setState(SyncState.unavailable);
    } else if (!supabaseConfig.isInitialized) {
      _setState(SyncState.unavailable);
    } else if (_state != SyncState.syncing) {
      _setState(SyncState.idle);
    }
  }

  // ============= COMPTAGE DES CHANGEMENTS =============

  /// Rafraîchir le compteur d'éléments en attente
  Future<void> _refreshPendingCount() async {
    _pendingChanges = await _syncService.refreshPendingCount();
    notifyListeners();
  }

  /// Obtenir le nombre de changements en attente (méthode publique)
  Future<int> getPendingCount() async {
    await _refreshPendingCount();
    return _pendingChanges;
  }

  // ============= SYNCHRONISATION =============

  /// Synchroniser maintenant
  ///
  /// Retourne true si la sync a réussi, false sinon.
  /// Ne fait rien si l'onboarding n'est pas terminé ou si Supabase n'est pas configuré.
  Future<bool> syncNow() async {
    // Vérifications préalables
    if (!canSync) {
      logger.info(
        'ℹ️ Sync non disponible: onboarding=$_onboardingCompleted, '
        'authorized=$_syncAuthorized, supabase=${supabaseConfig.isInitialized}',
      );
      _setState(SyncState.unavailable);
      return false;
    }

    if (_state == SyncState.syncing) {
      logger.warning('⚠️ Synchronisation déjà en cours');
      return false;
    }

    _setState(SyncState.syncing);
    _clearError();
    notifyListeners();

    try {
      final result = await _syncService.syncNow();

      if (result.success) {
        _lastSyncTime = DateTime.now();
        _setState(SyncState.success);
        logger.info('✅ Sync réussie: ${result.syncedCount} éléments');

        // Revenir à idle après un délai
        Future.delayed(const Duration(seconds: 3), () {
          if (_state == SyncState.success) {
            _setState(SyncState.idle);
          }
        });

        return true;
      } else {
        _setError(
          result.errors.isNotEmpty
              ? result.errors.first
              : 'Échec de la synchronisation',
        );
        return false;
      }
    } catch (e) {
      logger.error('❌ Erreur sync: $e');
      _setError(e.toString());
      return false;
    } finally {
      await _refreshPendingCount();
      notifyListeners();
    }
  }

  // ============= AUTO-SYNC =============

  /// Démarrer la synchronisation automatique
  void startAutoSync(ConnectivityProvider connectivityProvider) {
    if (_isAutoSyncActive) {
      logger.warning('⚠️ Auto-sync déjà active');
      return;
    }

    if (!canSync) {
      logger.info('ℹ️ Auto-sync non démarrée: conditions non remplies');
      return;
    }

    _syncService.startAutoSync();
    _isAutoSyncActive = true;
    logger.info('📡 Auto-sync activée');
    notifyListeners();
  }

  /// Arrêter la synchronisation automatique
  void stopAutoSync() {
    if (!_isAutoSyncActive) return;

    _syncService.stopAutoSync();
    _isAutoSyncActive = false;
    logger.info('🛑 Auto-sync désactivée');
    notifyListeners();
  }

  /// Activer/désactiver la sync (depuis les paramètres)
  void setSyncEnabled(bool enabled) {
    _syncAuthorized = enabled;

    if (enabled && _onboardingCompleted && !_isAutoSyncActive) {
      startAutoSync(ConnectivityProvider());
    } else if (!enabled && _isAutoSyncActive) {
      stopAutoSync();
    }

    _updateState();
    notifyListeners();
  }

  // ============= GESTION D'ÉTAT =============

  void _setState(SyncState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(SyncState.error);
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Réinitialiser l'état
  void reset() {
    _clearError();
    _onboardingCompleted = false;
    _syncAuthorized = false;
    _pendingChanges = 0;
    _lastSyncTime = null;
    stopAutoSync();
    _setState(SyncState.unavailable);
    notifyListeners();
  }

  @override
  void dispose() {
    _pendingCountSubscription?.cancel();
    stopAutoSync();
    super.dispose();
  }
}
