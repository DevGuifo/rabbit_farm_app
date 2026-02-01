import 'package:flutter/foundation.dart';
import '../models/lot.dart';
import '../models/lapin.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart';
import '../services/journal_service.dart';
import '../core/utils/logger.dart';

/// Provider pour gérer les Lots avec SQLite
///
/// Ce provider centralise toutes les opérations sur les lots :
/// - CRUD lots
/// - Gestion des effectifs
/// - Relation lots/individus
/// - Statistiques
class LotProvider with ChangeNotifier {
  // Services - injection de dépendance pour les tests
  final DatabaseHelper _db;
  final JournalService _journal;

  // Liste des lots en cache
  List<Lot> _lots = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructeur par défaut utilisant les singletons
  LotProvider() : _db = DatabaseHelper.instance, _journal = JournalService();

  /// Constructeur pour les tests avec injection de dépendance
  @visibleForTesting
  LotProvider.withDatabase(DatabaseHelper db, [JournalService? journal])
    : _db = db,
      _journal = journal ?? JournalService();

  // ============= GETTERS =============

  /// Obtenir la liste complète des lots
  List<Lot> get lots => List.unmodifiable(_lots);

  /// Obtenir les lots actifs uniquement
  List<Lot> get lotsActifs =>
      _lots.where((l) => l.statut == StatutLot.actif).toList();

  /// Obtenir le nombre total de lots
  int get nombreLots => _lots.length;

  /// Obtenir l'effectif total (tous lots actifs)
  int get effectifTotal => _lots.actifs.effectifTotal;

  /// Indique si les données sont en cours de chargement
  bool get isLoading => _isLoading;

  /// Message d'erreur le cas échéant
  String? get errorMessage => _errorMessage;

  // ============= CHARGEMENT =============

  /// Charger tous les lots depuis la base de données
  Future<void> chargerLots() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lots = await _db.getAllLots();
      logger.info('✅ ${_lots.length} lots chargés');
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des lots', e);
      _errorMessage = 'Erreur lors du chargement des lots';
      _lots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir les données
  Future<void> rafraichir() => chargerLots();

  // ============= GETTERS SPÉCIFIQUES =============

