import '../utils/logger.dart';
import 'database_helper.dart';
import 'notification_quota_manager.dart';

/// Notification consolidée prête à être envoyée
class ConsolidatedNotification {
  /// Titre de la notification
  final String titre;

  /// Corps du message
  final String corps;

  /// Payload pour la navigation (format: "type:id" ou "type:consolidated")
  final String payload;

  /// Priorité pour la gestion du quota
  final NotificationPriorite priorite;

  /// Nombre d'éléments regroupés
  final int count;

  /// IDs originaux des éléments regroupés (pour suivi)
  final List<int> idsOriginaux;

  /// Type de consolidation
  final TypeConsolidation type;

  const ConsolidatedNotification({
    required this.titre,
    required this.corps,
    required this.payload,
    required this.priorite,
    required this.count,
    required this.idsOriginaux,
    required this.type,
  });

  @override
  String toString() {
    return 'ConsolidatedNotification(type: $type, count: $count, titre: $titre)';
  }
}

/// Types de consolidation supportés
enum TypeConsolidation {
  peseeHebdo,
  stockFaible,
  poidsAnormal,
  vaccinationRappel,
  sevrage,
}

/// Élément de pesée en attente
class PendingPesee {
  final int lapinId;
  final String nomLapin;
  final DateTime datePrevue;

  const PendingPesee({
    required this.lapinId,
    required this.nomLapin,
    required this.datePrevue,
  });
}

/// Alerte de stock faible
class StockAlerte {
  final int produitId;
  final String nomProduit;
  final String categorie; // 'aliment', 'medicament'
  final double quantiteRestante;

  const StockAlerte({
    required this.produitId,
    required this.nomProduit,
    required this.categorie,
    required this.quantiteRestante,
  });
}

/// Alerte de poids anormal
class PoidsAlerte {
  final int lapinId;
  final String nomLapin;
  final double poidsActuel;
  final double poidsAttendu;
  final double ecartPourcent;

  const PoidsAlerte({
    required this.lapinId,
    required this.nomLapin,
    required this.poidsActuel,
    required this.poidsAttendu,
    required this.ecartPourcent,
  });
}

/// Service de consolidation des notifications
///
/// Regroupe les notifications similaires pour réduire la charge cognitive
/// et améliorer l'expérience utilisateur.
///
/// Exemple d'utilisation :
/// ```dart
/// final consolidator = NotificationConsolidator();
/// final pesees = await consolidator.getPeseesEnAttente();
/// if (pesees.length >= 3) {
///   final notif = await consolidator.consoliderPesees(pesees);
///   // Envoyer notif au lieu de pesees.length notifications
/// }
/// ```
class NotificationConsolidator {
  static final NotificationConsolidator _instance =
      NotificationConsolidator._internal();
  factory NotificationConsolidator() => _instance;
  NotificationConsolidator._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ===== SEUILS DE CONSOLIDATION =====

  /// Nombre minimum d'éléments pour déclencher la consolidation
  static const int seuilConsolidation = 3;

  /// Nombre maximum de noms à afficher dans le résumé
  static const int maxNomsAffichage = 3;

  // ===== CONSOLIDATION PESÉES =====

  /// Récupère les pesées en attente pour la semaine
  Future<List<PendingPesee>> getPeseesEnAttente() async {
    try {
      final lapins = await _db.getAllLapins();
      final pesees = await _db.getAllPesees();
      final now = DateTime.now();
      final result = <PendingPesee>[];

      for (final lapin in lapins) {
        if (lapin.id == null) continue;

        // Trouver la dernière pesée
        final peseesLapin = pesees.where((p) => p.lapinId == lapin.id).toList();
        DateTime? dateDernierePesee;

        if (peseesLapin.isNotEmpty) {
          peseesLapin.sort((a, b) => b.date.compareTo(a.date));
          dateDernierePesee = peseesLapin.first.date;
        }

        // Calculer la date de la prochaine pesée (7 jours après la dernière)
        final dateReference =
            dateDernierePesee ?? now.subtract(const Duration(days: 7));
        final datePrevue = dateReference.add(const Duration(days: 7));

        // Si la pesée est due cette semaine
        if (datePrevue.isBefore(now.add(const Duration(days: 7)))) {
          result.add(
            PendingPesee(
              lapinId: lapin.id!,
              nomLapin: lapin.nom,
              datePrevue: datePrevue,
            ),
          );
        }
      }

      return result;
    } catch (e) {
      logger.error('❌ Erreur récupération pesées en attente: $e');
      return [];
    }
  }

