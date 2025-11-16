# 🧪 Guide de Tests - Phase P0

**Application** : BunnyManager  
**Phase** : P0 - Corrections Critiques  
**Date** : 16 novembre 2025

---

## 📋 Checklist Validation Complète

Cochez chaque test après validation :

- [ ] **Test 1** : Navigation notification mise_bas
- [ ] **Test 2** : Navigation notification soin
- [ ] **Test 3** : Navigation notification alerte
- [ ] **Test 4** : Compression export ZIP
- [ ] **Test 5** : Persistance info dernière sauvegarde
- [ ] **Test 6** : Navigation calendrier → lapin
- [ ] **Test 7** : Gestion erreur photo (permission refusée)
- [ ] **Test 8** : Logging (vérification console)

---

## 🎯 Tests Détaillés

### **Test 1 : Navigation Notification Mise-Bas** ✅ P0.1

**Objectif** : Vérifier navigation depuis notification mise_bas vers ReproductionScreen

**Prérequis** :
- Application installée sur appareil/émulateur
- Permissions notifications accordées
- Au moins 1 mise-bas enregistrée

**Étapes** :
1. Planifier un accouplement avec date prévue mise-bas proche
2. Attendre notification "Mise-bas prévue pour [Nom lapin]"
3. Taper sur la notification
4. **Vérifier** : Navigation automatique vers `ReproductionScreen`
5. **Vérifier** : Onglet/section mise-bas visible
6. **Vérifier** : Informations correctes (lapin, date, statut)

**Résultat attendu** : ✅ Navigation fluide vers écran reproduction avec contexte mise-bas

**En cas d'échec** :
- Vérifier logs console : `[NotificationService] Navigation vers reproduction`
- Vérifier format payload notification : `mise_bas:123`

---

### **Test 2 : Navigation Notification Soin** ✅ P0.1

**Objectif** : Vérifier navigation depuis notification soin vers FicheSanteScreen

**Prérequis** :
- Au moins 1 soin programmé avec rappel

**Étapes** :
1. Créer un soin avec notification rappel
2. Attendre notification "Rappel soin : [Type] pour [Nom lapin]"
3. Taper sur la notification
4. **Vérifier** : Navigation automatique vers `FicheSanteScreen`
5. **Vérifier** : Fiche santé du lapin concerné affichée
6. **Vérifier** : Section soins visible avec soin en question

**Résultat attendu** : ✅ Navigation vers fiche santé avec soin en surbrillance

**En cas d'échec** :
- Vérifier logs : `[NotificationService] Récupération soin ID: XXX`
- Vérifier méthode `getSoinById()` dans DatabaseHelper

---

### **Test 3 : Navigation Notification Alerte** ✅ P0.1

**Objectif** : Vérifier navigation depuis notification alerte vers LapinDetailScreen

**Prérequis** :
- Au moins 1 alerte active (poids, santé, reproduction...)

**Étapes** :
1. Créer une alerte (ex: poids lapin critique)
2. Attendre notification "⚠️ Alerte : [Message]"
3. Taper sur la notification
4. **Vérifier** : Navigation automatique vers `LapinDetailScreen`
5. **Vérifier** : Fiche détaillée du lapin concerné
6. **Vérifier** : Badge/indicateur alerte visible

**Résultat attendu** : ✅ Navigation vers fiche lapin avec alerte mise en évidence

---

### **Test 4 : Compression Export ZIP** ✅ P0.4

**Objectif** : Vérifier génération archive ZIP compressée lors export

**Étapes** :
1. Aller dans menu `Utilitaire` → `Export/Import`
2. Cliquer sur "Créer une sauvegarde"
3. Attendre fin génération
4. Cliquer sur "Partager sauvegarde"
5. **Vérifier** : Fichier partagé format `.zip`
6. **Vérifier** : Nom fichier : `backup_bunnymanager_YYYYMMDD_HHMMSS.zip`
7. Extraire archive ZIP sur PC
8. **Vérifier** : Contenu :
   - `bunny_farm.db` (base de données)
   - Dossier `photos/` (si photos existantes)
   - `metadata.json` (optionnel)

**Résultat attendu** : ✅ Archive ZIP fonctionnelle, taille réduite ~70% vs DB seule

**Mesure** :
- Taille DB seule : ___________ Ko
- Taille archive ZIP : ___________ Ko
- Réduction : ___________% ✅

---

### **Test 5 : Persistance Info Dernière Sauvegarde** ✅ P0.2

**Objectif** : Vérifier sauvegarde/affichage informations dernière sauvegarde

**Étapes** :
1. Aller dans `Utilitaire` → `Export/Import`
2. **Vérifier** : Si aucune sauvegarde, message "Aucune sauvegarde effectuée"
3. Créer une sauvegarde (heure exacte : __:__)
4. **Vérifier** : Apparition card verte :
   ```
   ✅ Dernière sauvegarde
   [Date] à [Heure]
   [Chemin fichier]
   ```
5. Noter date/heure affichée : ___________________
6. **FERMER COMPLÈTEMENT L'APPLICATION** (kill process)
7. **RELANCER L'APPLICATION**
8. Aller dans `Utilitaire` → `Export/Import`
9. **Vérifier** : Card verte toujours affichée avec mêmes infos
10. Créer une nouvelle sauvegarde
11. **Vérifier** : Card mise à jour avec nouvelle date/heure

**Résultat attendu** : ✅ Persistance info sauvegarde entre sessions app

**Détails techniques** :
- Stockage : SharedPreferences
- Clés : `last_backup_path`, `last_backup_timestamp`

