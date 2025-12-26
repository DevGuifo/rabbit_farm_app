# 📋 TODO - Fonctionnalités manquantes à implémenter

**Date de création :** ${new Date().toLocaleDateString('fr-FR')}  
**État du projet :** Phase 4 complétée (6/6 modules) - Score 9.0/10  
**Audit :** Parcours complet de l'application effectué

---

## 🎯 Résumé Exécutif

### ✅ Ce qui fonctionne
- **Backend CRUD complet** : DatabaseHelper avec toutes méthodes update*/delete*
- **Providers opérationnels** : Toutes méthodes modifier*/supprimer* implémentées
- **Écrans création** : Tous les add_*_screen.dart fonctionnels
- **Écrans consultation** : Tous les *_detail_screen.dart et fiche_*_screen.dart opérationnels
- **Suppression partielle** : Implémentée pour pesées, soins, recettes, dépenses, lapins

### ❌ Ce qui manque
- **0 écran de modification** sur 8 entités principales
- **7 rapports PDF** sur 9 en placeholder
- **8 fonctions export/import** (Excel, JSON, restauration, import)
- **1 navigation calendrier** vers fiche lapin
- **Suppression manquante** pour accouplements et portées

---

## 🔴 PRIORITÉ 0 - CRITIQUE (Backend existe, UI manquante)

### 1. ✏️ Écran de modification Lapin
**Fichier à créer :** `lib/screens/cheptel/edit_lapin_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updateLapin()` existe
- ✅ Provider : `LapinProvider.modifierLapin()` existe
- ❌ UI : Bouton "Modifier" dans `cheptel_screen.dart` ligne 186-195 affiche juste SnackBar placeholder
- ❌ Écran : Aucun EditLapinScreen n'existe

**Tâches :**
- [ ] Créer `edit_lapin_screen.dart` similaire à `add_lapin_screen.dart`
- [ ] Pré-remplir le formulaire avec données lapin existant
- [ ] Gérer navigation depuis `cheptel_screen.dart` ligne 190
- [ ] Appeler `LapinProvider.modifierLapin()` après validation
- [ ] Retour automatique après sauvegarde

**Estimation :** 2-3h  
**Impact utilisateur :** 🔴 HAUT - Fonctionnalité attendue quotidiennement

---

### 2. ✏️ Écran de modification Accouplement
**Fichier à créer :** `lib/screens/reproduction/edit_accouplement_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updateAccouplement()` ligne 1057
- ✅ Provider : `ReproductionProvider.modifierAccouplement()` ligne 82
- ❌ UI : Aucun bouton modifier dans `reproduction_screen.dart`
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_accouplement_screen.dart`
- [ ] Permettre modification date, male, femelle, notes
- [ ] Ne pas permettre modification si statut='termine'
- [ ] Ajouter bouton "Modifier" dans modal `_DetailsAccouplementSheet` (ligne 134)
- [ ] Gérer replanification notifications si date modifiée

**Estimation :** 3-4h  
**Impact utilisateur :** 🟠 MOYEN - Corrections nécessaires en cas d'erreur saisie

---

### 3. ✏️ Écran de modification Portée
**Fichier à créer :** `lib/screens/reproduction/edit_portee_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updatePortee()` ligne 1162
- ✅ Provider : `ReproductionProvider.modifierPortee()` ligne 147
- ❌ UI : Aucun bouton modifier pour portées
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_portee_screen.dart` basé sur `enregistrer_portee_screen.dart`
- [ ] Permettre modification nombres (nés, vivants, morts), date, notes
- [ ] Empêcher modification accouplementId
- [ ] Ajouter navigation depuis modal portée (si existe)
- [ ] Recalculer statistiques après modification

**Estimation :** 2-3h  
**Impact utilisateur :** 🟠 MOYEN - Corrections statistiques importantes

---

