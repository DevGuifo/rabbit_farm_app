import 'package:flutter/foundation.dart';
import '../models/alerte.dart';
import '../services/database_helper.dart';
import 'deces_provider.dart';
import 'alimentation_provider.dart';

/// Provider pour la gestion des alertes
class AlerteProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DecesProvider _decesProvider;
  final AlimentationProvider _alimentationProvider;

  List<Alerte> _alertes = [];
  bool _isLoading = false;

  AlerteProvider({
    required DecesProvider decesProvider,
    required AlimentationProvider alimentationProvider,
  }) : _decesProvider = decesProvider,
       _alimentationProvider = alimentationProvider;

  List<Alerte> get alertes => _alertes;
  List<Alerte> get alertesNonLues => _alertes.where((a) => !a.estLue).toList();
  int get nombreAlertesNonLues => alertesNonLues.length;
  bool get isLoading => _isLoading;

  /// Obtenir les alertes par priorité
  List<Alerte> getAlertesByPriorite(PrioriteAlerte priorite) {
    return _alertes.where((a) => a.priorite == priorite).toList();
  }

  /// Marquer une alerte comme lue
  void marquerCommeLue(String alerteId) {
    final index = _alertes.indexWhere((a) => a.id == alerteId);
    if (index != -1) {
      _alertes[index] = _alertes[index].copyWith(estLue: true);
      notifyListeners();
    }
  }

  /// Supprimer une alerte
  void supprimerAlerte(String alerteId) {
    _alertes.removeWhere((a) => a.id == alerteId);
    notifyListeners();
  }

  /// Scanner toutes les alertes
  Future<void> scannerAlertes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _alertes.clear();

      // 1. Alertes vaccination (7 jours avant)
      await _scanVaccinations();

      // 2. Alertes palpation (J10-12 post-accouplement)
      await _scanPalpations();

      // 3. Alertes préparation nid (J28 gestation)
      await _scanPreparationNids();

      // 4. Alertes mise bas (J31±2)
      await _scanMisesBas();

      // 5. Alertes sevrage (J35-42)
      await _scanSevrages();

      // 6. Alertes pesée oubliée (>7 jours)
      await _scanPesees();

      // 7. Alertes traitements à administrer
      await _scanTraitements();

      // 8. Alertes poids anormal (±20% norme)
      await _scanPoidsAnormaux();

      // 9. Alertes stock aliment faible
      await _scanStocksFaibles();

      // 10. Alertes péremption médicament/aliment
      await _scanPeremptions();

      // 11. Alertes mortalité anormale
      await _scanMortaliteAnormale();

      // 12. Alertes consanguinité élevée (>25%)
      // À implémenter avec calcul génétique

      // 13. Alertes quarantaine terminée
      await _scanQuarantaines();

      // 14. Alertes reproducteur à réformer
      await _scanReformes();

      // 15. Alertes symptômes suspects
      // À implémenter avec analyse des soins récents

      // Trier par priorité puis date
      _alertes.sort((a, b) {
        final prioriteCompare = a.priorite.index.compareTo(b.priorite.index);
        if (prioriteCompare != 0) return prioriteCompare;
        return b.dateCreation.compareTo(a.dateCreation);
      });
    } catch (e) {
      debugPrint('❌ Erreur lors du scan des alertes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 1. Scanner les vaccinations à venir
  Future<void> _scanVaccinations() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        // Récupérer le dernier vaccin
        final soins = await _dbHelper.getSoinsByLapin(lapin.id!);
        final vaccins = soins.where((s) => s.type == 'Vaccination').toList();

        if (vaccins.isNotEmpty) {
          vaccins.sort((a, b) => b.date.compareTo(a.date));
          final dernierVaccin = vaccins.first;

          // Vérifier si le rappel approche (vaccination annuelle)
          if (dernierVaccin.dateRappel != null) {
            final joursAvantRappel = dernierVaccin.dateRappel!
                .difference(maintenant)
                .inDays;

            if (joursAvantRappel <= 7 && joursAvantRappel >= 0) {
              _alertes.add(
                Alerte(
                  id: 'vaccin_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
                  titre: 'Vaccination à prévoir',
                  description:
                      'Rappel de vaccination dans $joursAvantRappel jour(s) pour ${lapin.nom}',
                  type: TypeAlerte.vaccination,
                  priorite: joursAvantRappel <= 3
                      ? PrioriteAlerte.urgent
                      : PrioriteAlerte.important,
                  dateCreation: maintenant,
                  lapinId: lapin.id,
                  lapinNom: lapin.nom,
                  action: 'Planifier la vaccination',
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan vaccinations: $e');
    }
  }

  /// 2. Scanner les palpations à effectuer
  Future<void> _scanPalpations() async {
    try {
      final accouplements = await _dbHelper.getAllAccouplements();
      final maintenant = DateTime.now();

      for (final accouplement in accouplements) {
        if (accouplement.statut == 'En cours' ||
            accouplement.statut == 'Confirmé') {
          final joursDepuisAccouplement = maintenant
              .difference(accouplement.dateAccouplement)
              .inDays;

          // Palpation entre J10 et J12
          if (joursDepuisAccouplement >= 10 && joursDepuisAccouplement <= 12) {
            final femelle = await _dbHelper.getLapinById(
              accouplement.femelleId,
            );

            _alertes.add(
              Alerte(
                id: 'palpation_${accouplement.id}_${DateTime.now().millisecondsSinceEpoch}',
                titre: 'Palpation à effectuer',
                description:
                    'Palpation de gestation pour ${femelle?.nom ?? "Femelle"} (J$joursDepuisAccouplement)',
                type: TypeAlerte.palpation,
                priorite: PrioriteAlerte.important,
                dateCreation: maintenant,
                lapinId: femelle?.id,
                lapinNom: femelle?.nom,
                action: 'Effectuer la palpation',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan palpations: $e');
    }
  }

  /// 3. Scanner les préparations de nid
  Future<void> _scanPreparationNids() async {
    try {
      final accouplements = await _dbHelper.getAllAccouplements();
      final maintenant = DateTime.now();

      for (final accouplement in accouplements) {
        if (accouplement.statut == 'Confirmé') {
          final joursDepuisAccouplement = maintenant
              .difference(accouplement.dateAccouplement)
              .inDays;

          // Préparation nid à J28
          if (joursDepuisAccouplement == 28) {
            final femelle = await _dbHelper.getLapinById(
              accouplement.femelleId,
            );

            _alertes.add(
              Alerte(
                id: 'nid_${accouplement.id}_${DateTime.now().millisecondsSinceEpoch}',
                titre: 'Préparation du nid',
                description:
                    'Installer le nid pour ${femelle?.nom ?? "Femelle"} (J28)',
                type: TypeAlerte.preparationNid,
                priorite: PrioriteAlerte.important,
                dateCreation: maintenant,
                lapinId: femelle?.id,
                lapinNom: femelle?.nom,
                action: 'Installer le nid',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan nids: $e');
    }
  }

  /// 4. Scanner les mises bas à venir
  Future<void> _scanMisesBas() async {
    try {
      final accouplements = await _dbHelper.getAllAccouplements();
      final maintenant = DateTime.now();

      for (final accouplement in accouplements) {
        if (accouplement.statut == 'Confirmé') {
          final joursJusqueMiseBas = accouplement.dateMiseBasPrevue
              .difference(maintenant)
              .inDays;

          // Alerte J31±2 (entre J-2 et J+2)
          if (joursJusqueMiseBas >= -2 && joursJusqueMiseBas <= 2) {
            final femelle = await _dbHelper.getLapinById(
              accouplement.femelleId,
            );

            String message;
            if (joursJusqueMiseBas < 0) {
              message =
                  'Mise bas prévue il y a ${joursJusqueMiseBas.abs()} jour(s) pour ${femelle?.nom ?? "Femelle"}';
            } else if (joursJusqueMiseBas == 0) {
              message =
                  'Mise bas prévue aujourd\'hui pour ${femelle?.nom ?? "Femelle"}';
            } else {
              message =
                  'Mise bas prévue dans $joursJusqueMiseBas jour(s) pour ${femelle?.nom ?? "Femelle"}';
            }

            _alertes.add(
              Alerte(
                id: 'misebas_${accouplement.id}_${DateTime.now().millisecondsSinceEpoch}',
                titre: 'Mise bas imminente',
                description: message,
                type: TypeAlerte.miseBas,
                priorite: joursJusqueMiseBas <= 0
                    ? PrioriteAlerte.urgent
                    : PrioriteAlerte.important,
                dateCreation: maintenant,
                lapinId: femelle?.id,
                lapinNom: femelle?.nom,
                action: 'Surveiller la femelle',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan mises bas: $e');
    }
  }

  /// 5. Scanner les sevrages à effectuer
  Future<void> _scanSevrages() async {
    try {
      final portees = await _dbHelper.getAllPortees();
      final maintenant = DateTime.now();

      for (final portee in portees) {
        final joursDepuisMiseBas = maintenant
            .difference(portee.dateMiseBasReelle)
            .inDays;

        // Sevrage entre J35 et J42
        if (joursDepuisMiseBas >= 35 && joursDepuisMiseBas <= 42) {
          final accouplement = await _dbHelper.getAccouplementById(
            portee.accouplementId,
          );
          final femelle = accouplement != null
              ? await _dbHelper.getLapinById(accouplement.femelleId)
              : null;

          _alertes.add(
            Alerte(
              id: 'sevrage_${portee.id}_${DateTime.now().millisecondsSinceEpoch}',
              titre: 'Sevrage à effectuer',
              description:
                  'Sevrage de la portée de ${femelle?.nom ?? "Femelle"} (J$joursDepuisMiseBas)',
              type: TypeAlerte.sevrage,
              priorite: PrioriteAlerte.important,
              dateCreation: maintenant,
              lapinId: femelle?.id,
              lapinNom: femelle?.nom,
              action: 'Effectuer le sevrage',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan sevrages: $e');
    }
  }

  /// 6. Scanner les pesées oubliées
  Future<void> _scanPesees() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        if (lapin.statut == 'decede' || lapin.statut == 'vendu') continue;

        final pesees = await _dbHelper.getPeseesByLapin(lapin.id!);

        if (pesees.isEmpty) {
          // Aucune pesée enregistrée
          _alertes.add(
            Alerte(
              id: 'pesee_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
              titre: 'Aucune pesée enregistrée',
              description: 'Aucune pesée pour ${lapin.nom}',
              type: TypeAlerte.pesee,
              priorite: PrioriteAlerte.normal,
              dateCreation: maintenant,
              lapinId: lapin.id,
              lapinNom: lapin.nom,
              action: 'Enregistrer une pesée',
            ),
          );
        } else {
          // Vérifier la dernière pesée
          pesees.sort((a, b) => b.date.compareTo(a.date));
          final dernierePesee = pesees.first;
          final joursDepuisPesee = maintenant
              .difference(dernierePesee.date)
              .inDays;

          if (joursDepuisPesee > 7) {
            _alertes.add(
              Alerte(
                id: 'pesee_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
                titre: 'Pesée à effectuer',
                description:
                    'Dernière pesée de ${lapin.nom} il y a $joursDepuisPesee jours',
                type: TypeAlerte.pesee,
                priorite: joursDepuisPesee > 14
                    ? PrioriteAlerte.important
                    : PrioriteAlerte.normal,
                dateCreation: maintenant,
                lapinId: lapin.id,
                lapinNom: lapin.nom,
                action: 'Peser le lapin',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan pesées: $e');
    }
  }

  /// 7. Scanner les traitements à administrer
  Future<void> _scanTraitements() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        if (lapin.statut == 'decede' || lapin.statut == 'vendu') continue;

        final soins = await _dbHelper.getSoinsByLapin(lapin.id!);
        final traitementsEnCours = soins
            .where(
              (s) =>
                  s.dateRappel != null &&
                  s.dateRappel!.isAfter(
                    maintenant.subtract(const Duration(days: 1)),
                  ),
            )
            .toList();

        for (final traitement in traitementsEnCours) {
          final joursAvantRappel = traitement.dateRappel!
              .difference(maintenant)
              .inDays;

          if (joursAvantRappel <= 1 && joursAvantRappel >= -1) {
            _alertes.add(
              Alerte(
                id: 'traitement_${traitement.id}_${DateTime.now().millisecondsSinceEpoch}',
                titre: 'Traitement à administrer',
                description:
                    '${traitement.type} pour ${lapin.nom}: ${traitement.medicament ?? ""}',
                type: TypeAlerte.traitement,
                priorite: PrioriteAlerte.urgent,
                dateCreation: maintenant,
                lapinId: lapin.id,
                lapinNom: lapin.nom,
                action: 'Administrer le traitement',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan traitements: $e');
    }
  }

  /// 8. Scanner les poids anormaux
  Future<void> _scanPoidsAnormaux() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        if (lapin.statut == 'decede' || lapin.statut == 'vendu') continue;

        final pesees = await _dbHelper.getPeseesByLapin(lapin.id!);
        if (pesees.length < 2) continue;

        pesees.sort((a, b) => b.date.compareTo(a.date));
        final dernierePesee = pesees[0];
        final avantDernierePesee = pesees[1];

        // Calculer la variation de poids
        final variation =
            ((dernierePesee.poids - avantDernierePesee.poids) /
                avantDernierePesee.poids) *
            100;

        // Alerter si variation > ±20%
        if (variation.abs() > 20) {
          _alertes.add(
            Alerte(
              id: 'poids_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
              titre: 'Poids anormal détecté',
              description:
                  '${lapin.nom}: ${variation > 0 ? "gain" : "perte"} de ${variation.abs().toStringAsFixed(1)}% du poids',
              type: TypeAlerte.poidsAnormal,
              priorite: PrioriteAlerte.urgent,
              dateCreation: maintenant,
              lapinId: lapin.id,
              lapinNom: lapin.nom,
              action: 'Vérifier l\'état de santé',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan poids: $e');
    }
  }

  /// 9. Scanner les stocks faibles
  Future<void> _scanStocksFaibles() async {
    try {
      final alimentsFaibles = await _alimentationProvider
          .getAlimentsStockFaible();
      final maintenant = DateTime.now();

      for (final aliment in alimentsFaibles) {
        _alertes.add(
          Alerte(
            id: 'stock_${aliment.id}_${DateTime.now().millisecondsSinceEpoch}',
            titre: 'Stock faible',
            description:
                '${aliment.nom}: ${aliment.quantiteRestante.toStringAsFixed(1)}kg restant',
            type: TypeAlerte.stockFaible,
            priorite: aliment.quantiteRestante < 5
                ? PrioriteAlerte.urgent
                : PrioriteAlerte.important,
            dateCreation: maintenant,
            action: 'Réapprovisionner',
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur scan stocks: $e');
    }
  }

  /// 10. Scanner les péremptions
  Future<void> _scanPeremptions() async {
    try {
      final alimentsPeremption = await _alimentationProvider
          .getAlimentsPeremptionProche(jours: 30);
      final maintenant = DateTime.now();

      for (final aliment in alimentsPeremption) {
        if (aliment.datePeremption == null) continue;

        final joursAvantPeremption = aliment.datePeremption!
            .difference(maintenant)
            .inDays;

        _alertes.add(
          Alerte(
            id: 'peremption_${aliment.id}_${DateTime.now().millisecondsSinceEpoch}',
            titre: 'Péremption proche',
            description:
                '${aliment.nom} périme dans $joursAvantPeremption jour(s)',
            type: TypeAlerte.peremption,
            priorite: joursAvantPeremption <= 7
                ? PrioriteAlerte.urgent
                : PrioriteAlerte.important,
            dateCreation: maintenant,
            action: 'Utiliser en priorité',
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur scan péremptions: $e');
    }
  }

  /// 11. Scanner la mortalité anormale
  Future<void> _scanMortaliteAnormale() async {
    try {
      final estAnormale = await _decesProvider.detecterMortaliteAnormale();

      if (estAnormale) {
        final nombreDeces = await _decesProvider
            .getNombreDecesDerniersSeptJours();

        _alertes.add(
          Alerte(
            id: 'mortalite_${DateTime.now().millisecondsSinceEpoch}',
            titre: 'Mortalité anormale détectée',
            description:
                '$nombreDeces décès sur les 7 derniers jours (>5% du cheptel)',
            type: TypeAlerte.mortaliteAnormale,
            priorite: PrioriteAlerte.urgent,
            dateCreation: DateTime.now(),
            action: 'Consulter un vétérinaire',
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur scan mortalité: $e');
    }
  }

  /// 13. Scanner les quarantaines
  Future<void> _scanQuarantaines() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        if (lapin.statut == 'quarantaine') {
          // Quarantaine standard: 14 jours
          // À implémenter avec table quarantaine dédiée
          _alertes.add(
            Alerte(
              id: 'quarantaine_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
              titre: 'Vérifier la quarantaine',
              description: '${lapin.nom} en quarantaine',
              type: TypeAlerte.quarantaine,
              priorite: PrioriteAlerte.normal,
              dateCreation: maintenant,
              lapinId: lapin.id,
              lapinNom: lapin.nom,
              action: 'Vérifier l\'état',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan quarantaines: $e');
    }
  }

  /// 14. Scanner les reproducteurs à réformer
  Future<void> _scanReformes() async {
    try {
      final lapins = await _dbHelper.getAllLapins();
      final maintenant = DateTime.now();

      for (final lapin in lapins) {
        if (lapin.statut == 'decede' || lapin.statut == 'vendu') continue;

        final age = maintenant.difference(lapin.dateNaissance).inDays;
        final ageEnAnnees = age / 365;

        // Reproducteur > 4 ans = à réformer
        if (ageEnAnnees > 4 &&
            (lapin.statut == 'reproducteurActif' ||
                lapin.statut == 'reproducteurRepos')) {
          _alertes.add(
            Alerte(
              id: 'reforme_${lapin.id}_${DateTime.now().millisecondsSinceEpoch}',
              titre: 'Reproducteur à réformer',
              description:
                  '${lapin.nom} a ${ageEnAnnees.toStringAsFixed(1)} ans',
              type: TypeAlerte.reforme,
              priorite: PrioriteAlerte.normal,
              dateCreation: maintenant,
              lapinId: lapin.id,
              lapinNom: lapin.nom,
              action: 'Planifier la réforme',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur scan réformes: $e');
    }
  }
}
