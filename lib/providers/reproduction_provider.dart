import 'package:flutter/foundation.dart';
import '../models/accouplement.dart';
import '../models/enums/statut_accouplement.dart';
import '../models/portee.dart';
import '../models/journal_entry.dart';
import '../repositories/reproduction_repository.dart';
import '../repositories/lapin_repository.dart';
import '../services/notification_service.dart';
import '../services/smart_notification_service.dart';
import '../services/journal_service.dart';
import '../utils/logger.dart';

/// Provider pour gérer l'état des accouplements et portées
class ReproductionProvider with ChangeNotifier {
  final ReproductionRepository _repository;
  final LapinRepository _lapinRepository;
  final NotificationService _notificationService;
  final JournalService _journal;

  ReproductionProvider()
    : _repository = ReproductionRepository.instance,
      _lapinRepository = LapinRepository.instance,
      _notificationService = NotificationService(),
      _journal = JournalService();

  @visibleForTesting
  ReproductionProvider.withRepository(
    ReproductionRepository repository,
    LapinRepository lapinRepository,
    NotificationService notificationService,
    JournalService journalService,
  ) : _repository = repository,
      _lapinRepository = lapinRepository,
      _notificationService = notificationService,
      _journal = journalService;

  List<Accouplement> _accouplements = [];
  List<Portee> _portees = [];
  bool _isLoading = false;

  List<Accouplement> get accouplements => _accouplements;
  List<Portee> get portees => _portees;
  bool get isLoading => _isLoading;