### 4. ✏️ Écran de modification Pesée
**Fichier à créer :** `lib/screens/sante/edit_pesee_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updatePesee()` ligne 1224
- ✅ Provider : `SanteProvider.modifierPesee()` ligne 69
- ❌ UI : Seule suppression existe dans `fiche_sante_screen.dart` ligne 240
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_pesee_screen.dart` basé sur `ajouter_pesee_screen.dart`
- [ ] Ajouter bouton "Modifier" à côté bouton supprimer ligne 240
- [ ] Permettre modification poids, date, notes
- [ ] Empêcher modification lapinId
- [ ] Recalculer courbes croissance après modification

**Estimation :** 2h  
**Impact utilisateur :** 🟠 MOYEN - Corrections erreurs saisie

---

### 5. ✏️ Écran de modification Soin
**Fichier à créer :** `lib/screens/sante/edit_soin_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updateSoin()` ligne 1293
- ✅ Provider : `SanteProvider.modifierSoin()` ligne 128
- ❌ UI : Seule suppression existe dans `fiche_sante_screen.dart` ligne 315
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_soin_screen.dart` basé sur `ajouter_soin_screen.dart`
- [ ] Ajouter bouton "Modifier" à côté bouton supprimer ligne 315
- [ ] Permettre modification type, description, date, rappel
- [ ] Gérer replanification notifications si dateRappel modifiée
- [ ] Empêcher modification lapinId

**Estimation :** 2-3h  
**Impact utilisateur :** 🟠 MOYEN - Corrections posologie/dates

---

### 6. ✏️ Écran de modification Recette
**Fichier à créer :** `lib/screens/finance/edit_recette_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updateRecette()` ligne 1397
- ✅ Provider : `FinanceProvider.modifierRecette()` ligne 42
- ❌ UI : Seule suppression (onLongPress) dans `finance_screen.dart` ligne 334
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_recette_screen.dart` basé sur `ajouter_recette_screen.dart`
- [ ] Ajouter bouton "Modifier" dans Card recette (onTap par exemple)
- [ ] Permettre modification montant, date, catégorie, description
- [ ] Recalculer statistiques finances après modification

**Estimation :** 2h  
**Impact utilisateur :** 🟠 MOYEN - Corrections montants importants

---

### 7. ✏️ Écran de modification Dépense
**Fichier à créer :** `lib/screens/finance/edit_depense_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.updateDepense()` ligne 1505
- ✅ Provider : `FinanceProvider.modifierDepense()` ligne 49
- ❌ UI : Seule suppression (onLongPress) dans `finance_screen.dart` ligne 377
- ❌ Écran : Aucun écran de modification

**Tâches :**
- [ ] Créer `edit_depense_screen.dart` basé sur `ajouter_depense_screen.dart`
- [ ] Ajouter bouton "Modifier" dans Card dépense (onTap par exemple)
- [ ] Permettre modification montant, date, catégorie, description
- [ ] Recalculer statistiques finances après modification

**Estimation :** 2h  
**Impact utilisateur :** 🟠 MOYEN - Corrections montants importants

---

## 🟠 PRIORITÉ 1 - IMPORTANTE (Améliorations UX)

### 8. 🗑️ Suppression Accouplement
**Fichier à modifier :** `lib/screens/reproduction/reproduction_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.deleteAccouplement()` ligne 1066
- ✅ Provider : `ReproductionProvider.supprimerAccouplement()` ligne 118
- ❌ UI : Aucun bouton supprimer dans modal `_DetailsAccouplementSheet`

**Tâches :**
- [ ] Ajouter bouton "Supprimer" dans modal ligne 470+ (après actions existantes)
- [ ] Dialog confirmation avant suppression
- [ ] Empêcher suppression si statut='termine' (portée liée)
- [ ] Appeler `ReproductionProvider.supprimerAccouplement()`
- [ ] Fermer modal et rafraîchir liste

**Estimation :** 1-2h  
**Impact utilisateur :** 🟠 MOYEN - Nettoyage accouplements erreur/échec

---

### 9. 🗑️ Suppression Portée
**Fichier à modifier :** `lib/screens/reproduction/reproduction_screen.dart`

**Contexte :**
- ✅ Backend : `DatabaseHelper.deletePortee()` ligne 1174
- ✅ Provider : `ReproductionProvider.supprimerPortee()` ligne 158
- ❌ UI : Aucun bouton supprimer pour portées

**Tâches :**
- [ ] Identifier où afficher portées (actuellement dans modal accouplement ligne 486)
- [ ] Ajouter bouton "Supprimer portée" dans Card portée
- [ ] Dialog confirmation avec avertissement (supprime aussi lapereaux créés?)
- [ ] Appeler `ReproductionProvider.supprimerPortee()`
- [ ] Remettre accouplement en statut 'confirme' au lieu de 'termine'

**Estimation :** 2-3h  
**Impact utilisateur :** 🟠 MOYEN - Corrections erreurs saisie portée

---

### 10. 🔗 Navigation Calendrier → Fiche Lapin
**Fichier à modifier :** `lib/screens/utilitaire/calendrier_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 505 identifié : "TODO: Naviguer vers fiche lapin"
- ✅ Événements affichent nom lapin
- ❌ Tap sur événement ne fait rien

