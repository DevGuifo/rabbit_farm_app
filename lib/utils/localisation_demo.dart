import '../models/batiment.dart';
import '../models/clapier.dart';
import '../models/cage.dart';
import '../services/database_helper.dart';
import '../services/localisation_service.dart';
import 'logger.dart';

/// Classe pour initialiser des données de démonstration pour la localisation
class LocalisationDemo {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Créer une structure de localisation complète pour la démonstration
  Future<void> creerStructureDemo() async {
    logger.info('🏗️ Initialisation de la structure de localisation...');

    // Vérifier si déjà initialisé
    final batiments = await _db.getAllBatiments();
    if (batiments.isNotEmpty) {
      logger.info(
        '✅ Structure déjà initialisée (${batiments.length} bâtiment(s))',
      );
      return;
    }

    // === BÂTIMENT A ===
    final batimentA = await _db.ajouterBatiment(
      Batiment(nom: 'A', description: 'Bâtiment principal'),
    );
    logger.info('✅ Bâtiment A créé (ID: $batimentA)');

    // Clapier Intérieur
    final clapierIntA = await _db.ajouterClapier(
      Clapier(
        batimentId: batimentA,
        nom: 'Intérieur',
        type: 'interieur',
        description: 'Zone intérieure climatisée',
      ),
    );

    // Cages individuelles (A-INT-01 à A-INT-05)
    for (int i = 1; i <= 5; i++) {
      await _db.ajouterCage(
        Cage(
          clapierId: clapierIntA,
          numero: 'A-INT-${i.toString().padLeft(2, '0')}',
          type: 'individuelle',
          capacite: 1,
          description: 'Cage individuelle standard',
        ),
      );
    }

    // Clapier Extérieur
    final clapierExtA = await _db.ajouterClapier(
      Clapier(
        batimentId: batimentA,
        nom: 'Extérieur',
        type: 'exterieur',
        description: 'Enclos extérieurs',
      ),
    );

    // Cages collectives (A-EXT-01 à A-EXT-03)
    for (int i = 1; i <= 3; i++) {
      await _db.ajouterCage(
        Cage(
          clapierId: clapierExtA,
          numero: 'A-EXT-${i.toString().padLeft(2, '0')}',
          type: 'collective',
          capacite: 5,
          description: 'Cage collective extérieure',
        ),
      );
    }

    logger.info('✅ Bâtiment A : 8 cages créées (5 intérieur + 3 extérieur)');

    // === BÂTIMENT B ===
    final batimentB = await _db.ajouterBatiment(
      Batiment(nom: 'B', description: 'Bâtiment de reproduction'),
    );
    logger.info('✅ Bâtiment B créé (ID: $batimentB)');

    // Clapier Reproduction
    final clapierRepro = await _db.ajouterClapier(
      Clapier(
        batimentId: batimentB,
        nom: 'Reproduction',
        type: 'interieur',
        description: 'Zone dédiée à la reproduction',
      ),
    );

    // Cages avec nid (B-INT-01 à B-INT-04)
    for (int i = 1; i <= 4; i++) {
      await _db.ajouterCage(
        Cage(
          clapierId: clapierRepro,
          numero: 'B-INT-${i.toString().padLeft(2, '0')}',
          type: 'nid',
          capacite: 1,
          description: 'Cage avec boîte à nid',
        ),
      );
    }

    // Clapier Quarantaine
    final clapierQua = await _db.ajouterClapier(
      Clapier(
        batimentId: batimentB,
        nom: 'Quarantaine',
        type: 'quarantaine',
        description: 'Zone de quarantaine isolée',
      ),
    );

    // Cages de quarantaine (B-QUA-01 à B-QUA-02)
    for (int i = 1; i <= 2; i++) {
      await _db.ajouterCage(
        Cage(
          clapierId: clapierQua,
          numero: 'B-QUA-${i.toString().padLeft(2, '0')}',
          type: 'individuelle',
          capacite: 1,
          description: 'Cage de quarantaine',
        ),
      );
    }

    logger.info(
      '✅ Bâtiment B : 6 cages créées (4 reproduction + 2 quarantaine)',
    );

    // === BÂTIMENT C ===
    final batimentC = await _db.ajouterBatiment(
      Batiment(nom: 'C', description: 'Bâtiment d\'engraissement'),
    );
    logger.info('✅ Bâtiment C créé (ID: $batimentC)');

    // Clapier Engraissement
    final clapierEngr = await _db.ajouterClapier(
      Clapier(
        batimentId: batimentC,
        nom: 'Engraissement',
        type: 'interieur',
        description: 'Zone d\'engraissement des lapereaux',
      ),
    );

    // Grandes cages collectives (C-INT-01 à C-INT-04)
    for (int i = 1; i <= 4; i++) {
      await _db.ajouterCage(
        Cage(
          clapierId: clapierEngr,
          numero: 'C-INT-${i.toString().padLeft(2, '0')}',
          type: 'collective',
          capacite: 8,
          description: 'Grande cage collective pour engraissement',
        ),
      );
    }

    logger.info('✅ Bâtiment C : 4 cages créées (engraissement)');

    logger.info('\n🎉 Structure de localisation complète :');
    logger.info('   • 3 bâtiments (A, B, C)');
    logger.info('   • 6 clapiers');
    logger.info('   • 18 cages au total');
    logger.info('   • Capacité totale : 49 lapins');
  }