  /// Obtenir un lot par son ID
  Lot? getLotById(int id) {
    try {
      return _lots.firstWhere((lot) => lot.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir un lot par son identifiant (LP-XXXX-XX-XXX)
  Lot? getLotByIdentifiant(String identifiant) {
    try {
      return _lots.firstWhere((lot) => lot.identifiant == identifiant);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les lots par type
  List<Lot> getLotsParType(TypeLot type) {
    return _lots.where((lot) => lot.type == type).toList();
  }

  /// Obtenir les lots par statut
  List<Lot> getLotsParStatut(StatutLot statut) {
    return _lots.where((lot) => lot.statut == statut).toList();
  }

  /// Lots d'engraissement actifs
  List<Lot> get lotsEngraissement => _lots
      .where(
        (l) => l.type == TypeLot.engraissement && l.statut == StatutLot.actif,
      )
      .toList();

  /// Lots de reproduction actifs
  List<Lot> get lotsReproduction => _lots
      .where(
        (l) => l.type == TypeLot.reproduction && l.statut == StatutLot.actif,
      )
      .toList();

  // ============= OPÉRATIONS CRUD =============

  /// Ajouter un nouveau lot
  Future<Lot> ajouterLot({
    required int effectif,
    required TypeLot type,
    int? cageId,
    LotMetadata? metadata,
    String? photoPath,
  }) async {
    try {
      // Générer l'identifiant unique
      final identifiant = await _db.genererProchainIdentifiantLot(
        DateTime.now(),
      );

      final lot = Lot(
        identifiant: identifiant,
        dateCreation: DateTime.now(),
        effectifInitial: effectif,
        effectifActuel: effectif,
        type: type,
        statut: StatutLot.actif,
        cageId: cageId,
        metadata: metadata ?? const LotMetadata(),
        photoPath: photoPath,
        hasIndividus: false,
      );

      final lotAjoute = await _db.insertLot(lot);
      _lots.add(lotAjoute);
      notifyListeners();

      // 📝 Journal automatique
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.creation,
        entiteId: lotAjoute.id,
        entiteNom: 'Lot ${lotAjoute.identifiant}',
        resumeAuto: 'Création du lot ${lotAjoute.identifiant}',
        contexte: {
          'type': type.label,
          'effectif': effectif,
          'identifiant': lotAjoute.identifiant,
        },
      );

      logger.info('✅ Lot créé: ${lotAjoute.identifiant}');
      return lotAjoute;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout du lot', e);
      rethrow;
    }
  }

  /// Ajouter un nouveau lot AVEC création optionnelle des fiches individuelles
  ///
  /// Cette méthode permet de créer un lot de 50-100+ lapins d'un coup
  /// en générant automatiquement leurs IDs au format LP-XXXX-XX-XXX.
  ///
  /// [effectif] : Nombre de lapins dans le lot
  /// [type] : Type de lot (engraissement, reproduction, mixte)
  /// [creerFichesIndividuelles] : Si true, crée une fiche par lapin
  /// [cageId] : Cage assignée (optionnel)
  /// [metadata] : Métadonnées du lot (race, origine, poids...)
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final lot = await lotProvider.ajouterLotAvecIndividus(
  ///   effectif: 50,
  ///   type: TypeLot.engraissement,
  ///   creerFichesIndividuelles: true,
  ///   metadata: LotMetadata(race: 'Californien', poidsEntree: 0.8),
  /// );
  /// ```
  Future<Lot> ajouterLotAvecIndividus({
    required int effectif,
    required TypeLot type,
    bool creerFichesIndividuelles = false,
    int? cageId,
    LotMetadata? metadata,
    String? photoPath,
  }) async {
    try {
      final lotAjoute = await _db.creerLotAvecIndividus(
        effectif: effectif,
        type: type,
        cageId: cageId,
        metadata: metadata,
        creerFichesIndividuelles: creerFichesIndividuelles,
      );

      _lots.add(lotAjoute);
      notifyListeners();

      // 📝 Journal automatique
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.creation,
        entiteId: lotAjoute.id,
        entiteNom: 'Lot ${lotAjoute.identifiant}',
        resumeAuto: creerFichesIndividuelles
            ? 'Création lot ${lotAjoute.identifiant} avec $effectif fiches individuelles'
            : 'Création lot ${lotAjoute.identifiant}',
        contexte: {
          'type': type.label,
          'effectif': effectif,
          'identifiant': lotAjoute.identifiant,
          'fichesIndividuelles': creerFichesIndividuelles,
        },
      );

      logger.info(
        '✅ Lot créé: ${lotAjoute.identifiant} (${creerFichesIndividuelles ? "avec" : "sans"} fiches)',
      );
      return lotAjoute;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout du lot avec individus', e);
      rethrow;
    }
  }

  /// Modifier un lot existant
  Future<void> modifierLot(Lot lot) async {
    if (lot.id == null) {
      throw ArgumentError('Impossible de modifier un lot sans ID');
    }

    try {
      await _db.updateLot(lot);
      final index = _lots.indexWhere((l) => l.id == lot.id);
      if (index != -1) {
        _lots[index] = lot;
        notifyListeners();

        // 📝 Journal automatique
        await _journal.enregistrer(
          typeEntite: TypeEntite.autre,
          typeAction: TypeAction.modification,
          entiteId: lot.id,
          entiteNom: 'Lot ${lot.identifiant}',
          resumeAuto: 'Modification du lot ${lot.identifiant}',
          contexte: {
            'statut': lot.statut.label,
            'effectif': lot.effectifActuel,
          },
        );
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la modification du lot', e);
      rethrow;
    }
  }

  /// Supprimer un lot
  ///
  /// ⚠️ Garde-fou Phase C : Vérifie qu'aucun lapin n'est associé au lot avant suppression.
  /// Si des lapins sont présents, lance une exception avec message explicite.
  Future<void> supprimerLot(int id) async {
    try {
      // Garde-fou : Vérifier qu'aucun lapin n'est associé
      final nombreLapins = await compterIndividusDuLot(id);
      if (nombreLapins > 0) {
        throw StateError(
          'Impossible de supprimer ce lot : $nombreLapins lapin(s) y sont encore associés. '
          'Veuillez d\'abord retirer ou réassigner ces lapins.',
        );
      }

      final lot = getLotById(id);
      final identifiant = lot?.identifiant ?? 'Lot #$id';

      await _db.deleteLot(id);
      _lots.removeWhere((lot) => lot.id == id);
      notifyListeners();

      // 📝 Journal automatique
      await _journal.enregistrer(
        typeEntite: TypeEntite.autre,
        typeAction: TypeAction.suppression,
        entiteId: id,
        entiteNom: 'Lot $identifiant',
        resumeAuto: 'Suppression du lot $identifiant',
      );

      logger.info('✅ Lot $identifiant supprimé');
    } on StateError {
      rethrow; // Propager l'erreur de garde-fou
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression du lot', e);
      rethrow;
    }
  }

  // ============= GESTION EFFECTIFS =============

  /// Mettre à jour l'effectif d'un lot
  Future<void> mettreAJourEffectif(int lotId, int nouvelEffectif) async {
    try {
      await _db.updateEffectifLot(lotId, nouvelEffectif);

      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1) {
        _lots[index] = _lots[index].copyWith(effectifActuel: nouvelEffectif);
        notifyListeners();
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour de l\'effectif', e);
      rethrow;
    }
  }

  /// Enregistrer une mortalité dans un lot
  Future<void> enregistrerMortalite(
    int lotId,
    int nombreMorts, {
    String? notes,
  }) async {
    try {
      await _db.ajusterEffectifLot(lotId, -nombreMorts);

      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1) {
        final lot = _lots[index];
        _lots[index] = lot.copyWith(
          effectifActuel: lot.effectifActuel - nombreMorts,
        );
        notifyListeners();

        // 📝 Journal automatique
        await _journal.enregistrer(
          typeEntite: TypeEntite.autre,
          typeAction: TypeAction.modification,
          entiteId: lotId,
          entiteNom: 'Lot ${lot.identifiant}',
          resumeAuto: 'Mortalité dans lot ${lot.identifiant}: $nombreMorts',
          contexte: {
            'nombreMorts': nombreMorts,
            'effectifRestant': lot.effectifActuel - nombreMorts,
            if (notes != null) 'notes': notes,
          },
        );
      }
    } catch (e) {
      logger.error('❌ Erreur lors de l\'enregistrement de la mortalité', e);
      rethrow;
    }
  }

  /// Enregistrer une vente partielle d'un lot
  Future<void> enregistrerVente(
    int lotId,
    int nombreVendus, {
    double? prixTotal,
  }) async {
    try {
      await _db.ajusterEffectifLot(lotId, -nombreVendus);

      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1) {
        final lot = _lots[index];
        _lots[index] = lot.copyWith(
          effectifActuel: lot.effectifActuel - nombreVendus,
        );
        notifyListeners();

        // 📝 Journal automatique
        await _journal.enregistrer(
          typeEntite: TypeEntite.vente,
          typeAction: TypeAction.creation,
          entiteId: lotId,
          entiteNom: 'Lot ${lot.identifiant}',
          resumeAuto: 'Vente de $nombreVendus sujets du lot ${lot.identifiant}',
          contexte: {
            'nombreVendus': nombreVendus,
            'effectifRestant': lot.effectifActuel - nombreVendus,
            if (prixTotal != null) 'prixTotal': prixTotal,
          },
        );
      }
    } catch (e) {
      logger.error('❌ Erreur lors de l\'enregistrement de la vente', e);
      rethrow;
    }
  }

  // ============= GESTION STATUTS =============

  /// Changer le statut d'un lot
  Future<void> changerStatut(int lotId, StatutLot nouveauStatut) async {
    try {
      await _db.changerStatutLot(lotId, nouveauStatut);

      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1) {
        final lot = _lots[index];
        _lots[index] = lot.copyWith(statut: nouveauStatut);
        notifyListeners();

        // 📝 Journal automatique
        await _journal.enregistrer(
          typeEntite: TypeEntite.autre,
          typeAction: TypeAction.modification,
          entiteId: lotId,
          entiteNom: 'Lot ${lot.identifiant}',
          resumeAuto:
              'Changement statut lot ${lot.identifiant}: ${nouveauStatut.label}',
        );
      }
    } catch (e) {
      logger.error('❌ Erreur lors du changement de statut', e);
      rethrow;
    }
  }

  /// Terminer un lot (tous vendus/réformés)
  Future<void> terminerLot(int lotId) async {
    await changerStatut(lotId, StatutLot.termine);
  }

  /// Marquer un lot comme vendu
  Future<void> marquerVendu(int lotId) async {
    await changerStatut(lotId, StatutLot.vendu);
  }

  // ============= RELATION LOTS/INDIVIDUS =============

  /// Récupérer les individus d'un lot
  Future<List<Lapin>> getIndividusDuLot(int lotId) async {
    try {
      return await _db.getIndividusByLotId(lotId);
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des individus', e);
      return [];
    }
  }

  /// Compter les individus d'un lot
  Future<int> compterIndividusDuLot(int lotId) async {
    try {
      return await _db.countIndividusByLotId(lotId);
    } catch (e) {
      logger.error('❌ Erreur lors du comptage des individus', e);
      return 0;
    }
  }

  /// Assigner un lapin existant à un lot
  Future<void> assignerLapinAuLot(int lapinId, int lotId) async {
    try {
      await _db.assignerLapinALot(lapinId, lotId);

      // Mettre à jour le flag hasIndividus
      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1 && !_lots[index].hasIndividus) {
        _lots[index] = _lots[index].copyWith(hasIndividus: true);
        notifyListeners();
      }
    } catch (e) {
      logger.error('❌ Erreur lors de l\'assignation du lapin', e);
      rethrow;
    }
  }