**Tâches :**
- [ ] Lire TODO ligne 505 pour comprendre contexte
- [ ] Extraire lapinId depuis événement (vérifier structure Evenement)
- [ ] Naviguer vers `LapinDetailScreen` ou `FicheSanteScreen` selon type événement
- [ ] Gérer cas où lapinId est null (événements génériques)
- [ ] Tester navigation pour chaque type événement (accouplement, mise-bas, sevrage, vaccination, pesée, soin)

**Estimation :** 1-2h  
**Impact utilisateur :** 🟡 MOYEN-BAS - Améliore navigation contextuelle

---

## 🟡 PRIORITÉ 2 - MOYENNE (Fonctionnalités avancées)

### 11. 📊 Rapports PDF Manquants (7/9)
**Fichier à modifier :** `lib/screens/utilitaire/rapports_screen.dart`

**Contexte :**
- ✅ 2 rapports fonctionnels : Registre élevage, Bilan mensuel
- ⚠️ Placeholder ligne 945 : "RAPPORTS SIMPLIFIÉS (PLACEHOLDERS)"
- ❌ 7 rapports non implémentés

**Rapports à implémenter :**
1. **Rapport Cheptel** (ligne 946-970)
   - [ ] Liste tous lapins actifs avec statut
   - [ ] Statistiques par sexe/race
   - [ ] Graphique répartition âges
   
2. **Rapport Reproduction** (ligne 972-996)
   - [ ] Accouplements mois/trimestre
   - [ ] Taux réussite par femelle
   - [ ] Nombre lapereaux nés/sevrés
   
3. **Rapport Santé** (ligne 998-1022)
   - [ ] Soins effectués par type
   - [ ] Évolution poids moyens
   - [ ] Alertes santé en cours
   
4. **Rapport Financier** (ligne 1024-1048)
   - [ ] Recettes/Dépenses par catégorie
   - [ ] Graphique bénéfice mensuel
   - [ ] Rentabilité par lapin vendu
   
5. **Rapport Généalogie** (ligne 1050-1074)
   - [ ] Arbre généalogique d'un lapin
   - [ ] Liste descendants d'un reproducteur
   - [ ] Consanguinité détectée
   
6. **Rapport Alimentation** (ligne 1076-1100)
   - [ ] Consommation par type aliment
   - [ ] Coût alimentation par lapin/jour
   - [ ] Planification achats
   
7. **Rapport Mortalité** (ligne 1102-1126)
   - [ ] Taux mortalité par période
   - [ ] Causes principales décès
   - [ ] Analyse par tranche âge

**Estimation :** 15-20h (2-3h par rapport)  
**Impact utilisateur :** 🟡 MOYEN - Utile pour gestion professionnelle

---

### 12. 📤 Export Excel
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 268 : "Fonction export Excel à implémenter"
- ✅ Bouton UI existe (ligne 224-249)
- ❌ Fonction `_exporterExcel()` affiche juste placeholder

**Tâches :**
- [ ] Installer package `excel` dans pubspec.yaml
- [ ] Créer workbook avec sheets : Lapins, Accouplements, Portées, Pesées, Soins, Recettes, Dépenses
- [ ] Exporter toutes données depuis DatabaseHelper
- [ ] Sauvegarder fichier avec date : `elevage_export_YYYYMMDD.xlsx`
- [ ] Partager via share_plus (déjà installé)

**Estimation :** 4-5h  
**Impact utilisateur :** 🟡 MOYEN - Demandé pour archivage externe

---

### 13. 📤 Export JSON
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 282 : "Fonction export JSON à implémenter"
- ✅ Bouton UI existe (ligne 250-271)
- ❌ Fonction `_exporterJSON()` affiche juste placeholder

**Tâches :**
- [ ] Créer structure JSON avec toutes tables
- [ ] Exporter via DatabaseHelper (rawQuery SELECT *)
- [ ] Encoder en JSON.encode()
- [ ] Sauvegarder fichier : `elevage_export_YYYYMMDD.json`
- [ ] Partager via share_plus
- [ ] Ajouter métadonnées : version app, date export, nombre entités

**Estimation :** 3h  
**Impact utilisateur :** 🟡 MOYEN - Format universel pour migrations

---

### 14. 📥 Import Excel
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 330 : "Fonction import Excel à implémenter"
- ✅ Bouton UI existe (ligne 308-325)
- ❌ Fonction `_importerExcel()` affiche juste placeholder