  /// Afficher un résumé de la structure de localisation
  Future<void> afficherResume() async {
    logger.info('\n📊 RÉSUMÉ DE LA STRUCTURE DE LOCALISATION\n');

    final batiments = await _db.getAllBatiments();
    int totalCages = 0;
    int totalCapacite = 0;

    for (var batiment in batiments) {
      logger.info('🏢 BÂTIMENT ${batiment.nom} - ${batiment.description}');
      final clapiers = await _db.getClapiersByBatiment(batiment.id!);

      for (var clapier in clapiers) {
        logger.info('  ├─ 📦 ${clapier.nom} (${clapier.type})');
        final cages = await _db.getCagesByClapier(clapier.id!);

        for (var cage in cages) {
          final occupants = await _db.getOccupantsCage(cage.id!);
          final statut = cage.getStatut(occupants);
          final emoji = _getEmojiStatut(statut);

          logger.info(
            '  │  ├─ $emoji ${cage.numero} - $occupants/${cage.capacite} - $statut',
          );
          totalCapacite += cage.capacite;
          totalCages++;
        }
      }
      logger.info('');
    }

    final totalOccupants = await _getTotalOccupants();
    final tauxOccupation = (totalOccupants / totalCapacite * 100)
        .toStringAsFixed(1);

    logger.info('📈 STATISTIQUES GLOBALES');
    logger.info('   • Bâtiments : ${batiments.length}');
    logger.info('   • Cages : $totalCages');
    logger.info('   • Capacité totale : $totalCapacite lapins');
    logger.info('   • Occupants : $totalOccupants lapins');
    logger.info('   • Taux d\'occupation : $tauxOccupation%');
    logger.info('   • Places libres : ${totalCapacite - totalOccupants}');
  }

  /// Obtenir le nombre total de lapins dans toutes les cages
  Future<int> _getTotalOccupants() async {
    final cages = await _db.database;
    final result = await cages.rawQuery(
      'SELECT COUNT(*) as count FROM lapins WHERE localisation IS NOT NULL',
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Obtenir un emoji selon le statut de la cage
  String _getEmojiStatut(String statut) {
    switch (statut) {
      case 'vide':
        return '⚪';
      case 'normale':
        return '🟢';
      case 'pleine':
        return '🟠';
      case 'surpeuplee':
        return '🔴';
      default:
        return '⚫';
    }
  }

  /// Simuler des occupations de cages pour la démonstration
  Future<void> simulerOccupations() async {
    logger.info('\n🎲 Simulation des occupations de cages...');

    // Récupérer tous les lapins sans localisation
    final db = await _db.database;
    final lapinsSansLoc = await db.query(
      'lapins',
      where: 'localisation IS NULL OR localisation = ""',
      limit: 10,
    );

    if (lapinsSansLoc.isEmpty) {
      logger.info('ℹ️ Aucun lapin sans localisation trouvé');
      return;
    }

    // Récupérer des cages disponibles
    final cagesDisponibles = await _db.getCagesDisponibles();

    if (cagesDisponibles.isEmpty) {
      logger.warning('⚠️ Aucune cage disponible');
      return;
    }

    int placementsReussis = 0;
    for (var lapinMap in lapinsSansLoc) {
      if (cagesDisponibles.isEmpty) break;

      // Prendre une cage au hasard
      final cageData = cagesDisponibles.removeAt(0);
      final cage = cageData['cage'] as Cage;

      // Placer le lapin
      await db.update(
        'lapins',
        {'localisation': cage.numero},
        where: 'id = ?',
        whereArgs: [lapinMap['id']],
      );

      placementsReussis++;
      logger.info('  ✅ Lapin #${lapinMap['id']} → ${cage.numero}');
    }

    logger.info('🎉 $placementsReussis lapin(s) placé(s) dans des cages');
  }
}
