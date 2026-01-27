
/// Helpers de test partagés pour le projet BunnyManager
/// 
/// Ce fichier contient des utilitaires pour faciliter les tests unitaires :
/// - Initialisation du logger en mode silencieux
/// - Mocks communs
/// - Données de test réutilisables
library;

import 'package:rabbit_farm_app/core/utils/logger.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/enums/sexe.dart';

/// Initialise l'environnement de test
/// 
/// Doit être appelé dans setUpAll() de chaque fichier de test :
/// ```dart
/// setUpAll(() {
///   initTestEnvironment();
/// });
/// ```
void initTestEnvironment() {
  // Initialiser le logger en mode production (silencieux)
  logger.initialize(isProduction: true);
}

/// Données de test pour les lapins
class LapinTestData {
  LapinTestData._();
  
  /// Liste de lapins de test standard
  static List<Lapin> get standardList => [
    Lapin(
      id: 1,
      nom: 'Flocon',
      race: 'Géant des Flandres',
      sexe: Sexe.male,
      dateNaissance: DateTime(2024, 1, 15),
      poids: 7.5,
      statut: 'Reproducteur',
    ),
    Lapin(
      id: 2,
      nom: 'Neige',
      race: 'Rex',
      sexe: Sexe.femelle,
      dateNaissance: DateTime(2024, 3, 20),
      poids: 4.5,
      statut: 'Reproductrice',
    ),
    Lapin(
      id: 3,
      nom: 'Caramel',
      race: 'Bélier',
      sexe: Sexe.male,
      dateNaissance: DateTime(2024, 6, 10),
      poids: 3.0,
      statut: 'Actif',
    ),
    Lapin(
      id: 4,
      nom: 'Cannelle',
      race: 'Bélier',
      sexe: Sexe.femelle,
      dateNaissance: DateTime(2024, 5, 5),
      poids: 3.5,
      statut: 'Gestante',
    ),
  ];
  
  /// Un lapin mâle reproducteur
  static Lapin get maleReproducteur => Lapin(
    id: 100,
    nom: 'Champion',
    race: 'Géant des Flandres',
    sexe: Sexe.male,
    dateNaissance: DateTime(2023, 6, 1),
    poids: 8.2,
    statut: 'Reproducteur',
    numeroIdentification: 'GDF-2023-001',
  );
  
  /// Une femelle reproductrice
  static Lapin get femelleReproductrice => Lapin(
    id: 101,
    nom: 'Belle',
    race: 'Fauve de Bourgogne',
    sexe: Sexe.femelle,
    dateNaissance: DateTime(2023, 8, 15),
    poids: 4.8,
    statut: 'Reproductrice',
    numeroIdentification: 'FDB-2023-015',
  );
  
  /// Un lapereau pour tests de sevrage
  static Lapin get lapereau => Lapin(
    id: 200,
    nom: 'Petit',
    race: 'Bélier',
    sexe: Sexe.male,
    dateNaissance: DateTime.now().subtract(const Duration(days: 35)),
    poids: 0.8,
    statut: 'Sevrage',
  );
  
  /// Un lapin nouveau (sans ID)
  static Lapin get nouveau => Lapin(
    nom: 'Nouveau',
    race: 'Rex',
    sexe: Sexe.femelle,
    dateNaissance: DateTime.now().subtract(const Duration(days: 90)),
  );
}

/// Extensions utiles pour les tests
extension LapinListTestExtension on List<Lapin> {
  /// Filtre par sexe
  List<Lapin> bySexe(Sexe sexe) => 
      where((l) => l.sexe == sexe).toList();
  
  /// Compte les mâles
  int get malesCount => bySexe(Sexe.male).length;
  
  /// Compte les femelles
  int get femellesCount => bySexe(Sexe.femelle).length;
}
