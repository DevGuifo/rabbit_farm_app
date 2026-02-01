import 'package:flutter/foundation.dart';
import 'dart:math';
import '../services/database_helper.dart';
import '../models/lapin.dart';
import '../models/lot.dart';
import '../models/enums/sexe.dart';

/// Service d'injection de données fictives pour le développement
///
/// ⚠️ Ce service ne fonctionne QU'EN MODE DEBUG.
/// Il est utilisé pour tester l'application avec des données réalistes.
///
/// Usage :
/// ```dart
/// if (kDebugMode) {
///   await SeedDataService.instance.seedAll();
/// }
/// ```
class SeedDataService {
  static final SeedDataService instance = SeedDataService._internal();
  SeedDataService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final Random _random = Random();

  // Données de référence
  static const List<String> _races = [
    'Californien',
    'Néo-Zélandais',
    'Papillon',
    'Rex',
    'Fauve de Bourgogne',
    'Géant des Flandres',
    'Angora',
    'Chinchilla',
  ];

  static const List<String> _nomsLapins = [
    'Pompon',
    'Fluffy',
    'Caramel',
    'Noisette',
    'Cookie',
    'Flocon',
    'Cannelle',
    'Réglisse',
    'Vanille',
    'Cacahuète',
    'Praline',
    'Moka',
    'Biscuit',
    'Câlin',
    'Doudou',
    'Mignon',
    'Pelote',
    'Boule',
  ];

  /// Générer toutes les données de test
  Future<SeedResult> seedAll() async {
    if (!kDebugMode) {
      return SeedResult(
        success: false,
        message: 'Seed non autorisé en production',
      );
    }

    try {
      int lapinsCount = 0;
      int lotsCount = 0;

      // 1. Créer quelques lots
      for (int i = 0; i < 3; i++) {
        final lot = await _createLot(TypeLot.values[i % TypeLot.values.length]);
        if (lot != null) lotsCount++;
      }

      // 2. Créer des lapins individuels (hors lot)
      for (int i = 0; i < 10; i++) {
        final lapin = await _createLapin(null);
        if (lapin != null) lapinsCount++;
      }

      return SeedResult(
        success: true,
        message: 'Seed terminé : $lapinsCount lapins, $lotsCount lots',
        lapinsCreated: lapinsCount,
        lotsCreated: lotsCount,
      );
    } catch (e) {
      return SeedResult(success: false, message: 'Erreur seed : $e');
    }
  }

  /// Créer un lapin fictif
  Future<Lapin?> _createLapin(int? lotId) async {
    try {
      final sexe = _random.nextBool() ? Sexe.male : Sexe.femelle;
      final race = _races[_random.nextInt(_races.length)];
      final nom = _nomsLapins[_random.nextInt(_nomsLapins.length)];

      // Date de naissance aléatoire (1-12 mois)
      final daysAgo = 30 + _random.nextInt(330);
      final dateNaissance = DateTime.now().subtract(Duration(days: daysAgo));

      // Poids selon l'âge
      final poids = 0.5 + (_random.nextDouble() * 4.5);

      // Générer un numéro d'identification simple
      final numeroId =
          'LP-${dateNaissance.year}-${dateNaissance.month.toString().padLeft(2, '0')}-${_random.nextInt(999).toString().padLeft(3, '0')}';

      final lapin = Lapin(
        nom: nom,
        race: race,
        sexe: sexe,
        dateNaissance: dateNaissance,
        poids: poids,
        statut: 'actif',
        lotId: lotId,
        numeroIdentification: numeroId,
      );

      final insertedLapin = await _db.insertLapin(lapin);
      return insertedLapin;
    } catch (e) {
      debugPrint('Erreur création lapin seed : $e');
      return null;
    }
  }

  /// Créer un lot fictif avec effectif
  Future<Lot?> _createLot(TypeLot type) async {
    try {
      final effectif = 10 + _random.nextInt(40);
      final identifiant = await _db.genererProchainIdentifiantLot(
        DateTime.now(),
      );

      final lot = Lot(
        identifiant: identifiant,
        dateCreation: DateTime.now().subtract(
          Duration(days: _random.nextInt(60)),
        ),
        effectifInitial: effectif,
        effectifActuel: effectif - _random.nextInt(5),
        type: type,
        statut: StatutLot.actif,
        metadata: LotMetadata(
          race: _races[_random.nextInt(_races.length)],
          poidsEntree: 0.5 + (_random.nextDouble() * 0.5),
        ),
      );

      final lotInserted = await _db.insertLot(lot);
      return lotInserted;
    } catch (e) {
      debugPrint('Erreur création lot seed : $e');
      return null;
    }
  }

  /// Vider toutes les données de test
  Future<void> clearAll() async {
    if (!kDebugMode) return;

    final db = await _db.database;
    await db.delete('lapins');
    await db.delete('lots');
    debugPrint('🗑️ Données de test supprimées');
  }
}

/// Résultat d'une opération de seed
class SeedResult {
  final bool success;
  final String message;
  final int lapinsCreated;
  final int lotsCreated;

  SeedResult({
    required this.success,
    required this.message,
    this.lapinsCreated = 0,
    this.lotsCreated = 0,
  });
}