  /// Consolide les notifications de pesée en une seule notification résumée
  Future<ConsolidatedNotification?> consoliderPesees(
    List<PendingPesee> pesees,
  ) async {
    if (pesees.isEmpty) return null;

    // Si moins que le seuil, pas de consolidation
    if (pesees.length < seuilConsolidation) {
      logger.debug(
        '📊 ${pesees.length} pesées en attente (< seuil $seuilConsolidation) : pas de consolidation',
      );
      return null;
    }

    // Trier par date prévue
    pesees.sort((a, b) => a.datePrevue.compareTo(b.datePrevue));

    // Construire le message
    final noms = pesees.map((p) => p.nomLapin).take(maxNomsAffichage).toList();
    final reste = pesees.length - noms.length;

    String corps;
    if (reste > 0) {
      corps =
          '${noms.join(", ")} et $reste autre${reste > 1 ? "s" : ""} attendent leur pesée.';
    } else {
      corps = '${noms.join(", ")} attendent leur pesée.';
    }

    logger.info('📦 Consolidation: ${pesees.length} pesées → 1 notification');

    return ConsolidatedNotification(
      titre: '⚖️ ${pesees.length} pesées à faire cette semaine',
      corps: corps,
      payload: 'pesee:consolidated',
      priorite: NotificationPriorite.operationnelle,
      count: pesees.length,
      idsOriginaux: pesees.map((p) => p.lapinId).toList(),
      type: TypeConsolidation.peseeHebdo,
    );
  }

  // ===== CONSOLIDATION STOCKS =====

  /// Seuil d'alerte par défaut pour les aliments (en kg)
  /// Les aliments n'ont pas de seuil configurable, on utilise 20% de la quantité achetée
  static const double seuilAlerteAlimentPourcent = 0.2;

  /// Récupère les alertes de stock faible
  Future<List<StockAlerte>> getStocksFaibles() async {
    try {
      final result = <StockAlerte>[];

      // Aliments - utiliser quantiteRestante et calculer le seuil (20% de quantiteAchetee)
      final aliments = await _db.getAllAliments();
      for (final aliment in aliments) {
        if (aliment.id == null) continue;
        // Seuil = 20% de la quantité achetée
        final seuil = aliment.quantiteAchetee * seuilAlerteAlimentPourcent;
        if (aliment.quantiteRestante < seuil) {
          result.add(
            StockAlerte(
              produitId: aliment.id!,
              nomProduit: aliment.nom,
              categorie: 'aliment',
              quantiteRestante: aliment.quantiteRestante,
            ),
          );
        }
      }

      // Médicaments - utiliser le getter estSousSeuilAlerte du modèle
      final medicaments = await _db.getAllMedicaments();
      for (final medicament in medicaments) {
        if (medicament.id == null) continue;
        // Utiliser le getter du modèle qui gère le seuil
        if (medicament.estSousSeuilAlerte) {
          result.add(
            StockAlerte(
              produitId: medicament.id!,
              nomProduit: medicament.nom,
              categorie: 'medicament',
              quantiteRestante: medicament.quantiteStock,
            ),
          );
        }
      }

      return result;
    } catch (e) {
      logger.error('❌ Erreur récupération stocks faibles: $e');
      return [];
    }
  }

