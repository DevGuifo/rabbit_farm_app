import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../services/secure_storage_service.dart';
import '../services/supabase_auth_service.dart';
import '../utils/logger.dart';

/// Service de synchronisation avec Supabase
/// 
/// Gère :
/// - Sync UP (local → remote)
/// - Sync DOWN (remote → local)
/// - Gestion des conflits (Last Update Wins)
/// - Queue de synchronisation
class SupabaseSyncService {
  static final SupabaseSyncService _instance = SupabaseSyncService._internal();
  factory SupabaseSyncService() => _instance;
  SupabaseSyncService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // ============= ÉTAT =============

  /// Vérifier si une synchronisation est en cours
  bool get isSyncing => _isSyncing;

  /// Obtenir la date de la dernière synchronisation
  DateTime? get lastSyncTime => _lastSyncTime;

  // ============= SYNCHRONISATION COMPLÈTE =============

  /// Synchroniser toutes les données (UP puis DOWN)
  /// 
  /// Retourne true si la synchronisation réussit
  Future<bool> syncAll() async {
    if (_isSyncing) {
      logger.warning('⚠️ Synchronisation déjà en cours');
      return false;
    }

    if (!_authService.isAuthenticated) {
      logger.warning('⚠️ Utilisateur non authentifié, synchronisation annulée');
      return false;
    }

    _isSyncing = true;

    try {
      logger.info('🔄 Début de la synchronisation complète');

      // 1. Sync DOWN (récupérer les modifications depuis Supabase)
      await syncDown();

      // 2. Sync UP (envoyer les modifications locales)
      await syncUp();

      // 3. Mettre à jour le timestamp de dernière sync
      final now = DateTime.now();
      await _secureStorage.setLastSyncTimestamp(now.toIso8601String());
      _lastSyncTime = now;

      logger.info('✅ Synchronisation complète réussie');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la synchronisation: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // ============= SYNC UP (LOCAL → REMOTE) =============

  /// Synchroniser les modifications locales vers Supabase
  /// 
  /// Envoie tous les enregistrements avec is_dirty = 1
  Future<void> syncUp() async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non authentifié');
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User ID non disponible');
    }

    final db = await DatabaseHelper.instance.database;
    final client = _authService.client;

    logger.info('📤 Sync UP : Envoi des modifications locales...');

    // Liste des tables à synchroniser (priorité 1)
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

    int totalSynced = 0;

    for (final tableName in tables) {
      try {
        // Récupérer tous les enregistrements avec is_dirty = 1
        final dirtyRecords = await db.query(
          tableName,
          where: 'is_dirty = 1 AND (is_deleted = 0 OR is_deleted IS NULL)',
        );

        if (dirtyRecords.isEmpty) continue;

        logger.info('📤 Sync UP $tableName : ${dirtyRecords.length} enregistrements');

        for (final record in dirtyRecords) {
          try {
            // Préparer les données pour Supabase
            final supabaseData = _prepareDataForSupabase(record, tableName);

            // Vérifier si l'enregistrement existe sur Supabase
            // (on utilise l'ID local comme référence temporaire)
            final localId = record['id'] as int?;
            if (localId == null) continue;

            // Chercher l'enregistrement sur Supabase par user_id et données similaires
            // Utilise des critères de matching spécifiques selon la table
            final existingRecord = await _findExistingRecord(
              client,
              tableName,
              userId,
              localId,
              record,
            );

            if (existingRecord != null) {
              // UPDATE
              await client.from(tableName).update(supabaseData).eq('id', existingRecord['id']);
              logger.debug('✅ $tableName (id: $localId) : Mis à jour sur Supabase');
            } else {
              // INSERT
              supabaseData['user_id'] = userId;
              await client.from(tableName).insert(supabaseData);
              logger.debug('✅ $tableName (id: $localId) : Inséré sur Supabase');
            }

            // Marquer comme synchronisé
            await db.update(
              tableName,
              {
                'is_dirty': 0,
                'synced_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [localId],
            );

            totalSynced++;
          } catch (e) {
            logger.error('❌ Erreur lors de la sync UP de $tableName (id: ${record['id']}): $e');
            // Continuer avec les autres enregistrements
          }
        }

        // Gérer les suppressions (soft delete)
        final deletedRecords = await db.query(
          tableName,
          where: 'is_deleted = 1 AND is_dirty = 1',
        );

        for (final record in deletedRecords) {
          try {
            final localId = record['id'] as int?;
            if (localId == null) continue;

            // Récupérer les données locales pour le matching
            final localRecordData = await db.query(
              tableName,
              where: 'id = ?',
              whereArgs: [localId],
              limit: 1,
            );

            final existingRecord = localRecordData.isNotEmpty
                ? await _findExistingRecord(
                    client,
                    tableName,
                    userId,
                    localId,
                    localRecordData.first,
                  )
                : null;

            if (existingRecord != null) {
              // Soft delete sur Supabase
              await client
                  .from(tableName)
                  .update({'deleted_at': DateTime.now().toIso8601String()})
                  .eq('id', existingRecord['id']);

              // Marquer comme synchronisé
              await db.update(
                tableName,
                {
                  'is_dirty': 0,
                  'synced_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: [localId],
              );

              totalSynced++;
            }
          } catch (e) {
            logger.error('❌ Erreur lors de la suppression de $tableName: $e');
          }
        }
      } catch (e) {
        logger.error('❌ Erreur lors de la sync UP de la table $tableName: $e');
        // Continuer avec les autres tables
      }
    }

    logger.info('✅ Sync UP terminée : $totalSynced enregistrements synchronisés');
  }

  // ============= SYNC DOWN (REMOTE → LOCAL) =============

  /// Synchroniser les modifications depuis Supabase vers le local
  /// 
  /// Récupère tous les enregistrements modifiés depuis last_sync_timestamp
  Future<void> syncDown() async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non authentifié');
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User ID non disponible');
    }

    final db = await DatabaseHelper.instance.database;
    final client = _authService.client;

    logger.info('📥 Sync DOWN : Récupération des modifications depuis Supabase...');

    // Récupérer le timestamp de la dernière sync
    final lastSyncTimestamp = await _secureStorage.getLastSyncTimestamp();
    final lastSyncDate = lastSyncTimestamp != null
        ? DateTime.parse(lastSyncTimestamp)
        : DateTime.fromMillisecondsSinceEpoch(0);

    // Liste des tables à synchroniser
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

    int totalSynced = 0;

    for (final tableName in tables) {
      try {
        // Récupérer les enregistrements modifiés depuis last_sync_timestamp
        // Note: On filtre les deleted_at null directement dans la requête
        final query = client
            .from(tableName)
            .select()
            .eq('user_id', userId)
            .gte('updated_at', lastSyncDate.toIso8601String());

        final response = await query;

        if (response.isEmpty) continue;

        // Filtrer les enregistrements supprimés
        final activeRecords = (response as List)
            .where((record) => record['deleted_at'] == null)
            .toList();

        if (activeRecords.isEmpty) continue;

        logger.info('📥 Sync DOWN $tableName : ${activeRecords.length} enregistrements');

        for (final remoteRecord in activeRecords) {
          try {
            // Convertir les données Supabase vers le format local
            final localData = _prepareDataForLocal(remoteRecord, tableName);

            // Vérifier si l'enregistrement existe localement
            // On utilise un mapping entre l'ID Supabase et l'ID local
            // Pour simplifier, on cherche par user_id et données similaires
            final existingLocal = await _findLocalRecord(db, tableName, localData);

            if (existingLocal != null) {
              // Conflit potentiel : vérifier les timestamps
              final localUpdatedAt = existingLocal['updated_at'] as String?;
              final remoteUpdatedAt = remoteRecord['updated_at'] as String?;

              if (localUpdatedAt != null &&
                  remoteUpdatedAt != null &&
                  DateTime.parse(localUpdatedAt).isAfter(DateTime.parse(remoteUpdatedAt))) {
                // Local est plus récent → marquer pour sync UP
                await db.update(
                  tableName,
                  {'is_dirty': 1},
                  where: 'id = ?',
                  whereArgs: [existingLocal['id']],
                );
                logger.debug('⚠️ Conflit $tableName : Local plus récent, marqué pour sync UP');
                continue;
              }

              // Remote est plus récent ou égal → UPDATE local
              await db.update(
                tableName,
                {
                  ...localData,
                  'is_dirty': 0,
                  'synced_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: [existingLocal['id']],
              );
              logger.debug('✅ $tableName (id: ${existingLocal['id']}) : Mis à jour localement');
            } else {
              // Nouvel enregistrement → INSERT local
              await db.insert(tableName, {
                ...localData,
                'is_dirty': 0,
                'synced_at': DateTime.now().toIso8601String(),
              });
              logger.debug('✅ $tableName : Inséré localement');
            }

            totalSynced++;
          } catch (e) {
            logger.error('❌ Erreur lors de la sync DOWN de $tableName: $e');
            // Continuer avec les autres enregistrements
          }
        }
      } catch (e) {
        logger.error('❌ Erreur lors de la sync DOWN de la table $tableName: $e');
        // Continuer avec les autres tables
      }
    }

    logger.info('✅ Sync DOWN terminée : $totalSynced enregistrements synchronisés');
  }

  // ============= MÉTHODES UTILITAIRES =============

  /// Préparer les données pour Supabase (convertir format local → Supabase)
  Map<String, dynamic> _prepareDataForSupabase(
    Map<String, dynamic> localData,
    String tableName,
  ) {
    final supabaseData = Map<String, dynamic>.from(localData);

    // Supprimer les champs de sync (sauf si nécessaires)
    supabaseData.remove('is_dirty');
    supabaseData.remove('is_deleted');
    supabaseData.remove('sync_conflict');

    // Convertir les noms de colonnes si nécessaire
    // (pour l'instant, on garde les mêmes noms)

    return supabaseData;
  }

  /// Préparer les données pour le local (convertir format Supabase → local)
  Map<String, dynamic> _prepareDataForLocal(
    Map<String, dynamic> supabaseData,
    String tableName,
  ) {
    final localData = Map<String, dynamic>.from(supabaseData);

    // Supprimer l'ID Supabase (on garde l'ID local)
    localData.remove('id');

    // Ajouter les champs de sync par défaut
    localData['is_dirty'] = 0;
    localData['is_deleted'] = 0;

    return localData;
  }

  /// Trouver un enregistrement existant sur Supabase
  /// 
  /// Utilise des critères de matching spécifiques selon la table pour éviter les doublons
  Future<Map<String, dynamic>?> _findExistingRecord(
    SupabaseClient client,
    String tableName,
    String userId,
    int localId,
    Map<String, dynamic> localData,
  ) async {
    try {
      // Récupérer les données locales pour le matching
      final db = await DatabaseHelper.instance.database;
      final localRecord = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [localId],
        limit: 1,
      );

      if (localRecord.isEmpty) return null;
      final local = localRecord.first;

      // Matching selon la table avec critères spécifiques
      switch (tableName) {
        case 'lapins':
          // Pour les lapins : matcher par nom + date_naissance + race (si disponible)
          final nom = local['nom'] as String?;
          final dateNaissance = local['date_naissance'] as String?;
          final race = local['race'] as String?;

          if (nom != null && dateNaissance != null) {
            var query = client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('nom', nom)
                .eq('date_naissance', dateNaissance);

            if (race != null) {
              query = query.eq('race', race);
            }

            final response = await query.limit(10);
            if (response.isNotEmpty) {
              // Retourner le premier match (le plus récent si plusieurs)
              return (response as List).first;
            }
          }
          break;

        case 'accouplements':
          // Pour les accouplements : matcher par male_id + femelle_id + date_accouplement
          final maleId = local['male_id'] as int?;
          final femelleId = local['femelle_id'] as int?;
          final dateAccouplement = local['date_accouplement'] as String?;

          if (maleId != null && femelleId != null && dateAccouplement != null) {
            // Note: Les IDs Supabase sont des UUID, on ne peut pas matcher directement
            // On utilise la date et on cherche les accouplements récents
            final response = await client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date_accouplement', dateAccouplement)
                .limit(10);

            // Filtrer par IDs si on a un mapping (pour l'instant, retourner le premier)
            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        case 'portees':
          // Pour les portées : matcher par accouplement_id + date_mise_bas_reelle
          final accouplementId = local['accouplement_id'] as int?;
          final dateMiseBas = local['date_mise_bas_reelle'] as String?;

          if (accouplementId != null && dateMiseBas != null) {
            final response = await client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date_mise_bas_reelle', dateMiseBas)
                .limit(10);

            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        case 'pesees':
          // Pour les pesées : matcher par lapin_id + date + poids (approximatif)
          final lapinId = local['lapin_id'] as int?;
          final date = local['date'] as String?;
          final poids = local['poids'] as double?;

          if (lapinId != null && date != null) {
            var query = client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date', date);

            if (poids != null) {
              // Tolérance de 0.1 kg pour le poids
              query = query.gte('poids', poids - 0.1).lte('poids', poids + 0.1);
            }

            final response = await query.limit(10);
            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        case 'soins':
          // Pour les soins : matcher par lapin_id + date + type
          final lapinIdSoin = local['lapin_id'] as int?;
          final dateSoin = local['date'] as String?;
          final type = local['type'] as String?;

          if (lapinIdSoin != null && dateSoin != null && type != null) {
            final response = await client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date', dateSoin)
                .eq('type', type)
                .limit(10);

            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        case 'recettes':
        case 'depenses':
          // Pour finances : matcher par date + montant + description
          final dateFinance = local['date'] as String?;
          final montant = local['montant'] as double?;
          final description = local['description'] as String?;

          if (dateFinance != null && montant != null) {
            var query = client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date', dateFinance)
                .eq('montant', montant);

            if (description != null) {
              query = query.eq('description', description);
            }

            final response = await query.limit(10);
            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        case 'deces':
          // Pour les décès : matcher par lapin_id + date_deces
          final lapinIdDeces = local['lapin_id'] as int?;
          final dateDeces = local['date_deces'] as String?;

          if (lapinIdDeces != null && dateDeces != null) {
            final response = await client
                .from(tableName)
                .select()
                .eq('user_id', userId)
                .eq('date_deces', dateDeces)
                .limit(10);

            if (response.isNotEmpty) {
              return (response as List).first;
            }
          }
          break;

        default:
          // Pour les autres tables : chercher par user_id uniquement (moins fiable)
          logger.warning('⚠️ Matching générique pour $tableName (peut causer des doublons)');
          final response = await client
              .from(tableName)
              .select()
              .eq('user_id', userId)
              .limit(10);

          if (response.isNotEmpty) {
            return (response as List).first;
          }
      }

      return null;
    } catch (e) {
      logger.error('❌ Erreur lors de la recherche sur Supabase: $e');
      return null;
    }
  }

  /// Trouver un enregistrement local
  /// 
  /// Utilise des critères de matching spécifiques selon la table
  Future<Map<String, dynamic>?> _findLocalRecord(
    Database db,
    String tableName,
    Map<String, dynamic> remoteData,
  ) async {
    try {
      final userId = remoteData['user_id'] as String?;
      if (userId == null) return null;

      // Matching selon la table avec critères spécifiques
      switch (tableName) {
        case 'lapins':
          // Pour les lapins : matcher par nom + date_naissance + race
          final nom = remoteData['nom'] as String?;
          final dateNaissance = remoteData['date_naissance'] as String?;
          final race = remoteData['race'] as String?;

          if (nom != null && dateNaissance != null) {
            var where = 'user_id = ? AND nom = ? AND date_naissance = ?';
            var whereArgs = [userId, nom, dateNaissance];

            if (race != null) {
              where += ' AND race = ?';
              whereArgs.add(race);
            }

            final results = await db.query(
              tableName,
              where: where,
              whereArgs: whereArgs,
              limit: 1,
            );

            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'accouplements':
          // Pour les accouplements : matcher par date_accouplement
          final dateAccouplement = remoteData['date_accouplement'] as String?;
          if (dateAccouplement != null) {
            final results = await db.query(
              tableName,
              where: 'user_id = ? AND date_accouplement = ?',
              whereArgs: [userId, dateAccouplement],
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'portees':
          // Pour les portées : matcher par date_mise_bas_reelle
          final dateMiseBas = remoteData['date_mise_bas_reelle'] as String?;
          if (dateMiseBas != null) {
            final results = await db.query(
              tableName,
              where: 'user_id = ? AND date_mise_bas_reelle = ?',
              whereArgs: [userId, dateMiseBas],
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'pesees':
          // Pour les pesées : matcher par date + poids (approximatif)
          final date = remoteData['date'] as String?;
          final poids = remoteData['poids'] as double?;
          if (date != null && poids != null) {
            final results = await db.query(
              tableName,
              where: 'user_id = ? AND date = ? AND ABS(poids - ?) < 0.1',
              whereArgs: [userId, date, poids],
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'soins':
          // Pour les soins : matcher par date + type
          final dateSoin = remoteData['date'] as String?;
          final type = remoteData['type'] as String?;
          if (dateSoin != null && type != null) {
            final results = await db.query(
              tableName,
              where: 'user_id = ? AND date = ? AND type = ?',
              whereArgs: [userId, dateSoin, type],
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'recettes':
        case 'depenses':
          // Pour finances : matcher par date + montant + description
          final dateFinance = remoteData['date'] as String?;
          final montant = remoteData['montant'] as double?;
          final description = remoteData['description'] as String?;
          if (dateFinance != null && montant != null) {
            var where = 'user_id = ? AND date = ? AND montant = ?';
            var whereArgs = [userId, dateFinance, montant];

            if (description != null) {
              where += ' AND description = ?';
              whereArgs.add(description);
            }

            final results = await db.query(
              tableName,
              where: where,
              whereArgs: whereArgs,
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        case 'deces':
          // Pour les décès : matcher par date_deces
          final dateDeces = remoteData['date_deces'] as String?;
          if (dateDeces != null) {
            final results = await db.query(
              tableName,
              where: 'user_id = ? AND date_deces = ?',
              whereArgs: [userId, dateDeces],
              limit: 1,
            );
            if (results.isNotEmpty) return results.first;
          }
          break;

        default:
          // Pour les autres tables : chercher par user_id uniquement (moins fiable)
          logger.warning('⚠️ Matching générique pour $tableName (peut causer des doublons)');
          final results = await db.query(
            tableName,
            where: 'user_id = ?',
            whereArgs: [userId],
            limit: 1,
          );
          if (results.isNotEmpty) return results.first;
      }

      return null;
    } catch (e) {
      logger.error('❌ Erreur lors de la recherche locale: $e');
      return null;
    }
  }
}

