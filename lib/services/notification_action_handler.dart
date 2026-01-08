import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/pesee.dart';
import '../models/soin.dart';
import '../utils/logger.dart';
import 'coach_notification_service.dart';
import 'database_helper.dart';
import 'notification_service.dart';

/// Gestionnaire centralisé des actions de notifications
///
/// Ce service traite toutes les actions déclenchées depuis les boutons
/// des notifications. Il :
/// - Met à jour les données en base
/// - Replanifie les notifications suivantes
/// - Journalise les actions pour audit
///
/// ⚠️ AUCUNE logique métier dans l'UI - tout passe par ici
class NotificationActionHandler {
  static final NotificationActionHandler _instance =
      NotificationActionHandler._internal();
  factory NotificationActionHandler() => _instance;
  NotificationActionHandler._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Accès lazy au NotificationService pour éviter la dépendance circulaire
  NotificationService get _notificationService => NotificationService();

  /// Accès lazy au CoachNotificationService
  CoachNotificationService get _coachService => CoachNotificationService();

  /// Actions supportées par type de notification
  static const Map<String, List<String>> actionsParType = {
    'mise_bas': ['fait', 'echec', 'reporter'],
    'mise_bas_jour': ['fait', 'echec', 'reporter'],
    'palpation': ['gestante', 'non_gestante', 'refaire'],
    'nid': ['fait', 'reporter'],
    'sevrage': ['fait', 'reporter'],
    'pesee': ['ok', 'probleme', 'reporter'],
    'pesee_portee': ['ok', 'probleme', 'reporter'],
    'soin': ['fait', 'reporter'],
    // Actions coach quotidien
    'coach': [
      'rituel_ok',
      'rituel_probleme',
      'rituel_later',
      'suivi_resolu',
      'suivi_encours',
      'suivi_aide',
    ],
  };

  /// Labels utilisateur pour chaque action (pour affichage et logs)
  static const Map<String, String> actionLabels = {
    'fait': '✅ Fait',
    'ok': '✅ OK',
    'echec': '❌ Échec',
    'gestante': '✅ Gestante',
    'non_gestante': '❌ Non gestante',
    'refaire': '❓ À refaire',
    'probleme': '⚠️ Problème',
    'reporter': '⏰ Reporter',
  };

  /// Traite une action reçue depuis une notification
  ///
  /// [payload] Format: "type:id" (ex: "mise_bas:42")
  /// [action] L'action choisie (ex: "fait", "reporter")
  ///
  /// Retourne true si l'action a été traitée avec succès
  Future<bool> handleAction(String payload, String action) async {
    try {
      logger.info('🔔 Action notification: $payload -> $action');

      // Parser le payload
      final parts = payload.split(':');
      if (parts.length != 2) {
        logger.warning('❌ Payload invalide: $payload');
        return false;
      }

      final type = parts[0];
      final id = int.tryParse(parts[1]);

      if (id == null) {
        logger.warning('❌ ID invalide dans payload: $payload');
        return false;
      }

      // Vérifier que l'action est valide pour ce type
      final actionsValides = actionsParType[type];
      if (actionsValides == null || !actionsValides.contains(action)) {
        logger.warning('❌ Action "$action" invalide pour type "$type"');
        return false;
      }

      // Router vers le gestionnaire approprié
      switch (type) {
        case 'mise_bas':
        case 'mise_bas_jour':
          return await _handleMiseBasAction(id, action);
        case 'palpation':
          return await _handlePalpationAction(id, action);
        case 'nid':
          return await _handleNidAction(id, action);
        case 'sevrage':
          return await _handleSevrageAction(id, action);
        case 'pesee':
          return await _handlePeseeAction(id, action);
        case 'pesee_portee':
          return await _handlePeseePorteeAction(id, action);
        case 'soin':
          return await _handleSoinAction(id, action);
        case 'coach':
          // Déléguer au service coach
          await _coachService.handleResponse(action, id);
          return true;
        default:
          logger.warning('❌ Type de notification inconnu: $type');
          return false;
      }
    } catch (e, stackTrace) {
      logger.error('❌ Erreur traitement action notification', e, stackTrace);
      return false;
    }
  }

  // ========== GESTIONNAIRES PAR TYPE ==========