  /// Retirer un lapin d'un lot (Phase C - garde-fou)
  ///
  /// Cette méthode retire un lapin du lot sans perte de données :
  /// - Le lapin reste dans la base avec lot_id = null
  /// - L'effectif du lot est décrémenté
  /// - Le journal est mis à jour
  Future<void> retirerLapinDuLot(int lapinId, int lotId) async {
    try {
      // Retirer le lapin du lot (met lot_id à null)
      await _db.retirerLapinDuLot(lapinId);

      // Mettre à jour l'effectif du lot
      final index = _lots.indexWhere((l) => l.id == lotId);
      if (index != -1) {
        final lot = _lots[index];
        final nouveauEffectif = lot.effectifActuel - 1;
        _lots[index] = lot.copyWith(effectifActuel: nouveauEffectif);

        // Si plus aucun individu, mettre à jour hasIndividus
        if (nouveauEffectif == 0) {
          _lots[index] = _lots[index].copyWith(hasIndividus: false);
        }

        notifyListeners();

        // 📝 Journal automatique
        await _journal.enregistrer(
          typeEntite: TypeEntite.autre,
          typeAction: TypeAction.modification,
          entiteId: lotId,
          entiteNom: 'Lot ${lot.identifiant}',
          resumeAuto: 'Lapin #$lapinId retiré du lot ${lot.identifiant}',
          contexte: {'lapinId': lapinId, 'effectifRestant': nouveauEffectif},
        );
      }

      logger.info('✅ Lapin #$lapinId retiré du lot #$lotId');
    } catch (e) {
      logger.error('❌ Erreur lors du retrait du lapin', e);
      rethrow;
    }
  }

