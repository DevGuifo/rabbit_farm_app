import 'dart:async';
import 'dart:convert';
import '../services/database_helper.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';

/// Type d'opération de synchronisation
enum SyncOperation { insert, update, delete }

/// État d'un élément dans la queue de synchronisation
enum SyncItemStatus {
  /// En attente de synchronisation
  pending,

  /// Synchronisation en cours
  syncing,

  /// Synchronisé avec succès
  synced,

  /// Échec de synchronisation
  failed,

  /// Conflit détecté (modification concurrente)
  conflict,
}

/// Élément dans la queue de synchronisation
class SyncQueueItem {
  final int id;
  final String tableName;
  final int localId;
  final SyncOperation operation;
  final Map<String, dynamic>? payload;
  final SyncItemStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? syncedAt;

  SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.localId,
    required this.operation,
    this.payload,
    required this.status,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    this.syncedAt,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as int,
      tableName: map['table_name'] as String,
      localId: map['local_id'] as int,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == (map['operation'] as String).toLowerCase(),
        orElse: () => SyncOperation.update,
      ),
      payload: map['payload'] != null
          ? jsonDecode(map['payload'] as String) as Map<String, dynamic>
          : null,
      status: SyncItemStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String).toLowerCase(),
        orElse: () => SyncItemStatus.pending,
      ),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'local_id': localId,
      'operation': operation.name.toUpperCase(),
      'payload': payload != null ? jsonEncode(payload) : null,
      'status': status.name,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}

/// Résultat d'une synchronisation
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final Duration duration;
  final List<String> errors;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.conflictCount = 0,
    required this.duration,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, synced: $syncedCount, '
        'failed: $failedCount, conflicts: $conflictCount, '
        'duration: ${duration.inMilliseconds}ms)';
  }
}