---

### **Test 6 : Navigation Calendrier → Lapin** ✅ P0.3

**Objectif** : Vérifier bouton "Voir lapin" dans calendrier

**Prérequis** :
- Au moins 1 événement dans calendrier lié à un lapin

**Étapes** :
1. Aller dans `Utilitaire` → `Calendrier`
2. Naviguer vers date avec événement (marqueur visible)
3. Taper sur événement pour afficher détails
4. **Vérifier** : Bouton "Voir lapin" présent
5. Cliquer sur "Voir lapin"
6. **Vérifier** : Navigation automatique vers `LapinDetailScreen`
7. **Vérifier** : Fiche du bon lapin affichée (nom, race, numéro)

**Test erreur** :
1. (Facultatif) Supprimer le lapin de la DB manuellement
2. Taper sur événement puis "Voir lapin"
3. **Vérifier** : SnackBar erreur "Lapin introuvable" (pas de crash)

**Résultat attendu** : ✅ Navigation fluide + gestion erreur propre

---

### **Test 7 : Gestion Erreur Photo (Permission Refusée)** ✅ P0.5

**Objectif** : Vérifier remontée erreurs photo avec exceptions typées

**Étapes** :
1. Aller dans fiche lapin
2. Cliquer sur "Ajouter photo"
3. Choisir "Prendre photo" ou "Galerie"
4. **REFUSER** permission caméra/galerie si demandée
5. **Vérifier** : Affichage message erreur clair :
   ```
   ❌ Permission refusée
   Veuillez autoriser l'accès à la caméra/galerie dans les paramètres
   ```
6. **Vérifier** : Pas de crash silencieux
7. **Vérifier console logs** : 
   ```
   [PhotoService] ERROR: PhotoPermissionDeniedException
   ```

**Test annulation** :
1. Cliquer sur "Ajouter photo"
2. **ANNULER** sélection (bouton retour)
3. **Vérifier** : Retour écran lapin sans erreur
4. **Vérifier console** : `[PhotoService] DEBUG: Annulation sélection photo par utilisateur`

**Résultat attendu** : ✅ Erreurs remontées proprement, pas de `null` silencieux

---

### **Test 8 : Logging Professionnel** ✅ P0.6

**Objectif** : Vérifier remplacement print() par logger

**Prérequis** :
- Application lancée en mode debug
- Console visible (Android Studio, VS Code...)

**Actions déclenchant logs** :
1. Créer un lapin (LapinProvider)
2. Créer un soin (SanteProvider)
3. Planifier accouplement (ReproductionProvider)
4. Changer thème (ThemeProvider)
5. Lancer migration DB (DatabaseHelper)

**Vérifier absence de** :
```
❌ print('Erreur ...')
❌ print('Debug ...')
```

**Vérifier présence de** :
```
✅ [LapinProvider] INFO: Lapin ajouté ...
✅ [SanteProvider] ERROR: Erreur création soin ...
✅ [ReproductionProvider] WARNING: Accouplement en conflit ...
✅ [ThemeProvider] ERROR: Erreur sauvegarde thème ...
✅ [DatabaseHelper] INFO: Migration vers version X ...
```

**Format attendu** :
```
[TIMESTAMP] [NIVEAU] [Source] Message
```

**Résultat attendu** : ✅ 0 print() dans logs, 100% logger professionnel

---

## 📊 Rapport de Tests

Remplir après exécution complète :

| Test | Statut | Commentaires | Bug ID (si échec) |
|------|--------|--------------|-------------------|
| Test 1 - Navigation mise_bas | ⬜ PASS / ❌ FAIL | | |
| Test 2 - Navigation soin | ⬜ PASS / ❌ FAIL | | |
| Test 3 - Navigation alerte | ⬜ PASS / ❌ FAIL | | |
| Test 4 - Compression ZIP | ⬜ PASS / ❌ FAIL | Taille: ___ Ko → ___ Ko | |
| Test 5 - Persistance backup | ⬜ PASS / ❌ FAIL | | |
| Test 6 - Navigation calendrier | ⬜ PASS / ❌ FAIL | | |
| Test 7 - Erreurs photo | ⬜ PASS / ❌ FAIL | | |
| Test 8 - Logging | ⬜ PASS / ❌ FAIL | print() restants: ___ | |

**Tests réussis** : ___/8  
**Tests échoués** : ___/8  
**Phase P0 validée** : ⬜ OUI / ❌ NON

---

## 🐛 Template Signalement Bug

Si un test échoue, copier/remplir ce template :

```
BUG #XXX - [Titre court]

Phase: P0.X
Test échoué: [Numéro test]
Sévérité: 🔴 CRITIQUE / 🟠 MAJEURE / 🟡 MINEURE

Reproduction:
1. [Étape 1]
2. [Étape 2]
3. ...

Résultat obtenu:
[Description]

Résultat attendu:
[Description]

Logs/Traces:
```
[Copier logs console]
```

Appareil:
- Modèle: [Android/iOS, version OS]
- Flutter version: [flutter --version]

Capture d'écran:
[Joindre screenshot si pertinent]
```

---

## ✅ Validation Finale

Après tous les tests :

- [ ] **8/8 tests PASS** → Phase P0 validée ✅
- [ ] **6-7/8 tests PASS** → Bugs mineurs à corriger
- [ ] **<6/8 tests PASS** → Revue code nécessaire

**Validé par** : _________________  
**Date** : _________________  
**Signature** : _________________

---

**Prochaine étape** : Phase P1 (Fonctionnalités incomplètes)