  // ============= STATISTIQUES =============

  /// Obtenir les statistiques globales des lots
  Future<Map<String, dynamic>> getStatistiques() async {
    try {
      return await _db.getLotsStatistiques();
    } catch (e) {
      logger.error('❌ Erreur lors du calcul des statistiques', e);
      return {};
    }
  }

  /// Lots avec mortalité élevée (> 10%)
  List<Lot> get lotsAvecMortaliteElevee => _lots.avecMortaliteElevee;

  /// Lots à surveiller (mortalité > 5%)
  List<Lot> get lotsASurveiller => _lots
      .where((l) => l.tauxMortalite > 5 && l.statut == StatutLot.actif)
      .toList();

  // ============= MIGRATION =============

  /// Migrer les lapins existants sans lot vers un lot par défaut
  Future<Lot?> migrerLapinsExistants() async {
    try {
      final lotMigration = await _db.migrerLapinsSansLot();
      if (lotMigration != null) {
        _lots.add(lotMigration);
        notifyListeners();
      }
      return lotMigration;
    } catch (e) {
      logger.error('❌ Erreur lors de la migration', e);
      return null;
    }
  }

  // ============= RECHERCHE =============

  /// Rechercher des lots par terme
  List<Lot> rechercher(String terme) {
    if (terme.isEmpty) return _lots;

    final termeNormalise = terme.toLowerCase();
    return _lots.where((lot) {
      return lot.identifiant.toLowerCase().contains(termeNormalise) ||
          lot.type.label.toLowerCase().contains(termeNormalise) ||
          lot.statut.label.toLowerCase().contains(termeNormalise) ||
          (lot.metadata.race?.toLowerCase().contains(termeNormalise) ??
              false) ||
          (lot.metadata.notes?.toLowerCase().contains(termeNormalise) ?? false);
    }).toList();
  }

  /// Filtrer les lots
  List<Lot> filtrer({
    TypeLot? type,
    StatutLot? statut,
    int? effectifMin,
    int? effectifMax,
  }) {
    return _lots.where((lot) {
      if (type != null && lot.type != type) return false;
      if (statut != null && lot.statut != statut) return false;
      if (effectifMin != null && lot.effectifActuel < effectifMin) return false;
      if (effectifMax != null && lot.effectifActuel > effectifMax) return false;
      return true;
    }).toList();
  }
}
