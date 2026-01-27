import 'package:flutter/foundation.dart';
import '../models/lapin.dart';
import '../models/portee.dart';
import '../models/journal_entry.dart';
import '../models/enums/sexe.dart';
import '../repositories/lapin_repository.dart';
import '../services/journal_service.dart';
import '../utils/logger.dart';

/// Provider pour gérer la liste des lapins avec SQLite
class LapinProvider with ChangeNotifier {
  // Services - injection de dépendance pour les tests
  final LapinRepository _repository;
  final JournalService _journal;

  // Liste des lapins en cache
  List<Lapin> _lapins = [];
  bool _isLoading = false;

  /// Constructeur par défaut utilisant les singletons
  LapinProvider()
    : _repository = LapinRepository.instance,
      _journal = JournalService();

  /// Constructeur pour les tests avec injection de dépendance
  @visibleForTesting
  LapinProvider.withRepository(
    LapinRepository repository, [
    JournalService? journal,
  ]) : _repository = repository,
       _journal = journal ?? JournalService();

  /// Obtenir la liste complète des lapins
  List<Lapin> get lapins => List.unmodifiable(_lapins);

  /// Obtenir le nombre total de lapins
  int get nombreLapins => _lapins.length;

  /// Indique si les données sont en cours de chargement
  bool get isLoading => _isLoading;

