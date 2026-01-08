import '../models/journal_entry.dart';
import '../utils/logger.dart';
import 'database_helper.dart';

/// Service de journalisation automatique
///
/// Principe : L'utilisateur agit, l'app écrit.
///
/// Ce service capture automatiquement toutes les actions utilisateur
/// et génère un historique riche sans saisie manuelle.
class JournalService {
  // Singleton pattern
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;
  JournalService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= MÉTHODES DE JOURNALISATION AUTOMATIQUE =============

  /// Enregistrer un événement dans le journal
  ///
  /// Cette méthode est appelée automatiquement par les providers
  /// lors de chaque action utilisateur.
  Future<int> enregistrer({
    required TypeEntite typeEntite,
    required TypeAction typeAction,
    int? entiteId,
    String? entiteNom,
    StatutEvenement statut = StatutEvenement.normal,
    String? resumeAuto,
    Map<String, dynamic> contexte = const {},
  }) async {
    // Générer le résumé automatique si non fourni
    final resume =
        resumeAuto ?? _genererResume(typeEntite, typeAction, entiteNom);

    final entry = JournalEntry(
      timestamp: DateTime.now(),
      typeEntite: typeEntite,
      entiteId: entiteId,
      entiteNom: entiteNom,
      typeAction: typeAction,
      statut: statut,
      resumeAuto: resume,
      contexte: contexte,
    );

    try {
      final id = await _db.insertJournalEntry(entry);
      logger.debug('📝 Journal auto: $resume');
      return id;
    } catch (e) {
      logger.error('❌ Erreur journalisation: $e');
      return -1;
    }
  }

  /// Générer un résumé automatique lisible
  String _genererResume(TypeEntite type, TypeAction action, String? nom) {
    final entiteLabel = nom ?? type.label;
    final actionVerbe = action.verbe;
    return '$entiteLabel $actionVerbe';
  }

  // ============= RACCOURCIS PAR TYPE D'ENTITÉ =============

