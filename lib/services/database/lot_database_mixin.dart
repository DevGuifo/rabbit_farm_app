import 'database_base.dart';
import '../../models/lot.dart';
import '../../models/lapin.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/validation_exception.dart';

/// Mixin pour les opérations de base de données liées aux Lots
///
/// Ce mixin étend [DatabaseBase] pour fournir les opérations CRUD
/// sur la table `lots` et gérer les relations lots/individus.
mixin LotDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS CRUD LOTS =============

  /// Récupérer tous les lots
  Future<List<Lot>> getAllLots({String? orderBy}) async {
    try {
      final db = await database;
      final results = await db.query(
        'lots',
        orderBy: orderBy ?? 'date_creation DESC',
      );
      return results.map((map) => Lot.fromMap(map)).toList();
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des lots: $e');
      return [];
    }
  }

  /// Récupérer un lot par son ID
  Future<Lot?> getLotById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        'lots',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return Lot.fromMap(results.first);
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération du lot $id: $e');
      return null;
    }
  }

  /// Récupérer un lot par son identifiant (LP-XXXX-XX-XXX)
  Future<Lot?> getLotByIdentifiant(String identifiant) async {
    try {
      final db = await database;
      final results = await db.query(
        'lots',
        where: 'identifiant = ?',
        whereArgs: [identifiant],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return Lot.fromMap(results.first);
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération du lot $identifiant: $e');
      return null;
    }
  }

  /// Insérer un nouveau lot
  Future<Lot> insertLot(Lot lot) async {
    try {
      final db = await database;
      final map = lot.toMap();
      map.remove('id'); // Supprimer l'ID pour auto-increment

      final id = await db.insert('lots', map);
      logger.info('✅ Lot inséré avec ID: $id');
      return lot.copyWith(id: id);
    } catch (e) {
      logger.error('❌ Erreur lors de l\'insertion du lot: $e');
      rethrow;
    }
  }

  /// Créer un lot AVEC génération optionnelle des fiches individuelles
  ///
  /// Cette méthode permet de créer un lot de 50-100+ lapins d'un coup
  /// en générant automatiquement leurs IDs au format LP-XXXX-XX-XXX.
  ///
  /// [effectif] : Nombre de lapins dans le lot
  /// [type] : Type de lot (engraissement, reproduction, mixte)
  /// [cageId] : Cage assignée (optionnel)
  /// [metadata] : Métadonnées du lot (race, origine, poids...)
  /// [creerFichesIndividuelles] : Si true, crée les fiches lapin individuelles
  ///
  /// Retourne le lot créé avec son ID
  Future<Lot> creerLotAvecIndividus({
    required int effectif,
    required TypeLot type,
    int? cageId,
    LotMetadata? metadata,
    bool creerFichesIndividuelles = false,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now();

      // Générer l'identifiant du lot
      final identifiantLot = await genererProchainIdentifiantLot(now);

      // Déterminer le statut par défaut selon le type
      String statutLapin;
      switch (type) {
        case TypeLot.reproduction:
          statutLapin = 'Reproducteur';
          break;
        case TypeLot.engraissement:
          statutLapin = 'Engraissement';
          break;
        case TypeLot.mixte:
          statutLapin = 'Actif';
          break;
      }

      // Transaction pour garantir la cohérence
      return await db.transaction((txn) async {
        // 1. Créer le lot
        final lotMap = {
          'identifiant': identifiantLot,
          'date_creation': now.toIso8601String(),
          'effectif_initial': effectif,
          'effectif_actuel': effectif,
          'type': type.value,
          'statut': StatutLot.actif.value,
          'cage_id': cageId,
          'metadata': metadata?.toJson() ?? '{}',
          'photo_path': null,
          'has_individus': creerFichesIndividuelles ? 1 : 0,
        };

        final lotId = await txn.insert('lots', lotMap);
        logger.info('✅ Lot $identifiantLot créé avec ID: $lotId');

        // 2. Si demandé, créer les fiches individuelles
        if (creerFichesIndividuelles && effectif > 0) {
          final annee = now.year.toString();
          final mois = now.month.toString().padLeft(2, '0');
          final prefix = 'LP-$annee-$mois-';

          // Trouver le dernier numéro de séquence pour ce mois
          final seqResult = await txn.rawQuery(
            "SELECT MAX(CAST(SUBSTR(numero_identification, -3) AS INTEGER)) as max_seq "
            "FROM lapins WHERE numero_identification LIKE ?",
            ['$prefix%'],
          );

          int nextSeq = 1;
          if (seqResult.isNotEmpty && seqResult.first['max_seq'] != null) {
            nextSeq = (seqResult.first['max_seq'] as int) + 1;
          }

          // Batch des données pour insertion
          final batch = txn.batch();
          for (int i = 0; i < effectif; i++) {
            final seq = nextSeq + i;
            final idLapin = '$prefix${seq.toString().padLeft(3, '0')}';

            batch.insert('lapins', {
              'nom': '', // Nom vide = pas de surnom individuel
              'race': metadata?.race ?? 'Non spécifié',
              'sexe': 'Indéterminé',
              'date_naissance': now.toIso8601String(),
              'poids': metadata?.poidsEntree,
              'statut': statutLapin,
              'localisation': null,
              'photo_path': null,
              'numero_identification': idLapin,
              'couleur': null,
              'prix_achat': null,
              'origine': metadata?.origine,
              'notes': 'Créé automatiquement avec le lot $identifiantLot',
              'caracteristiques': null,
              'cage_id': cageId,
              'lot_id': lotId,
            });
          }

          await batch.commit(noResult: true);
          logger.info(
            '✅ $effectif fiches individuelles créées pour le lot $identifiantLot',
          );
        }

        return Lot(
          id: lotId,
          identifiant: identifiantLot,
          dateCreation: now,
          effectifInitial: effectif,
          effectifActuel: effectif,
          type: type,
          statut: StatutLot.actif,
          cageId: cageId,
          metadata: metadata ?? const LotMetadata(),
          hasIndividus: creerFichesIndividuelles,
        );
      });
    } catch (e) {
      logger.error('❌ Erreur création lot avec individus: $e');
      rethrow;
    }
  }

  /// Mettre à jour un lot existant
  Future<void> updateLot(Lot lot) async {
    if (lot.id == null) {
      throw ArgumentError('Impossible de mettre à jour un lot sans ID');
    }

    try {
      final db = await database;
      await db.update(
        'lots',
        lot.toMap(),
        where: 'id = ?',
        whereArgs: [lot.id],
      );
      logger.info('✅ Lot ${lot.identifiant} mis à jour');
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour du lot: $e');
      rethrow;
    }
  }

  /// Supprimer un lot (vérifie les lapins d'abord)
  Future<void> deleteLot(int id) async {
    try {
      final db = await database;

      // 🔒 SECURITÉ P0.3 : Vérifier les lapins avant suppression
      final occupants = await countIndividusByLotId(id);
      if (occupants > 0) {
        throw ValidationException(
          reason:
              'Impossible de supprimer ce lot car il contient $occupants lapin(s). '
              'Veuillez d\'abord déplacer les lapins ou vider le lot.',
        );
      }

      await db.delete('lots', where: 'id = ?', whereArgs: [id]);
      logger.info('✅ Lot $id supprimé');
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression du lot: $e');
      rethrow;
    }
  }

  // ============= RELATIONS LOTS/INDIVIDUS =============

  /// Récupérer les individus d'un lot
  Future<List<Lapin>> getIndividusByLotId(int lotId) async {
    try {
      final db = await database;
      final results = await db.query(
        'lapins',
        where: 'lot_id = ?',
        whereArgs: [lotId],
        orderBy: 'nom ASC',
      );
      return results.map((map) => Lapin.fromMap(map)).toList();
    } catch (e) {
      logger.error(
        '❌ Erreur lors de la récupération des individus du lot $lotId: $e',
      );
      return [];
    }
  }

  /// Compter les individus d'un lot
  Future<int> countIndividusByLotId(int lotId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lapins WHERE lot_id = ?',
        [lotId],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      logger.error('❌ Erreur lors du comptage des individus: $e');
      return 0;
    }
  }

  /// Assigner un lapin à un lot
  Future<void> assignerLapinALot(int lapinId, int lotId) async {
    try {
      final db = await database;
      await db.update(
        'lapins',
        {'lot_id': lotId},
        where: 'id = ?',
        whereArgs: [lapinId],
      );

      // Mettre à jour hasIndividus sur le lot
      await db.rawUpdate('UPDATE lots SET has_individus = 1 WHERE id = ?', [
        lotId,
      ]);

      logger.info('✅ Lapin $lapinId assigné au lot $lotId');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'assignation: $e');
      rethrow;
    }
  }

  /// Retirer un lapin d'un lot (met lot_id à NULL)
  Future<void> retirerLapinDuLot(int lapinId) async {
    try {
      final db = await database;
      await db.update(
        'lapins',
        {'lot_id': null},
        where: 'id = ?',
        whereArgs: [lapinId],
      );
      logger.info('✅ Lapin $lapinId retiré de son lot');
    } catch (e) {
      logger.error('❌ Erreur lors du retrait: $e');
      rethrow;
    }
  }

  // ============= OPÉRATIONS GROUPÉES =============

  /// Mettre à jour l'effectif actuel d'un lot
  Future<void> updateEffectifLot(int lotId, int nouvelEffectif) async {
    try {
      final db = await database;
      await db.update(
        'lots',
        {'effectif_actuel': nouvelEffectif},
        where: 'id = ?',
        whereArgs: [lotId],
      );
      logger.info('✅ Effectif lot $lotId mis à jour: $nouvelEffectif');
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour de l\'effectif: $e');
      rethrow;
    }
  }

  /// Incrémenter ou décrémenter l'effectif d'un lot
  Future<void> ajusterEffectifLot(int lotId, int delta) async {
    try {
      final db = await database;
      await db.rawUpdate(
        'UPDATE lots SET effectif_actuel = effectif_actuel + ? WHERE id = ? AND (effectif_actuel + ?) >= 0',
        [delta, lotId, delta],
      );
      logger.info(
        '✅ Effectif lot $lotId ajusté: ${delta >= 0 ? '+' : ''}$delta',
      );
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajustement de l\'effectif: $e');
      rethrow;
    }
  }

  /// Changer le statut d'un lot
  Future<void> changerStatutLot(int lotId, StatutLot nouveauStatut) async {
    try {
      final db = await database;
      await db.update(
        'lots',
        {'statut': nouveauStatut.value},
        where: 'id = ?',
        whereArgs: [lotId],
      );
      logger.info('✅ Statut lot $lotId changé: ${nouveauStatut.label}');
    } catch (e) {
      logger.error('❌ Erreur lors du changement de statut: $e');
      rethrow;
    }
  }

  // ============= GÉNÉRATION D'IDENTIFIANT =============

  /// Générer le prochain identifiant de lot pour une date donnée
  Future<String> genererProchainIdentifiantLot(DateTime date) async {
    try {
      final db = await database;
      final annee = date.year.toString();
      final mois = date.month.toString().padLeft(2, '0');
      final prefix = 'LP-$annee-$mois-';

      // Trouver le dernier numéro de séquence pour ce mois
      final result = await db.rawQuery(
        "SELECT MAX(CAST(SUBSTR(identifiant, -3) AS INTEGER)) as max_seq FROM lots WHERE identifiant LIKE ?",
        ['$prefix%'],
      );

      int nextSeq = 1;
      if (result.isNotEmpty && result.first['max_seq'] != null) {
        nextSeq = (result.first['max_seq'] as int) + 1;
      }

      return Lot.genererIdentifiant(date, nextSeq);
    } catch (e) {
      logger.error('❌ Erreur lors de la génération de l\'identifiant: $e');
      // Fallback avec timestamp
      return Lot.genererIdentifiant(date, DateTime.now().millisecond);
    }
  }

  // ============= REQUÊTES FILTRÉES =============

  /// Récupérer les lots par type
  Future<List<Lot>> getLotsByType(TypeLot type) async {
    try {
      final db = await database;
      final results = await db.query(
        'lots',
        where: 'type = ?',
        whereArgs: [type.value],
        orderBy: 'date_creation DESC',
      );
      return results.map((map) => Lot.fromMap(map)).toList();
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des lots par type: $e');
      return [];
    }
  }

  /// Récupérer les lots par statut
  Future<List<Lot>> getLotsByStatut(StatutLot statut) async {
    try {
      final db = await database;
      final results = await db.query(
        'lots',
        where: 'statut = ?',
        whereArgs: [statut.value],
        orderBy: 'date_creation DESC',
      );
      return results.map((map) => Lot.fromMap(map)).toList();
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des lots par statut: $e');
      return [];
    }
  }

  /// Récupérer les lots actifs
  Future<List<Lot>> getLotsActifs() async {
    return getLotsByStatut(StatutLot.actif);
  }

  /// Récupérer les statistiques globales des lots
  Future<Map<String, dynamic>> getLotsStatistiques() async {
    try {
      final db = await database;

      // Effectif total
      final effectifResult = await db.rawQuery(
        'SELECT SUM(effectif_actuel) as total FROM lots WHERE statut = ?',
        [StatutLot.actif.value],
      );
      final effectifTotal = (effectifResult.first['total'] as int?) ?? 0;

      // Nombre de lots par statut
      final lotsParStatut = await db.rawQuery('''
        SELECT statut, COUNT(*) as count FROM lots GROUP BY statut
      ''');

      // Nombre de lots par type
      final lotsParType = await db.rawQuery('''
        SELECT type, COUNT(*) as count FROM lots GROUP BY type
      ''');

      return {
        'effectif_total': effectifTotal,
        'lots_par_statut': {
          for (var r in lotsParStatut) r['statut']: r['count'],
        },
        'lots_par_type': {for (var r in lotsParType) r['type']: r['count']},
      };
    } catch (e) {
      logger.error('❌ Erreur lors du calcul des statistiques: $e');
      return {'effectif_total': 0, 'lots_par_statut': {}, 'lots_par_type': {}};
    }
  }

  // ============= MIGRATION =============

  /// Migrer les lapins existants vers un lot par défaut
  /// Cette méthode crée un lot "MIGRATION" et y assigne tous les lapins sans lot
  Future<Lot?> migrerLapinsSansLot() async {
    try {
      final db = await database;

      // Compter les lapins sans lot
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lapins WHERE lot_id IS NULL',
      );
      final count = (countResult.first['count'] as int?) ?? 0;

      if (count == 0) {
        logger.info('ℹ️ Aucun lapin sans lot à migrer');
        return null;
      }

      // Générer un identifiant pour le lot de migration
      final identifiant = await genererProchainIdentifiantLot(DateTime.now());

      // Créer le lot de migration
      final lotMigration = Lot(
        identifiant: identifiant,
        dateCreation: DateTime.now(),
        effectifInitial: count,
        effectifActuel: count,
        type: TypeLot.mixte,
        statut: StatutLot.actif,
        metadata: LotMetadata(
          notes:
              'Lot créé automatiquement lors de la migration. '
              'Contient $count lapins existants.',
          origine: 'Migration automatique',
        ),
        hasIndividus: true,
      );

      final lotInsere = await insertLot(lotMigration);

      // Assigner tous les lapins sans lot à ce lot
      await db.rawUpdate('UPDATE lapins SET lot_id = ? WHERE lot_id IS NULL', [
        lotInsere.id,
      ]);

      logger.info(
        '✅ Migration terminée: $count lapins assignés au lot ${lotInsere.identifiant}',
      );
      return lotInsere;
    } catch (e) {
      logger.error('❌ Erreur lors de la migration des lapins: $e');
      return null;
    }
  }
}