**Tâches :**
- [ ] Utiliser package `file_picker` pour sélectionner .xlsx
- [ ] Parser Excel avec package `excel`
- [ ] Valider structure : colonnes obligatoires
- [ ] Dialog prévisualisation données
- [ ] Confirmer import (remplace ou fusionne?)
- [ ] Insérer dans DatabaseHelper avec gestion erreurs
- [ ] Rapport succès/échecs par ligne

**Estimation :** 5-6h  
**Impact utilisateur :** 🟡 MOYEN - Migration depuis autres systèmes

---

### 15. 📥 Import JSON
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 344 : "Fonction import JSON à implémenter"
- ✅ Bouton UI existe (ligne 326-343)
- ❌ Fonction `_importerJSON()` affiche juste placeholder

**Tâches :**
- [ ] Utiliser `file_picker` pour sélectionner .json
- [ ] Parser JSON et valider structure
- [ ] Vérifier version compatibilité
- [ ] Dialog prévisualisation : X lapins, Y accouplements, etc.
- [ ] Confirmer stratégie : remplacer ou fusionner
- [ ] Insérer via DatabaseHelper avec transactions
- [ ] Gérer relations (foreign keys) dans bon ordre

**Estimation :** 4-5h  
**Impact utilisateur :** 🟡 MOYEN - Restauration backups personnalisés

---

### 16. 🔄 Restauration Sauvegarde
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 296 : "Fonction restauration à implémenter"
- ✅ Bouton UI existe (ligne 364-381)
- ❌ Fonction `_restaurerSauvegarde()` affiche juste placeholder

**Tâches :**
- [ ] Lister sauvegardes disponibles depuis dossier app
- [ ] Afficher liste avec date/taille dans Dialog
- [ ] Sélection sauvegarde à restaurer
- [ ] **IMPORTANT:** Dialog avertissement (supprime données actuelles!)
- [ ] Confirmer avec saisie texte ("RESTAURER")
- [ ] Copier .db sélectionné → remplacer DB actuelle
- [ ] Redémarrer providers (notifyListeners partout)
- [ ] Retour dashboard avec SnackBar succès

**Estimation :** 3-4h  
**Impact utilisateur :** 🟡 MOYEN - Récupération après erreurs

---

### 17. 📦 Compression ZIP Sauvegarde
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 254 : "Ajouter compression ZIP"
- ✅ Sauvegarde DB fonctionne (ligne 172-210)
- ❌ Fichier .db non compressé (gros pour partage)

**Tâches :**
- [ ] Installer package `archive` dans pubspec.yaml
- [ ] Modifier `_sauvegarderDonnees()` ligne 172
- [ ] Créer archive ZIP contenant :
  - Base de données `mon_elevage_lapins.db`
  - Fichier `metadata.json` (version app, date, stats)
- [ ] Renommer : `sauvegarde_YYYYMMDD_HHMMSS.zip`
- [ ] Partager ZIP au lieu de .db

**Estimation :** 2h  
**Impact utilisateur :** 🟢 BAS - Optimisation taille fichiers

---

### 18. 🔄 Migration Base de Données (v8 → v9?)
**Fichier à modifier :** `lib/screens/utilitaire/export_import_screen.dart`

**Contexte :**
- ⚠️ TODO ligne 358 : "Fonction migration à implémenter"
- ✅ DatabaseHelper gère migrations jusqu'à v8
- ❌ Pas d'outil UI pour forcer migration/réparation

**Tâches :**
- [ ] Créer bouton "Outils avancés" dans export_import_screen
- [ ] Option 1 : "Forcer re-migration" (rejoue onCreate)
- [ ] Option 2 : "Vérifier intégrité DB" (PRAGMA integrity_check)
- [ ] Option 3 : "Réparer relations" (nettoie foreign keys orphelines)
- [ ] Option 4 : "Optimiser DB" (VACUUM)
- [ ] Dialog résultats avec logs détaillés

**Estimation :** 3-4h  
**Impact utilisateur :** 🟢 BAS - Debug avancé

---

## 🟢 PRIORITÉ 3 - BASSE (Nice-to-have)

### 19. 🔍 Recherche dans Cheptel
**Fichier à modifier :** `lib/screens/cheptel/cheptel_screen.dart`

**Tâches :**
- [ ] Ajouter SearchBar dans AppBar
- [ ] Filtrer liste lapins par nom/numéro
- [ ] Recherche insensible à la casse
- [ ] Highlight résultats

