import 'package:flutter/foundation.dart';
import '../services/supabase_sync_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/database_helper.dart';
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
}

/// Provider pour gérer la synchronisation
/// 
/// Gère :
/// - L'état de synchronisation
/// - La synchronisation automatique
/// - La synchronisation manuelle
/// - Les erreurs de synchronisation
class SyncProvider extends ChangeNotifier {
  static final SyncProvider _instance = SyncProvider._internal();
  factory SyncProvider() => _instance;
  SyncProvider._internal();

  final SupabaseSyncService _syncService = SupabaseSyncService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  SyncState _state = SyncState.idle;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  ConnectivityProvider? _connectivityProvider;
  bool _isAutoSyncActive = false;

  // ============= GETTERS =============

  SyncState get state => _state;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChanges => _pendingChanges;
  bool get isSyncing => _state == SyncState.syncing;
  bool get hasError => _state == SyncState.error;

  // ============= INITIALISATION =============

  /// Initialiser le provider
  Future<void> initialize() async {
    try {
      // Charger le timestamp de dernière sync
      final syncService = SupabaseSyncService();
      _lastSyncTime = syncService.lastSyncTime;

      // Compter les changements en attente
      await _countPendingChanges();

      logger.info('✅ SyncProvider initialisé');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation SyncProvider: $e');
    }
  }

  // ============= SYNCHRONISATION MANUELLE =============

  /// Synchroniser manuellement toutes les données
  /// 
  /// Retourne true si la synchronisation réussit
  Future<bool> syncNow() async {
    if (_state == SyncState.syncing) {
      logger.warning('⚠️ Synchronisation déjà en cours');
      return false;
    }

    if (!_authService.isAuthenticated) {
      _setError('Utilisateur non authentifié');
      return false;
    }

    _setState(SyncState.syncing);
    _clearError();

    try {
      logger.info('🔄 Synchronisation manuelle démarrée');

      final success = await _syncService.syncAll();

      if (success) {
        _lastSyncTime = _syncService.lastSyncTime;
        await _countPendingChanges();
        _setState(SyncState.success);
        logger.info('✅ Synchronisation manuelle réussie');
        return true;
      } else {
        _setError('Échec de la synchronisation');
        return false;
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la synchronisation: $e');
      _setError(e.toString());
      return false;
    }
  }

  // ============= SYNCHRONISATION AUTOMATIQUE =============

  /// Synchroniser automatiquement si les conditions sont remplies
  /// 
  /// Conditions :
  /// - Utilisateur authentifié
  /// - Connectivité réseau disponible
  /// - Pas de synchronisation en cours
  Future<bool> autoSync({
    required ConnectivityProvider connectivityProvider,
  }) async {
    // Vérifier les conditions
    if (!_authService.isAuthenticated) {
      logger.debug('⏭️ Auto-sync ignorée : utilisateur non authentifié');
      return false;
    }

    if (!connectivityProvider.isOnline) {
      logger.debug('⏭️ Auto-sync ignorée : pas de connexion');
      return false;
    }

    if (_state == SyncState.syncing) {
      logger.debug('⏭️ Auto-sync ignorée : synchronisation déjà en cours');
      return false;
    }

    // Vérifier s'il y a des changements en attente
    await _countPendingChanges();
    if (_pendingChanges == 0) {
      logger.debug('⏭️ Auto-sync ignorée : aucun changement en attente');
      return false;
    }

    // Lancer la synchronisation
    logger.info('🔄 Auto-sync démarrée ($_pendingChanges changements en attente)');
    return await syncNow();
  }

  // ============= COMPTAGE DES CHANGEMENTS =============

  /// Compter les enregistrements avec is_dirty = 1
  Future<void> _countPendingChanges() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final tables = [
        'lapins',
        'accouplements',
        'portees',
        'pesees',
        'soins',
        'recettes',
        'depenses',
        'deces',
      ];

      int total = 0;

      for (final table in tables) {
        try {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table WHERE is_dirty = 1',
          );
          total += result.first['count'] as int? ?? 0;
        } catch (e) {
          // Table peut ne pas avoir les champs de sync encore
          logger.debug('⚠️ Impossible de compter les changements pour $table: $e');
        }
      }

      _pendingChanges = total;
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors du comptage des changements: $e');
    }
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
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == SyncState.error) {
      _setState(SyncState.idle);
    }
  }

  /// Réinitialiser l'état d'erreur
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Réinitialiser l'état après un succès
  void resetState() {
    if (_state == SyncState.success) {
      _setState(SyncState.idle);
    }
  }

  // ============= SYNCHRONISATION AUTOMATIQUE EN ARRIÈRE-PLAN =============

  /// Démarrer la synchronisation automatique
  /// 
  /// Écoute les changements de connectivité et synchronise automatiquement
  /// quand l'utilisateur est authentifié et en ligne
  void startAutoSync(ConnectivityProvider connectivityProvider) {
    if (_isAutoSyncActive) {
      logger.debug('⚠️ Auto-sync déjà active');
      return;
    }

    _connectivityProvider = connectivityProvider;
    _isAutoSyncActive = true;

    // Écouter les changements de connectivité
    connectivityProvider.addListener(_handleConnectivityChange);

    // Tenter une synchronisation immédiate si les conditions sont remplies
    _tryAutoSync();

    logger.info('✅ Auto-sync démarrée');
  }

  /// Arrêter la synchronisation automatique
  void stopAutoSync() {
    if (!_isAutoSyncActive) return;

    if (_connectivityProvider != null) {
      _connectivityProvider!.removeListener(_handleConnectivityChange);
      _connectivityProvider = null;
    }

    _isAutoSyncActive = false;
    logger.info('⏸️ Auto-sync arrêtée');
  }

  /// Gérer les changements de connectivité
  void _handleConnectivityChange() {
    if (!_isAutoSyncActive || _connectivityProvider == null) return;

    // Si la connexion est rétablie, tenter une synchronisation
    if (_connectivityProvider!.isOnline) {
      _tryAutoSync();
    }
  }

  /// Tenter une synchronisation automatique
  Future<void> _tryAutoSync() async {
    if (_connectivityProvider == null) return;

    // Attendre un court délai pour éviter les synchronisations trop fréquentes
    await Future.delayed(const Duration(seconds: 2));

    if (!_isAutoSyncActive || _connectivityProvider == null) return;

    await autoSync(connectivityProvider: _connectivityProvider!);
  }
}

