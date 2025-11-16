import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/portee.dart';
import '../models/pesee.dart';
import '../models/soin.dart';
import '../models/recette.dart';
import '../models/depense.dart';
import '../models/deces.dart';
import '../models/aliment.dart';
import '../models/collecte_fumier.dart';
import '../models/medicament.dart';
import '../models/utilisation_medicament.dart';
import '../models/quarantaine.dart';
import '../models/reforme.dart';
import '../utils/logger.dart';

/// Service de gestion de la base de données SQLite
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mon_elevage_lapins.db');
    return _database!;
  }

  /// Initialiser la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Créer les tables de la base de données
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realTypeNullable = 'REAL';

    // Table des lapins
    await db.execute('''
      CREATE TABLE lapins (
        id $idType,
        nom $textType,
        race $textType,
        sexe $textType,
        date_naissance $textType,
        poids $realTypeNullable,
        statut $textTypeNullable,
        localisation $textTypeNullable,
        photo_path $textTypeNullable,
        numero_identification $textTypeNullable,
        couleur $textTypeNullable,
        prix_achat $realTypeNullable,
        origine $textTypeNullable,
        notes $textTypeNullable,
        caracteristiques $textTypeNullable
      )
    ''');

    // Table des relations (généalogie)
    await db.execute('''
      CREATE TABLE relations (
        id $idType,
        lapin_id INTEGER NOT NULL,
        pere_id INTEGER,
        mere_id INTEGER,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE,
        FOREIGN KEY (pere_id) REFERENCES lapins (id) ON DELETE SET NULL,
        FOREIGN KEY (mere_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    // Table des accouplements
    await db.execute('''
      CREATE TABLE accouplements (
        id $idType,
        male_id INTEGER NOT NULL,
        femelle_id INTEGER NOT NULL,
        date_accouplement $textType,
        date_mise_bas_prevue $textType,
        statut $textType,
        notes $textTypeNullable,
        FOREIGN KEY (male_id) REFERENCES lapins (id) ON DELETE CASCADE,
        FOREIGN KEY (femelle_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des portées
    await db.execute('''
      CREATE TABLE portees (
        id $idType,
        accouplement_id INTEGER NOT NULL,
        date_mise_bas_reelle $textType,
        nombre_nes INTEGER NOT NULL,
        nombre_vivants INTEGER NOT NULL,
        nombre_morts INTEGER NOT NULL,
        notes $textTypeNullable,
        FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
      )
    ''');

    // Table des pesées
    await db.execute('''
      CREATE TABLE pesees (
        id $idType,
        lapin_id INTEGER NOT NULL,
        date $textType,
        poids REAL NOT NULL,
        notes $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des soins
    await db.execute('''
      CREATE TABLE soins (
        id $idType,
        lapin_id INTEGER NOT NULL,
        date $textType,
        type $textType,
        description $textType,
        medicament $textTypeNullable,
        dosage $textTypeNullable,
        date_rappel $textTypeNullable,
        notes $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des recettes
    await db.execute('''
      CREATE TABLE recettes (
        id $idType,
        date $textType,
        categorie $textType,
        montant REAL NOT NULL,
        description $textType,
        lapin_id INTEGER,
        notes $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    // Table des dépenses
    await db.execute('''
      CREATE TABLE depenses (
        id $idType,
        date $textType,
        categorie $textType,
        montant REAL NOT NULL,
        description $textType,
        notes $textTypeNullable
      )
    ''');

    // Table des décès (version 6)
    await db.execute('''
      CREATE TABLE deces (
        id $idType,
        lapin_id INTEGER NOT NULL,
        date_deces $textType,
        age_au_deces_jours INTEGER NOT NULL,
        cause $textType,
        circonstances_detaillees $textType,
        autopsie_realisee INTEGER NOT NULL DEFAULT 0,
        resultats_autopsie $textTypeNullable,
        mesures_preventives $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des aliments (version 6)
    await db.execute('''
      CREATE TABLE aliments (
        id $idType,
        nom $textType,
        type $textType,
        marque $textTypeNullable,
        fournisseur $textTypeNullable,
        conditionnement $textTypeNullable,
        quantite_achetee REAL NOT NULL,
        quantite_restante REAL NOT NULL,
        prix_unitaire REAL NOT NULL,
        prix_total REAL NOT NULL,
        date_achat $textType,
        date_peremption $textTypeNullable,
        composition $textTypeNullable,
        lieu_stockage $textTypeNullable,
        photo_path $textTypeNullable
      )
    ''');

    // Table des distributions d'aliments (version 6)
    await db.execute('''
      CREATE TABLE distributions_aliment (
        id $idType,
        aliment_id INTEGER NOT NULL,
        date $textType,
        quantite_distribuee REAL NOT NULL,
        cages_concernees $textTypeNullable,
        observations $textTypeNullable,
        FOREIGN KEY (aliment_id) REFERENCES aliments (id) ON DELETE CASCADE
      )
    ''');

    // Table des collectes de fumier (version 7)
    await db.execute('''
      CREATE TABLE collectes_fumier (
        id $idType,
        date_collecte $textType,
        quantite REAL NOT NULL,
        type $textType,
        destination $textTypeNullable,
        prix_vente REAL,
        notes $textTypeNullable
      )
    ''');

    // Table des médicaments (version 7)
    await db.execute('''
      CREATE TABLE medicaments (
        id $idType,
        nom $textType,
        type $textType,
        quantite_stock REAL NOT NULL,
        unite $textType,
        seuil_alerte REAL,
        date_expiration $textTypeNullable,
        prix_unitaire REAL,
        posologie $textTypeNullable,
        notes $textTypeNullable
      )
    ''');

    // Table des utilisations de médicaments (version 7)
    await db.execute('''
      CREATE TABLE utilisations_medicament (
        id $idType,
        medicament_id INTEGER NOT NULL,
        lapin_id INTEGER,
        date_utilisation $textType,
        quantite_utilisee REAL NOT NULL,
        motif $textTypeNullable,
        notes $textTypeNullable,
        FOREIGN KEY (medicament_id) REFERENCES medicaments (id) ON DELETE CASCADE,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    // Table de quarantaine (version 7)
    await db.execute('''
      CREATE TABLE quarantaines (
        id $idType,
        lapin_id INTEGER NOT NULL,
        date_debut $textType,
        date_fin $textTypeNullable,
        motif $textType,
        symptomes $textTypeNullable,
        traitement $textTypeNullable,
        statut $textType,
        notes $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des réformes (version 7)
    await db.execute('''
      CREATE TABLE reformes (
        id $idType,
        lapin_id INTEGER NOT NULL,
        date_reforme $textType,
        motif $textType,
        destination $textType,
        prix_vente REAL,
        poids_vif REAL,
        notes $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
      )
    ''');

    // Table des sevrages (version 8)
    await db.execute('''
      CREATE TABLE sevrages (
        id $idType,
        portee_id INTEGER NOT NULL,
        date_sevrage $textType,
        nombre_lapereaux INTEGER NOT NULL,
        poids_moyen_sevrage REAL,
        nouvelle_cage $textTypeNullable,
        observations $textTypeNullable,
        alimentation_post_sevrage $textTypeNullable,
        FOREIGN KEY (portee_id) REFERENCES portees (id) ON DELETE CASCADE
      )
    ''');

    // Table des palpations (version 8)
    await db.execute('''
      CREATE TABLE palpations (
        id $idType,
        accouplement_id INTEGER NOT NULL,
        date_palpation $textType,
        resultat $textType,
        nombre_foetus_estimes INTEGER,
        techniques $textTypeNullable,
        observations $textTypeNullable,
        FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
      )
    ''');

    // Table des préparations de nid (version 8)
    await db.execute('''
      CREATE TABLE preparations_nid (
        id $idType,
        accouplement_id INTEGER NOT NULL,
        date_preparation $textType,
        nid_prepare INTEGER NOT NULL,
        materiaux_fournis $textTypeNullable,
        qualite_nid $textTypeNullable,
        observations $textTypeNullable,
        FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
      )
    ''');

    // Table des protocoles de soin (version 8)
    await db.execute('''
      CREATE TABLE protocoles_soin (
        id $idType,
        nom $textType,
        description $textType,
        type $textType,
        frequence $textType,
        medicaments_necessaires $textType,
        lapins_concernes $textTypeNullable,
        cout_estime REAL,
        instructions $textTypeNullable,
        actif INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Créer les index
    await db.execute('CREATE INDEX idx_deces_lapin_id ON deces(lapin_id)');
    await db.execute('CREATE INDEX idx_deces_date ON deces(date_deces)');
    await db.execute(
      'CREATE INDEX idx_distributions_aliment_id ON distributions_aliment(aliment_id)',
    );
    await db.execute(
      'CREATE INDEX idx_distributions_date ON distributions_aliment(date)',
    );
    await db.execute(
      'CREATE INDEX idx_collectes_fumier_date ON collectes_fumier(date_collecte)',
    );
    await db.execute('CREATE INDEX idx_medicaments_type ON medicaments(type)');
    await db.execute(
      'CREATE INDEX idx_utilisations_medicament_id ON utilisations_medicament(medicament_id)',
    );
    await db.execute(
      'CREATE INDEX idx_quarantaines_lapin_id ON quarantaines(lapin_id)',
    );
    await db.execute(
      'CREATE INDEX idx_quarantaines_statut ON quarantaines(statut)',
    );
    await db.execute(
      'CREATE INDEX idx_reformes_lapin_id ON reformes(lapin_id)',
    );
    await db.execute(
      'CREATE INDEX idx_reformes_date ON reformes(date_reforme)',
    );

    // Index version 8 (Phase 3 : Optimisation)
    await db.execute(
      'CREATE INDEX idx_sevrages_portee_id ON sevrages(portee_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sevrages_date ON sevrages(date_sevrage)',
    );
    await db.execute(
      'CREATE INDEX idx_palpations_accouplement_id ON palpations(accouplement_id)',
    );
    await db.execute(
      'CREATE INDEX idx_palpations_date ON palpations(date_palpation)',
    );
    await db.execute(
      'CREATE INDEX idx_preparations_nid_accouplement_id ON preparations_nid(accouplement_id)',
    );
    await db.execute(
      'CREATE INDEX idx_protocoles_type ON protocoles_soin(type)',
    );
    await db.execute(
      'CREATE INDEX idx_protocoles_actif ON protocoles_soin(actif)',
    );

    logger.info('✅ Toutes les tables créées avec succès (versions 1-8)');
  }

  /// Mettre à jour la base de données (migrations)
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    if (oldVersion < 2) {
      // Migration vers version 2 : Ajout de la table relations
      await db.execute('''
        CREATE TABLE relations (
          id $idType,
          lapin_id INTEGER NOT NULL,
          pere_id INTEGER,
          mere_id INTEGER,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE,
          FOREIGN KEY (pere_id) REFERENCES lapins (id) ON DELETE SET NULL,
          FOREIGN KEY (mere_id) REFERENCES lapins (id) ON DELETE SET NULL
        )
      ''');
      logger.info('✅ Migration vers version 2 : Table relations ajoutée');
    }

    if (oldVersion < 3) {
      // Migration vers version 3 : Ajout des tables accouplements et portees
      await db.execute('''
        CREATE TABLE accouplements (
          id $idType,
          male_id INTEGER NOT NULL,
          femelle_id INTEGER NOT NULL,
          date_accouplement $textType,
          date_mise_bas_prevue $textType,
          statut $textType,
          notes $textTypeNullable,
          FOREIGN KEY (male_id) REFERENCES lapins (id) ON DELETE CASCADE,
          FOREIGN KEY (femelle_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE portees (
          id $idType,
          accouplement_id INTEGER NOT NULL,
          date_mise_bas_reelle $textType,
          nombre_nes INTEGER NOT NULL,
          nombre_vivants INTEGER NOT NULL,
          nombre_morts INTEGER NOT NULL,
          notes $textTypeNullable,
          FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
        )
      ''');
      logger.info(
        '✅ Migration vers version 3 : Tables accouplements et portees ajoutées',
      );
    }

    if (oldVersion < 4) {
      // Migration vers version 4 : Ajout des tables pesees et soins
      await db.execute('''
        CREATE TABLE pesees (
          id $idType,
          lapin_id INTEGER NOT NULL,
          date $textType,
          poids REAL NOT NULL,
          notes $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE soins (
          id $idType,
          lapin_id INTEGER NOT NULL,
          date $textType,
          type $textType,
          description $textType,
          medicament $textTypeNullable,
          dosage $textTypeNullable,
          date_rappel $textTypeNullable,
          notes $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');
      logger.info(
        '✅ Migration vers version 4 : Tables pesees et soins ajoutées',
      );
    }

    // Migration de la version 4 à 5
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE recettes (
          id $idType,
          date $textType,
          categorie $textType,
          montant REAL NOT NULL,
          description $textType,
          lapin_id INTEGER,
          notes $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE depenses (
          id $idType,
          date $textType,
          categorie $textType,
          montant REAL NOT NULL,
          description $textType,
          notes $textTypeNullable
        )
      ''');
      logger.info(
        '✅ Migration vers version 5 : Tables recettes et depenses ajoutées',
      );
    }

    // Migration de la version 5 à 6
    if (oldVersion < 6) {
      // Table des décès
      await db.execute('''
        CREATE TABLE deces (
          id $idType,
          lapin_id INTEGER NOT NULL,
          date_deces $textType,
          age_au_deces_jours INTEGER NOT NULL,
          cause $textType,
          circonstances_detaillees $textType,
          autopsie_realisee INTEGER NOT NULL DEFAULT 0,
          resultats_autopsie $textTypeNullable,
          mesures_preventives $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');

      // Table des aliments
      await db.execute('''
        CREATE TABLE aliments (
          id $idType,
          nom $textType,
          type $textType,
          marque $textTypeNullable,
          fournisseur $textTypeNullable,
          conditionnement $textTypeNullable,
          quantite_achetee REAL NOT NULL,
          quantite_restante REAL NOT NULL,
          prix_unitaire REAL NOT NULL,
          prix_total REAL NOT NULL,
          date_achat $textType,
          date_peremption $textTypeNullable,
          composition $textTypeNullable,
          lieu_stockage $textTypeNullable,
          photo_path $textTypeNullable
        )
      ''');

      // Table des distributions d'aliments
      await db.execute('''
        CREATE TABLE distributions_aliment (
          id $idType,
          aliment_id INTEGER NOT NULL,
          date $textType,
          quantite_distribuee REAL NOT NULL,
          cages_concernees $textTypeNullable,
          observations $textTypeNullable,
          FOREIGN KEY (aliment_id) REFERENCES aliments (id) ON DELETE CASCADE
        )
      ''');

      // Index pour améliorer les performances
      await db.execute('CREATE INDEX idx_deces_lapin_id ON deces(lapin_id)');
      await db.execute('CREATE INDEX idx_deces_date ON deces(date_deces)');
      await db.execute(
        'CREATE INDEX idx_distributions_aliment_id ON distributions_aliment(aliment_id)',
      );
      await db.execute(
        'CREATE INDEX idx_distributions_date ON distributions_aliment(date)',
      );

      logger.info(
        '✅ Migration vers version 6 : Tables deces, aliments et distributions_aliment ajoutées',
      );
    }

    // Migration de la version 6 à 7 : Rentabilité (fumier, médicaments, quarantaine, réforme)
    if (oldVersion < 7) {
      // Table des collectes de fumier
      await db.execute('''
        CREATE TABLE collectes_fumier (
          id $idType,
          date_collecte $textType,
          quantite REAL NOT NULL,
          type $textType,
          destination $textTypeNullable,
          prix_vente REAL,
          notes $textTypeNullable
        )
      ''');

      // Table des médicaments
      await db.execute('''
        CREATE TABLE medicaments (
          id $idType,
          nom $textType,
          type $textType,
          quantite_stock REAL NOT NULL,
          unite $textType,
          seuil_alerte REAL,
          date_expiration $textTypeNullable,
          prix_unitaire REAL,
          posologie $textTypeNullable,
          notes $textTypeNullable
        )
      ''');

      // Table des utilisations de médicaments
      await db.execute('''
        CREATE TABLE utilisations_medicament (
          id $idType,
          medicament_id INTEGER NOT NULL,
          lapin_id INTEGER,
          date_utilisation $textType,
          quantite_utilisee REAL NOT NULL,
          motif $textTypeNullable,
          notes $textTypeNullable,
          FOREIGN KEY (medicament_id) REFERENCES medicaments (id) ON DELETE CASCADE,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
        )
      ''');

      // Table de quarantaine
      await db.execute('''
        CREATE TABLE quarantaines (
          id $idType,
          lapin_id INTEGER NOT NULL,
          date_debut $textType,
          date_fin $textTypeNullable,
          motif $textType,
          symptomes $textTypeNullable,
          traitement $textTypeNullable,
          statut $textType,
          notes $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');

      // Table des réformes
      await db.execute('''
        CREATE TABLE reformes (
          id $idType,
          lapin_id INTEGER NOT NULL,
          date_reforme $textType,
          motif $textType,
          destination $textType,
          prix_vente REAL,
          poids_vif REAL,
          notes $textTypeNullable,
          FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE CASCADE
        )
      ''');

      // Index pour améliorer les performances
      await db.execute(
        'CREATE INDEX idx_collectes_fumier_date ON collectes_fumier(date_collecte)',
      );
      await db.execute(
        'CREATE INDEX idx_medicaments_type ON medicaments(type)',
      );
      await db.execute(
        'CREATE INDEX idx_utilisations_medicament_id ON utilisations_medicament(medicament_id)',
      );
      await db.execute(
        'CREATE INDEX idx_quarantaines_lapin_id ON quarantaines(lapin_id)',
      );
      await db.execute(
        'CREATE INDEX idx_quarantaines_statut ON quarantaines(statut)',
      );
      await db.execute(
        'CREATE INDEX idx_reformes_lapin_id ON reformes(lapin_id)',
      );
      await db.execute(
        'CREATE INDEX idx_reformes_date ON reformes(date_reforme)',
      );

      logger.info(
        '✅ Migration vers version 7 : Tables fumier, médicaments, quarantaine et réforme ajoutées',
      );
    }

    // Migration de la version 7 à 8 : Optimisation (sevrage, palpation, nid, protocoles)
    if (oldVersion < 8) {
      // Table des sevrages
      await db.execute('''
        CREATE TABLE sevrages (
          id $idType,
          portee_id INTEGER NOT NULL,
          date_sevrage $textType,
          nombre_lapereaux INTEGER NOT NULL,
          poids_moyen_sevrage REAL,
          nouvelle_cage $textTypeNullable,
          observations $textTypeNullable,
          alimentation_post_sevrage $textTypeNullable,
          FOREIGN KEY (portee_id) REFERENCES portees (id) ON DELETE CASCADE
        )
      ''');

      // Table des palpations
      await db.execute('''
        CREATE TABLE palpations (
          id $idType,
          accouplement_id INTEGER NOT NULL,
          date_palpation $textType,
          resultat $textType,
          nombre_foetus_estimes INTEGER,
          techniques $textTypeNullable,
          observations $textTypeNullable,
          FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
        )
      ''');

      // Table des préparations de nid
      await db.execute('''
        CREATE TABLE preparations_nid (
          id $idType,
          accouplement_id INTEGER NOT NULL,
          date_preparation $textType,
          nid_prepare INTEGER NOT NULL,
          materiaux_fournis $textTypeNullable,
          qualite_nid $textTypeNullable,
          observations $textTypeNullable,
          FOREIGN KEY (accouplement_id) REFERENCES accouplements (id) ON DELETE CASCADE
        )
      ''');

      // Table des protocoles de soin
      await db.execute('''
        CREATE TABLE protocoles_soin (
          id $idType,
          nom $textType,
          description $textType,
          type $textType,
          frequence $textType,
          medicaments_necessaires $textType,
          lapins_concernes $textTypeNullable,
          cout_estime REAL,
          instructions $textTypeNullable,
          actif INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Index pour améliorer les performances
      await db.execute(
        'CREATE INDEX idx_sevrages_portee_id ON sevrages(portee_id)',
      );
      await db.execute(
        'CREATE INDEX idx_sevrages_date ON sevrages(date_sevrage)',
      );
      await db.execute(
        'CREATE INDEX idx_palpations_accouplement_id ON palpations(accouplement_id)',
      );
      await db.execute(
        'CREATE INDEX idx_palpations_date ON palpations(date_palpation)',
      );
      await db.execute(
        'CREATE INDEX idx_preparations_nid_accouplement_id ON preparations_nid(accouplement_id)',
      );
      await db.execute(
        'CREATE INDEX idx_protocoles_type ON protocoles_soin(type)',
      );
      await db.execute(
        'CREATE INDEX idx_protocoles_actif ON protocoles_soin(actif)',
      );

      logger.info(
        '✅ Migration vers version 8 : Tables sevrage, palpation, nid et protocoles ajoutées',
      );
    }

    // Migration de la version 8 à 9 : Nouveaux champs lapins
    if (oldVersion < 9) {
      await db.execute(
        'ALTER TABLE lapins ADD COLUMN numero_identification TEXT',
      );
      await db.execute('ALTER TABLE lapins ADD COLUMN couleur TEXT');
      await db.execute('ALTER TABLE lapins ADD COLUMN prix_achat REAL');
      await db.execute('ALTER TABLE lapins ADD COLUMN origine TEXT');
      await db.execute('ALTER TABLE lapins ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE lapins ADD COLUMN caracteristiques TEXT');

      logger.info(
        '✅ Migration vers version 9 : Nouveaux champs lapins ajoutés (numero_identification, couleur, prix_achat, origine, notes, caracteristiques)',
      );
    }
  }

  // ============= OPÉRATIONS CRUD SUR LES LAPINS =============

  /// Insérer un lapin dans la base de données
  Future<Lapin> insertLapin(Lapin lapin) async {
    final db = await database;
    final id = await db.insert('lapins', lapin.toMap());
    return lapin.copyWith(id: id);
  }

  /// Récupérer tous les lapins
  Future<List<Lapin>> getAllLapins() async {
    final db = await database;
    final result = await db.query('lapins', orderBy: 'nom ASC');
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer un lapin par son ID
  Future<Lapin?> getLapinById(int id) async {
    final db = await database;
    final maps = await db.query('lapins', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Lapin.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un lapin
  Future<int> updateLapin(Lapin lapin) async {
    final db = await database;
    return db.update(
      'lapins',
      lapin.toMap(),
      where: 'id = ?',
      whereArgs: [lapin.id],
    );
  }

  /// Supprimer un lapin
  Future<int> deleteLapin(int id) async {
    final db = await database;
    return await db.delete('lapins', where: 'id = ?', whereArgs: [id]);
  }

  /// Récupérer les lapins par sexe
  Future<List<Lapin>> getLapinsBySexe(String sexe) async {
    final db = await database;
    final result = await db.query(
      'lapins',
      where: 'sexe = ?',
      whereArgs: [sexe],
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer les lapins par statut
  Future<List<Lapin>> getLapinsByStatut(String statut) async {
    final db = await database;
    final result = await db.query(
      'lapins',
      where: 'statut = ?',
      whereArgs: [statut],
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Compter le nombre total de lapins
  Future<int> countLapins() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM lapins');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ============= OPÉRATIONS SUR LES RELATIONS =============

  /// Récupérer les IDs des parents d'un lapin
  Future<Map<String, int?>?> getRelationByLapinId(int lapinId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'relations',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
    );
    if (maps.isEmpty) return null;
    return {
      'pereId': maps.first['pere_id'] as int?,
      'mereId': maps.first['mere_id'] as int?,
    };
  }

  /// Enregistrer les parents d'un lapin
  Future<void> setParents(int lapinId, int? pereId, int? mereId) async {
    final db = await database;

    // Supprimer la relation existante si elle existe
    await db.delete('relations', where: 'lapin_id = ?', whereArgs: [lapinId]);

    // Insérer la nouvelle relation
    await db.insert('relations', {
      'lapin_id': lapinId,
      'pere_id': pereId,
      'mere_id': mereId,
    });
  }

  /// Récupérer le père d'un lapin
  Future<Lapin?> getPere(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.pere_id
      WHERE r.lapin_id = ?
    ''',
      [lapinId],
    );

    if (result.isNotEmpty) {
      return Lapin.fromMap(result.first);
    }
    return null;
  }

  /// Récupérer la mère d'un lapin
  Future<Lapin?> getMere(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.mere_id
      WHERE r.lapin_id = ?
    ''',
      [lapinId],
    );

    if (result.isNotEmpty) {
      return Lapin.fromMap(result.first);
    }
    return null;
  }

  /// Récupérer les deux parents d'un lapin
  Future<Map<String, Lapin?>> getParents(int lapinId) async {
    final pere = await getPere(lapinId);
    final mere = await getMere(lapinId);
    return {'pere': pere, 'mere': mere};
  }

  /// Récupérer les enfants d'un lapin
  Future<List<Lapin>> getEnfants(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.lapin_id
      WHERE r.pere_id = ? OR r.mere_id = ?
      ORDER BY l.nom ASC
    ''',
      [lapinId, lapinId],
    );

    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer les ancêtres d'un lapin (récursif sur N générations)
  Future<Map<String, dynamic>> getAncetres(
    int lapinId, {
    int generations = 3,
  }) async {
    final lapin = await getLapinById(lapinId);
    if (lapin == null) return {};

    Map<String, dynamic> arbre = {'lapin': lapin, 'pere': null, 'mere': null};

    if (generations > 0) {
      final parents = await getParents(lapinId);
      if (parents['pere'] != null) {
        arbre['pere'] = await getAncetres(
          parents['pere']!.id!,
          generations: generations - 1,
        );
      }
      if (parents['mere'] != null) {
        arbre['mere'] = await getAncetres(
          parents['mere']!.id!,
          generations: generations - 1,
        );
      }
    }

    return arbre;
  }

  /// Calculer le coefficient de consanguinité (simplifié)
  Future<double> calculerConsanguinite(int lapinId) async {
    // Récupérer les ancêtres sur 3 générations
    final ancetres = await getAncetres(lapinId, generations: 3);

    // Collecter tous les IDs des ancêtres
    Set<int> idsAncetres = {};
    void collecterIds(Map<String, dynamic>? noeud) {
      if (noeud == null) return;
      if (noeud['lapin'] is Lapin) {
        final id = (noeud['lapin'] as Lapin).id;
        if (id != null) idsAncetres.add(id);
      }
      collecterIds(noeud['pere']);
      collecterIds(noeud['mere']);
    }

    collecterIds(ancetres);

    // Si on a moins de 2 ancêtres, pas de consanguinité
    if (idsAncetres.length < 2) return 0.0;

    // Calculer le taux de consanguinité simplifié
    // (Nombre d'ancêtres uniques / Nombre d'ancêtres théoriques)
    int ancetresTheoriques = 2 + 4 + 8; // 3 générations
    int ancetresUniques = idsAncetres.length;

    double tauxConsanguinite = 1.0 - (ancetresUniques / ancetresTheoriques);
    return tauxConsanguinite.clamp(0.0, 1.0);
  }

  /// Supprimer la base de données (utile pour les tests)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mon_elevage_lapins.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // ============= OPÉRATIONS CRUD SUR LES ACCOUPLEMENTS =============

  /// Insérer un accouplement dans la base de données
  Future<Accouplement> insertAccouplement(Accouplement accouplement) async {
    final db = await database;
    final id = await db.insert('accouplements', accouplement.toMap());
    return accouplement.copyWith(id: id);
  }

  /// Récupérer tous les accouplements
  Future<List<Accouplement>> getAllAccouplements() async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer un accouplement par son ID
  Future<Accouplement?> getAccouplementById(int id) async {
    final db = await database;
    final maps = await db.query(
      'accouplements',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Accouplement.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un accouplement
  Future<int> updateAccouplement(Accouplement accouplement) async {
    final db = await database;
    return db.update(
      'accouplements',
      accouplement.toMap(),
      where: 'id = ?',
      whereArgs: [accouplement.id],
    );
  }

  /// Supprimer un accouplement
  Future<int> deleteAccouplement(int id) async {
    final db = await database;
    return await db.delete('accouplements', where: 'id = ?', whereArgs: [id]);
  }

  /// Récupérer les accouplements par statut
  Future<List<Accouplement>> getAccouplementsByStatut(String statut) async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      where: 'statut = ?',
      whereArgs: [statut],
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer les accouplements en attente (à venir)
  Future<List<Accouplement>> getAccouplementsEnAttente() async {
    return await getAccouplementsByStatut('en_attente');
  }

  /// Récupérer les accouplements d'une femelle
  Future<List<Accouplement>> getAccouplementsByFemelle(int femelleId) async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      where: 'femelle_id = ?',
      whereArgs: [femelleId],
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer les accouplements d'un mâle
  Future<List<Accouplement>> getAccouplementsByMale(int maleId) async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      where: 'male_id = ?',
      whereArgs: [maleId],
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES PORTÉES =============

  /// Insérer une portée dans la base de données
  Future<Portee> insertPortee(Portee portee) async {
    final db = await database;
    final id = await db.insert('portees', portee.toMap());
    return portee.copyWith(id: id);
  }

  /// Récupérer toutes les portées
  Future<List<Portee>> getAllPortees() async {
    final db = await database;
    final result = await db.query(
      'portees',
      orderBy: 'date_mise_bas_reelle DESC',
    );
    return result.map((json) => Portee.fromMap(json)).toList();
  }

  /// Récupérer une portée par son ID
  Future<Portee?> getPorteeById(int id) async {
    final db = await database;
    final maps = await db.query('portees', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Portee.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Récupérer la portée d'un accouplement
  Future<Portee?> getPorteeByAccouplement(int accouplementId) async {
    final db = await database;
    final maps = await db.query(
      'portees',
      where: 'accouplement_id = ?',
      whereArgs: [accouplementId],
    );

    if (maps.isNotEmpty) {
      return Portee.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour une portée
  Future<int> updatePortee(Portee portee) async {
    final db = await database;
    return db.update(
      'portees',
      portee.toMap(),
      where: 'id = ?',
      whereArgs: [portee.id],
    );
  }

  /// Supprimer une portée
  Future<int> deletePortee(int id) async {
    final db = await database;
    return await db.delete('portees', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES PESÉES =============

  /// Insérer une pesée dans la base de données
  Future<Pesee> insertPesee(Pesee pesee) async {
    final db = await database;
    final id = await db.insert('pesees', pesee.toMap());
    return pesee.copyWith(id: id);
  }

  /// Récupérer toutes les pesées
  Future<List<Pesee>> getAllPesees() async {
    final db = await database;
    final result = await db.query('pesees', orderBy: 'date DESC');
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  /// Récupérer les pesées d'un lapin
  Future<List<Pesee>> getPeseesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'pesees',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date ASC',
    );
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  /// Récupérer la dernière pesée d'un lapin
  Future<Pesee?> getDernierePesee(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'pesees',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Pesee.fromMap(result.first);
    }
    return null;
  }

  /// Mettre à jour une pesée
  Future<int> updatePesee(Pesee pesee) async {
    final db = await database;
    return db.update(
      'pesees',
      pesee.toMap(),
      where: 'id = ?',
      whereArgs: [pesee.id],
    );
  }

  /// Supprimer une pesée
  Future<int> deletePesee(int id) async {
    final db = await database;
    return await db.delete('pesees', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES SOINS =============

  /// Insérer un soin dans la base de données
  Future<Soin> insertSoin(Soin soin) async {
    final db = await database;
    final id = await db.insert('soins', soin.toMap());
    return soin.copyWith(id: id);
  }

  /// Récupérer tous les soins
  Future<List<Soin>> getAllSoins() async {
    final db = await database;
    final result = await db.query('soins', orderBy: 'date DESC');
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer les soins d'un lapin
  Future<List<Soin>> getSoinsByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer un soin par son ID
  Future<Soin?> getSoinById(int id) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Soin.fromMap(result.first);
  }

  /// Récupérer les soins avec rappel nécessaire
  Future<List<Soin>> getSoinsAvecRappel() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'soins',
      where: 'date_rappel IS NOT NULL AND date_rappel <= ?',
      whereArgs: [now],
      orderBy: 'date_rappel ASC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer les soins par type
  Future<List<Soin>> getSoinsByType(String type) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Mettre à jour un soin
  Future<int> updateSoin(Soin soin) async {
    final db = await database;
    return db.update(
      'soins',
      soin.toMap(),
      where: 'id = ?',
      whereArgs: [soin.id],
    );
  }

  /// Supprimer un soin
  Future<int> deleteSoin(int id) async {
    final db = await database;
    return await db.delete('soins', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES RECETTES =============

  /// Insérer une recette
  Future<Recette> insertRecette(Recette recette) async {
    final db = await database;
    final id = await db.insert('recettes', recette.toMap());
    return recette.copyWith(id: id);
  }

  /// Récupérer toutes les recettes
  Future<List<Recette>> getAllRecettes() async {
    final db = await database;
    final result = await db.query('recettes', orderBy: 'date DESC');
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par période
  Future<List<Recette>> getRecettesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final result = await db.query(
      'recettes',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par catégorie
  Future<List<Recette>> getRecettesByCategorie(String categorie) async {
    final db = await database;
    final result = await db.query(
      'recettes',
      where: 'categorie = ?',
      whereArgs: [categorie],
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes liées à un lapin
  Future<List<Recette>> getRecettesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'recettes',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Calculer le total des recettes
  Future<double> getTotalRecettes() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(montant) as total FROM recettes',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Calculer le total des recettes par période
  Future<double> getTotalRecettesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(montant) as total FROM recettes WHERE date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Calculer le total des recettes par catégorie
  Future<Map<String, double>> getTotalRecettesByCategorie() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT categorie, SUM(montant) as total FROM recettes GROUP BY categorie',
    );

    final Map<String, double> totaux = {};
    for (var row in result) {
      totaux[row['categorie'] as String] = (row['total'] as double?) ?? 0.0;
    }
    return totaux;
  }

  /// Mettre à jour une recette
  Future<int> updateRecette(Recette recette) async {
    final db = await database;
    return db.update(
      'recettes',
      recette.toMap(),
      where: 'id = ?',
      whereArgs: [recette.id],
    );
  }

  /// Supprimer une recette
  Future<int> deleteRecette(int id) async {
    final db = await database;
    return await db.delete('recettes', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES DÉPENSES =============

  /// Insérer une dépense
  Future<Depense> insertDepense(Depense depense) async {
    final db = await database;
    final id = await db.insert('depenses', depense.toMap());
    return depense.copyWith(id: id);
  }

  /// Récupérer toutes les dépenses
  Future<List<Depense>> getAllDepenses() async {
    final db = await database;
    final result = await db.query('depenses', orderBy: 'date DESC');
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Récupérer les dépenses par période
  Future<List<Depense>> getDepensesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final result = await db.query(
      'depenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Récupérer les dépenses par catégorie
  Future<List<Depense>> getDepensesByCategorie(String categorie) async {
    final db = await database;
    final result = await db.query(
      'depenses',
      where: 'categorie = ?',
      whereArgs: [categorie],
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Calculer le total des dépenses
  Future<double> getTotalDepenses() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(montant) as total FROM depenses',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Calculer le total des dépenses par période
  Future<double> getTotalDepensesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(montant) as total FROM depenses WHERE date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Calculer le total des dépenses par catégorie
  Future<Map<String, double>> getTotalDepensesByCategorie() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT categorie, SUM(montant) as total FROM depenses GROUP BY categorie',
    );

    final Map<String, double> totaux = {};
    for (var row in result) {
      totaux[row['categorie'] as String] = (row['total'] as double?) ?? 0.0;
    }
    return totaux;
  }

  /// Calculer le bénéfice (recettes - dépenses)
  Future<double> getBenefice() async {
    final recettes = await getTotalRecettes();
    final depenses = await getTotalDepenses();
    return recettes - depenses;
  }

  /// Calculer le bénéfice par période
  Future<double> getBeneficeByPeriode(DateTime debut, DateTime fin) async {
    final recettes = await getTotalRecettesByPeriode(debut, fin);
    final depenses = await getTotalDepensesByPeriode(debut, fin);
    return recettes - depenses;
  }

  /// Mettre à jour une dépense
  Future<int> updateDepense(Depense depense) async {
    final db = await database;
    return db.update(
      'depenses',
      depense.toMap(),
      where: 'id = ?',
      whereArgs: [depense.id],
    );
  }

  /// Supprimer une dépense
  Future<int> deleteDepense(int id) async {
    final db = await database;
    return await db.delete('depenses', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES DÉCÈS =============

  /// Insérer un décès
  Future<Deces> insertDeces(Deces deces) async {
    final db = await database;
    final id = await db.insert('deces', deces.toMap());
    return deces.copyWith(id: id);
  }

  /// Récupérer tous les décès
  Future<List<Deces>> getAllDeces() async {
    final db = await database;
    final result = await db.query('deces', orderBy: 'date_deces DESC');
    return result.map((json) => Deces.fromMap(json)).toList();
  }

  /// Récupérer les décès d'un lapin
  Future<Deces?> getDecesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'deces',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Deces.fromMap(result.first);
  }

  /// Récupérer les décès par période
  Future<List<Deces>> getDecesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.query(
      'deces',
      where: 'date_deces >= ? AND date_deces <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date_deces DESC',
    );
    return result.map((json) => Deces.fromMap(json)).toList();
  }

  /// Récupérer les décès par cause
  Future<List<Deces>> getDecesByCause(String cause) async {
    final db = await database;
    final result = await db.query(
      'deces',
      where: 'cause = ?',
      whereArgs: [cause],
      orderBy: 'date_deces DESC',
    );
    return result.map((json) => Deces.fromMap(json)).toList();
  }

  /// Compter le nombre de décès sur une période
  Future<int> countDecesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM deces WHERE date_deces >= ? AND date_deces <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Mettre à jour un décès
  Future<int> updateDeces(Deces deces) async {
    final db = await database;
    return db.update(
      'deces',
      deces.toMap(),
      where: 'id = ?',
      whereArgs: [deces.id],
    );
  }

  /// Supprimer un décès
  Future<int> deleteDeces(int id) async {
    final db = await database;
    return await db.delete('deces', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES ALIMENTS =============

  /// Insérer un aliment
  Future<Aliment> insertAliment(Aliment aliment) async {
    final db = await database;
    final id = await db.insert('aliments', aliment.toMap());
    return aliment.copyWith(id: id);
  }

  /// Récupérer tous les aliments
  Future<List<Aliment>> getAllAliments() async {
    final db = await database;
    final result = await db.query('aliments', orderBy: 'date_achat DESC');
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  /// Récupérer les aliments en stock
  Future<List<Aliment>> getAlimentsEnStock() async {
    final db = await database;
    final result = await db.query(
      'aliments',
      where: 'quantite_restante > 0',
      orderBy: 'date_peremption ASC',
    );
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  /// Récupérer les aliments par type
  Future<List<Aliment>> getAlimentsByType(String type) async {
    final db = await database;
    final result = await db.query(
      'aliments',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date_achat DESC',
    );
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  /// Récupérer les aliments proches de la péremption
  Future<List<Aliment>> getAlimentsPeremptionProche(int joursAvant) async {
    final db = await database;
    final dateLimite = DateTime.now().add(Duration(days: joursAvant));
    final result = await db.query(
      'aliments',
      where: 'date_peremption <= ? AND quantite_restante > 0',
      whereArgs: [dateLimite.toIso8601String()],
      orderBy: 'date_peremption ASC',
    );
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  /// Calculer la valeur totale du stock
  Future<double> getValeurStock() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(prix_unitaire * quantite_restante) as total FROM aliments WHERE quantite_restante > 0',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Mettre à jour un aliment
  Future<int> updateAliment(Aliment aliment) async {
    final db = await database;
    return db.update(
      'aliments',
      aliment.toMap(),
      where: 'id = ?',
      whereArgs: [aliment.id],
    );
  }

  /// Supprimer un aliment
  Future<int> deleteAliment(int id) async {
    final db = await database;
    return await db.delete('aliments', where: 'id = ?', whereArgs: [id]);
  }

  // ============= OPÉRATIONS CRUD SUR LES DISTRIBUTIONS D'ALIMENTS =============

  /// Insérer une distribution d'aliment
  Future<DistributionAliment> insertDistributionAliment(
    DistributionAliment distribution,
  ) async {
    final db = await database;
    final id = await db.insert('distributions_aliment', distribution.toMap());
    return distribution.copyWith(id: id);
  }

  /// Récupérer toutes les distributions
  Future<List<DistributionAliment>> getAllDistributions() async {
    final db = await database;
    final result = await db.query(
      'distributions_aliment',
      orderBy: 'date DESC',
    );
    return result.map((json) => DistributionAliment.fromMap(json)).toList();
  }

  /// Récupérer les distributions d'un aliment
  Future<List<DistributionAliment>> getDistributionsByAliment(
    int alimentId,
  ) async {
    final db = await database;
    final result = await db.query(
      'distributions_aliment',
      where: 'aliment_id = ?',
      whereArgs: [alimentId],
      orderBy: 'date DESC',
    );
    return result.map((json) => DistributionAliment.fromMap(json)).toList();
  }

  /// Récupérer les distributions par période
  Future<List<DistributionAliment>> getDistributionsByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final result = await db.query(
      'distributions_aliment',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => DistributionAliment.fromMap(json)).toList();
  }

  /// Calculer la consommation totale d'un aliment
  Future<double> getConsommationAliment(int alimentId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantite_distribuee) as total FROM distributions_aliment WHERE aliment_id = ?',
      [alimentId],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Calculer la consommation par période
  Future<double> getConsommationByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantite_distribuee) as total FROM distributions_aliment WHERE date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Mettre à jour une distribution
  Future<int> updateDistributionAliment(
    DistributionAliment distribution,
  ) async {
    final db = await database;
    return db.update(
      'distributions_aliment',
      distribution.toMap(),
      where: 'id = ?',
      whereArgs: [distribution.id],
    );
  }

  /// Supprimer une distribution
  Future<int> deleteDistributionAliment(int id) async {
    final db = await database;
    return await db.delete(
      'distributions_aliment',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