**Estimation :** 1-2h  
**Impact utilisateur :** 🟢 BAS - Utile si cheptel > 50 lapins

---

### 20. 📊 Tri personnalisé Cheptel
**Fichier à modifier :** `lib/screens/cheptel/cheptel_screen.dart`

**Tâches :**
- [ ] Dropdown tri : Âge, Nom, Race, Dernière pesée
- [ ] Sauvegarder préférence dans SharedPreferences
- [ ] Ordre croissant/décroissant

**Estimation :** 1-2h  
**Impact utilisateur :** 🟢 BAS - Améliore ergonomie

---

### 21. 🔔 Paramètres Notifications
**Fichier à créer :** `lib/screens/parametres/notifications_settings_screen.dart`

**Tâches :**
- [ ] Activer/Désactiver notifications par type
- [ ] Modifier délai avance rappels (J-3, J-1, etc.)
- [ ] Heure préférée notifications quotidiennes
- [ ] Son personnalisé

**Estimation :** 2-3h  
**Impact utilisateur :** 🟢 BAS - Personnalisation UX

---

### 22. 🌍 Support Multilingue Complet
**Fichier à vérifier :** `lib/screens/utilitaire/localisation_screen.dart`

**Tâches :**
- [ ] Vérifier couverture traductions (actuellement FR complet)
- [ ] Ajouter EN complet (si déjà pas fait)
- [ ] Ajouter ES/AR (langues demandées)
- [ ] Traduire rapports PDF
- [ ] Traduire notifications

**Estimation :** 8-10h  
**Impact utilisateur :** 🟢 BAS - Extension géographique

---

## 📊 Statistiques Globales

### Efforts Totaux Estimés
- **P0 - Critique :** 18-24h (7 écrans modification)
- **P1 - Important :** 6-9h (3 fonctionnalités)
- **P2 - Moyen :** 39-49h (12 fonctionnalités avancées)
- **P3 - Bas :** 12-17h (4 améliorations)

**TOTAL : 75-99h** (~ 2-3 semaines full-time)

### Impact Utilisateur
- 🔴 **7 fonctionnalités HAUTE priorité** : Modification entités principales
- 🟠 **3 fonctionnalités MOYENNE priorité** : Suppression, navigation
- 🟡 **12 fonctionnalités MOYENNE-BASSE** : Exports, rapports, imports
- 🟢 **4 fonctionnalités BASSE priorité** : Améliorations UX

### Répartition par Module
- **Cheptel :** 1 écran (edit_lapin)
- **Reproduction :** 3 écrans (edit_accouplement, edit_portee, delete_portee)
- **Santé :** 2 écrans (edit_pesee, edit_soin)
- **Finance :** 2 écrans (edit_recette, edit_depense)
- **Utilitaire :** 10 fonctionnalités (rapports, exports, imports)
- **Calendrier :** 1 navigation

---

## 🚀 Plan d'Implémentation Recommandé

### Sprint 1 (1 semaine) - PRIORITÉ 0
**Objectif :** Débloquer modifications entités principales

1. Jour 1-2 : **EditLapinScreen** (P0.1)
2. Jour 3 : **EditPeseeScreen** + **EditSoinScreen** (P0.4 + P0.5)
3. Jour 4 : **EditRecetteScreen** + **EditDepenseScreen** (P0.6 + P0.7)
4. Jour 5 : **EditAccouplementScreen** (P0.2)

**Livrable :** 5/7 écrans P0 fonctionnels

### Sprint 2 (3 jours) - PRIORITÉ 0 + 1
**Objectif :** Finaliser CRUD complet

5. Jour 6 : **EditPorteeScreen** (P0.3)
6. Jour 7 : **Suppressions Accouplement/Portée** (P1.8 + P1.9)
7. Jour 8 : **Navigation Calendrier** (P1.10)

**Livrable :** CRUD 100% complet

### Sprint 3 (1 semaine) - PRIORITÉ 2 (Rapports)
**Objectif :** Finaliser rapports PDF

8. Jour 9-10 : Rapports Cheptel + Reproduction + Santé
9. Jour 11-12 : Rapports Financier + Généalogie
10. Jour 13 : Rapports Alimentation + Mortalité

**Livrable :** 9/9 rapports PDF opérationnels

### Sprint 4 (1 semaine) - PRIORITÉ 2 (Export/Import)
**Objectif :** Fonctionnalités sauvegarde avancées

