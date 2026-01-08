import 'package:sqflite/sqflite.dart';
import 'logger.dart';

/// Service de migration automatique des données
/// Phase 3 : Conversion champs texte → clés étrangères
class DataMigrationService {
  /// Migrer toutes les données (appelé lors de la migration DB v17)
  static Future<void> migrerToutesLesDonnees(Database db) async {
    logger.info('🔄 [Migration Phase 3] Début migration données texte → FK...');

    try {
      await migrerMateriaux(db);
      await migrerMedicaments(db);
      await migrerLocalisations(db);

      logger.info(
        '✅ [Migration Phase 3] Migration données terminée avec succès',
      );
    } catch (e) {
      logger.error('❌ [Migration Phase 3] Erreur globale: $e');
      rethrow;
    }
  }

  /// Migration 1 : preparations_nid.materiaux_fournis → materiau_id
  /// Le plus simple : détecter matériaux courants dans le texte
  static Future<void> migrerMateriaux(Database db) async {
    logger.info('  🔄 Migration materiaux_fournis → materiau_id...');

    try {
      // Compter enregistrements à migrer
      final countResult = await db.rawQuery('''
        SELECT COUNT(*) as total 
        FROM preparations_nid 
        WHERE materiau_id IS NULL AND materiaux_fournis IS NOT NULL
      ''');
      final total = countResult.first['total'] as int;

      if (total == 0) {
        logger.info('    ⏭️  Aucune préparation de nid à migrer');
        return;
      }

      // Récupérer toutes les préparations à migrer
      final preparations = await db.rawQuery('''
        SELECT id, materiaux_fournis 
        FROM preparations_nid 
        WHERE materiau_id IS NULL AND materiaux_fournis IS NOT NULL
      ''');

      int migres = 0;

      for (final prep in preparations) {
        final prepId = prep['id'] as int;
        final materiauxTexte = (prep['materiaux_fournis'] as String)
            .toLowerCase();

        // Détection par mots-clés (paille > foin > copeaux > mixte par défaut)
        int materiauId;
        if (materiauxTexte.contains('paille')) {
          materiauId = 1; // Paille
        } else if (materiauxTexte.contains('foin')) {
          materiauId = 2; // Foin
        } else if (materiauxTexte.contains('copeau')) {
          materiauId = 3; // Copeaux
        } else if (materiauxTexte.contains('mixte') ||
            materiauxTexte.contains(',')) {
          materiauId = 4; // Mixte (ou présence de plusieurs matériaux)
        } else {
          materiauId = 2; // Foin par défaut (matériau le plus courant)
        }

        await db.update(
          'preparations_nid',
          {'materiau_id': materiauId},
          where: 'id = ?',
          whereArgs: [prepId],
        );
        migres++;
      }

      logger.info('    ✅ $migres préparations de nid migrées (sur $total)');
    } catch (e) {
      logger.error('    ❌ Erreur migration matériaux: $e');
      rethrow;
    }
  }

  /// Migration 2 : soins.medicament → medicament_id
  /// Créer médicaments manquants, puis lier
  static Future<void> migrerMedicaments(Database db) async {
    logger.info('  🔄 Migration medicament → medicament_id...');

    try {
      // 1. Extraire tous les noms de médicaments uniques
      final medicamentsTexte = await db.rawQuery('''
        SELECT DISTINCT TRIM(medicament) as nom
        FROM soins 
        WHERE medicament IS NOT NULL 
          AND medicament != ''
          AND medicament_id IS NULL
      ''');

      if (medicamentsTexte.isEmpty) {
        logger.info('    ⏭️  Aucun médicament à migrer');
        return;
      }

      int crees = 0;
      int lies = 0;

      // 2. Pour chaque médicament texte, créer ou trouver équivalent
      for (final row in medicamentsTexte) {
        final nomTexte = row['nom'] as String;
        final nomNormalise = _normaliserNomMedicament(nomTexte);

        // Vérifier si existe déjà (insensible à la casse)
        final existants = await db.rawQuery(
          '''
          SELECT id FROM medicaments 
          WHERE LOWER(TRIM(nom)) = LOWER(?)
          LIMIT 1
        ''',
          [nomNormalise],
        );

        int medicamentId;

        if (existants.isEmpty) {
          // Créer nouveau médicament
          medicamentId = await db.insert('medicaments', {
            'nom': nomNormalise,
            'type_medicament': 'autre',
            'quantite_stock': 0.0,
            'unite': 'ml',
            'date_creation': DateTime.now().toIso8601String(),
          });
          crees++;
          logger.info(
            '      ➕ Médicament créé: "$nomNormalise" (ID: $medicamentId)',
          );
        } else {
          medicamentId = existants.first['id'] as int;
        }

        // 3. Lier tous les soins ayant ce nom (insensible casse)
        final updated = await db.rawUpdate(
          '''
          UPDATE soins 
          SET medicament_id = ?
          WHERE LOWER(TRIM(medicament)) = LOWER(?)
            AND medicament_id IS NULL
        ''',
          [medicamentId, nomTexte],
        );

        lies += updated;
      }

      logger.info('    ✅ $crees médicaments créés, $lies soins liés');
    } catch (e) {
      logger.error('    ❌ Erreur migration médicaments: $e');
      rethrow;
    }
  }