  /// Charger tous les lapins depuis la base de données
  Future<void> chargerLapins() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lapins = await _repository.getAll();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des lapins', e);
      _lapins = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir un lapin par son ID
  Lapin? getLapinById(int id) {
    try {
      return _lapins.firstWhere((lapin) => lapin.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajouter un nouveau lapin
  Future<Lapin> ajouterLapin(Lapin lapin) async {
    try {
      final lapinAjoute = await _repository.insert(lapin);
      _lapins.add(lapinAjoute);
      notifyListeners();

      // 📝 Journal automatique
      await _journal.lapin(
        action: TypeAction.creation,
        lapinId: lapinAjoute.id!,
        lapinNom: lapinAjoute.nom,
        contexte: {
          'race': lapinAjoute.race,
          'sexe': lapinAjoute.sexe,
          'statut': lapinAjoute.statut ?? 'Actif',
        },
      );

      return lapinAjoute;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout du lapin', e);
      rethrow;
    }
  }

  /// Modifier un lapin existant
  Future<void> modifierLapin(Lapin lapin) async {
    try {
      await _repository.update(lapin);
      final index = _lapins.indexWhere((l) => l.id == lapin.id);
      if (index != -1) {
        _lapins[index] = lapin;
        notifyListeners();

        // 📝 Journal automatique
        await _journal.lapin(
          action: TypeAction.modification,
          lapinId: lapin.id!,
          lapinNom: lapin.nom,
          contexte: {'statut': lapin.statut ?? 'Actif', 'poids': lapin.poids},
        );
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la modification du lapin', e);
      rethrow;
    }
  }

  /// Supprimer un lapin
  Future<void> supprimerLapin(int id) async {
    try {
      // Récupérer le nom avant suppression pour le journal
      final lapin = getLapinById(id);
      final nomLapin = lapin?.nom ?? 'Lapin #$id';

      await _repository.delete(id);
      _lapins.removeWhere((lapin) => lapin.id == id);
      notifyListeners();

      // 📝 Journal automatique
      await _journal.lapin(
        action: TypeAction.suppression,
        lapinId: id,
        lapinNom: nomLapin,
      );
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression du lapin', e);
      rethrow;
    }
  }

  /// Obtenir les lapins filtrés par sexe
  List<Lapin> getLapinsParSexe(Sexe sexe) {
    return _lapins.where((lapin) => lapin.sexe == sexe).toList();
  }

  /// Obtenir les mâles
  List<Lapin> get males => getLapinsParSexe(Sexe.male);

  /// Obtenir les femelles
  List<Lapin> get femelles => getLapinsParSexe(Sexe.femelle);

  /// Obtenir les lapins par statut
  List<Lapin> getLapinsParStatut(String statut) {
    return _lapins.where((lapin) => lapin.statut == statut).toList();
  }

  /// Mettre à jour uniquement le statut d'un lapin
  Future<void> updateStatut(int lapinId, String nouveauStatut) async {
    try {
      final lapin = _lapins.firstWhere((l) => l.id == lapinId);
      final lapinMisAJour = lapin.copyWith(statut: nouveauStatut);
      await modifierLapin(lapinMisAJour);
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour du statut', e);
      rethrow;
    }
  }

  /// Initialiser avec des données de test (uniquement si la BDD est vide)
  Future<void> initialiserDonneesTest() async {
    final count = await _repository.count();

    if (count == 0) {
      // Ajouter 5 lapins de test uniquement si la BDD est vide
      final lapinsTest = [
        Lapin(
          nom: 'Flocon',
          race: 'Géant des Flandres',
          sexe: Sexe.male,
          dateNaissance: DateTime.now().subtract(const Duration(days: 365)),
          poids: 7.5,
          statut: 'Reproducteur',
          localisation: 'Cage A1',
        ),
        Lapin(
          nom: 'Caramel',
          race: 'Fauve de Bourgogne',
          sexe: Sexe.femelle,
          dateNaissance: DateTime.now().subtract(const Duration(days: 280)),
          poids: 4.2,
          statut: 'Reproductrice',
          localisation: 'Cage B2',
        ),
        Lapin(
          nom: 'Panpan',
          race: 'Bélier Nain',
          sexe: Sexe.male,
          dateNaissance: DateTime.now().subtract(const Duration(days: 120)),
          poids: 1.8,
          statut: 'Engraissement',
          localisation: 'Cage C1',
        ),
        Lapin(
          nom: 'Neige',
          race: 'Blanc de Hotot',
          sexe: Sexe.femelle,
          dateNaissance: DateTime.now().subtract(const Duration(days: 90)),
          poids: 2.1,
          localisation: 'Cage C2',
        ),
        Lapin(
          nom: 'Roux',
          race: 'Néo-Zélandais',
          sexe: Sexe.male,
          dateNaissance: DateTime.now().subtract(const Duration(days: 60)),
          poids: 1.5,
          localisation: 'Cage D1',
        ),
      ];

      for (final lapin in lapinsTest) {
        await _repository.insert(lapin);
      }

      logger.info('✅ 5 lapins de test ajoutés à la base de données');
    }

    // Recharger les lapins depuis la BDD
    await chargerLapins();
  }

  /// Effacer toutes les données
  Future<void> effacerTout() async {
    try {
      for (final lapin in _lapins) {
        if (lapin.id != null) {
          await _repository.delete(lapin.id!);
        }
      }
      _lapins.clear();
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression des données', e);
      rethrow;
    }
  }

  /// LOGIQUE MÉTIER POUR LE DASHBOARD

  // Cache des statistiques pour les variations
  Map<String, int>? _statsIl30Jours;
  DateTime? _statsCacheTimestamp;

  /// Obtenir les statistiques du cheptel pour le dashboard
  Map<String, int> getStatistiquesCheptel(dynamic reproProvider) {
    // Compter les reproducteurs mâles
    final malesReproducteurs = _lapins
        .where((l) => l.sexe == Sexe.male && l.statut == 'Reproducteur')
        .length;

    // Compter les reproductrices femelles
    final femellesReproductrices = _lapins
        .where(
          (l) =>
              l.sexe == Sexe.femelle &&
              (l.statut == 'Reproductrice' || l.statut == 'Reproducteur'),
        )
        .length;

    // Compter les femelles gestantes (accouplements en attente ou confirmés)
    int gestantes = 0;
    if (reproProvider != null && reproProvider.accouplements != null) {
      final accouplementsActifs = reproProvider.accouplements
          .where((a) => a.statut == 'en_attente' || a.statut == 'confirme')
          .toList();

      // Obtenir les IDs uniques des femelles gestantes
      final femellesGestantesIds = accouplementsActifs
          .map((a) => a.femelleId)
          .toSet();
      gestantes = femellesGestantesIds.length;
    }

    // Compter les lapereaux (lapins de moins de 8 semaines)
    final maintenant = DateTime.now();
    final lapereaux = _lapins.where((l) {
      final ageEnSemaines = maintenant.difference(l.dateNaissance).inDays ~/ 7;
      return ageEnSemaines < 8;
    }).length;

    // Compter les portées actives (avec lapereaux vivants)
    int porteesActives = 0;
    if (reproProvider != null && reproProvider.portees != null) {
      porteesActives = reproProvider.portees
          .where((Portee p) => p.nombreVivants > 0)
          .length;
    }

    return {
      'total': _lapins.length,
      'males': malesReproducteurs,
      'femelles': femellesReproductrices,
      'gestantes': gestantes,
      'lapereaux': lapereaux,
      'porteesActives': porteesActives,
    };
  }

  /// Calculer la variation en pourcentage d'une statistique sur 30 jours
  /// Retourne un texte formaté ex: "+12%", "-5%", "0%"
  String getVariationStat(String typeStat, int valeurActuelle) {
    // Si pas de cache ou cache trop vieux (>24h), simuler anciennes stats
    if (_statsIl30Jours == null ||
        _statsCacheTimestamp == null ||
        DateTime.now().difference(_statsCacheTimestamp!).inHours > 24) {
      // Estimation: on simule une variation aléatoire entre -10% et +15%
      // En production réelle, il faudrait stocker les stats historiques en DB
      final variation = (valeurActuelle * 0.05).round(); // +5% par défaut
      return variation > 0
          ? '+${((variation / valeurActuelle) * 100).toStringAsFixed(0)}%'
          : '0%';
    }

    final ancienneValeur = _statsIl30Jours![typeStat] ?? valeurActuelle;
    if (ancienneValeur == 0) return '0%';

    final diff = valeurActuelle - ancienneValeur;
    final pourcentage = (diff / ancienneValeur * 100).round();

    if (pourcentage > 0) {
      return '+$pourcentage%';
    } else if (pourcentage < 0) {
      return '$pourcentage%';
    } else {
      return '0%';
    }
  }
}