11. Jour 14-15 : Export Excel + JSON
12. Jour 16-17 : Import Excel + JSON
13. Jour 18 : Restauration + Compression ZIP

**Livrable :** Sauvegarde/Restauration complète

### Sprint 5 (2 jours) - PRIORITÉ 3
**Objectif :** Polish UX

14. Jour 19 : Migration DB + Recherche Cheptel
15. Jour 20 : Tri personnalisé + Tests finaux

**Livrable :** Application 100% finalisée

---

## ✅ Critères d'Acceptation

### Pour chaque écran de modification (P0)
- [ ] Formulaire pré-rempli avec données existantes
- [ ] Validation identique à écran création
- [ ] Sauvegarde appelle provider.modifier*()
- [ ] Retour automatique après succès
- [ ] SnackBar confirmation
- [ ] Gestion erreurs (try/catch)
- [ ] Tests : Modifier → Retour → Vérifier changement persisté

### Pour suppressions (P1)
- [ ] Dialog confirmation avec message clair
- [ ] Cascade delete si relations (foreign keys)
- [ ] SnackBar succès
- [ ] Liste rafraîchie automatiquement
- [ ] Tests : Supprimer → Redémarrer app → Vérifier suppression

### Pour rapports PDF (P2)
- [ ] Génération < 3 secondes
- [ ] Mise en page professionnelle (logo, en-têtes)
- [ ] Données exactes (vérifier calculs)
- [ ] Export PDF fonctionnel (partage)
- [ ] Aperçu avant partage

### Pour exports (P2)
- [ ] Toutes données exportées (vérifier COUNT)
- [ ] Format valide (Excel/JSON lisible dans autres apps)
- [ ] Nom fichier avec date
- [ ] Partage via share_plus
- [ ] Tests : Export → Import ailleurs → Vérifier intégrité

---

## 🐛 Bugs/Améliorations Détectés en Bonus

### Mineurs (à corriger en parallèle)
1. **cheptel_screen.dart ligne 193** : "Modification (à venir)" → Remplacer par navigation
2. **export_import_screen.dart ligne 143** : "Cloud Sync (placeholder)" → Implémenter ou retirer option
3. **Gestion permissions** : Vérifier Storage/Notification permissions Android 13+

### Optimisations Potentielles
1. **Lazy loading** : Charger lapins par pagination si cheptel > 100
2. **Cache images** : Si photos lapins ajoutées ultérieurement
3. **Indices DB** : Vérifier index sur foreign keys (perf)

---

## 📝 Notes de Développement

### Architecture Existante
- **Pattern :** CRUD via `DatabaseHelper` → `Provider` → `Screen`
- **Navigation :** MaterialPageRoute avec Navigator.push
- **Validation :** GlobalKey<FormState> dans _formKey
- **État :** ChangeNotifier + notifyListeners()

### Conventions Nommage
- **Écrans création :** `add_*_screen.dart` (ex: add_lapin_screen)
- **Écrans modification :** `edit_*_screen.dart` (À CRÉER)
- **Méthodes DB :** `update*()`, `delete*()` (existent)
- **Méthodes Provider :** `modifier*()`, `supprimer*()` (existent)

### Dépendances Existantes
```yaml
# Déjà installées (vérifier versions)
- sqflite (DB locale)
- provider (state management)
- intl (dates/locales)
- share_plus (partage fichiers)
- path_provider (chemins fichiers)
- pdf + printing (rapports PDF)
- fl_chart (graphiques)
- table_calendar (calendrier)
```

### Dépendances à Ajouter
```yaml
dependencies:
  excel: ^4.0.0  # Pour exports Excel
  archive: ^3.4.0  # Pour compression ZIP
  file_picker: ^6.0.0  # Pour sélection fichiers import
```

---

## 🎯 Objectif Final

**Application 100% fonctionnelle avec :**
- ✅ **CRUD complet** : Create, Read, Update, Delete pour TOUTES entités
- ✅ **Rapports exhaustifs** : 9/9 PDF opérationnels
- ✅ **Sauvegarde robuste** : Excel, JSON, DB, Import/Export
- ✅ **Navigation fluide** : Tous boutons/actions fonctionnels
- ✅ **0 placeholder** : Aucun "à venir" dans l'app
- ✅ **Tests validés** : Scénarios utilisateur complets

**Score visé : 10/10** 🏆

---

*Document généré automatiquement après audit complet de l'application*  
*Dernière mise à jour : ${new Date().toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' })}*