  /// Consolide les alertes de stock en une seule notification
  Future<ConsolidatedNotification?> consoliderStocks(
    List<StockAlerte> alertes,
  ) async {
    if (alertes.isEmpty) return null;

    // Grouper par catégorie
    final aliments = alertes.where((a) => a.categorie == 'aliment').toList();
    final medicaments = alertes
        .where((a) => a.categorie == 'medicament')
        .toList();

    // Construire le message
    final noms = alertes
        .map((a) => a.nomProduit)
        .take(maxNomsAffichage)
        .toList();
    final reste = alertes.length - noms.length;

    String corps;
    if (reste > 0) {
      corps =
          '${noms.join(", ")} et $reste autre${reste > 1 ? "s" : ""} sont en rupture prochaine.';
    } else {
      corps =
          '${noms.join(", ")} ${alertes.length > 1 ? "sont" : "est"} en rupture prochaine.';
    }

    // Ajouter détail par catégorie
    final details = <String>[];
    if (aliments.isNotEmpty) {
      details.add(
        '${aliments.length} aliment${aliments.length > 1 ? "s" : ""}',
      );
    }
    if (medicaments.isNotEmpty) {
      details.add(
        '${medicaments.length} médicament${medicaments.length > 1 ? "s" : ""}',
      );
    }
    if (details.isNotEmpty) {
      corps += '\n(${details.join(", ")})';
    }

    logger.info(
      '📦 Consolidation: ${alertes.length} alertes stock → 1 notification',
    );

    return ConsolidatedNotification(
      titre: '📦 ${alertes.length} stocks à réapprovisionner',
      corps: corps,
      payload: 'stock:consolidated',
      priorite: NotificationPriorite.operationnelle,
      count: alertes.length,
      idsOriginaux: alertes.map((a) => a.produitId).toList(),
      type: TypeConsolidation.stockFaible,
    );
  }

  // ===== CONSOLIDATION POIDS ANORMAUX =====

  /// Consolide les alertes de poids anormal
  Future<ConsolidatedNotification?> consoliderPoidsAnormaux(
    List<PoidsAlerte> alertes,
  ) async {
    if (alertes.isEmpty) return null;

    // Trier par écart (le plus grave en premier)
    alertes.sort(
      (a, b) => b.ecartPourcent.abs().compareTo(a.ecartPourcent.abs()),
    );

    final noms = alertes.map((a) => a.nomLapin).take(maxNomsAffichage).toList();
    final reste = alertes.length - noms.length;

    String corps;
    if (reste > 0) {
      corps =
          '${noms.join(", ")} et $reste autre${reste > 1 ? "s" : ""} présentent un poids anormal.';
    } else {
      corps =
          '${noms.join(", ")} présente${alertes.length > 1 ? "nt" : ""} un poids anormal.';
    }

    // Ajouter statistique
    final ecartMax = alertes.first.ecartPourcent.abs().toStringAsFixed(0);
    corps += '\nÉcart max: $ecartMax%';

    logger.info(
      '📦 Consolidation: ${alertes.length} alertes poids → 1 notification',
    );

    // Les alertes poids sont plus critiques
    final priorite =
        alertes.length >= 5 || alertes.first.ecartPourcent.abs() > 30
        ? NotificationPriorite.critique
        : NotificationPriorite.operationnelle;

    return ConsolidatedNotification(
      titre: '⚠️ ${alertes.length} lapins avec poids anormal',
      corps: corps,
      payload: 'poids_anormal:consolidated',
      priorite: priorite,
      count: alertes.length,
      idsOriginaux: alertes.map((a) => a.lapinId).toList(),
      type: TypeConsolidation.poidsAnormal,
    );
  }

  // ===== UTILITAIRES =====

  /// Génère un message résumé générique
  String genererMessageResume(
    String type,
    int count,
    List<String> details, {
    int maxDetails = 3,
  }) {
    if (details.isEmpty) {
      return '$count élément${count > 1 ? "s" : ""} à traiter.';
    }

    final affichage = details.take(maxDetails).toList();
    final reste = details.length - affichage.length;

    if (reste > 0) {
      return '${affichage.join(", ")} et $reste autre${reste > 1 ? "s" : ""}.';
    } else {
      return '${affichage.join(", ")}.';
    }
  }

  /// Vérifie si une consolidation est nécessaire pour un type donné
  Future<bool> doitConsolider(TypeConsolidation type) async {
    switch (type) {
      case TypeConsolidation.peseeHebdo:
        final pesees = await getPeseesEnAttente();
        return pesees.length >= seuilConsolidation;

      case TypeConsolidation.stockFaible:
        final stocks = await getStocksFaibles();
        return stocks.length >= seuilConsolidation;

      default:
        return false;
    }
  }

  /// Retourne les statistiques de consolidation
  Future<Map<String, int>> getStats() async {
    final pesees = await getPeseesEnAttente();
    final stocks = await getStocksFaibles();

    return {
      'peseesEnAttente': pesees.length,
      'stocksFaibles': stocks.length,
      'seuilConsolidation': seuilConsolidation,
    };
  }
}