  /// Journaliser une action sur un lapin
  Future<int> lapin({
    required TypeAction action,
    required int lapinId,
    required String lapinNom,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    return enregistrer(
      typeEntite: TypeEntite.lapin,
      typeAction: action,
      entiteId: lapinId,
      entiteNom: lapinNom,
      contexte: contexte,
      statut: statut,
    );
  }

  /// Journaliser une action sur un accouplement
  Future<int> accouplement({
    required TypeAction action,
    required int accouplementId,
    String? maleNom,
    String? femelleNom,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = maleNom != null && femelleNom != null
        ? '$maleNom × $femelleNom'
        : 'Accouplement #$accouplementId';
    return enregistrer(
      typeEntite: TypeEntite.accouplement,
      typeAction: action,
      entiteId: accouplementId,
      entiteNom: nom,
      contexte: {
        if (maleNom != null) 'male': maleNom,
        if (femelleNom != null) 'femelle': femelleNom,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une action sur une portée
  Future<int> portee({
    required TypeAction action,
    required int porteeId,
    String? mereNom,
    int? nombreLapereaux,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = mereNom != null ? 'Portée de $mereNom' : 'Portée #$porteeId';
    return enregistrer(
      typeEntite: TypeEntite.portee,
      typeAction: action,
      entiteId: porteeId,
      entiteNom: nom,
      contexte: {
        if (nombreLapereaux != null) 'nombreLapereaux': nombreLapereaux,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser un soin
  Future<int> soin({
    required TypeAction action,
    required int soinId,
    required String lapinNom,
    String? typeSoin,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = typeSoin != null
        ? '$typeSoin pour $lapinNom'
        : 'Soin pour $lapinNom';
    return enregistrer(
      typeEntite: TypeEntite.soin,
      typeAction: action,
      entiteId: soinId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (typeSoin != null) 'type': typeSoin,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une pesée
  Future<int> pesee({
    required TypeAction action,
    required int peseeId,
    required String lapinNom,
    double? poids,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = poids != null
        ? '$lapinNom : ${poids.toStringAsFixed(2)} kg'
        : 'Pesée de $lapinNom';
    return enregistrer(
      typeEntite: TypeEntite.pesee,
      typeAction: action,
      entiteId: peseeId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (poids != null) 'poids': poids,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une dépense
  Future<int> depense({
    required TypeAction action,
    required int depenseId,
    required double montant,
    String? categorie,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = categorie != null
        ? '$categorie : ${montant.toStringAsFixed(0)} FCFA'
        : 'Dépense : ${montant.toStringAsFixed(0)} FCFA';
    return enregistrer(
      typeEntite: TypeEntite.depense,
      typeAction: action,
      entiteId: depenseId,
      entiteNom: nom,
      contexte: {
        'montant': montant,
        if (categorie != null) 'categorie': categorie,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une recette
  Future<int> recette({
    required TypeAction action,
    required int recetteId,
    required double montant,
    String? categorie,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = categorie != null
        ? '$categorie : ${montant.toStringAsFixed(0)} FCFA'
        : 'Recette : ${montant.toStringAsFixed(0)} FCFA';
    return enregistrer(
      typeEntite: TypeEntite.recette,
      typeAction: action,
      entiteId: recetteId,
      entiteNom: nom,
      contexte: {
        'montant': montant,
        if (categorie != null) 'categorie': categorie,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser un décès
  Future<int> deces({
    required TypeAction action,
    required int decesId,
    required String lapinNom,
    String? cause,
    Map<String, dynamic> contexte = const {},
  }) {
    final nom = cause != null ? '$lapinNom - $cause' : 'Décès de $lapinNom';
    return enregistrer(
      typeEntite: TypeEntite.deces,
      typeAction: action,
      entiteId: decesId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (cause != null) 'cause': cause,
        ...contexte,
      },
      statut: StatutEvenement.anomalie,
    );
  }

  /// Journaliser une mise en quarantaine
  Future<int> quarantaine({
    required TypeAction action,
    required int quarantaineId,
    required String lapinNom,
    String? raison,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.action,
  }) {
    final nom = raison != null
        ? '$lapinNom en quarantaine: $raison'
        : '$lapinNom mis en quarantaine';
    return enregistrer(
      typeEntite: TypeEntite.quarantaine,
      typeAction: action,
      entiteId: quarantaineId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (raison != null) 'raison': raison,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser un sevrage
  Future<int> sevrage({
    required TypeAction action,
    required int sevrageId,
    required String lapinNom,
    int? ageJours,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.succes,
  }) {
    final nom = ageJours != null
        ? '$lapinNom sevré à $ageJours jours'
        : '$lapinNom sevré';
    return enregistrer(
      typeEntite: TypeEntite.sevrage,
      typeAction: action,
      entiteId: sevrageId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (ageJours != null) 'ageJours': ageJours,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser un rituel
  Future<int> rituel({
    required TypeAction action,
    required int rituelId,
    required String typeRituel,
    int? actionsCompletees,
    int? totalActions,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final progression = actionsCompletees != null && totalActions != null
        ? ' ($actionsCompletees/$totalActions)'
        : '';
    final nom = 'Rituel $typeRituel$progression';
    return enregistrer(
      typeEntite: TypeEntite.rituel,
      typeAction: action,
      entiteId: rituelId,
      entiteNom: nom,
      contexte: {
        'type': typeRituel,
        if (actionsCompletees != null) 'completees': actionsCompletees,
        if (totalActions != null) 'total': totalActions,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une anomalie
  Future<int> anomalie({
    required int anomalieId,
    required String description,
    required int severite,
    String? lapinNom,
    Map<String, dynamic> contexte = const {},
  }) {
    final statut = severite >= 3
        ? StatutEvenement.anomalie
        : severite >= 2
        ? StatutEvenement.action
        : StatutEvenement.info;

    final nom = lapinNom != null
        ? 'Anomalie sur $lapinNom: $description'
        : 'Anomalie: $description';

    return enregistrer(
      typeEntite: TypeEntite.anomalie,
      typeAction: TypeAction.anomalie,
      entiteId: anomalieId,
      entiteNom: nom,
      contexte: {
        'severite': severite,
        if (lapinNom != null) 'lapin': lapinNom,
        'description': description,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une palpation
  Future<int> palpation({
    required TypeAction action,
    required int palpationId,
    required String femelleNom,
    String? resultat,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    final nom = resultat != null
        ? 'Palpation $femelleNom: $resultat'
        : 'Palpation de $femelleNom';
    return enregistrer(
      typeEntite: TypeEntite.palpation,
      typeAction: action,
      entiteId: palpationId,
      entiteNom: nom,
      contexte: {
        'femelle': femelleNom,
        if (resultat != null) 'resultat': resultat,
        ...contexte,
      },
      statut: statut,
    );
  }

  /// Journaliser une préparation de nid
  Future<int> preparationNid({
    required TypeAction action,
    required int preparationId,
    required String femelleNom,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.normal,
  }) {
    return enregistrer(
      typeEntite: TypeEntite.preparationNid,
      typeAction: action,
      entiteId: preparationId,
      entiteNom: 'Nid préparé pour $femelleNom',
      contexte: {'femelle': femelleNom, ...contexte},
      statut: statut,
    );
  }

  /// Journaliser une réforme
  Future<int> reforme({
    required TypeAction action,
    required int reformeId,
    required String lapinNom,
    String? motif,
    Map<String, dynamic> contexte = const {},
    StatutEvenement statut = StatutEvenement.info,
  }) {
    final nom = motif != null
        ? '$lapinNom réformé: $motif'
        : '$lapinNom réformé';
    return enregistrer(
      typeEntite: TypeEntite.reforme,
      typeAction: action,
      entiteId: reformeId,
      entiteNom: nom,
      contexte: {
        'lapin': lapinNom,
        if (motif != null) 'motif': motif,
        ...contexte,
      },
      statut: statut,
    );
  }

  // ============= CONSULTATION =============

  /// Obtenir le journal d'aujourd'hui
  Future<List<JournalEntry>> aujourdhui() => _db.getJournalAujourdhui();

  /// Obtenir le journal de la semaine
  Future<List<JournalEntry>> semaine() => _db.getJournalSemaine();

  /// Obtenir le journal du mois
  Future<List<JournalEntry>> mois() => _db.getJournalMois();

  /// Obtenir les entrées non lues
  Future<List<JournalEntry>> nonLus() => _db.getJournalNonLu();

  /// Compter les entrées non lues
  Future<int> countNonLus() => _db.countJournalNonLu();

  /// Obtenir l'historique d'une entité
  Future<List<JournalEntry>> historiqueEntite(TypeEntite type, int id) =>
      _db.getHistoriqueEntite(type, id);

  /// Marquer comme lu
  Future<void> marquerLu(int id) => _db.marquerJournalLu(id);

  /// Marquer tout comme lu
  Future<void> marquerToutLu() => _db.marquerToutLu();

  /// Ajouter une note utilisateur
  Future<void> ajouterNote(int id, String note) =>
      _db.ajouterNoteJournal(id, note);

  /// Obtenir les statistiques
  Future<Map<String, dynamic>> stats() => _db.getStatsJournal();
}
