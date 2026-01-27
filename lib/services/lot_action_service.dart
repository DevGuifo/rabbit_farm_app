import '../models/lapin.dart';
import '../models/journal_entry.dart';
import 'database_helper.dart';
import 'journal_service.dart';
import '../core/utils/logger.dart';

/// Service pour les actions groupées sur les Lots
///
/// Ce service permet d'appliquer des actions à tous les individus
/// d'un lot en une seule opération (vaccination, pesée, soin, etc.)
class LotActionService {
  static final LotActionService instance = LotActionService._();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final JournalService _journal = JournalService();

  LotActionService._();

  // ============= SOINS & VACCINATION =============

  /// Appliquer une vaccination à tous les individus d'un lot
  ///
  /// Si le lot n'a pas de fiches individuelles (hasIndividus = false),
  /// enregistre l'action au niveau du lot dans les métadonnées.
  ///
  /// [lotId] : ID du lot
  /// [typeVaccin] : Type de vaccin administré
  /// [date] : Date de vaccination
  /// [notes] : Notes additionnelles
  Future<int> vaccinerLot(
    int lotId, {
    required String typeVaccin,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) {
        throw ArgumentError('Lot $lotId non trouvé');
      }

      int nombreTraites = 0;

      if (lot.hasIndividus) {
        // Appliquer aux individus
        final individus = await _db.getIndividusByLotId(lotId);
        final db = await _db.database;

        await db.transaction((txn) async {
          for (final lapin in individus) {
            if (lapin.id != null) {
              await txn.insert('soins', {
                'lapin_id': lapin.id,
                'date': date.toIso8601String(),
                'type': 'Vaccination',
                'description': typeVaccin,
                'medicament': null,
                'dosage': null,
                'date_rappel': null,
                'notes': notes ?? 'Vaccination groupée lot ${lot.identifiant}',
                'medicament_id': null,
              });
              nombreTraites++;
            }
          }
        });
      } else {
        // Enregistrer au niveau lot (effectif comme nombre traité)
        nombreTraites = lot.effectifActuel;
      }

      // 📝 Journal automatique
      await _journal.enregistrer(
        typeEntite: TypeEntite.soin,
        typeAction: TypeAction.creation,
        entiteId: lotId,
        entiteNom: 'Lot ${lot.identifiant}',
        resumeAuto:
            'Vaccination groupée: $typeVaccin sur lot ${lot.identifiant}',
        contexte: {
          'typeVaccin': typeVaccin,
          'nombreTraites': nombreTraites,
          'hasIndividus': lot.hasIndividus,
        },
      );

      logger.info(
        '✅ Vaccination lot ${lot.identifiant}: $nombreTraites sujets',
      );
      return nombreTraites;
    } catch (e) {
      logger.error('❌ Erreur vaccination lot: $e');
      rethrow;
    }
  }

  /// Appliquer un soin à tous les individus d'un lot
  Future<int> soignerLot(
    int lotId, {
    required String typeSoin,
    required String description,
    required DateTime date,
    int? medicamentId,
    String? dosage,
    String? notes,
  }) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) {
        throw ArgumentError('Lot $lotId non trouvé');
      }

      int nombreTraites = 0;

      if (lot.hasIndividus) {
        final individus = await _db.getIndividusByLotId(lotId);
        final db = await _db.database;

        await db.transaction((txn) async {
          for (final lapin in individus) {
            if (lapin.id != null) {
              await txn.insert('soins', {
                'lapin_id': lapin.id,
                'date': date.toIso8601String(),
                'type': typeSoin,
                'description': description,
                'medicament': null,
                'dosage': dosage,
                'date_rappel': null,
                'notes': notes ?? 'Soin groupé lot ${lot.identifiant}',
                'medicament_id': medicamentId,
              });
              nombreTraites++;
            }
          }
        });
      } else {
        nombreTraites = lot.effectifActuel;
      }

      // 📝 Journal
      await _journal.enregistrer(
        typeEntite: TypeEntite.soin,
        typeAction: TypeAction.creation,
        entiteId: lotId,
        entiteNom: 'Lot ${lot.identifiant}',
        resumeAuto: 'Soin groupé: $typeSoin sur lot ${lot.identifiant}',
        contexte: {'typeSoin': typeSoin, 'nombreTraites': nombreTraites},
      );

      logger.info('✅ Soin lot ${lot.identifiant}: $nombreTraites sujets');
      return nombreTraites;
    } catch (e) {
      logger.error('❌ Erreur soin lot: $e');
      rethrow;
    }
  }

  // ============= PESÉE GROUPÉE =============

  /// Enregistrer une pesée groupée (poids moyen du lot)
  ///
  /// Met à jour le poids moyen dans les métadonnées du lot.
  /// Si le lot a des individus, peut optionnellement mettre à jour
  /// le poids de tous les individus avec la moyenne.
  Future<void> peserLot(
    int lotId, {
    required double poidsMoyen,
    required DateTime date,
    bool mettreAJourIndividus = false,
  }) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) {
        throw ArgumentError('Lot $lotId non trouvé');
      }

      // Mettre à jour les métadonnées du lot
      final newMetadata = lot.metadata.copyWith(poidsMoyen: poidsMoyen);
      await _db.updateLot(lot.copyWith(metadata: newMetadata));

      // Optionnel: mettre à jour les individus
      if (mettreAJourIndividus && lot.hasIndividus) {
        final db = await _db.database;
        await db.rawUpdate('UPDATE lapins SET poids = ? WHERE lot_id = ?', [
          poidsMoyen,
          lotId,
        ]);
      }

      // 📝 Journal
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.modification,
        entiteId: lotId,
        entiteNom: 'Lot ${lot.identifiant}',
        resumeAuto:
            'Pesée lot ${lot.identifiant}: ${poidsMoyen.toStringAsFixed(2)} kg',
        contexte: {'poidsMoyen': poidsMoyen, 'effectif': lot.effectifActuel},
      );

      logger.info('✅ Pesée lot ${lot.identifiant}: $poidsMoyen kg');
    } catch (e) {
      logger.error('❌ Erreur pesée lot: $e');
      rethrow;
    }
  }

  // ============= CHANGEMENT DE STATUT GROUPÉ =============

  /// Changer le statut de tous les individus d'un lot
  Future<int> changerStatutIndividus(
    int lotId, {
    required String nouveauStatut,
  }) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) {
        throw ArgumentError('Lot $lotId non trouvé');
      }

      if (!lot.hasIndividus) {
        logger.warning(
          '⚠️ Lot ${lot.identifiant} n\'a pas de fiches individuelles',
        );
        return 0;
      }

      final db = await _db.database;
      final result = await db.rawUpdate(
        'UPDATE lapins SET statut = ? WHERE lot_id = ?',
        [nouveauStatut, lotId],
      );

      // 📝 Journal
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.modification,
        entiteId: lotId,
        entiteNom: 'Lot ${lot.identifiant}',
        resumeAuto: 'Changement statut lot ${lot.identifiant}: $nouveauStatut',
        contexte: {'nouveauStatut': nouveauStatut, 'nombreMisAJour': result},
      );

      logger.info(
        '✅ Statut lot ${lot.identifiant}: $result individus → $nouveauStatut',
      );
      return result;
    } catch (e) {
      logger.error('❌ Erreur changement statut lot: $e');
      rethrow;
    }
  }

  // ============= DÉPLACEMENTS GROUPÉS =============

  /// Déplacer tous les individus d'un lot vers une nouvelle cage
  Future<int> deplacerLot(int lotId, {required int nouvelleCageId}) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) {
        throw ArgumentError('Lot $lotId non trouvé');
      }

      // Mettre à jour le lot
      await _db.updateLot(lot.copyWith(cageId: nouvelleCageId));

      int nombreDeplaces = 0;

      // Si le lot a des individus, mettre à jour aussi
      if (lot.hasIndividus) {
        final db = await _db.database;
        nombreDeplaces = await db.rawUpdate(
          'UPDATE lapins SET cage_id = ? WHERE lot_id = ?',
          [nouvelleCageId, lotId],
        );
      } else {
        nombreDeplaces = lot.effectifActuel;
      }

      // 📝 Journal
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.modification,
        entiteId: lotId,
        entiteNom: 'Lot ${lot.identifiant}',
        resumeAuto:
            'Deplacement lot ${lot.identifiant} vers cage #$nouvelleCageId',
        contexte: {
          'nouvelleCageId': nouvelleCageId,
          'nombreDeplaces': nombreDeplaces,
        },
      );

      logger.info(
        '✅ Deplacement lot ${lot.identifiant}: $nombreDeplaces sujets',
      );
      return nombreDeplaces;
    } catch (e) {
      logger.error('❌ Erreur déplacement lot: $e');
      rethrow;
    }
  }

  // ============= STATISTIQUES =============

  /// Obtenir le résumé des actions effectuées sur un lot
  Future<Map<String, dynamic>> getResumeLot(int lotId) async {
    try {
      final lot = await _db.getLotById(lotId);
      if (lot == null) return {};

      final individus = lot.hasIndividus
          ? await _db.getIndividusByLotId(lotId)
          : <Lapin>[];

      // Compter les soins si individus
      int totalSoins = 0;
      if (lot.hasIndividus && individus.isNotEmpty) {
        final db = await _db.database;
        final ids = individus
            .map((l) => l.id)
            .where((id) => id != null)
            .toList();
        if (ids.isNotEmpty) {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM soins WHERE lapin_id IN (${ids.join(",")})',
          );
          totalSoins = (result.first['count'] as int?) ?? 0;
        }
      }

      return {
        'lot': lot,
        'effectifActuel': lot.effectifActuel,
        'tauxMortalite': lot.tauxMortalite,
        'poidsMoyen': lot.metadata.poidsMoyen,
        'ageEnJours': lot.ageEnJours,
        'hasIndividus': lot.hasIndividus,
        'nombreIndividus': individus.length,
        'totalSoins': totalSoins,
      };
    } catch (e) {
      logger.error('❌ Erreur résumé lot: $e');
      return {};
    }
  }
}
