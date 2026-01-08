import 'dart:convert';
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
import '../models/tache.dart';
import '../models/user.dart';
import '../models/user_action_log.dart';
import '../models/batiment.dart';
import '../models/clapier.dart';
import '../models/cage.dart';
import '../models/medicament.dart';
import '../models/rituel.dart';
import '../models/anomalie_rituel.dart';
import '../models/journal_entry.dart';
import '../utils/logger.dart';
import '../utils/data_migration_service.dart';
import 'secure_storage_service.dart';

/// Service de gestion de la base de données SQLite
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  final SecureStorageService _secureStorage = SecureStorageService();

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
      version: 20,
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
        caracteristiques $textTypeNullable,
        cage_id INTEGER
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
        medicament_id INTEGER,
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
        type_materiau $textTypeNullable,
        quantite_materiau REAL,
        boite_nid_installee INTEGER DEFAULT 0,
        disposition_nid $textTypeNullable,
        observations $textTypeNullable,
        temperature_ambiance REAL,
        materiau_id INTEGER,
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
      'CREATE INDEX idx_preparations_nid_materiau_id ON preparations_nid(materiau_id)',
    );
    await db.execute(
      'CREATE INDEX idx_soins_medicament_id ON soins(medicament_id)',
    );
    await db.execute(
      'CREATE INDEX idx_protocoles_type ON protocoles_soin(type)',
    );
    await db.execute(
      'CREATE INDEX idx_protocoles_actif ON protocoles_soin(actif)',
    );

    // Table des événements personnalisés (version 14)
    await db.execute('''
      CREATE TABLE evenements_personnalises (
        id $idType,
        titre $textType,
        description $textTypeNullable,
        date $textType,
        heure $textTypeNullable,
        categorie $textTypeNullable,
        lapin_id INTEGER,
        important INTEGER NOT NULL DEFAULT 0,
        notification_active INTEGER NOT NULL DEFAULT 0,
        couleur $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_evenements_date ON evenements_personnalises(date)',
    );
    await db.execute(
      'CREATE INDEX idx_evenements_lapin_id ON evenements_personnalises(lapin_id)',
    );

    // Tables de localisation (version 10)
    await db.execute('''
      CREATE TABLE batiments (
        id $idType,
        nom $textType,
        description $textTypeNullable,
        date_creation $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE clapiers (
        id $idType,
        batiment_id INTEGER NOT NULL,
        nom $textType,
        type $textType,
        description $textTypeNullable,
        date_creation $textType,
        FOREIGN KEY (batiment_id) REFERENCES batiments (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cages (
        id $idType,
        clapier_id INTEGER NOT NULL,
        numero $textType,
        type $textType,
        capacite INTEGER NOT NULL,
        description $textTypeNullable,
        date_creation $textType,
        FOREIGN KEY (clapier_id) REFERENCES clapiers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_clapiers_batiment ON clapiers(batiment_id)',
    );
    await db.execute('CREATE INDEX idx_cages_clapier ON cages(clapier_id)');
    await db.execute('CREATE INDEX idx_cages_numero ON cages(numero)');
    await db.execute(
      'CREATE INDEX idx_lapins_localisation ON lapins(localisation)',
    );
    await db.execute('CREATE INDEX idx_lapins_cage_id ON lapins(cage_id)');

    // Table des tâches (version 15)
    await db.execute('''
      CREATE TABLE taches (
        id $idType,
        titre $textType,
        description $textTypeNullable,
        date_planification $textType,
        priorite $textType DEFAULT 'normale',
        categorie $textType DEFAULT 'autre',
        statut $textType DEFAULT 'a_faire',
        lapin_id INTEGER,
        est_recurrente INTEGER NOT NULL DEFAULT 0,
        frequence_recurrence $textTypeNullable,
        date_creation $textType,
        date_modification $textTypeNullable,
        date_completion $textTypeNullable,
        notes $textTypeNullable,
        piece_jointe_path $textTypeNullable,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_taches_date_planification ON taches(date_planification)',
    );
    await db.execute('CREATE INDEX idx_taches_statut ON taches(statut)');
    await db.execute('CREATE INDEX idx_taches_lapin_id ON taches(lapin_id)');
    await db.execute('CREATE INDEX idx_taches_categorie ON taches(categorie)');

    // Table des utilisateurs (version 16)
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        nom $textType,
        prenom $textTypeNullable,
        role $textType DEFAULT 'eleveur',
        photo_path $textTypeNullable,
        is_active INTEGER NOT NULL DEFAULT 1,
        date_creation $textType,
        derniere_connexion $textTypeNullable,
        notes $textTypeNullable
      )
    ''');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_role ON users(role)');
    await db.execute('CREATE INDEX idx_users_is_active ON users(is_active)');

    // Table de l'historique des actions utilisateurs (version 16)
    await db.execute('''
      CREATE TABLE user_action_logs (
        id $idType,
        user_id INTEGER NOT NULL,
        action_type $textType,
        entity_type $textType,
        entity_id INTEGER,
        description $textTypeNullable,
        details $textTypeNullable,
        date_action $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_user_action_logs_user_id ON user_action_logs(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_user_action_logs_date_action ON user_action_logs(date_action)',
    );
    await db.execute(
      'CREATE INDEX idx_user_action_logs_entity_type ON user_action_logs(entity_type)',
    );

    // Table des rituels quotidiens (version 17)
    await db.execute('''
      CREATE TABLE rituels (
        id $idType,
        date $textType,
        type $textType,
        actions $textType,
        date_creation $textType,
        date_completion $textTypeNullable
      )
    ''');

    await db.execute('CREATE INDEX idx_rituels_date ON rituels(date)');
    await db.execute('CREATE INDEX idx_rituels_type ON rituels(type)');
    await db.execute(
      'CREATE UNIQUE INDEX idx_rituels_date_type ON rituels(date, type)',
    );

    // Table des anomalies de rituels (version 18)
    await db.execute('''
      CREATE TABLE anomalies_rituels (
        id $idType,
        date_observation $textType,
        rituel_id INTEGER,
        action_rituel_id $textType,
        action_rituel_titre $textType,
        types_anomalies $textType,
        portee $textType,
        lapin_id INTEGER,
        cage_id $textTypeNullable,
        severite INTEGER NOT NULL DEFAULT 1,
        action_suggeree $textType,
        action_prise $textTypeNullable,
        statut $textType DEFAULT 'nouveau',
        note_libre $textTypeNullable,
        date_resolution $textTypeNullable,
        FOREIGN KEY (rituel_id) REFERENCES rituels (id) ON DELETE SET NULL,
        FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_anomalies_date ON anomalies_rituels(date_observation)',
    );
    await db.execute(
      'CREATE INDEX idx_anomalies_statut ON anomalies_rituels(statut)',
    );
    await db.execute(
      'CREATE INDEX idx_anomalies_severite ON anomalies_rituels(severite)',
    );
    await db.execute(
      'CREATE INDEX idx_anomalies_rituel_id ON anomalies_rituels(rituel_id)',
    );

    // Table du journal automatique (version 20)
    // L'utilisateur agit, l'app écrit.
    await db.execute('''
      CREATE TABLE journal_automatique (
        id $idType,
        timestamp $textType,
        type_entite $textType,
        entite_id INTEGER,
        entite_nom $textTypeNullable,
        type_action $textType,
        statut $textType DEFAULT 'normal',
        resume_auto $textType,
        contexte $textTypeNullable,
        note_utilisateur $textTypeNullable,
        lu INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_journal_timestamp ON journal_automatique(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_journal_type_entite ON journal_automatique(type_entite)',
    );
    await db.execute(
      'CREATE INDEX idx_journal_statut ON journal_automatique(statut)',
    );
    await db.execute('CREATE INDEX idx_journal_lu ON journal_automatique(lu)');

    logger.info('✅ Toutes les tables créées avec succès (versions 1-20)');
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

    // Migration de la version 9 à 10 : Tables de localisation (hiérarchie bâtiments > clapiers > cages)
    if (oldVersion < 10) {
      // Table des bâtiments
      await db.execute('''
        CREATE TABLE batiments (
          id $idType,
          nom $textType,
          description $textTypeNullable,
          date_creation $textType
        )
      ''');

      // Table des clapiers/zones
      await db.execute('''
        CREATE TABLE clapiers (
          id $idType,
          batiment_id INTEGER NOT NULL,
          nom $textType,
          type $textType,
          description $textTypeNullable,
          date_creation $textType,
          FOREIGN KEY (batiment_id) REFERENCES batiments (id) ON DELETE CASCADE
        )
      ''');

      // Table des cages
      await db.execute('''
        CREATE TABLE cages (
          id $idType,
          clapier_id INTEGER NOT NULL,
          numero $textType,
          type $textType,
          capacite INTEGER NOT NULL,
          description $textTypeNullable,
          date_creation $textType,
          FOREIGN KEY (clapier_id) REFERENCES clapiers (id) ON DELETE CASCADE
        )
      ''');

      // Index pour améliorer les performances
      await db.execute(
        'CREATE INDEX idx_clapiers_batiment ON clapiers(batiment_id)',
      );
      await db.execute('CREATE INDEX idx_cages_clapier ON cages(clapier_id)');
      await db.execute('CREATE INDEX idx_cages_numero ON cages(numero)');
      await db.execute(
        'CREATE INDEX idx_lapins_localisation ON lapins(localisation)',
      );

      logger.info(
        '✅ Migration vers version 10 : Tables de localisation ajoutées (batiments, clapiers, cages)',
      );
    }

    // Migration de la version 10 à 11 : Champs de synchronisation Supabase
    if (oldVersion < 11) {
      // Liste des tables à migrer (priorité 1)
      final tables = [
        'lapins',
        'accouplements',
        'portees',
        'pesees',
        'soins',
        'recettes',
        'depenses',
        'deces',
        'aliments',
        'distributions_aliment',
      ];

      for (final table in tables) {
        try {
          // Ajouter les champs de synchronisation
          await db.execute('ALTER TABLE $table ADD COLUMN user_id TEXT');
          await db.execute(
            'ALTER TABLE $table ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
          );
          await db.execute(
            'ALTER TABLE $table ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
          );
          await db.execute('ALTER TABLE $table ADD COLUMN synced_at TEXT');
          await db.execute(
            'ALTER TABLE $table ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute('ALTER TABLE $table ADD COLUMN deleted_at TEXT');
          await db.execute('ALTER TABLE $table ADD COLUMN sync_conflict TEXT');

          // Initialiser les données existantes
          await db.execute('''
            UPDATE $table SET 
              created_at = datetime('now'),
              updated_at = datetime('now'),
              is_dirty = 0
            WHERE created_at IS NULL
          ''');

          logger.info('✅ Migration $table : Champs de sync ajoutés');
        } catch (e) {
          logger.error('❌ Erreur lors de la migration de $table: $e');
          // Continuer avec les autres tables
        }
      }

      // Créer les index pour optimiser les requêtes de synchronisation
      final indexTables = [
        'lapins',
        'accouplements',
        'portees',
        'pesees',
        'soins',
        'recettes',
        'depenses',
        'deces',
        'aliments',
        'distributions_aliment',
      ];

      for (final table in indexTables) {
        try {
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_${table}_user_id ON $table(user_id)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_${table}_is_dirty ON $table(is_dirty)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_${table}_updated_at ON $table(updated_at)',
          );
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la création des index pour $table: $e',
          );
        }
      }

      logger.info(
        '✅ Migration vers version 11 : Champs de synchronisation ajoutés',
      );
    }

    // Migration de la version 11 à 12 : Vérification et ajout des colonnes manquantes
    if (oldVersion < 12) {
      // Fonction helper pour vérifier si une colonne existe
      Future<bool> columnExists(
        Database db,
        String table,
        String column,
      ) async {
        try {
          final result = await db.rawQuery("PRAGMA table_info($table)");
          return result.any((row) => row['name'] == column);
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la vérification de la colonne $column dans $table: $e',
          );
          return false;
        }
      }

      // Liste des tables à migrer
      final tables = [
        'lapins',
        'accouplements',
        'portees',
        'pesees',
        'soins',
        'recettes',
        'depenses',
        'deces',
        'aliments',
        'distributions_aliment',
      ];

      for (final table in tables) {
        try {
          logger.info('🔄 Vérification de la table $table...');

          // Vérifier et ajouter user_id
          if (!await columnExists(db, table, 'user_id')) {
            await db.execute('ALTER TABLE $table ADD COLUMN user_id TEXT');
            logger.info('✅ Migration $table : Colonne user_id ajoutée');
          } else {
            logger.info('ℹ️ Colonne user_id existe déjà dans $table');
          }

          // Vérifier et ajouter created_at
          if (!await columnExists(db, table, 'created_at')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
            );
            logger.info('✅ Migration $table : Colonne created_at ajoutée');
          }

          // Vérifier et ajouter updated_at
          if (!await columnExists(db, table, 'updated_at')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
            );
            logger.info('✅ Migration $table : Colonne updated_at ajoutée');
          }

          // Vérifier et ajouter synced_at
          if (!await columnExists(db, table, 'synced_at')) {
            await db.execute('ALTER TABLE $table ADD COLUMN synced_at TEXT');
            logger.info('✅ Migration $table : Colonne synced_at ajoutée');
          }

          // Vérifier et ajouter is_dirty
          if (!await columnExists(db, table, 'is_dirty')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1',
            );
            logger.info('✅ Migration $table : Colonne is_dirty ajoutée');
          }

          // Vérifier et ajouter is_deleted (pour compatibilité avec le code existant)
          if (!await columnExists(db, table, 'is_deleted')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
            );
            logger.info('✅ Migration $table : Colonne is_deleted ajoutée');
          }

          // Vérifier et ajouter deleted_at
          if (!await columnExists(db, table, 'deleted_at')) {
            await db.execute('ALTER TABLE $table ADD COLUMN deleted_at TEXT');
            logger.info('✅ Migration $table : Colonne deleted_at ajoutée');
          }

          // Vérifier et ajouter sync_conflict
          if (!await columnExists(db, table, 'sync_conflict')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN sync_conflict TEXT',
            );
            logger.info('✅ Migration $table : Colonne sync_conflict ajoutée');
          }

          // Initialiser les données existantes si nécessaire
          await db.execute('''
            UPDATE $table SET 
              created_at = COALESCE(created_at, datetime('now')),
              updated_at = COALESCE(updated_at, datetime('now')),
              is_dirty = COALESCE(is_dirty, 0),
              is_deleted = COALESCE(is_deleted, 0)
            WHERE created_at IS NULL OR updated_at IS NULL
          ''');
        } catch (e) {
          logger.error('❌ Erreur lors de la migration de $table: $e');
          // Continuer avec les autres tables
        }
      }

      // Fonction helper pour vérifier si une colonne existe (utilisée pour les index)
      Future<bool> columnExistsForIndex(
        Database db,
        String table,
        String column,
      ) async {
        try {
          final result = await db.rawQuery("PRAGMA table_info($table)");
          return result.any((row) => row['name'] == column);
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la vérification de la colonne $column dans $table: $e',
          );
          return false;
        }
      }

      // Créer les index pour optimiser les requêtes de synchronisation
      // Vérifier que les colonnes existent avant de créer les index
      for (final table in tables) {
        try {
          if (await columnExistsForIndex(db, table, 'user_id')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_user_id ON $table(user_id)',
            );
          }
          if (await columnExistsForIndex(db, table, 'is_dirty')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_is_dirty ON $table(is_dirty)',
            );
          }
          if (await columnExistsForIndex(db, table, 'updated_at')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_updated_at ON $table(updated_at)',
            );
          }
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la création des index pour $table: $e',
          );
        }
      }

      logger.info(
        '✅ Migration vers version 12 : Vérification et ajout des colonnes manquantes',
      );
    }

    // Migration de la version 12 à 13 : Forcer la vérification et l'ajout des colonnes manquantes
    // Cette migration s'exécute même si certaines colonnes existent déjà
    if (oldVersion < 13) {
      // Fonction helper pour vérifier si une colonne existe
      Future<bool> columnExists(
        Database db,
        String table,
        String column,
      ) async {
        try {
          final result = await db.rawQuery("PRAGMA table_info($table)");
          return result.any((row) => row['name'] == column);
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la vérification de la colonne $column dans $table: $e',
          );
          return false;
        }
      }

      // Liste des tables à migrer
      final tables = [
        'lapins',
        'accouplements',
        'portees',
        'pesees',
        'soins',
        'recettes',
        'depenses',
        'deces',
        'aliments',
        'distributions_aliment',
      ];

      logger.info(
        '🔄 Migration vers version 13 : Vérification forcée des colonnes...',
      );

      for (final table in tables) {
        try {
          logger.info('🔄 Vérification de la table $table...');

          // Vérifier et ajouter user_id
          if (!await columnExists(db, table, 'user_id')) {
            await db.execute('ALTER TABLE $table ADD COLUMN user_id TEXT');
            logger.info('✅ Migration $table : Colonne user_id ajoutée');
          } else {
            logger.info('ℹ️ Colonne user_id existe déjà dans $table');
          }

          // Vérifier et ajouter created_at
          if (!await columnExists(db, table, 'created_at')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
            );
            logger.info('✅ Migration $table : Colonne created_at ajoutée');
          }

          // Vérifier et ajouter updated_at
          if (!await columnExists(db, table, 'updated_at')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
            );
            logger.info('✅ Migration $table : Colonne updated_at ajoutée');
          }

          // Vérifier et ajouter synced_at
          if (!await columnExists(db, table, 'synced_at')) {
            await db.execute('ALTER TABLE $table ADD COLUMN synced_at TEXT');
            logger.info('✅ Migration $table : Colonne synced_at ajoutée');
          }

          // Vérifier et ajouter is_dirty
          if (!await columnExists(db, table, 'is_dirty')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1',
            );
            logger.info('✅ Migration $table : Colonne is_dirty ajoutée');
          }

          // Vérifier et ajouter is_deleted (pour compatibilité avec le code existant)
          if (!await columnExists(db, table, 'is_deleted')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
            );
            logger.info('✅ Migration $table : Colonne is_deleted ajoutée');
          }

          // Vérifier et ajouter deleted_at
          if (!await columnExists(db, table, 'deleted_at')) {
            await db.execute('ALTER TABLE $table ADD COLUMN deleted_at TEXT');
            logger.info('✅ Migration $table : Colonne deleted_at ajoutée');
          }

          // Vérifier et ajouter sync_conflict
          if (!await columnExists(db, table, 'sync_conflict')) {
            await db.execute(
              'ALTER TABLE $table ADD COLUMN sync_conflict TEXT',
            );
            logger.info('✅ Migration $table : Colonne sync_conflict ajoutée');
          }

          // Initialiser les données existantes si nécessaire
          try {
            await db.execute('''
              UPDATE $table SET 
                created_at = COALESCE(created_at, datetime('now')),
                updated_at = COALESCE(updated_at, datetime('now')),
                is_dirty = COALESCE(is_dirty, 0),
                is_deleted = COALESCE(is_deleted, 0)
              WHERE created_at IS NULL OR updated_at IS NULL
            ''');
          } catch (e) {
            // Ignorer les erreurs d'UPDATE si les colonnes n'existent pas encore
            logger.debug(
              '⚠️ Erreur lors de l\'initialisation des données pour $table: $e',
            );
          }
        } catch (e) {
          logger.error('❌ Erreur lors de la migration de $table: $e');
          // Continuer avec les autres tables
        }
      }

      // Créer les index pour optimiser les requêtes de synchronisation
      // Vérifier que les colonnes existent avant de créer les index
      for (final table in tables) {
        try {
          // Index user_id
          if (await columnExists(db, table, 'user_id')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_user_id ON $table(user_id)',
            );
            logger.info('✅ Index idx_${table}_user_id créé');
          }

          // Index is_dirty
          if (await columnExists(db, table, 'is_dirty')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_is_dirty ON $table(is_dirty)',
            );
            logger.info('✅ Index idx_${table}_is_dirty créé');
          }

          // Index updated_at
          if (await columnExists(db, table, 'updated_at')) {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_${table}_updated_at ON $table(updated_at)',
            );
            logger.info('✅ Index idx_${table}_updated_at créé');
          }
        } catch (e) {
          logger.error(
            '❌ Erreur lors de la création des index pour $table: $e',
          );
        }
      }

      logger.info(
        '✅ Migration vers version 13 : Vérification forcée des colonnes terminée',
      );
    }

    // Migration de la version 13 à 14 : Table evenements_personnalises
    if (oldVersion < 14) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info(
        '🔄 Migration vers version 14 : Ajout table evenements_personnalises...',
      );

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS evenements_personnalises (
            id $idType,
            titre $textType,
            description $textTypeNullable,
            date $textType,
            heure $textTypeNullable,
            categorie $textTypeNullable,
            lapin_id INTEGER,
            important INTEGER NOT NULL DEFAULT 0,
            notification_active INTEGER NOT NULL DEFAULT 0,
            couleur $textTypeNullable,
            FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_evenements_date ON evenements_personnalises(date)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_evenements_lapin_id ON evenements_personnalises(lapin_id)',
        );

        logger.info(
          '✅ Migration vers version 14 : Table evenements_personnalises ajoutée',
        );
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 14: $e');
      }
    }

    if (oldVersion < 15) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info('🔄 Migration vers version 15 : Ajout table taches...');

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS taches (
            id $idType,
            titre $textType,
            description $textTypeNullable,
            date_planification $textType,
            priorite $textType DEFAULT 'normale',
            categorie $textType DEFAULT 'autre',
            statut $textType DEFAULT 'a_faire',
            lapin_id INTEGER,
            est_recurrente INTEGER NOT NULL DEFAULT 0,
            frequence_recurrence $textTypeNullable,
            date_creation $textType,
            date_modification $textTypeNullable,
            date_completion $textTypeNullable,
            notes $textTypeNullable,
            piece_jointe_path $textTypeNullable,
            FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_taches_date_planification ON taches(date_planification)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_taches_statut ON taches(statut)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_taches_lapin_id ON taches(lapin_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_taches_categorie ON taches(categorie)',
        );

        logger.info('✅ Migration vers version 15 : Table taches ajoutée');
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 15: $e');
      }
    }

    if (oldVersion < 16) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info(
        '🔄 Migration vers version 16 : Ajout tables users et user_action_logs...',
      );

      try {
        // Table des utilisateurs
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id $idType,
            email $textType UNIQUE,
            nom $textType,
            prenom $textTypeNullable,
            role $textType DEFAULT 'eleveur',
            photo_path $textTypeNullable,
            is_active INTEGER NOT NULL DEFAULT 1,
            date_creation $textType,
            derniere_connexion $textTypeNullable,
            notes $textTypeNullable
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active)',
        );

        // Table de l'historique des actions utilisateurs
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_action_logs (
            id $idType,
            user_id INTEGER NOT NULL,
            action_type $textType,
            entity_type $textType,
            entity_id INTEGER,
            description $textTypeNullable,
            details $textTypeNullable,
            date_action $textType,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_user_action_logs_user_id ON user_action_logs(user_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_user_action_logs_date_action ON user_action_logs(date_action)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_user_action_logs_entity_type ON user_action_logs(entity_type)',
        );

        logger.info(
          '✅ Migration vers version 16 : Tables users et user_action_logs ajoutées',
        );
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 16: $e');
      }
    }

    // Migration de la version 16 à 17 : Refactoring FK (localisation, medicament, materiau)
    if (oldVersion < 17) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';

      logger.info(
        '🔄 Migration vers version 17 : Refactoring champs texte → FK...',
      );

      try {
        // 1. Créer table materiaux (pour preparations_nid.type_materiau)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS materiaux (
            id $idType,
            nom $textType UNIQUE,
            description TEXT,
            prix_unitaire REAL,
            stock_actuel REAL
          )
        ''');

        // Pré-remplir table materiaux avec valeurs standards
        await db.execute('''
          INSERT OR IGNORE INTO materiaux (id, nom, description) VALUES
          (1, 'Paille', 'Matériau classique pour nids'),
          (2, 'Foin', 'Doux et isolant'),
          (3, 'Copeaux', 'Copeaux de bois absorbants'),
          (4, 'Mixte', 'Combinaison de matériaux')
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_materiaux_nom ON materiaux(nom)',
        );

        // 2. Ajouter colonne cage_id à lapins (FK vers cages.id)
        await db.execute('ALTER TABLE lapins ADD COLUMN cage_id INTEGER');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_lapins_cage_id ON lapins(cage_id)',
        );
        logger.info('  ✅ Colonne lapins.cage_id ajoutée (FK vers cages.id)');

        // 3. Ajouter colonne medicament_id à soins (FK vers medicaments.id)
        await db.execute('ALTER TABLE soins ADD COLUMN medicament_id INTEGER');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_soins_medicament_id ON soins(medicament_id)',
        );
        logger.info(
          '  ✅ Colonne soins.medicament_id ajoutée (FK vers medicaments.id)',
        );

        // 4. Ajouter colonne materiau_id à preparations_nid (FK vers materiaux.id)
        await db.execute(
          'ALTER TABLE preparations_nid ADD COLUMN materiau_id INTEGER',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_preparations_nid_materiau_id ON preparations_nid(materiau_id)',
        );
        logger.info(
          '  ✅ Colonne preparations_nid.materiau_id ajoutée (FK vers materiaux.id)',
        );

        logger.info(
          '✅ Migration vers version 17 : Colonnes FK ajoutées avec succès',
        );
        logger.info(
          '⚠️  Les anciennes colonnes texte sont conservées pour backward compatibility',
        );

        // 5. Migration automatique des données existantes (Phase 3)
        await DataMigrationService.migrerToutesLesDonnees(db);
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 17: $e');
      }
    }

    // Migration de la version 17 à 18 : Tables rituels et anomalies_rituels
    if (oldVersion < 18) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info(
        '🔄 Migration vers version 18 : Tables rituels et anomalies_rituels...',
      );

      try {
        // 1. Créer la table rituels (oubliée dans migration 17)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rituels (
            id $idType,
            date $textType,
            type $textType,
            actions $textType,
            date_creation $textType,
            date_completion $textTypeNullable
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_rituels_date ON rituels(date)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_rituels_type ON rituels(type)',
        );
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_rituels_date_type ON rituels(date, type)',
        );

        logger.info('  ✅ Table rituels créée');

        // 2. Créer la table anomalies_rituels
        await db.execute('''
          CREATE TABLE IF NOT EXISTS anomalies_rituels (
            id $idType,
            date_observation $textType,
            rituel_id INTEGER,
            action_rituel_id $textType,
            action_rituel_titre $textType,
            types_anomalies $textType,
            portee $textType,
            lapin_id INTEGER,
            cage_id $textTypeNullable,
            severite INTEGER NOT NULL DEFAULT 1,
            action_suggeree $textType,
            action_prise $textTypeNullable,
            statut $textType DEFAULT 'nouveau',
            note_libre $textTypeNullable,
            date_resolution $textTypeNullable,
            FOREIGN KEY (rituel_id) REFERENCES rituels (id) ON DELETE SET NULL,
            FOREIGN KEY (lapin_id) REFERENCES lapins (id) ON DELETE SET NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_anomalies_date ON anomalies_rituels(date_observation)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_anomalies_statut ON anomalies_rituels(statut)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_anomalies_severite ON anomalies_rituels(severite)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_anomalies_rituel_id ON anomalies_rituels(rituel_id)',
        );

        logger.info(
          '✅ Migration vers version 18 : Tables rituels et anomalies_rituels créées',
        );
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 18: $e');
      }
    }

    // Migration de la version 18 à 19 : Correction - table rituels manquante
    if (oldVersion < 19) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info(
        '🔄 Migration vers version 19 : Vérification table rituels...',
      );

      try {
        // Créer la table rituels si elle n'existe pas (correction bug migration 17/18)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rituels (
            id $idType,
            date $textType,
            type $textType,
            actions $textType,
            date_creation $textType,
            date_completion $textTypeNullable
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_rituels_date ON rituels(date)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_rituels_type ON rituels(type)',
        );
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_rituels_date_type ON rituels(date, type)',
        );

        logger.info(
          '✅ Migration vers version 19 : Table rituels vérifiée/créée',
        );
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 19: $e');
      }
    }

    // Migration de la version 19 à 20 : Journal automatique
    if (oldVersion < 20) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      logger.info('🔄 Migration vers version 20 : Journal automatique...');

      try {
        // Table du journal automatique
        // L'utilisateur agit, l'app écrit.
        await db.execute('''
          CREATE TABLE IF NOT EXISTS journal_automatique (
            id $idType,
            timestamp $textType,
            type_entite $textType,
            entite_id INTEGER,
            entite_nom $textTypeNullable,
            type_action $textType,
            statut $textType DEFAULT 'normal',
            resume_auto $textType,
            contexte $textTypeNullable,
            note_utilisateur $textTypeNullable,
            lu INTEGER DEFAULT 0
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_journal_timestamp ON journal_automatique(timestamp)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_journal_type_entite ON journal_automatique(type_entite)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_journal_statut ON journal_automatique(statut)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_journal_lu ON journal_automatique(lu)',
        );

        logger.info(
          '✅ Migration vers version 20 : Table journal_automatique créée',
        );
      } catch (e) {
        logger.error('❌ Erreur lors de la migration vers version 20: $e');
      }
    }
  }

  // ============= MÉTHODES UTILITAIRES =============

  /// Obtenir le user_id actuel depuis SecureStorage
  ///
  /// Retourne null si aucun utilisateur n'est connecté
  Future<String?> _getCurrentUserId() async {
    try {
      return await _secureStorage.getUserId();
    } catch (e) {
      logger.debug('⚠️ Impossible de récupérer le user_id: $e');
      return null;
    }
  }

  /// Construire une clause WHERE avec filtrage user_id
  ///
  /// [baseWhere] : Clause WHERE de base (peut être null)
  /// [baseWhereArgs] : Arguments de la clause WHERE de base
  /// [userId] : User ID pour le filtrage (peut être null)
  /// [tableName] : Nom de la table pour vérifier si user_id existe (optionnel)
  ///
  /// Retourne un tuple (where, whereArgs) avec le filtrage user_id ajouté si la colonne existe
  Future<(String, List<dynamic>)> _buildWhereWithUserId(
    String? baseWhere,
    List<dynamic>? baseWhereArgs,
    String? userId, {
    String? tableName,
  }) async {
    final whereArgs = <dynamic>[];
    var where = '';

    // Vérifier si la colonne user_id existe dans la table
    bool hasUserIdColumn = true;
    if (tableName != null && userId != null) {
      try {
        final db = await database;
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        final columnNames = columns.map((row) => row['name'] as String).toSet();
        hasUserIdColumn = columnNames.contains('user_id');
      } catch (e) {
        // En cas d'erreur, supposer que la colonne n'existe pas
        hasUserIdColumn = false;
      }
    }

    // Ajouter le filtrage user_id si disponible et colonne existe
    if (userId != null && hasUserIdColumn) {
      where = 'user_id = ?';
      whereArgs.add(userId);
    }

    // Ajouter la clause WHERE de base si elle existe
    if (baseWhere != null && baseWhere.isNotEmpty) {
      if (where.isNotEmpty) {
        where = '$where AND ($baseWhere)';
      } else {
        where = baseWhere;
      }
      if (baseWhereArgs != null) {
        whereArgs.addAll(baseWhereArgs);
      }
    }

    return (where.isEmpty ? '1=1' : where, whereArgs);
  }

  /// Préparer les données pour insertion avec user_id et timestamps
  ///
  /// Définit automatiquement :
  /// - user_id (si non défini et utilisateur connecté)
  /// - created_at (si non défini et colonne existe)
  /// - updated_at (si non défini et colonne existe)
  /// - is_dirty = 1 (pour synchronisation, si colonne existe)
  /// - is_deleted = 0 (par défaut, si colonne existe)
  ///
  /// Vérifie l'existence des colonnes avant de les ajouter pour éviter les erreurs
  Future<Map<String, dynamic>> _prepareDataForInsert(
    Map<String, dynamic> data, {
    String? tableName,
  }) async {
    final map = Map<String, dynamic>.from(data);

    // Si un nom de table est fourni, vérifier l'existence des colonnes
    bool hasUserId = true;
    bool hasCreatedAt = true;
    bool hasUpdatedAt = true;
    bool hasIsDirty = true;
    bool hasIsDeleted = true;

    if (tableName != null) {
      final db = await database;
      try {
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        final columnNames = columns.map((row) => row['name'] as String).toSet();

        hasUserId = columnNames.contains('user_id');
        hasCreatedAt = columnNames.contains('created_at');
        hasUpdatedAt = columnNames.contains('updated_at');
        hasIsDirty = columnNames.contains('is_dirty');
        hasIsDeleted = columnNames.contains('is_deleted');
      } catch (e) {
        // En cas d'erreur, supposer que les colonnes n'existent pas
        logger.debug(
          '⚠️ Impossible de vérifier les colonnes pour $tableName: $e',
        );
        hasUserId = false;
        hasCreatedAt = false;
        hasUpdatedAt = false;
        hasIsDirty = false;
        hasIsDeleted = false;
      }
    }

    // Définir user_id si non défini, utilisateur connecté, et colonne existe
    if (hasUserId && map['user_id'] == null) {
      final userId = await _getCurrentUserId();
      if (userId != null) {
        map['user_id'] = userId;
      }
    } else if (!hasUserId) {
      map.remove('user_id');
    }

    // Définir les timestamps si non définis et colonnes existent
    if (hasCreatedAt) {
      final now = DateTime.now().toIso8601String();
      map['created_at'] ??= now;
    } else {
      map.remove('created_at');
    }

    if (hasUpdatedAt) {
      final now = DateTime.now().toIso8601String();
      map['updated_at'] ??= now;
    } else {
      map.remove('updated_at');
    }

    // Définir les flags de synchronisation si colonnes existent
    if (hasIsDirty) {
      map['is_dirty'] = 1; // Marquer comme à synchroniser
    } else {
      map.remove('is_dirty');
    }

    if (hasIsDeleted) {
      map['is_deleted'] ??= 0;
    } else {
      map.remove('is_deleted');
    }

    return map;
  }

  /// Filtrer les colonnes inexistantes d'un Map avant update
  ///
  /// Vérifie l'existence des colonnes dans la table et supprime celles qui n'existent pas
  Future<Map<String, dynamic>> _filterColumnsForUpdate(
    Map<String, dynamic> data,
    String tableName,
  ) async {
    final db = await database;
    try {
      final columns = await db.rawQuery("PRAGMA table_info($tableName)");
      final columnNames = columns.map((row) => row['name'] as String).toSet();

      // Filtrer le Map pour ne garder que les colonnes existantes
      final filtered = <String, dynamic>{};
      for (final entry in data.entries) {
        if (columnNames.contains(entry.key)) {
          filtered[entry.key] = entry.value;
        }
      }

      return filtered;
    } catch (e) {
      logger.debug('⚠️ Impossible de filtrer les colonnes pour $tableName: $e');
      // En cas d'erreur, retourner les données telles quelles
      return data;
    }
  }

  // ============= OPÉRATIONS CRUD SUR INFRASTRUCTURE =============
  // Phase 5: Méthodes helper pour uniformiser l'API

  /// Insérer un bâtiment dans la base de données
  Future<Batiment> insertBatiment(Batiment batiment) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      batiment.toMap(),
      tableName: 'batiments',
    );
    final id = await db.insert('batiments', map);
    return batiment.copyWith(id: id);
  }

  /// Supprimer un bâtiment (cascade sur clapiers et cages)
  Future<void> deleteBatiment(int id) async {
    final db = await database;
    await db.delete('batiments', where: 'id = ?', whereArgs: [id]);
  }

  /// Insérer un clapier dans la base de données
  Future<Clapier> insertClapier(Clapier clapier) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      clapier.toMap(),
      tableName: 'clapiers',
    );
    final id = await db.insert('clapiers', map);
    return clapier.copyWith(id: id);
  }

  /// Insérer une cage dans la base de données
  Future<Cage> insertCage(Cage cage) async {
    final db = await database;
    final map = await _prepareDataForInsert(cage.toMap(), tableName: 'cages');
    final id = await db.insert('cages', map);
    return cage.copyWith(id: id);
  }

  /// Insérer un médicament dans la base de données
  Future<Medicament> insertMedicament(Medicament medicament) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      medicament.toMap(),
      tableName: 'medicaments',
    );
    final id = await db.insert('medicaments', map);
    return medicament.copyWith(id: id);
  }

  // ============= OPÉRATIONS CRUD SUR LES LAPINS =============

  /// Insérer un lapin dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Lapin> insertLapin(Lapin lapin) async {
    final db = await database;
    final map = await _prepareDataForInsert(lapin.toMap(), tableName: 'lapins');
    final id = await db.insert('lapins', map);
    return lapin.copyWith(id: id);
  }

  /// Récupérer tous les lapins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getAllLapins() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer un lapin par son ID
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  Future<Lapin?> getLapinById(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'lapins',
    );
    final maps = await db.query('lapins', where: where, whereArgs: whereArgs);

    if (maps.isNotEmpty) {
      return Lapin.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un lapin
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  /// Définit automatiquement updated_at
  Future<int> updateLapin(Lapin lapin) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final map = lapin.toMap();
    // Définir updated_at automatiquement (si colonne existe)
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    // Marquer comme dirty pour synchronisation (si colonne existe)
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'lapins');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [lapin.id],
      userId,
      tableName: 'lapins',
    );
    return db.update('lapins', filteredMap, where: where, whereArgs: whereArgs);
  }

  /// Supprimer un lapin
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  /// Utilise soft delete (is_deleted = 1) pour la synchronisation
  Future<int> deleteLapin(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    // Soft delete : marquer comme supprimé au lieu de supprimer réellement
    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'lapins');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'lapins',
    );
    return await db.update(
      'lapins',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les lapins par sexe
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getLapinsBySexe(String sexe) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'sexe = ?',
      [sexe],
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer les lapins par statut
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getLapinsByStatut(String statut) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'statut = ?',
      [statut],
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Compter le nombre total de lapins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<int> countLapins() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'lapins',
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM lapins WHERE $where',
      whereArgs.isEmpty ? null : whereArgs,
    );
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

  /// Calculer le coefficient de consanguinité selon l'algorithme de Wright
  /// F = Σ (1/2)^(n+1) * (1 + FA)
  /// où n = nombre de générations dans le chemin commun, FA = consanguinité de l'ancêtre commun
  Future<double> calculerConsanguinite(int lapinId) async {
    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    // Si pas de parents, pas de consanguinité
    if (pere == null || mere == null || pere.id == null || mere.id == null) {
      return 0.0;
    }

    // Si les parents sont les mêmes (impossible mais vérification)
    if (pere.id == mere.id) {
      return 1.0; // Consanguinité maximale
    }

    // Récupérer tous les ancêtres du père et de la mère (jusqu'à 5 générations pour précision)
    final ancetresPere = await _collecterTousAncetres(
      pere.id!,
      maxGenerations: 5,
    );
    final ancetresMere = await _collecterTousAncetres(
      mere.id!,
      maxGenerations: 5,
    );

    // Trouver les ancêtres communs
    final ancetresCommuns = ancetresPere.keys.toSet().intersection(
      ancetresMere.keys.toSet(),
    );

    if (ancetresCommuns.isEmpty) {
      return 0.0; // Pas d'ancêtres communs = pas de consanguinité
    }

    // Calculer le coefficient de consanguinité selon Wright
    double coefficientTotal = 0.0;

    for (final ancetreId in ancetresCommuns) {
      // Récupérer les chemins vers cet ancêtre commun depuis le père et la mère
      final cheminsPere = await _trouverCheminsVersAncetre(
        pere.id!,
        ancetreId,
        ancetresPere,
      );
      final cheminsMere = await _trouverCheminsVersAncetre(
        mere.id!,
        ancetreId,
        ancetresMere,
      );

      // Pour chaque combinaison de chemins
      for (final cheminPere in cheminsPere) {
        for (final cheminMere in cheminsMere) {
          // Longueur totale du chemin (père -> ancêtre + ancêtre -> mère)
          final longueurChemin = cheminPere.length + cheminMere.length;

          // Calculer la consanguinité de l'ancêtre commun (récursif)
          final consanguiniteAncetre = await calculerConsanguinite(ancetreId);

          // Formule de Wright : (1/2)^(n+1) * (1 + FA)
          final contribution =
              (1 / (1 << (longueurChemin + 1))) * (1 + consanguiniteAncetre);
          coefficientTotal += contribution;
        }
      }
    }

    return coefficientTotal.clamp(0.0, 1.0);
  }

  /// Collecter tous les ancêtres d'un lapin avec leur profondeur
  Future<Map<int, int>> _collecterTousAncetres(
    int lapinId, {
    int maxGenerations = 5,
    int profondeur = 0,
    Map<int, int>? resultat,
  }) async {
    resultat ??= {};
    if (profondeur >= maxGenerations) return resultat;

    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    if (pere != null && pere.id != null) {
      // Enregistrer l'ancêtre avec sa profondeur minimale
      if (!resultat.containsKey(pere.id!) ||
          resultat[pere.id]! > profondeur + 1) {
        resultat[pere.id!] = profondeur + 1;
      }
      await _collecterTousAncetres(
        pere.id!,
        maxGenerations: maxGenerations,
        profondeur: profondeur + 1,
        resultat: resultat,
      );
    }

    if (mere != null && mere.id != null) {
      if (!resultat.containsKey(mere.id!) ||
          resultat[mere.id]! > profondeur + 1) {
        resultat[mere.id!] = profondeur + 1;
      }
      await _collecterTousAncetres(
        mere.id!,
        maxGenerations: maxGenerations,
        profondeur: profondeur + 1,
        resultat: resultat,
      );
    }

    return resultat;
  }

  /// Trouver tous les chemins vers un ancêtre commun
  Future<List<List<int>>> _trouverCheminsVersAncetre(
    int lapinId,
    int ancetreId,
    Map<int, int> ancetres,
  ) async {
    if (lapinId == ancetreId) {
      return [[]]; // Chemin vide (on est déjà à l'ancêtre)
    }

    if (!ancetres.containsKey(ancetreId)) {
      return []; // Ancêtre non accessible depuis ce lapin
    }

    // Récupérer les parents de ce lapin
    return _trouverCheminsRecursif(lapinId, ancetreId, ancetres, {});
  }

  /// Trouver les chemins récursivement (avec protection contre les cycles)
  Future<List<List<int>>> _trouverCheminsRecursif(
    int lapinId,
    int ancetreId,
    Map<int, int> ancetres,
    Set<int> visite,
  ) async {
    if (lapinId == ancetreId) {
      return [[]];
    }

    if (visite.contains(lapinId)) {
      return []; // Cycle détecté
    }

    visite.add(lapinId);
    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    List<List<int>> chemins = [];

    if (pere != null && pere.id != null) {
      final cheminsPere = await _trouverCheminsRecursif(
        pere.id!,
        ancetreId,
        ancetres,
        Set.from(visite),
      );
      for (final chemin in cheminsPere) {
        chemins.add([pere.id!, ...chemin]);
      }
    }

    if (mere != null && mere.id != null) {
      final cheminsMere = await _trouverCheminsRecursif(
        mere.id!,
        ancetreId,
        ancetres,
        Set.from(visite),
      );
      for (final chemin in cheminsMere) {
        chemins.add([mere.id!, ...chemin]);
      }
    }

    return chemins;
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
  ///
  /// Définit automatiquement user_id si disponible
  Future<Accouplement> insertAccouplement(Accouplement accouplement) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      accouplement.toMap(),
      tableName: 'accouplements',
    );
    final id = await db.insert('accouplements', map);
    return accouplement.copyWith(id: id);
  }

  /// Récupérer tous les accouplements
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Accouplement>> getAllAccouplements() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'accouplements',
    );
    final result = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer un accouplement par son ID
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  Future<Accouplement?> getAccouplementById(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'accouplements',
    );
    final maps = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs,
    );

    if (maps.isNotEmpty) {
      return Accouplement.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un accouplement
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  /// Définit automatiquement updated_at et is_dirty
  Future<int> updateAccouplement(Accouplement accouplement) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final map = accouplement.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'accouplements');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [accouplement.id],
      userId,
      tableName: 'accouplements',
    );
    return db.update(
      'accouplements',
      filteredMap,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Supprimer un accouplement
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteAccouplement(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(
      updateData,
      'accouplements',
    );

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'accouplements',
    );
    return await db.update(
      'accouplements',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les accouplements par statut
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Accouplement>> getAccouplementsByStatut(String statut) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'statut = ?',
      [statut],
      userId,
      tableName: 'accouplements',
    );
    final result = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs,
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
  ///
  /// Définit automatiquement user_id si disponible
  Future<Portee> insertPortee(Portee portee) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      portee.toMap(),
      tableName: 'portees',
    );
    final id = await db.insert('portees', map);
    return portee.copyWith(id: id);
  }

  /// Récupérer toutes les portées
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Portee>> getAllPortees() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'portees',
    );
    final result = await db.query(
      'portees',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
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
    final map = portee.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'portees');

    return db.update(
      'portees',
      filteredMap,
      where: 'id = ?',
      whereArgs: [portee.id],
    );
  }

  /// Supprimer une portée
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deletePortee(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'portees');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'portees',
    );
    return await db.update(
      'portees',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES PESÉES =============

  /// Insérer une pesée dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Pesee> insertPesee(Pesee pesee) async {
    final db = await database;
    final map = await _prepareDataForInsert(pesee.toMap(), tableName: 'pesees');
    final id = await db.insert('pesees', map);
    return pesee.copyWith(id: id);
  }

  /// Récupérer toutes les pesées
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Pesee>> getAllPesees() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'pesees',
    );
    final result = await db.query(
      'pesees',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
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
    final map = pesee.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'pesees');

    return db.update(
      'pesees',
      filteredMap,
      where: 'id = ?',
      whereArgs: [pesee.id],
    );
  }

  /// Supprimer une pesée
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deletePesee(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'pesees');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'pesees',
    );
    return await db.update(
      'pesees',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les pesées par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Pesee>> getPeseesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'pesees',
    );
    final result = await db.query(
      'pesees',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES SOINS =============

  /// Insérer un soin dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Soin> insertSoin(Soin soin) async {
    final db = await database;
    final map = await _prepareDataForInsert(soin.toMap(), tableName: 'soins');
    final id = await db.insert('soins', map);
    return soin.copyWith(id: id);
  }

  /// Récupérer tous les soins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Soin>> getAllSoins() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'soins',
    );
    final result = await db.query(
      'soins',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
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
    final map = soin.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'soins');

    return db.update(
      'soins',
      filteredMap,
      where: 'id = ?',
      whereArgs: [soin.id],
    );
  }

  /// Supprimer un soin
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteSoin(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'soins');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'soins',
    );
    return await db.update(
      'soins',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les soins par période
  Future<List<Soin>> getSoinsByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES MÉDICAMENTS =============

  /// Récupérer tous les médicaments
  Future<List<Medicament>> getAllMedicaments() async {
    final db = await database;
    final result = await db.query('medicaments', orderBy: 'nom ASC');
    return result.map((json) => Medicament.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES ALIMENTS =============

  /// Récupérer tous les aliments
  Future<List<Aliment>> getAllAliments() async {
    final db = await database;
    final result = await db.query('aliments', orderBy: 'date_achat DESC');
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES DEPENSES =============

  /// Récupérer toutes les dépenses
  Future<List<Depense>> getAllDepenses() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'depenses',
    );
    final result = await db.query(
      'depenses',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  // ============= OPÉRATIONS CRUD SUR LES RECETTES =============

  /// Insérer une recette
  ///
  /// Définit automatiquement user_id si disponible
  Future<Recette> insertRecette(Recette recette) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      recette.toMap(),
      tableName: 'recettes',
    );
    final id = await db.insert('recettes', map);
    return recette.copyWith(id: id);
  }

  /// Récupérer toutes les recettes
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getAllRecettes() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getRecettesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par catégorie
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getRecettesByCategorie(String categorie) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'categorie = ?',
      [categorie],
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs,
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
    final map = recette.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'recettes');

    return db.update(
      'recettes',
      filteredMap,
      where: 'id = ?',
      whereArgs: [recette.id],
    );
  }

  /// Supprimer une recette
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteRecette(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'recettes');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'recettes',
    );
    return await db.update(
      'recettes',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES DÉPENSES =============

  /// Insérer une dépense
  ///
  /// Définit automatiquement user_id si disponible
  Future<Depense> insertDepense(Depense depense) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      depense.toMap(),
      tableName: 'depenses',
    );
    final id = await db.insert('depenses', map);
    return depense.copyWith(id: id);
  }

  /// Récupérer les dépenses par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Depense>> getDepensesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'depenses',
    );
    final result = await db.query(
      'depenses',
      where: where,
      whereArgs: whereArgs,
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
    final map = depense.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'depenses');

    return db.update(
      'depenses',
      filteredMap,
      where: 'id = ?',
      whereArgs: [depense.id],
    );
  }

  /// Supprimer une dépense
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteDepense(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'depenses');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'depenses',
    );
    return await db.update(
      'depenses',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES DÉCÈS =============

  /// Insérer un décès
  ///
  /// Définit automatiquement user_id si disponible
  Future<Deces> insertDeces(Deces deces) async {
    final db = await database;
    final map = await _prepareDataForInsert(deces.toMap(), tableName: 'deces');
    final id = await db.insert('deces', map);
    return deces.copyWith(id: id);
  }

  /// Récupérer tous les décès
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Deces>> getAllDeces() async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'deces',
    );
    final result = await db.query(
      'deces',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date_deces DESC',
    );
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
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Deces>> getDecesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final (where, whereArgs) = await _buildWhereWithUserId(
      'date_deces >= ? AND date_deces <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'deces',
    );
    final result = await db.query(
      'deces',
      where: where,
      whereArgs: whereArgs,
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
    final map = deces.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'deces');

    return db.update(
      'deces',
      filteredMap,
      where: 'id = ?',
      whereArgs: [deces.id],
    );
  }

  /// Supprimer un décès
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteDeces(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'deces');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'deces',
    );
    return await db.update(
      'deces',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES ALIMENTS =============

  /// Insérer un aliment
  ///
  /// Définit automatiquement user_id si disponible
  Future<Aliment> insertAliment(Aliment aliment) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      aliment.toMap(),
      tableName: 'aliments',
    );
    final id = await db.insert('aliments', map);
    return aliment.copyWith(id: id);
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
    final map = aliment.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(map, 'aliments');

    return db.update(
      'aliments',
      filteredMap,
      where: 'id = ?',
      whereArgs: [aliment.id],
    );
  }

  /// Supprimer un aliment
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteAliment(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(updateData, 'aliments');

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'aliments',
    );
    return await db.update(
      'aliments',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES DISTRIBUTIONS D'ALIMENTS =============

  /// Insérer une distribution d'aliment
  ///
  /// Définit automatiquement user_id si disponible
  Future<DistributionAliment> insertDistributionAliment(
    DistributionAliment distribution,
  ) async {
    final db = await database;
    final map = await _prepareDataForInsert(
      distribution.toMap(),
      tableName: 'distributions_aliment',
    );
    final id = await db.insert('distributions_aliment', map);
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
    final map = distribution.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await _filterColumnsForUpdate(
      map,
      'distributions_aliment',
    );

    return db.update(
      'distributions_aliment',
      filteredMap,
      where: 'id = ?',
      whereArgs: [distribution.id],
    );
  }

  /// Supprimer une distribution
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteDistributionAliment(int id) async {
    final db = await database;
    final userId = await _getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await _filterColumnsForUpdate(
      updateData,
      'distributions_aliment',
    );

    final (where, whereArgs) = await _buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'distributions_aliment',
    );
    return await db.update(
      'distributions_aliment',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES TÂCHES =============

  /// Insérer une tâche
  Future<Tache> insertTache(Tache tache) async {
    final db = await database;
    final map = tache.toMap();
    final id = await db.insert('taches', map);
    return tache.copyWith(id: id);
  }

  /// Récupérer toutes les tâches
  Future<List<Tache>> getAllTaches() async {
    final db = await database;
    final result = await db.query(
      'taches',
      orderBy: 'date_planification ASC, priorite DESC',
    );
    return result.map((json) => Tache.fromMap(json)).toList();
  }

  /// Récupérer les tâches par statut
  Future<List<Tache>> getTachesByStatut(String statut) async {
    final db = await database;
    final result = await db.query(
      'taches',
      where: 'statut = ?',
      whereArgs: [statut],
      orderBy: 'date_planification ASC, priorite DESC',
    );
    return result.map((json) => Tache.fromMap(json)).toList();
  }

  /// Récupérer les tâches par catégorie
  Future<List<Tache>> getTachesByCategorie(String categorie) async {
    final db = await database;
    final result = await db.query(
      'taches',
      where: 'categorie = ?',
      whereArgs: [categorie],
      orderBy: 'date_planification ASC, priorite DESC',
    );
    return result.map((json) => Tache.fromMap(json)).toList();
  }

  /// Récupérer les tâches d'un lapin
  Future<List<Tache>> getTachesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'taches',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date_planification ASC, priorite DESC',
    );
    return result.map((json) => Tache.fromMap(json)).toList();
  }

  /// Récupérer les tâches par période
  Future<List<Tache>> getTachesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.query(
      'taches',
      where: 'date_planification >= ? AND date_planification <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date_planification ASC, priorite DESC',
    );
    return result.map((json) => Tache.fromMap(json)).toList();
  }

  /// Récupérer les tâches pour aujourd'hui
  Future<List<Tache>> getTachesAujourdhui() async {
    final now = DateTime.now();
    final debut = DateTime(now.year, now.month, now.day);
    final fin = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getTachesByPeriode(debut, fin);
  }

  /// Récupérer les tâches pour cette semaine
  Future<List<Tache>> getTachesCetteSemaine() async {
    final now = DateTime.now();
    final debutSemaine = now.subtract(Duration(days: now.weekday - 1));
    final debut = DateTime(
      debutSemaine.year,
      debutSemaine.month,
      debutSemaine.day,
    );
    final finSemaine = debut.add(const Duration(days: 6));
    final fin = DateTime(
      finSemaine.year,
      finSemaine.month,
      finSemaine.day,
      23,
      59,
      59,
    );
    return getTachesByPeriode(debut, fin);
  }

  /// Récupérer une tâche par ID
  Future<Tache?> getTacheById(int id) async {
    final db = await database;
    final result = await db.query(
      'taches',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Tache.fromMap(result.first);
  }

  /// Mettre à jour une tâche
  Future<int> updateTache(Tache tache) async {
    final db = await database;
    final map = tache.toMap();
    map['date_modification'] = DateTime.now().toIso8601String();
    return db.update('taches', map, where: 'id = ?', whereArgs: [tache.id]);
  }

  /// Supprimer une tâche
  Future<int> deleteTache(int id) async {
    final db = await database;
    return db.delete('taches', where: 'id = ?', whereArgs: [id]);
  }

  /// Marquer une tâche comme terminée
  Future<int> marquerTacheTerminee(int id) async {
    final db = await database;
    return db.update(
      'taches',
      {
        'statut': 'terminee',
        'date_completion': DateTime.now().toIso8601String(),
        'date_modification': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============= GESTION DES UTILISATEURS =============

  /// Créer un nouvel utilisateur
  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  /// Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'nom ASC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  /// Récupérer un utilisateur par ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Récupérer un utilisateur par email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Récupérer les utilisateurs actifs
  Future<List<User>> getActiveUsers() async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'nom ASC',
    );
    return result.map((map) => User.fromMap(map)).toList();
  }

  /// Mettre à jour un utilisateur
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Supprimer un utilisateur (soft delete)
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.update(
      'users',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Activer un utilisateur
  Future<int> activateUser(int id) async {
    final db = await database;
    return await db.update(
      'users',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mettre à jour la dernière connexion d'un utilisateur
  Future<int> updateLastConnection(int userId) async {
    final db = await database;
    return await db.update(
      'users',
      {'derniere_connexion': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ============= GESTION DES LOGS D'ACTIONS =============

  /// Enregistrer une action utilisateur
  Future<int> logUserAction(UserActionLog log) async {
    final db = await database;
    return await db.insert('user_action_logs', log.toMap());
  }

  /// Récupérer les logs d'actions d'un utilisateur
  Future<List<UserActionLog>> getUserActionLogs(
    int userId, {
    int? limit,
  }) async {
    final db = await database;
    final result = await db.query(
      'user_action_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_action DESC',
      limit: limit,
    );
    return result.map((map) => UserActionLog.fromMap(map)).toList();
  }

  /// Récupérer tous les logs d'actions
  Future<List<UserActionLog>> getAllActionLogs({int? limit}) async {
    final db = await database;
    final result = await db.query(
      'user_action_logs',
      orderBy: 'date_action DESC',
      limit: limit,
    );
    return result.map((map) => UserActionLog.fromMap(map)).toList();
  }

  /// Récupérer les logs d'actions par type d'entité
  Future<List<UserActionLog>> getActionLogsByEntityType(
    String entityType, {
    int? limit,
  }) async {
    final db = await database;
    final result = await db.query(
      'user_action_logs',
      where: 'entity_type = ?',
      whereArgs: [entityType],
      orderBy: 'date_action DESC',
      limit: limit,
    );
    return result.map((map) => UserActionLog.fromMap(map)).toList();
  }

  /// Récupérer les logs d'actions par période
  Future<List<UserActionLog>> getActionLogsByPeriod(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final result = await db.query(
      'user_action_logs',
      where: 'date_action >= ? AND date_action <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date_action DESC',
    );
    return result.map((map) => UserActionLog.fromMap(map)).toList();
  }

  /// Supprimer les logs d'actions anciens (plus de X jours)
  Future<int> deleteOldActionLogs(int daysOld) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    return await db.delete(
      'user_action_logs',
      where: 'date_action < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES RITUELS =============

  /// Insérer un nouveau rituel
  Future<Rituel> insertRituel(Rituel rituel) async {
    final db = await database;

    // Convertir les actions en JSON
    final actionsJson = jsonEncode(
      rituel.actions.map((a) => a.toMap()).toList(),
    );

    final map = {
      'date': DateTime(
        rituel.date.year,
        rituel.date.month,
        rituel.date.day,
      ).toIso8601String(),
      'type': rituel.type.name,
      'actions': actionsJson,
      'date_creation': rituel.dateCreation.toIso8601String(),
      'date_completion': rituel.dateCompletion?.toIso8601String(),
    };

    final id = await db.insert('rituels', map);
    return rituel.copyWith(id: id);
  }

  /// Mettre à jour un rituel
  Future<int> updateRituel(Rituel rituel) async {
    final db = await database;

    // Convertir les actions en JSON
    final actionsJson = jsonEncode(
      rituel.actions.map((a) => a.toMap()).toList(),
    );

    final map = {
      'date': DateTime(
        rituel.date.year,
        rituel.date.month,
        rituel.date.day,
      ).toIso8601String(),
      'type': rituel.type.name,
      'actions': actionsJson,
      'date_creation': rituel.dateCreation.toIso8601String(),
      'date_completion': rituel.dateCompletion?.toIso8601String(),
    };

    return db.update('rituels', map, where: 'id = ?', whereArgs: [rituel.id]);
  }

  /// Récupérer un rituel par date et type
  Future<Rituel?> getRituelByDateAndType(DateTime date, String type) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();

    final result = await db.query(
      'rituels',
      where: 'date = ? AND type = ?',
      whereArgs: [dateStr, type],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final map = result.first;
    final actionsJson = map['actions'] as String;
    final actionsList = (jsonDecode(actionsJson) as List)
        .map((a) => ActionRituel.fromMap(a as Map<String, dynamic>))
        .toList();

    return Rituel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      type: TypeRituel.values.firstWhere((e) => e.name == map['type']),
      actions: actionsList,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateCompletion: map['date_completion'] != null
          ? DateTime.parse(map['date_completion'] as String)
          : null,
    );
  }

  /// Récupérer l'historique des rituels
  Future<List<Rituel>> getHistoriqueRituels({int limite = 14}) async {
    final db = await database;

    final result = await db.query(
      'rituels',
      orderBy: 'date DESC, type ASC',
      limit: limite,
    );

    return result.map((map) {
      final actionsJson = map['actions'] as String;
      final actionsList = (jsonDecode(actionsJson) as List)
          .map((a) => ActionRituel.fromMap(a as Map<String, dynamic>))
          .toList();

      return Rituel(
        id: map['id'] as int?,
        date: DateTime.parse(map['date'] as String),
        type: TypeRituel.values.firstWhere((e) => e.name == map['type']),
        actions: actionsList,
        dateCreation: DateTime.parse(map['date_creation'] as String),
        dateCompletion: map['date_completion'] != null
            ? DateTime.parse(map['date_completion'] as String)
            : null,
      );
    }).toList();
  }

  /// Supprimer un rituel
  Future<int> deleteRituel(int id) async {
    final db = await database;
    return db.delete('rituels', where: 'id = ?', whereArgs: [id]);
  }

  /// Supprimer les rituels anciens (plus de X jours)
  Future<int> deleteOldRituels(int daysOld) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    return await db.delete(
      'rituels',
      where: 'date < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // ============= MÉTHODES ANOMALIES RITUELS =============

  /// Insérer une nouvelle anomalie de rituel
  Future<int> insertAnomalieRituel(AnomalieRituel anomalie) async {
    final db = await database;
    return await db.insert('anomalies_rituels', anomalie.toMap());
  }

  /// Mettre à jour une anomalie
  Future<int> updateAnomalieRituel(AnomalieRituel anomalie) async {
    final db = await database;
    return await db.update(
      'anomalies_rituels',
      anomalie.toMap(),
      where: 'id = ?',
      whereArgs: [anomalie.id],
    );
  }

  /// Récupérer une anomalie par ID
  Future<AnomalieRituel?> getAnomalieRituelById(int id) async {
    final db = await database;
    final result = await db.query(
      'anomalies_rituels',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return AnomalieRituel.fromMap(result.first);
  }

  /// Récupérer les anomalies du jour
  Future<List<AnomalieRituel>> getAnomaliesAujourdhui() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final dateStr = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    ).toIso8601String().substring(0, 10);

    final result = await db.query(
      'anomalies_rituels',
      where: 'date_observation LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'date_observation DESC',
    );
    return result.map((m) => AnomalieRituel.fromMap(m)).toList();
  }

  /// Récupérer les anomalies non résolues
  Future<List<AnomalieRituel>> getAnomaliesNonResolues() async {
    final db = await database;
    final result = await db.query(
      'anomalies_rituels',
      where: 'statut IN (?, ?)',
      whereArgs: ['nouveau', 'enCours'],
      orderBy: 'severite DESC, date_observation DESC',
    );
    return result.map((m) => AnomalieRituel.fromMap(m)).toList();
  }

  /// Récupérer les anomalies critiques (sévérité 3)
  Future<List<AnomalieRituel>> getAnomaliesCritiques() async {
    final db = await database;
    final result = await db.query(
      'anomalies_rituels',
      where: 'severite = 3 AND statut IN (?, ?)',
      whereArgs: ['nouveau', 'enCours'],
      orderBy: 'date_observation DESC',
    );
    return result.map((m) => AnomalieRituel.fromMap(m)).toList();
  }

  /// Récupérer l'historique des anomalies (avec pagination)
  Future<List<AnomalieRituel>> getHistoriqueAnomalies({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final result = await db.query(
      'anomalies_rituels',
      orderBy: 'date_observation DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((m) => AnomalieRituel.fromMap(m)).toList();
  }

  /// Récupérer les anomalies pour un lapin spécifique
  Future<List<AnomalieRituel>> getAnomaliesPourLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'anomalies_rituels',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date_observation DESC',
    );
    return result.map((m) => AnomalieRituel.fromMap(m)).toList();
  }

  /// Marquer une anomalie comme résolue
  Future<int> resoudreAnomalie(int id, {ActionSuggeree? actionPrise}) async {
    final db = await database;
    return await db.update(
      'anomalies_rituels',
      {
        'statut': 'resolu',
        'action_prise': actionPrise?.name,
        'date_resolution': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mettre à jour le statut d'une anomalie
  Future<int> updateStatutAnomalie(int id, StatutAnomalie statut) async {
    final db = await database;
    return await db.update(
      'anomalies_rituels',
      {'statut': statut.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprimer une anomalie
  Future<int> deleteAnomalieRituel(int id) async {
    final db = await database;
    return await db.delete(
      'anomalies_rituels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Compter les anomalies par statut
  Future<Map<String, int>> countAnomaliesParStatut() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT statut, COUNT(*) as count 
      FROM anomalies_rituels 
      GROUP BY statut
    ''');

    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['statut'] as String] = row['count'] as int;
    }
    return counts;
  }

  /// Statistiques des anomalies sur une période
  Future<StatsAnomalies> getStatsAnomalies() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final debutSemaine = aujourdhui.subtract(const Duration(days: 7));
    final dateAujourdhui = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    ).toIso8601String().substring(0, 10);

    // Total aujourd'hui
    final countAujourdhui = await db.rawQuery('''
      SELECT COUNT(*) as count FROM anomalies_rituels 
      WHERE date_observation LIKE '$dateAujourdhui%'
    ''');
    final totalAujourdhui = (countAujourdhui.first['count'] as int?) ?? 0;

    // Total semaine
    final countSemaine = await db.rawQuery('''
      SELECT COUNT(*) as count FROM anomalies_rituels 
      WHERE date_observation >= '${debutSemaine.toIso8601String()}'
    ''');
    final totalSemaine = (countSemaine.first['count'] as int?) ?? 0;

    // Non résolues
    final countNonResolues = await db.rawQuery('''
      SELECT COUNT(*) as count FROM anomalies_rituels 
      WHERE statut IN ('nouveau', 'enCours')
    ''');
    final nonResolues = (countNonResolues.first['count'] as int?) ?? 0;

    // Critiques
    final countCritiques = await db.rawQuery('''
      SELECT COUNT(*) as count FROM anomalies_rituels 
      WHERE severite = 3 AND statut IN ('nouveau', 'enCours')
    ''');
    final critiques = (countCritiques.first['count'] as int?) ?? 0;

    return StatsAnomalies(
      totalAujourdhui: totalAujourdhui,
      totalSemaine: totalSemaine,
      nonResolues: nonResolues,
      critiques: critiques,
      parType: {},
      parPortee: {},
    );
  }

  // ============= MÉTHODES JOURNAL AUTOMATIQUE =============
  // L'utilisateur agit, l'app écrit.

  /// Insérer une entrée de journal (automatique)
  Future<int> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    final id = await db.insert('journal_automatique', entry.toMap());
    logger.debug('📝 Journal: ${entry.resumeComplet}');
    return id;
  }

  /// Mettre à jour une entrée de journal (note utilisateur)
  Future<void> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    await db.update(
      'journal_automatique',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Obtenir les entrées du journal pour aujourd'hui
  Future<List<JournalEntry>> getJournalAujourdhui() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final dateStr = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    ).toIso8601String().substring(0, 10);

    final result = await db.query(
      'journal_automatique',
      where: 'timestamp LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir les entrées du journal pour une semaine
  Future<List<JournalEntry>> getJournalSemaine() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final debutSemaine = aujourdhui.subtract(const Duration(days: 7));

    final result = await db.query(
      'journal_automatique',
      where: 'timestamp >= ?',
      whereArgs: [debutSemaine.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir les entrées du journal pour un mois
  Future<List<JournalEntry>> getJournalMois() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final debutMois = DateTime(
      aujourdhui.year,
      aujourdhui.month - 1,
      aujourdhui.day,
    );

    final result = await db.query(
      'journal_automatique',
      where: 'timestamp >= ?',
      whereArgs: [debutMois.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir les entrées du journal entre deux dates
  Future<List<JournalEntry>> getJournalPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final result = await db.query(
      'journal_automatique',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir les entrées non lues
  Future<List<JournalEntry>> getJournalNonLu() async {
    final db = await database;
    final result = await db.query(
      'journal_automatique',
      where: 'lu = 0',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir les entrées par type d'entité
  Future<List<JournalEntry>> getJournalParEntite(TypeEntite type) async {
    final db = await database;
    final result = await db.query(
      'journal_automatique',
      where: 'type_entite = ?',
      whereArgs: [type.name],
      orderBy: 'timestamp DESC',
      limit: 100,
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Obtenir l'historique d'une entité spécifique
  Future<List<JournalEntry>> getHistoriqueEntite(
    TypeEntite type,
    int entiteId,
  ) async {
    final db = await database;
    final result = await db.query(
      'journal_automatique',
      where: 'type_entite = ? AND entite_id = ?',
      whereArgs: [type.name, entiteId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// Marquer une entrée comme lue
  Future<void> marquerJournalLu(int id) async {
    final db = await database;
    await db.update(
      'journal_automatique',
      {'lu': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marquer toutes les entrées comme lues
  Future<void> marquerToutLu() async {
    final db = await database;
    await db.update('journal_automatique', {'lu': 1});
  }

  /// Ajouter une note utilisateur à une entrée
  Future<void> ajouterNoteJournal(int id, String note) async {
    final db = await database;
    await db.update(
      'journal_automatique',
      {'note_utilisateur': note},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Compter les entrées non lues
  Future<int> countJournalNonLu() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM journal_automatique WHERE lu = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Statistiques du journal
  Future<Map<String, dynamic>> getStatsJournal() async {
    final db = await database;
    final aujourdhui = DateTime.now();
    final dateAujourdhui = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    ).toIso8601String().substring(0, 10);
    final debutSemaine = aujourdhui.subtract(const Duration(days: 7));

    // Total aujourd'hui
    final countAujourdhui = await db.rawQuery(
      "SELECT COUNT(*) as count FROM journal_automatique WHERE timestamp LIKE '$dateAujourdhui%'",
    );

    // Total semaine
    final countSemaine = await db.rawQuery(
      "SELECT COUNT(*) as count FROM journal_automatique WHERE timestamp >= '${debutSemaine.toIso8601String()}'",
    );

    // Non lus
    final countNonLus = await db.rawQuery(
      'SELECT COUNT(*) as count FROM journal_automatique WHERE lu = 0',
    );

    // Anomalies aujourd'hui
    final countAnomalies = await db.rawQuery(
      "SELECT COUNT(*) as count FROM journal_automatique WHERE statut = 'anomalie' AND timestamp LIKE '$dateAujourdhui%'",
    );

    return {
      'aujourdhui': (countAujourdhui.first['count'] as int?) ?? 0,
      'semaine': (countSemaine.first['count'] as int?) ?? 0,
      'nonLus': (countNonLus.first['count'] as int?) ?? 0,
      'anomaliesAujourdhui': (countAnomalies.first['count'] as int?) ?? 0,
    };
  }

  /// Supprimer les entrées anciennes (archivage)
  Future<int> archiverJournalAncien(int joursConservation) async {
    final db = await database;
    final limite = DateTime.now().subtract(Duration(days: joursConservation));
    return await db.delete(
      'journal_automatique',
      where: 'timestamp < ?',
      whereArgs: [limite.toIso8601String()],
    );
  }
}