  /// Charger tous les accouplements depuis la base de données
  Future<void> chargerAccouplements() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accouplements = await _repository.getAllAccouplements();
    } catch (e) {
      logger.error('Erreur lors du chargement des accouplements', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger toutes les portées depuis la base de données
  Future<void> chargerPortees() async {
    _isLoading = true;
    notifyListeners();

    try {
      _portees = await _repository.getAllPortees();
    } catch (e) {
      logger.error('Erreur lors du chargement des portées', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger accouplements et portées
  Future<void> chargerTout() async {
    await Future.wait([chargerAccouplements(), chargerPortees()]);
  }

  /// Ajouter un accouplement
  Future<Accouplement> ajouterAccouplement(Accouplement accouplement) async {
    try {
      final nouveauAccouplement = await _repository.insertAccouplement(
        accouplement,
      );
      _accouplements.insert(0, nouveauAccouplement);

      // Planifier les notifications si l'accouplement est en attente
      if (nouveauAccouplement.statut == StatutAccouplement.enAttente &&
          nouveauAccouplement.id != null) {
        final femelle = await _lapinRepository.getById(
          nouveauAccouplement.femelleId,
        );
        if (femelle != null) {
          // Notification mise bas (3 jours avant)
          await _notificationService.planifierRappelMiseBas(
            accouplementId: nouveauAccouplement.id!,
            dateMiseBasPrevue: nouveauAccouplement.dateMiseBasPrevue,
            nomFemelle: femelle.nom,
          );
          // Notification palpation (10 jours après accouplement)
          await _notificationService.planifierRappelPalpation(
            accouplementId: nouveauAccouplement.id!,
            dateAccouplement: nouveauAccouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
          // Notification préparation nid (28 jours après accouplement)
          await _notificationService.planifierRappelNid(
            accouplementId: nouveauAccouplement.id!,
            dateAccouplement: nouveauAccouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
        }
      }

      notifyListeners();

      // Scanner et planifier toutes les notifications après ajout
      final smartNotificationService = SmartNotificationService();
      smartNotificationService.scanAndScheduleAllNotifications().catchError((
        e,
      ) {
        logger.error('Erreur lors du scan des notifications: $e');
      });

      return nouveauAccouplement;
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de l\'accouplement', e);
      rethrow;
    }
  }

  /// Modifier un accouplement
  Future<void> modifierAccouplement(Accouplement accouplement) async {
    try {
      await _repository.updateAccouplement(accouplement);
      final index = _accouplements.indexWhere((a) => a.id == accouplement.id);
      if (index != -1) {
        _accouplements[index] = accouplement;

        // Gérer les notifications selon le statut
        if (accouplement.id != null) {
          if (accouplement.statut == StatutAccouplement.enAttente) {
            // Replanifier toutes les notifications
            final femelle = await _lapinRepository.getById(
              accouplement.femelleId,
            );
            if (femelle != null) {
              // Annuler les anciennes notifications
              await _notificationService.annulerRappelMiseBas(accouplement.id!);
              await _notificationService.annulerRappelPalpation(
                accouplement.id!,
              );
              await _notificationService.annulerRappelNid(accouplement.id!);
              // Replanifier
              await _notificationService.planifierRappelMiseBas(
                accouplementId: accouplement.id!,
                dateMiseBasPrevue: accouplement.dateMiseBasPrevue,
                nomFemelle: femelle.nom,
              );
              await _notificationService.planifierRappelPalpation(
                accouplementId: accouplement.id!,
                dateAccouplement: accouplement.dateAccouplement,
                nomFemelle: femelle.nom,
              );
              await _notificationService.planifierRappelNid(
                accouplementId: accouplement.id!,
                dateAccouplement: accouplement.dateAccouplement,
                nomFemelle: femelle.nom,
              );
            }
          } else {
            // Annuler toutes les notifications si le statut n'est plus "en_attente"
            await _notificationService.annulerRappelMiseBas(accouplement.id!);
            await _notificationService.annulerRappelPalpation(accouplement.id!);
            await _notificationService.annulerRappelNid(accouplement.id!);
          }
        }

        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de l\'accouplement', e);
      rethrow;
    }
  }

  /// Supprimer un accouplement
  Future<void> supprimerAccouplement(int id) async {
    try {
      // Annuler la notification associée
      await _notificationService.annulerRappelMiseBas(id);

      await _repository.deleteAccouplement(id);
      _accouplements.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de l\'accouplement', e);
      rethrow;
    }
  }

  /// Ajouter une portée
  Future<Portee> ajouterPortee(Portee portee) async {
    try {
      // ✅ TRANSACTION ATOMIQUE: Création portée + Clôture accouplement
      final nouvellePortee = await _repository.enregistrerMiseBas(
        portee: portee,
        accouplementId: portee.accouplementId,
      );

      _portees.insert(0, nouvellePortee);

      // Mettre à jour l'accouplement dans le cache local
      final index = _accouplements.indexWhere(
        (a) => a.id == portee.accouplementId,
      );
      if (index != -1) {
        _accouplements[index] = _accouplements[index].copyWith(
          statut: StatutAccouplement.termine,
        );
      }

      notifyListeners();

      // 📝 Journal automatique - récupérer la mère via l'accouplement
      final accouplement = await _repository.getAccouplementById(
        nouvellePortee.accouplementId,
      );
      String? mereNom;
      if (accouplement != null) {
        final mere = await _lapinRepository.getById(accouplement.femelleId);
        mereNom = mere?.nom;
      }
      await _journal.portee(
        action: TypeAction.creation,
        porteeId: nouvellePortee.id!,
        mereNom: mereNom,
        nombreLapereaux: nouvellePortee.nombreNes,
        contexte: {
          'dateMiseBas': nouvellePortee.dateMiseBasReelle.toIso8601String(),
          'nombreVivants': nouvellePortee.nombreVivants,
        },
        statut: StatutEvenement.succes,
      );

      // Scanner et planifier toutes les notifications après ajout de portée
      final smartNotificationService = SmartNotificationService();
      smartNotificationService.scanAndScheduleAllNotifications().catchError((
        e,
      ) {
        logger.error('Erreur lors du scan des notifications: $e');
      });

      return nouvellePortee;
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de la portée', e);
      rethrow;
    }
  }

  /// Modifier une portée
  Future<void> modifierPortee(Portee portee) async {
    try {
      await _repository.updatePortee(portee);
      final index = _portees.indexWhere((p) => p.id == portee.id);
      if (index != -1) {
        _portees[index] = portee;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de la portée', e);
      rethrow;
    }
  }

  /// Supprimer une portée
  Future<void> supprimerPortee(int id) async {
    try {
      await _repository.deletePortee(id);
      _portees.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de la portée', e);
      rethrow;
    }
  }

  /// Récupérer les accouplements en attente
  Future<List<Accouplement>> getAccouplementsEnAttente() async {
    try {
      return await _repository.getAccouplementsEnAttente();
    } catch (e) {
      logger.error(
        'Erreur lors de la récupération des accouplements en attente',
        e,
      );
      return [];
    }
  }

  /// Récupérer la portée d'un accouplement
  Future<Portee?> getPorteeByAccouplement(int accouplementId) async {
    try {
      return await _repository.getPorteeByAccouplement(accouplementId);
    } catch (e) {
      logger.error('Erreur lors de la récupération de la portée', e);
      return null;
    }
  }

  /// Marquer un accouplement comme confirmé (après palpation)
  Future<void> confirmerAccouplement(int accouplementId) async {
    final accouplement = _accouplements.firstWhere(
      (a) => a.id == accouplementId,
    );
    await modifierAccouplement(
      accouplement.copyWith(statut: StatutAccouplement.confirme),
    );
  }

  /// Marquer un accouplement comme échec
  Future<void> marquerEchec(int accouplementId) async {
    final accouplement = _accouplements.firstWhere(
      (a) => a.id == accouplementId,
    );
    await modifierAccouplement(
      accouplement.copyWith(statut: StatutAccouplement.echec),
    );
  }

  /// Terminer un accouplement (après enregistrement de la portée)
  Future<void> terminerAccouplement(int accouplementId) async {
    final accouplement = _accouplements.firstWhere(
      (a) => a.id == accouplementId,
    );
    await modifierAccouplement(
      accouplement.copyWith(statut: StatutAccouplement.termine),
    );
  }

  /// LOGIQUE MÉTIER POUR LE DASHBOARD

  /// Obtenir les mises bas imminentes (dans les 3 prochains jours)
  List<Accouplement> getMisesBasImminentes() {
    final maintenant = DateTime.now();
    return _accouplements.where((acc) {
      if (acc.statut != StatutAccouplement.enAttente &&
          acc.statut != StatutAccouplement.confirme) {
        return false;
      }
      final joursRestants = acc.dateMiseBasPrevue.difference(maintenant).inDays;
      return joursRestants >= 0 && joursRestants <= 3;
    }).toList()..sort(
      (a, b) => a.dateMiseBasPrevue.compareTo(b.dateMiseBasPrevue),
    );
  }

  /// Obtenir les palpations à effectuer (10-12 jours post-accouplement)
  List<Accouplement> getPalpationsAFaire() {
    final maintenant = DateTime.now();
    return _accouplements.where((acc) {
        if (acc.statut != StatutAccouplement.enAttente) {
          return false;
        }
        final joursDepuis = maintenant.difference(acc.dateAccouplement).inDays;
        return joursDepuis >= 10 && joursDepuis <= 12;
      }).toList()
      ..sort((a, b) => a.dateAccouplement.compareTo(b.dateAccouplement));
  }

  /// Obtenir les portées nécessitant des pesées (lapereaux < 8 semaines non sevrés)
  List<Portee> getPeseesAFaire() {
    final maintenant = DateTime.now();
    return _portees.where((portee) {
        if (portee.nombreVivants == 0) return false;
        final ageEnSemaines =
            maintenant.difference(portee.dateMiseBasReelle).inDays ~/ 7;
        // Pesées hebdomadaires jusqu'au sevrage (8 semaines max)
        return ageEnSemaines > 0 && ageEnSemaines < 8;
      }).toList()
      ..sort((a, b) => a.dateMiseBasReelle.compareTo(b.dateMiseBasReelle));
  }

  /// Obtenir les sevrages prévus (portées de 5-6 semaines)
  List<Portee> getSevragePrevus() {
    final maintenant = DateTime.now();
    return _portees.where((portee) {
        if (portee.nombreVivants == 0) return false;
        final ageEnSemaines =
            maintenant.difference(portee.dateMiseBasReelle).inDays ~/ 7;
        return ageEnSemaines >= 5 && ageEnSemaines <= 6;
      }).toList()
      ..sort((a, b) => a.dateMiseBasReelle.compareTo(b.dateMiseBasReelle));
  }
}