  /// Migration 3 : lapins.localisation → cage_id
  /// Le plus complexe : parser format texte libre
  static Future<void> migrerLocalisations(Database db) async {
    logger.info('  🔄 Migration localisation → cage_id...');

    try {
      // Récupérer tous les lapins avec localisation texte non migrée
      final lapins = await db.rawQuery('''
        SELECT id, localisation 
        FROM lapins 
        WHERE cage_id IS NULL 
          AND localisation IS NOT NULL 
          AND localisation != ''
      ''');

      if (lapins.isEmpty) {
        logger.info('    ⏭️  Aucune localisation à migrer');
        return;
      }

      int resolus = 0;
      int echoues = 0;

      for (final lapin in lapins) {
        final lapinId = lapin['id'] as int;
        final localisation = lapin['localisation'] as String;

        final cageId = await _resoudreLocalisation(db, localisation);

        if (cageId != null) {
          await db.update(
            'lapins',
            {'cage_id': cageId},
            where: 'id = ?',
            whereArgs: [lapinId],
          );
          resolus++;
        } else {
          echoues++;
          logger.warning(
            '      ⚠️  Lapin $lapinId: localisation "$localisation" non résolue',
          );
        }
      }

      logger.info(
        '    ✅ $resolus lapins migrés, $echoues localisations non résolues',
      );

      if (echoues > 0) {
        logger.warning(
          '    ⚠️  $echoues lapins nécessitent une assignation manuelle de cage',
        );
      }
    } catch (e) {
      logger.error('    ❌ Erreur migration localisations: $e');
      rethrow;
    }
  }

  /// Parser localisation format "Bâtiment X - Clapier Y - Cage Z"
  static Future<int?> _resoudreLocalisation(
    Database db,
    String localisation,
  ) async {
    try {
      // Nettoyer et séparer
      final parts = localisation
          .split('-')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.length < 3) {
        // Format non standard, essayer extraction simple
        return await _resoudreLocalisationSimple(db, localisation);
      }

      // Extraire composants (ex: "Bâtiment A - Clapier 1 - Cage 3")
      final batimentStr = parts[0];
      final clapierStr = parts[1];
      final cageStr = parts[2];

      // Extraire noms/numéros (retire préfixes "Bâtiment", "Clapier", "Cage")
      final batimentNom = batimentStr
          .replaceAll(RegExp(r'b[aâ]timent\s*', caseSensitive: false), '')
          .trim();
      final clapierNom = clapierStr
          .replaceAll(RegExp(r'clapier\s*', caseSensitive: false), '')
          .trim();
      final cageNumero = cageStr
          .replaceAll(RegExp(r'cage\s*', caseSensitive: false), '')
          .trim();

      // Recherche cascade : Batiment → Clapier → Cage
      final batiments = await db.query(
        'batiments',
        where: 'LOWER(TRIM(nom)) = LOWER(?)',
        whereArgs: [batimentNom],
      );

      if (batiments.isEmpty) {
        logger.warning('      Bâtiment "$batimentNom" introuvable');
        return null;
      }

      final batimentId = batiments.first['id'] as int;

      final clapiers = await db.query(
        'clapiers',
        where: 'batiment_id = ? AND LOWER(TRIM(nom)) = LOWER(?)',
        whereArgs: [batimentId, clapierNom],
      );

      if (clapiers.isEmpty) {
        logger.warning(
          '      Clapier "$clapierNom" introuvable dans bâtiment $batimentId',
        );
        return null;
      }

      final clapierId = clapiers.first['id'] as int;

      final cages = await db.query(
        'cages',
        where: 'clapier_id = ? AND LOWER(TRIM(numero)) = LOWER(?)',
        whereArgs: [clapierId, cageNumero],
      );

      if (cages.isEmpty) {
        logger.warning(
          '      Cage "$cageNumero" introuvable dans clapier $clapierId',
        );
        return null;
      }

      return cages.first['id'] as int;
    } catch (e) {
      logger.warning('      Erreur parsing localisation "$localisation": $e');
      return null;
    }
  }

  /// Résolution simple si format non standard (recherche par numéro cage seul)
  static Future<int?> _resoudreLocalisationSimple(
    Database db,
    String localisation,
  ) async {
    // Extraire premier nombre trouvé (ex: "Cage3" → "3")
    final match = RegExp(r'\d+').firstMatch(localisation);
    if (match == null) return null;

    final numero = match.group(0)!;

    // Rechercher cage par numéro
    final cages = await db.query(
      'cages',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    if (cages.length == 1) {
      // Une seule cage avec ce numéro → match sûr
      return cages.first['id'] as int;
    } else if (cages.length > 1) {
      logger.warning('      Ambiguïté: $numero cages avec numéro "$numero"');
      return null;
    }

    return null;
  }

  /// Normaliser nom médicament (lowercase, trim, corrections courantes)
  static String _normaliserNomMedicament(String nom) {
    String normalise = nom.trim();

    // Corrections orthographiques courantes
    final corrections = {
      'ivermectin': 'Ivermectine',
      'ivermecine': 'Ivermectine',
      'myxo': 'Myxomatose',
      'vhd': 'VHD',
      'rhd': 'VHD',
      'penicilline': 'Pénicilline',
      'amoxicilline': 'Amoxicilline',
    };

    final normaliseLower = normalise.toLowerCase();
    for (final entry in corrections.entries) {
      if (normaliseLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Capitaliser première lettre
    if (normalise.isNotEmpty) {
      return normalise[0].toUpperCase() + normalise.substring(1);
    }

    return normalise;
  }
}