  /// Traite les actions de mise bas
  Future<bool> _handleMiseBasAction(int accouplementId, String action) async {
    try {
      final accouplement = await _db.getAccouplementById(accouplementId);
      if (accouplement == null) {
        logger.warning('❌ Accouplement $accouplementId non trouvé');
        return false;
      }

      switch (action) {
        case 'fait':
          // Marquer comme terminé avec succès
          // L'utilisateur devra ensuite enregistrer les détails de la portée
          final accouplementMaj = accouplement.copyWith(statut: 'termine');
          await _db.updateAccouplement(accouplementMaj);

          // Annuler les notifications de mise bas restantes
          await _notificationService.annulerRappelMiseBas(accouplementId);

          // Log pour l'utilisateur
          logger.info(
            '✅ Mise bas enregistrée pour accouplement $accouplementId',
          );

          // Planifier notification de rappel pour enregistrer la portée
          await _planifierRappelEnregistrerPortee(accouplementId);
          return true;

        case 'echec':
          // Marquer comme échoué (pas de portée)
          final accouplementMaj = accouplement.copyWith(statut: 'echoue');
          await _db.updateAccouplement(accouplementMaj);

          // Annuler toutes les notifications liées
          await _notificationService.annulerRappelMiseBas(accouplementId);
          await _notificationService.annulerRappelNid(accouplementId);

          logger.info('❌ Mise bas échouée pour accouplement $accouplementId');
          return true;

        case 'reporter':
          // Reporter de 24h
          final nouvelleDateMiseBas = DateTime.now().add(
            const Duration(days: 1),
          );

          // Annuler l'ancienne notification
          await _notificationService.annulerRappelMiseBas(accouplementId);

          // Replanifier pour demain
          final femelle = await _db.getLapinById(accouplement.femelleId);
          if (femelle != null) {
            await _notificationService.planifierRappelMiseBas(
              accouplementId: accouplementId,
              dateMiseBasPrevue: nouvelleDateMiseBas,
              nomFemelle: femelle.nom,
            );
          }

          logger.info(
            '⏰ Mise bas reportée de 24h pour accouplement $accouplementId',
          );
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action mise bas: $e');
      return false;
    }
  }

  /// Traite les actions de palpation
  Future<bool> _handlePalpationAction(int accouplementId, String action) async {
    try {
      final accouplement = await _db.getAccouplementById(accouplementId);
      if (accouplement == null) {
        logger.warning('❌ Accouplement $accouplementId non trouvé');
        return false;
      }

      switch (action) {
        case 'gestante':
          // Confirmer la gestation
          final accouplementMaj = accouplement.copyWith(statut: 'confirme');
          await _db.updateAccouplement(accouplementMaj);

          // Annuler notification de palpation
          await _notificationService.annulerRappelPalpation(accouplementId);

          // Les notifications de nid et mise bas sont déjà planifiées
          logger.info(
            '✅ Gestation confirmée pour accouplement $accouplementId',
          );
          return true;

        case 'non_gestante':
          // Marquer comme non gestante (échec)
          final accouplementMaj = accouplement.copyWith(statut: 'echoue');
          await _db.updateAccouplement(accouplementMaj);

          // Annuler toutes les notifications de cet accouplement
          await _notificationService.annulerRappelPalpation(accouplementId);
          await _notificationService.annulerRappelNid(accouplementId);
          await _notificationService.annulerRappelMiseBas(accouplementId);

          logger.info(
            '❌ Gestation non confirmée pour accouplement $accouplementId',
          );
          return true;

        case 'refaire':
          // Reporter la palpation de 2 jours
          await _notificationService.annulerRappelPalpation(accouplementId);

          final femelle = await _db.getLapinById(accouplement.femelleId);
          if (femelle != null) {
            // Replanifier dans 2 jours
            final dateAccouplementDecalee = accouplement.dateAccouplement
                .subtract(const Duration(days: 2));

            await _notificationService.planifierRappelPalpation(
              accouplementId: accouplementId,
              dateAccouplement: dateAccouplementDecalee,
              nomFemelle: femelle.nom,
            );
          }

          logger.info(
            '❓ Palpation à refaire dans 2 jours pour accouplement $accouplementId',
          );
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action palpation: $e');
      return false;
    }
  }

  /// Traite les actions de préparation du nid
  Future<bool> _handleNidAction(int accouplementId, String action) async {
    try {
      switch (action) {
        case 'fait':
          // Annuler la notification
          await _notificationService.annulerRappelNid(accouplementId);

          // TODO: Enregistrer que le nid est préparé (table préparation_nid)
          logger.info('✅ Nid préparé pour accouplement $accouplementId');
          return true;

        case 'reporter':
          // Reporter de 24h
          await _notificationService.annulerRappelNid(accouplementId);

          final accouplement = await _db.getAccouplementById(accouplementId);
          if (accouplement != null) {
            final femelle = await _db.getLapinById(accouplement.femelleId);
            if (femelle != null) {
              // Replanifier pour demain
              final dateAccouplementDecalee = accouplement.dateAccouplement
                  .subtract(const Duration(days: 1));

              await _notificationService.planifierRappelNid(
                accouplementId: accouplementId,
                dateAccouplement: dateAccouplementDecalee,
                nomFemelle: femelle.nom,
              );
            }
          }

          logger.info(
            '⏰ Préparation nid reportée de 24h pour accouplement $accouplementId',
          );
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action nid: $e');
      return false;
    }
  }

  /// Traite les actions de sevrage
  Future<bool> _handleSevrageAction(int porteeId, String action) async {
    try {
      switch (action) {
        case 'fait':
          // Annuler la notification de sevrage
          await _notificationService.planifierNotification(
            notificationId: 600000 + porteeId,
            titre: '',
            corps: '',
            date: DateTime.now().add(const Duration(days: 365)), // Invalide
            payload: 'sevrage:$porteeId',
          );

          // TODO: Marquer la portée comme sevrée
          logger.info('✅ Sevrage effectué pour portée $porteeId');
          return true;

        case 'reporter':
          // Reporter de 2 jours
          final portee = await _db.getPorteeById(porteeId);
          if (portee != null) {
            final nouvelleDateSevrage = DateTime.now().add(
              const Duration(days: 2),
            );

            await _notificationService.planifierNotification(
              notificationId: 600000 + porteeId,
              titre: '🍼 Rappel de sevrage',
              corps: 'Sevrage prévu pour ${portee.nombreVivants} lapereaux',
              date: nouvelleDateSevrage,
              payload: 'sevrage:$porteeId',
              channelId: 'sevrage_channel',
              channelName: 'Rappels de sevrage',
              channelDescription: 'Notifications pour les sevrages à effectuer',
              importance: Importance.high,
              priority: Priority.high,
            );
          }

          logger.info('⏰ Sevrage reporté de 2 jours pour portée $porteeId');
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action sevrage: $e');
      return false;
    }
  }

  /// Traite les actions de pesée individuelle
  Future<bool> _handlePeseeAction(int lapinId, String action) async {
    try {
      final lapin = await _db.getLapinById(lapinId);
      if (lapin == null) {
        logger.warning('❌ Lapin $lapinId non trouvé');
        return false;
      }

      switch (action) {
        case 'ok':
          // Pesée OK avec estimation automatique basée sur dernière pesée
          final pesees = await _db.getPeseesByLapin(lapinId);
          double poidsEstime = lapin.poids ?? 2.0;

          if (pesees.isNotEmpty) {
            pesees.sort((a, b) => b.date.compareTo(a.date));
            poidsEstime = pesees.first.poids;
          }

          // Enregistrer la pesée avec le poids estimé
          final nouvellePesee = Pesee(
            lapinId: lapinId,
            date: DateTime.now(),
            poids: poidsEstime,
            notes: 'Pesée confirmée via notification (poids estimé)',
          );
          await _db.insertPesee(nouvellePesee);

          // Annuler et replanifier la prochaine pesée
          await _notificationService.annulerRappelPesee(lapinId);
          await _notificationService.planifierRappelPeseeHebdomadaire(
            lapinId: lapinId,
            nomLapin: lapin.nom,
            dateDernierePesee: DateTime.now(),
          );

          logger.info('✅ Pesée OK enregistrée pour ${lapin.nom}');
          return true;

        case 'probleme':
          // L'utilisateur signale un problème - ne pas enregistrer de pesée
          // mais créer une alerte santé
          logger.warning(
            '⚠️ Problème signalé lors de la pesée de ${lapin.nom}',
          );

          // Reporter la pesée de 1 jour pour revérifier
          await _notificationService.annulerRappelPesee(lapinId);
          await _notificationService.planifierRappelPeseeHebdomadaire(
            lapinId: lapinId,
            nomLapin: lapin.nom,
            dateDernierePesee: DateTime.now().subtract(const Duration(days: 6)),
          );
          return true;

        case 'reporter':
          // Reporter de 24h
          await _notificationService.annulerRappelPesee(lapinId);
          await _notificationService.planifierRappelPeseeHebdomadaire(
            lapinId: lapinId,
            nomLapin: lapin.nom,
            dateDernierePesee: DateTime.now().subtract(const Duration(days: 6)),
          );

          logger.info('⏰ Pesée reportée de 24h pour ${lapin.nom}');
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action pesée: $e');
      return false;
    }
  }

  /// Traite les actions de pesée de portée
  Future<bool> _handlePeseePorteeAction(int porteeId, String action) async {
    try {
      switch (action) {
        case 'ok':
          logger.info('✅ Pesée portée $porteeId confirmée');
          return true;

        case 'probleme':
          logger.warning(
            '⚠️ Problème signalé lors de la pesée de la portée $porteeId',
          );
          return true;

        case 'reporter':
          logger.info('⏰ Pesée portée $porteeId reportée');
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action pesée portée: $e');
      return false;
    }
  }

  /// Traite les actions de soin
  Future<bool> _handleSoinAction(int soinId, String action) async {
    try {
      final soin = await _db.getSoinById(soinId);
      if (soin == null) {
        logger.warning('❌ Soin $soinId non trouvé');
        return false;
      }

      switch (action) {
        case 'fait':
          // Marquer le soin comme effectué
          // Créer un nouveau soin avec la date d'aujourd'hui
          final nouveauSoin = Soin(
            lapinId: soin.lapinId,
            date: DateTime.now(),
            type: soin.type,
            description: '${soin.description} (rappel effectué)',
            medicament: soin.medicament,
            medicamentId: soin.medicamentId,
            dosage: soin.dosage,
            // Pas de nouveau rappel automatique
          );
          await _db.insertSoin(nouveauSoin);

          // Annuler la notification
          await _notificationService.annulerRappelSoin(soinId);

          logger.info('✅ Soin effectué: ${soin.type}');
          return true;

        case 'reporter':
          // Reporter de 24h
          final lapin = await _db.getLapinById(soin.lapinId);
          if (lapin != null) {
            await _notificationService.annulerRappelSoin(soinId);
            await _notificationService.planifierRappelSoin(
              soinId: soinId,
              dateRappel: DateTime.now().add(const Duration(days: 1)),
              nomLapin: lapin.nom,
              typeSoin: soin.type,
            );
          }

          logger.info('⏰ Soin reporté de 24h: ${soin.type}');
          return true;

        default:
          return false;
      }
    } catch (e) {
      logger.error('❌ Erreur action soin: $e');
      return false;
    }
  }

  // ========== MÉTHODES UTILITAIRES ==========

  /// Planifie un rappel pour enregistrer les détails de la portée
  Future<void> _planifierRappelEnregistrerPortee(int accouplementId) async {
    final accouplement = await _db.getAccouplementById(accouplementId);
    if (accouplement == null) return;

    final femelle = await _db.getLapinById(accouplement.femelleId);
    if (femelle == null) return;

    // Rappel dans 2 heures pour enregistrer les détails
    await _notificationService.planifierNotification(
      notificationId: 800000 + accouplementId,
      titre: '📝 Enregistrer la portée',
      corps:
          'N\'oubliez pas d\'enregistrer les détails de la portée de ${femelle.nom}',
      date: DateTime.now().add(const Duration(hours: 2)),
      payload: 'enregistrer_portee:$accouplementId',
      channelId: 'reproduction_channel',
      channelName: 'Rappels de reproduction',
      channelDescription:
          'Notifications pour les accouplements et reproductions',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }
}
