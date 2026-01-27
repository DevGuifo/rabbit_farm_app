import '../models/lapin.dart';
import 'database_helper.dart';
import '../core/utils/logger.dart';

/// Service centralisé de génération d'identifiants uniques
///
/// Gère la création d'IDs au format LP-YYYY-MM-NNN pour:
/// - Lapins individuels (via numeroIdentification)
/// - Lots (via identifiant)
///
/// Garantit l'unicité des IDs en vérifiant la base de données
class IdGeneratorService {
  static final IdGeneratorService instance = IdGeneratorService._();
  final DatabaseHelper _db = DatabaseHelper.instance;

  IdGeneratorService._();

  /// Générer le prochain ID unique pour un lapin individuel
  ///
  /// Format: LP-YYYY-MM-NNN
  /// - YYYY: Année
  /// - MM: Mois (01-12)
  /// - NNN: Numéro séquentiel (001-999)
  ///
  /// Retourne le prochain ID disponible basé sur les IDs existants ce mois-ci
  Future<String> genererProchainIdLapin([DateTime? date]) async {
    final now = date ?? DateTime.now();

    try {
      final db = await _db.database;
      final annee = now.year.toString();
      final mois = now.month.toString().padLeft(2, '0');
      final prefix = 'LP-$annee-$mois-';

      // Trouver le dernier numéro de séquence pour ce mois
      final result = await db.rawQuery(
        "SELECT MAX(CAST(SUBSTR(numero_identification, -3) AS INTEGER)) as max_seq "
        "FROM lapins WHERE numero_identification LIKE ?",
        ['$prefix%'],
      );

      int nextSeq = 1;
      if (result.isNotEmpty && result.first['max_seq'] != null) {
        nextSeq = (result.first['max_seq'] as int) + 1;
      }

      if (nextSeq > 999) {
        logger.warning('⚠️ Limite de 999 IDs atteinte pour $prefix');
        // Fallback: utiliser timestamp ms
        nextSeq = now.millisecond + (now.second * 1000);
      }

      return Lapin.genererIdentifiant(now, nextSeq);
    } catch (e) {
      logger.error('❌ Erreur génération ID lapin: $e');
      // Fallback avec timestamp
      return Lapin.genererIdentifiant(now, now.millisecondsSinceEpoch % 1000);
    }
  }

  /// Générer plusieurs IDs en une seule transaction (pour bulk insert)
  ///
  /// Optimisé pour la performance lors de l'ajout de lots massifs.
  /// Réserve les IDs de manière séquentielle à partir du dernier ID existant.
  ///
  /// [count] : Nombre d'IDs à générer
  /// [date] : Date pour le préfixe (utilise DateTime.now() si null)
  ///
  /// Retourne une liste de [count] IDs uniques
  Future<List<String>> genererIdsLapins(int count, [DateTime? date]) async {
    if (count <= 0) return [];

    final now = date ?? DateTime.now();
    final ids = <String>[];

    try {
      final db = await _db.database;
      final annee = now.year.toString();
      final mois = now.month.toString().padLeft(2, '0');
      final prefix = 'LP-$annee-$mois-';

      // Trouver le dernier numéro de séquence pour ce mois
      final result = await db.rawQuery(
        "SELECT MAX(CAST(SUBSTR(numero_identification, -3) AS INTEGER)) as max_seq "
        "FROM lapins WHERE numero_identification LIKE ?",
        ['$prefix%'],
      );

      int nextSeq = 1;
      if (result.isNotEmpty && result.first['max_seq'] != null) {
        nextSeq = (result.first['max_seq'] as int) + 1;
      }

      // Générer les IDs séquentiels
      for (int i = 0; i < count; i++) {
        final seq = nextSeq + i;
        if (seq > 999) {
          logger.warning(
            '⚠️ Dépassement 999 IDs pour $prefix, utilisation timestamp',
          );
          ids.add(
            '$prefix${(now.millisecondsSinceEpoch + i).toString().substring(7)}',
          );
        } else {
          ids.add('$prefix${seq.toString().padLeft(3, '0')}');
        }
      }

      logger.info('✅ Générés ${ids.length} IDs: ${ids.first} → ${ids.last}');
      return ids;
    } catch (e) {
      logger.error('❌ Erreur génération IDs batch: $e');
      // Fallback: générer avec timestamp
      for (int i = 0; i < count; i++) {
        ids.add(
          Lapin.genererIdentifiant(
            now,
            (now.millisecondsSinceEpoch + i) % 1000,
          ),
        );
      }
      return ids;
    }
  }

  /// Vérifier si un ID existe déjà
  Future<bool> idExiste(String id) async {
    try {
      final db = await _db.database;
      final result = await db.query(
        'lapins',
        where: 'numero_identification = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      logger.error('❌ Erreur vérification ID: $e');
      return false;
    }
  }

  /// Obtenir des statistiques sur les IDs générés
  Future<Map<String, dynamic>> getStatistiquesIds() async {
    try {
      final db = await _db.database;

      // Total avec ID
      final totalAvecId = await db.rawQuery(
        "SELECT COUNT(*) as count FROM lapins WHERE numero_identification IS NOT NULL AND numero_identification != ''",
      );

      // Total sans ID
      final totalSansId = await db.rawQuery(
        "SELECT COUNT(*) as count FROM lapins WHERE numero_identification IS NULL OR numero_identification = ''",
      );

      final now = DateTime.now();
      final prefix = 'LP-${now.year}-${now.month.toString().padLeft(2, '0')}-';

      // IDs ce mois
      final idsCeMois = await db.rawQuery(
        "SELECT COUNT(*) as count FROM lapins WHERE numero_identification LIKE ?",
        ['$prefix%'],
      );

      return {
        'total_avec_id': (totalAvecId.first['count'] as int?) ?? 0,
        'total_sans_id': (totalSansId.first['count'] as int?) ?? 0,
        'ids_ce_mois': (idsCeMois.first['count'] as int?) ?? 0,
        'prefix_actuel': prefix,
      };
    } catch (e) {
      logger.error('❌ Erreur stats IDs: $e');
      return {};
    }
  }
}
