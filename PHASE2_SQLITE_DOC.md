# 📝 Phase 2 : Introduction de SQLite - Documentation

## ✅ Ce qui a été implémenté

### 1. Packages ajoutés
- `sqflite: ^2.3.0` - Base de données SQLite pour Flutter
- `path_provider: ^2.1.0` - Accès aux chemins système
- `path: ^1.8.3` - Manipulation de chemins de fichiers

### 2. Service DatabaseHelper
**Fichier** : `lib/services/database_helper.dart`

#### Fonctionnalités :
- **Singleton pattern** : Une seule instance de la base de données
- **Table `lapins`** avec colonnes :
  - `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
  - `nom` (TEXT NOT NULL)
  - `race` (TEXT NOT NULL)
  - `sexe` (TEXT NOT NULL)
  - `date_naissance` (TEXT NOT NULL)
  - `poids` (REAL, nullable)
  - `statut` (TEXT, nullable)
  - `localisation` (TEXT, nullable)
  - `photo_path` (TEXT, nullable)

#### Méthodes CRUD :
- `insertLapin(Lapin)` - Insérer un lapin
- `getAllLapins()` - Récupérer tous les lapins
- `getLapinById(int)` - Récupérer un lapin par ID
- `updateLapin(Lapin)` - Mettre à jour un lapin
- `deleteLapin(int)` - Supprimer un lapin
- `getLapinsBySexe(String)` - Filtrer par sexe
- `getLapinsByStatut(String)` - Filtrer par statut
- `countLapins()` - Compter les lapins

### 3. LapinProvider mis à jour
**Fichier** : `lib/providers/lapin_provider.dart`

#### Changements majeurs :
- ✅ Remplacement de la liste en mémoire par SQLite
- ✅ Méthodes asynchrones avec `async`/`await`
- ✅ Gestion du chargement avec `isLoading`
- ✅ Initialisation automatique des données de test (si BDD vide)
- ✅ Persistance des données

#### Nouvelles méthodes :
- `chargerLapins()` - Charger depuis la BDD
- `initialiserDonneesTest()` - Ajouter lapins de test si BDD vide
- Toutes les méthodes CRUD sont maintenant asynchrones

### 4. AddLapinScreen mis à jour
**Fichier** : `lib/screens/cheptel/add_lapin_screen.dart`

#### Changements :
- ✅ `_enregistrerLapin()` est maintenant asynchrone
- ✅ Indicateur de chargement lors de l'enregistrement
- ✅ Gestion des erreurs avec try/catch
- ✅ Messages de confirmation/erreur appropriés

### 5. main.dart mis à jour
**Fichier** : `lib/main.dart`

#### Changements :
- ✅ `main()` est maintenant asynchrone
- ✅ `WidgetsFlutterBinding.ensureInitialized()` ajouté
- ✅ Initialisation des données de test au démarrage

## 🎯 Fonctionnalités

### Persistance des données
- ✅ Les lapins ajoutés sont sauvegardés dans SQLite
- ✅ Les données persistent après redémarrage de l'app
- ✅ 5 lapins de test ajoutés automatiquement au premier lancement
- ✅ Les lapins de test ne sont PAS réajoutés à chaque démarrage

### Opérations disponibles
- ✅ Ajouter un lapin → Sauvegardé en BDD
- ✅ Afficher les lapins → Chargés depuis la BDD
- ⏳ Modifier un lapin (fonctionnalité à implémenter dans une phase future)
- ⏳ Supprimer un lapin (fonctionnalité à implémenter dans une phase future)

## 🧪 Comment tester

### Test 1 : Persistance des données
1. Lancez l'application : `flutter run`
2. Vérifiez que les 5 lapins de test sont présents
3. Ajoutez un nouveau lapin (ex: "Calin", race "Rex", etc.)
4. **Fermez complètement l'application** (pas juste retour en arrière)
5. Relancez l'application
6. ✅ Vérifiez que votre lapin "Calin" est toujours présent !

### Test 2 : Ajout de multiples lapins
1. Ajoutez 3 lapins différents
2. Vérifiez qu'ils apparaissent tous dans la liste
3. Redémarrez l'app
4. ✅ Les 8 lapins doivent être présents (5 de test + 3 ajoutés)

### Test 3 : Données de test
1. Si vous voulez réinitialiser la BDD, désinstallez l'app et réinstallez-la
2. Au premier lancement, les 5 lapins de test doivent réapparaître
3. Aux lancements suivants, ils ne sont pas dupliqués

## 📂 Emplacement de la base de données

La base de données est stockée dans :
- **Android** : `/data/data/com.example.rabbit_farm_app/databases/mon_elevage_lapins.db`
- **iOS** : `Library/Application Support/mon_elevage_lapins.db`

## ⚠️ Points importants

### Migrations de schéma
Pour l'instant, nous sommes à la **version 1** du schéma.
Lors de futures phases (ajout de tables relations, portées, etc.), il faudra :
1. Incrémenter `version` dans `openDatabase()`
2. Implémenter `onUpgrade` pour migrer les données

### Performance
- Les requêtes sont asynchrones (ne bloquent pas l'UI)
- La liste est mise en cache dans le Provider
- `chargerLapins()` est appelé après chaque modification

### Gestion d'erreurs
- Tous les `print()` d'erreurs devraient être remplacés par un vrai système de logging en production
- Les erreurs sont capturées mais l'app ne plante pas

## 🚀 Prochaines étapes (Phase 3)

- Ajouter une table `relations` pour la généalogie
- Lier les lapins parents-enfants
- Afficher l'arbre généalogique
- Calculer la consanguinité

## 📊 État de la roadmap

- [x] Phase 0 : Configuration
- [x] Phase 1 : Interface de base
- [x] Phase 2 : SQLite ← **VOUS ÊTES ICI**
- [ ] Phase 3 : Généalogie
- [ ] Phase 4 : Reproduction
- [ ] Phase 5 : Santé
- [ ] Phase 6 : Finances
- [ ] Phase 7 : Notifications
- [ ] Phase 8 : Exports PDF
- [ ] Phase 9 : Photos et UI
- [ ] Phase 10 : Finalisation

---

**Date de complétion** : 13 novembre 2025  
**Développé avec** : Flutter 3.x + SQLite (sqflite)