/// Service de synchronisation offline-first avec Supabase
///
/// Architecture :
/// 1. Toutes les opérations CRUD se font d'abord en local (SQLite)
/// 2. Les modifications sont enregistrées dans une queue locale (sync_queue)
/// 3. Quand la connexion est disponible, la queue est envoyée à Supabase
/// 4. Les conflits sont détectés et gérés (last-write-wins par défaut)
///
/// Usage :
/// ```dart
/// // Après une modification locale
/// await SyncService().enqueue(
///   tableName: 'lapins',
///   localId: lapin.id!,
///   operation: SyncOperation.update,
///   payload: lapin.toMap(),
/// );
///
/// // Synchroniser maintenant
/// final result = await SyncService().syncNow();
/// ```
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isInitialized = false;
  bool _isSyncing = false;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;
  Timer? _autoSyncTimer;

  // Configuration
  static const int maxRetries = 3;
  static const Duration autoSyncInterval = Duration(minutes: 5);
  static const Duration syncTimeout = Duration(seconds: 30);

  /// Indique si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Nombre d'éléments en attente de synchronisation
  int get pendingCount => _pendingCount;

  /// Date de la dernière synchronisation
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Indique si une synchronisation est en cours
  bool get isSyncing => _isSyncing;

  /// Indique si Supabase est disponible pour la sync
  bool get isSupabaseAvailable => supabaseConfig.isInitialized;

  /// Stream de notifications de changement
  final StreamController<int> _pendingCountController =
      StreamController<int>.broadcast();
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) {
      logger.warning('SyncService déjà initialisé');
      return;
    }

    try {
      // Créer la table sync_queue locale si elle n'existe pas
      await _ensureSyncQueueTable();

      // Compter les éléments en attente
      await refreshPendingCount();

      _isInitialized = true;
      logger.info('✅ SyncService initialisé (pending: $_pendingCount)');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation SyncService: $e');
    }
  }

  /// Créer la table sync_queue locale si nécessaire
  Future<void> _ensureSyncQueueTable() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        local_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT,
        status TEXT DEFAULT 'pending',
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT,
        UNIQUE(table_name, local_id, operation, status)
      )
    ''');

    // Index pour recherche efficace
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_status 
      ON sync_queue(status)
    ''');
  }

  /// Ajouter un élément à la queue de synchronisation
  Future<void> enqueue({
    required String tableName,
    required int localId,
    required SyncOperation operation,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Supprimer les entrées précédentes pour le même enregistrement
      // (évite la duplication si modification multiple avant sync)
      await db.delete(
        'sync_queue',
        where: 'table_name = ? AND local_id = ? AND status = ?',
        whereArgs: [tableName, localId, 'pending'],
      );

      // Insérer la nouvelle entrée
      await db.insert('sync_queue', {
        'table_name': tableName,
        'local_id': localId,
        'operation': operation.name.toUpperCase(),
        'payload': payload != null ? jsonEncode(payload) : null,
        'status': 'pending',
        'retry_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      await refreshPendingCount();
      logger.debug('Queue sync: ${operation.name} $tableName:$localId');
    } catch (e) {
      logger.error('Erreur enqueue sync: $e');
    }
  }

  /// Rafraîchir le compteur d'éléments en attente
  Future<int> refreshPendingCount() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM sync_queue WHERE status = 'pending'",
      );

      _pendingCount = result.first['count'] as int? ?? 0;
      _pendingCountController.add(_pendingCount);

      return _pendingCount;
    } catch (e) {
      logger.error('Erreur comptage pending: $e');
      return 0;
    }
  }

  /// Obtenir tous les éléments en attente
  Future<List<SyncQueueItem>> getPendingItems() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        'sync_queue',
        where: "status = 'pending'",
        orderBy: 'created_at ASC',
      );

      return results.map((map) => SyncQueueItem.fromMap(map)).toList();
    } catch (e) {
      logger.error('Erreur récupération pending: $e');
      return [];
    }
  }

  /// Synchroniser maintenant tous les éléments en attente
  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      logger.warning('Synchronisation déjà en cours');
      return SyncResult(
        success: false,
        duration: Duration.zero,
        errors: ['Synchronisation déjà en cours'],
      );
    }

    if (!isSupabaseAvailable) {
      logger.info('Supabase non disponible, synchronisation ignorée');
      return SyncResult(
        success: false,
        duration: Duration.zero,
        errors: ['Supabase non configuré'],
      );
    }

    _isSyncing = true;
    final startTime = DateTime.now();
    final errors = <String>[];
    int syncedCount = 0;
    int failedCount = 0;
    int conflictCount = 0;

    try {
      final items = await getPendingItems();

      if (items.isEmpty) {
        logger.info('Aucun élément à synchroniser');
        _lastSyncTime = DateTime.now();
        return SyncResult(
          success: true,
          duration: DateTime.now().difference(startTime),
        );
      }

      logger.info('Synchronisation de ${items.length} éléments...');

      for (final item in items) {
        try {
          final success = await _syncItem(item);

          if (success) {
            syncedCount++;
            await _markItemSynced(item.id);
          } else {
            failedCount++;
            await _incrementRetryCount(item.id);
          }
        } catch (e) {
          failedCount++;
          errors.add('${item.tableName}:${item.localId} - $e');
          await _markItemFailed(item.id, e.toString());
        }
      }

      _lastSyncTime = DateTime.now();
      await refreshPendingCount();

      // Log le résultat dans Supabase (analytics)
      await _logSyncResult(
        syncedCount: syncedCount,
        failedCount: failedCount,
        conflictCount: conflictCount,
        duration: DateTime.now().difference(startTime),
      );

      final result = SyncResult(
        success: failedCount == 0,
        syncedCount: syncedCount,
        failedCount: failedCount,
        conflictCount: conflictCount,
        duration: DateTime.now().difference(startTime),
        errors: errors,
      );

      logger.info('Synchronisation terminée: $result');
      return result;
    } catch (e) {
      logger.error('Erreur synchronisation: $e');
      return SyncResult(
        success: false,
        duration: DateTime.now().difference(startTime),
        errors: [e.toString()],
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Synchroniser un élément individuel
  Future<bool> _syncItem(SyncQueueItem item) async {
    final client = supabaseConfig.client;
    if (client == null) return false;

    try {
      switch (item.operation) {
        case SyncOperation.insert:
          await client.from(item.tableName).insert(item.payload!);
          break;

        case SyncOperation.update:
          await client
              .from(item.tableName)
              .update(item.payload!)
              .eq('local_id', item.localId);
          break;

        case SyncOperation.delete:
          await client
              .from(item.tableName)
              .delete()
              .eq('local_id', item.localId);
          break;
      }

      return true;
    } catch (e) {
      logger.error('Erreur sync item ${item.tableName}:${item.localId}: $e');
      return false;
    }
  }

  /// Marquer un élément comme synchronisé
  Future<void> _markItemSynced(int itemId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'sync_queue',
      {'status': 'synced', 'synced_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Marquer un élément comme échoué
  Future<void> _markItemFailed(int itemId, String error) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'sync_queue',
      {'status': 'failed', 'last_error': error},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Incrémenter le compteur de retry
  Future<void> _incrementRetryCount(int itemId) async {
    final db = await DatabaseHelper.instance.database;
    await db.rawUpdate(
      '''
      UPDATE sync_queue 
      SET retry_count = retry_count + 1,
          status = CASE 
            WHEN retry_count >= $maxRetries THEN 'failed'
            ELSE 'pending'
          END
      WHERE id = ?
    ''',
      [itemId],
    );
  }

  /// Logger le résultat de sync dans Supabase (analytics)
  Future<void> _logSyncResult({
    required int syncedCount,
    required int failedCount,
    required int conflictCount,
    required Duration duration,
  }) async {
    final client = supabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('sync_logs').insert({
        'user_id': supabaseConfig.currentUser?.id,
        'sync_started_at': _lastSyncTime?.subtract(duration).toIso8601String(),
        'sync_ended_at': _lastSyncTime?.toIso8601String(),
        'duration_ms': duration.inMilliseconds,
        'records_synced': syncedCount,
        'records_failed': failedCount,
        'sync_type': 'manual',
      });
    } catch (e) {
      logger.warning('Impossible de logger sync result: $e');
    }
  }

  /// Démarrer la synchronisation automatique
  void startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(autoSyncInterval, (_) async {
      if (_pendingCount > 0 && isSupabaseAvailable) {
        await syncNow();
      }
    });
    logger.info(
      'Auto-sync activé (intervalle: ${autoSyncInterval.inMinutes}min)',
    );
  }

  /// Arrêter la synchronisation automatique
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    logger.info('Auto-sync désactivé');
  }

  /// Nettoyer la queue (supprimer les éléments synchronisés anciens)
  Future<void> cleanupQueue({int daysOld = 7}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final cutoff = DateTime.now()
          .subtract(Duration(days: daysOld))
          .toIso8601String();

      final deleted = await db.delete(
        'sync_queue',
        where: "status = 'synced' AND synced_at < ?",
        whereArgs: [cutoff],
      );

      if (deleted > 0) {
        logger.info('Nettoyage queue: $deleted éléments supprimés');
      }
    } catch (e) {
      logger.error('Erreur nettoyage queue: $e');
    }
  }

  /// Méthodes de compatibilité avec l'ancien code

  /// Marquer un enregistrement comme modifié (alias pour enqueue)
  Future<void> markDirty({
    required String tableName,
    required int recordId,
  }) async {
    // Récupérer les données actuelles pour le payload
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [recordId],
      );

      if (results.isNotEmpty) {
        await enqueue(
          tableName: tableName,
          localId: recordId,
          operation: SyncOperation.update,
          payload: results.first,
        );
      }
    } catch (e) {
      logger.error('Erreur markDirty: $e');
    }
  }

  /// Marquer un enregistrement comme synchronisé
  Future<void> markSynced({
    required String tableName,
    required int recordId,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'sync_queue',
        where: "table_name = ? AND local_id = ? AND status = 'pending'",
        whereArgs: [tableName, recordId],
      );
      await refreshPendingCount();
    } catch (e) {
      logger.error('Erreur markSynced: $e');
    }
  }

  /// Obtenir tous les enregistrements en attente de sync pour une table
  Future<List<Map<String, dynamic>>> getPendingRecords(String tableName) async {
    try {
      final items = await getPendingItems();
      return items
          .where((item) => item.tableName == tableName)
          .map((item) => item.payload ?? {})
          .toList();
    } catch (e) {
      logger.error('Erreur getPendingRecords: $e');
      return [];
    }
  }

  /// Libérer les ressources
  void dispose() {
    _autoSyncTimer?.cancel();
    _pendingCountController.close();
  }
}
