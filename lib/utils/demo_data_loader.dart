import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Script d'injection de données de démonstration
/// Exécuter depuis l'application : DemoDataLoader.chargerDonnees()
class DemoDataLoader {
  static Future<void> chargerDonnees() async {
    final db = await DatabaseHelper.instance.database;
    logger.info('🎬 Début injection données SQL...');

    try {
      await db.transaction((txn) async {
        // ============================================
        // 1. INFRASTRUCTURE
        // ============================================

        // Bâtiments
        await txn.rawInsert('''
          INSERT OR IGNORE INTO batiments (id, nom, description, date_creation) VALUES
          (1, 'Bâtiment A - Reproducteurs', 'Bâtiment principal', '2024-01-01 10:00:00'),
          (2, 'Bâtiment B - Engraissement', 'Jeunes et engraissement', '2024-06-01 10:00:00')
        ''');

        // Clapiers
        await txn.rawInsert('''
          INSERT OR IGNORE INTO clapiers (id, batiment_id, nom, type, description, date_creation) VALUES
          (1, 1, 'Clapier 1', 'reproducteur', 'Clapier reproducteurs', '2024-01-01 10:30:00'),
          (2, 1, 'Clapier 2', 'reproducteur', 'Clapier reproducteurs', '2024-01-01 10:30:00'),
          (3, 2, 'Clapier 1', 'engraissement', 'Clapier engraissement', '2024-06-01 10:30:00')
        ''');

        // Cages
        for (int i = 1; i <= 5; i++) {
          await txn.rawInsert('''
            INSERT OR IGNORE INTO cages (id, clapier_id, numero, type, capacite, description, date_creation) VALUES
            ($i, 1, 'A1C$i', 'individuelle', 1, 'Cage individuelle', '2024-01-01 11:00:00')
          ''');
        }
        for (int i = 6; i <= 10; i++) {
          await txn.rawInsert('''
            INSERT OR IGNORE INTO cages (id, clapier_id, numero, type, capacite, description, date_creation) VALUES
            ($i, 2, 'A2C${i - 5}', 'individuelle', 1, 'Cage individuelle', '2024-01-01 11:00:00')
          ''');
        }
        for (int i = 11; i <= 13; i++) {
          await txn.rawInsert('''
            INSERT OR IGNORE INTO cages (id, clapier_id, numero, type, capacite, description, date_creation) VALUES
            ($i, 3, 'B1C${i - 10}', 'collective', 8, 'Cage collective', '2024-06-01 11:00:00')
          ''');
        }

        logger.info('✓ Infrastructure créée');

        // ============================================
        // 2. MÉDICAMENTS
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO medicaments (id, nom, type, quantite_stock, unite, seuil_alerte, date_expiration, prix_unitaire, posologie, notes) VALUES
          (1, 'Baycox', 'antiparasitaire', 180, 'ml', 30, '2026-12-31', 0.15, '0.4 ml/L pendant 2j', 'Conservation au frais'),
          (2, 'Nobivac Myxo', 'vaccin', 25, 'dose', 5, '2026-06-30', 2.50, '1 dose/lapin, rappel annuel', NULL),
          (3, 'Filavac VHD', 'vaccin', 30, 'dose', 5, '2027-01-31', 3.20, '1 dose/lapin, rappel 6 mois', NULL),
          (4, 'Ronaxan', 'antibiotique', 50, 'comprime', 10, '2026-07-15', 0.85, '1 cp/kg/jour 5j', NULL)
        ''');

        logger.info('✓ Médicaments créés');

        // ============================================
        // 3. LAPINS
        // ============================================

        // Mâles reproducteurs
        await txn.rawInsert('''
          INSERT OR IGNORE INTO lapins (id, nom, race, sexe, date_naissance, poids, statut, localisation, numero_identification, couleur, prix_achat, origine, notes) VALUES
          (1, 'Thor', 'Géant des Flandres', 'Mâle', '2023-03-15', 5.8, 'Reproducteur', 'A1C1', 'M1001', 'Gris', 45.00, 'Achat', 'Reproducteur actif'),
          (2, 'Zeus', 'Californien', 'Mâle', '2023-06-20', 5.2, 'Reproducteur', 'A1C2', 'M1002', 'Blanc', 40.00, 'Achat', 'Lignée performante'),
          (3, 'Apollo', 'Néo-Zélandais', 'Mâle', '2024-01-10', 4.9, 'Reproducteur', 'A1C3', 'M1003', 'Blanc', 42.00, 'Achat', 'Jeune reproducteur')
        ''');

        // Femelles reproductrices
        await txn.rawInsert('''
          INSERT OR IGNORE INTO lapins (id, nom, race, sexe, date_naissance, poids, statut, localisation, numero_identification, couleur, prix_achat, origine, notes) VALUES
          (4, 'Luna', 'Géant des Flandres', 'Femelle', '2023-04-10', 5.2, 'Reproducteur', 'A1C4', 'F2001', 'Gris', 48.00, 'Achat', 'Excellente mère'),
          (5, 'Bella', 'Californien', 'Femelle', '2023-05-22', 4.8, 'Reproducteur', 'A1C5', 'F2002', 'Blanc', 45.00, 'Achat', 'Reproductrice fiable'),
          (6, 'Daisy', 'Néo-Zélandais', 'Femelle', '2023-07-15', 4.5, 'Reproducteur', 'A2C1', 'F2003', 'Blanc', 43.00, 'Achat', 'Bonne productivité'),
          (7, 'Flora', 'Bélier Français', 'Femelle', '2023-08-01', 4.3, 'Reproducteur', 'A2C2', 'F2004', 'Fauve', 50.00, 'Achat', 'Caractère calme'),
          (8, 'Ruby', 'Californien', 'Femelle', '2024-02-14', 4.1, 'Reproducteur', 'A2C3', 'F2005', 'Blanc', 42.00, 'Achat', 'Jeune reproductrice')
        ''');

        // Jeunes
        await txn.rawInsert('''
          INSERT OR IGNORE INTO lapins (id, nom, race, sexe, date_naissance, poids, statut, localisation, origine) VALUES
          (11, 'Luna - Lapereau 1', 'Géant des Flandres', 'Mâle', '2025-10-15', 2.8, 'Jeune', 'B1C1', 'Naissance sur place'),
          (12, 'Luna - Lapereau 2', 'Géant des Flandres', 'Femelle', '2025-10-15', 2.6, 'Jeune', 'B1C1', 'Naissance sur place'),
          (13, 'Bella - Lapereau 1', 'Californien', 'Femelle', '2025-11-01', 2.5, 'Jeune', 'B1C1', 'Naissance sur place'),
          (14, 'Bella - Lapereau 2', 'Californien', 'Mâle', '2025-11-01', 2.4, 'Jeune', 'B1C1', 'Naissance sur place'),
          (15, 'Daisy - Lapereau 1', 'Néo-Zélandais', 'Mâle', '2025-11-10', 2.3, 'Jeune', 'B1C2', 'Naissance sur place'),
          (16, 'Daisy - Lapereau 2', 'Néo-Zélandais', 'Femelle', '2025-11-10', 2.2, 'Jeune', 'B1C2', 'Naissance sur place'),
          (17, 'Ruby - Lapereau 1', 'Californien', 'Femelle', '2025-12-01', 1.8, 'Jeune', 'B1C3', 'Naissance sur place'),
          (18, 'Ruby - Lapereau 2', 'Californien', 'Mâle', '2025-12-01', 1.7, 'Jeune', 'B1C3', 'Naissance sur place')
        ''');

        // Relations généalogiques
        await txn.rawInsert('''
          INSERT OR IGNORE INTO relations (lapin_id, pere_id, mere_id) VALUES
          (11, 1, 4), (12, 1, 4),
          (13, 2, 5), (14, 2, 5),
          (15, 1, 6), (16, 1, 6),
          (17, 2, 8), (18, 2, 8)
        ''');

        logger.info('✓ ${8} lapins reproducteurs + ${8} jeunes créés');

        // ============================================
        // 4. PESÉES
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO pesees (lapin_id, date, poids, notes) VALUES
          (1, '2025-06-01', 5.5, NULL),
          (1, '2025-12-01', 5.8, 'Poids stable'),
          (2, '2025-09-01', 5.1, NULL),
          (4, '2025-07-01', 5.3, 'Gestation'),
          (4, '2025-12-15', 5.2, NULL),
          (5, '2025-10-01', 5.0, 'Gestation'),
          (11, '2025-11-20', 1.2, 'Sevrage'),
          (11, '2025-12-20', 2.8, 'Croissance'),
          (13, '2025-12-05', 1.0, 'Sevrage'),
          (13, '2026-01-05', 2.5, 'Croissance')
        ''');

        logger.info('✓ Pesées créées');

        // ============================================
        // 5. SOINS
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO soins (lapin_id, date, type, description, medicament, dosage, date_rappel, notes) VALUES
          (1, '2025-03-15', 'vaccination', 'Vaccination Myxomatose', 'Nobivac Myxo', '1 dose', '2026-03-15', 'Vaccination annuelle'),
          (2, '2025-06-20', 'vaccination', 'Vaccination complète', 'Nobivac Myxo', '1 dose', '2026-06-20', NULL),
          (4, '2025-04-10', 'vaccination', 'Vaccination Myxomatose', 'Nobivac Myxo', '1 dose', '2026-04-10', NULL),
          (1, '2025-07-01', 'vermifuge', 'Cure préventive', 'Baycox', '0.4 ml/L 2j', NULL, 'Préventif'),
          (5, '2025-11-05', 'traitement', 'Infection respiratoire', 'Ronaxan', '1 cp/jour 5j', NULL, 'Guérison complète')
        ''');

        logger.info('✓ Soins créés');

        // ============================================
        // 6. ACCOUPLEMENTS
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO accouplements (id, male_id, femelle_id, date_accouplement, date_mise_bas_prevue, statut, notes) VALUES
          (1, 1, 4, '2025-09-15', '2025-10-16', 'termine', 'Portée réussie'),
          (2, 2, 5, '2025-10-01', '2025-11-01', 'termine', 'Bonne portée'),
          (3, 1, 6, '2025-10-10', '2025-11-10', 'termine', 'Portée moyenne'),
          (4, 2, 8, '2025-11-01', '2025-12-02', 'termine', 'Portée correcte'),
          (5, 2, 4, '2025-12-15', '2026-01-15', 'confirme', 'Gestation en cours'),
          (6, 1, 5, '2025-12-20', '2026-01-20', 'en_attente', 'Palpation prévue')
        ''');

        // Palpations
        await txn.rawInsert('''
          INSERT OR IGNORE INTO palpations (accouplement_id, date_palpation, resultat, nombre_foetus_estimes, observations) VALUES
          (1, '2025-09-26', 'positive', 8, 'Gestation confirmée'),
          (2, '2025-10-12', 'positive', 7, 'Bonne gestation'),
          (3, '2025-10-21', 'positive', 6, 'Gestation confirmée'),
          (4, '2025-11-12', 'positive', 6, 'Gestation normale'),
          (5, '2025-12-26', 'positive', 8, 'Gestation confirmée')
        ''');

        // Préparations nid
        await txn.rawInsert('''
          INSERT OR IGNORE INTO preparations_nid (accouplement_id, date_preparation, type_materiau, quantite_materiau, boite_nid_installee, disposition_nid, observations) VALUES
          (1, '2025-10-13', 'Foin, paille', 2.0, 1, 'coin gauche', 'Nid bien préparé'),
          (2, '2025-10-29', 'Foin, poils', 1.5, 1, 'centre', 'Préparation correcte'),
          (3, '2025-11-07', 'Foin, paille', 2.5, 1, 'coin droit', 'Très bon nid'),
          (4, '2025-11-29', 'Foin, paille, poils', 3.0, 1, 'coin gauche', 'Excellente préparation')
        ''');

        // Portées
        await txn.rawInsert('''
          INSERT OR IGNORE INTO portees (id, accouplement_id, date_mise_bas_reelle, nombre_nes, nombre_vivants, nombre_morts, notes) VALUES
          (1, 1, '2025-10-16', 8, 8, 0, 'Tous vivants'),
          (2, 2, '2025-11-02', 7, 7, 0, 'Bonne santé'),
          (3, 3, '2025-11-11', 6, 6, 0, 'Sans problème'),
          (4, 4, '2025-12-02', 6, 6, 0, 'Bonne portée')
        ''');

        // Sevrages
        await txn.rawInsert('''
          INSERT OR IGNORE INTO sevrages (portee_id, date_sevrage, nombre_lapereaux, poids_moyen_sevrage, nouvelle_cage, observations, alimentation_post_sevrage) VALUES
          (1, '2025-11-20', 8, 0.85, 'B1C1', 'Sevrage réussi', 'Granulés croissance + foin'),
          (2, '2025-12-07', 7, 0.78, 'B1C1/B1C2', 'Bon développement', 'Granulés croissance')
        ''');

        logger.info('✓ Reproduction complète créée');

        // ============================================
        // 7. FINANCES
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO depenses (date, categorie, montant, description) VALUES
          ('2025-01-15', 'alimentation', 85.00, 'Sac granulés 50kg'),
          ('2025-02-10', 'veterinaire', 35.00, 'Vaccins'),
          ('2025-04-20', 'equipement', 150.00, 'Cages neuves'),
          ('2025-06-10', 'veterinaire', 28.00, 'Médicaments'),
          ('2025-09-10', 'alimentation', 95.00, 'Stock granulés'),
          ('2025-11-15', 'alimentation', 88.00, 'Granulés croissance')
        ''');

        await txn.rawInsert('''
          INSERT OR IGNORE INTO recettes (date, categorie, montant, description) VALUES
          ('2025-08-15', 'vente_lapin', 35.00, 'Vente lapin 2.8kg'),
          ('2025-10-10', 'vente_lapin', 42.00, 'Vente reproducteur réformé'),
          ('2025-12-15', 'vente_lapin', 36.00, 'Vente lapin 3.0kg')
        ''');

        logger.info('✓ Finances créées');

        // ============================================
        // 8. TÂCHES
        // ============================================

        await txn.rawInsert('''
          INSERT OR IGNORE INTO taches (titre, description, date_planification, priorite, categorie, statut, est_recurrente, frequence_recurrence, date_creation) VALUES
          ('Vaccination reproducteurs', 'Vacciner contre myxomatose', '2026-03-15', 'haute', 'sante', 'a_faire', 1, 'annuelle', '2025-12-01'),
          ('Contrôle poids jeunes', 'Peser jeunes < 3 mois', '2026-01-08', 'normale', 'sante', 'a_faire', 1, 'hebdomadaire', '2025-12-20'),
          ('Commande aliment', 'Stock faible', '2026-01-10', 'haute', 'alimentation', 'a_faire', 0, NULL, '2025-12-30')
        ''');

        logger.info('✓ Tâches créées');
      });

      logger.info('✅ Injection terminée avec succès !');
      logger.info(
        '📊 Données : 16 lapins, 6 accouplements, 4 portées, 9 transactions',
      );
    } catch (e, stackTrace) {
      logger.error('❌ Erreur injection : $e');
      logger.error('Stack: $stackTrace');
      rethrow;
    }
  }
}
