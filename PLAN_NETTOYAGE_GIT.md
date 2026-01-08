# 🧹 PLAN NETTOYAGE & ORGANISATION - BunnyManager

**Date :** 8 janvier 2026  
**Responsable :** Lead Flutter Developer  
**Objectif :** Environnement propre, sûr, compréhensible

---

## 📊 ÉTAT ACTUEL (AVANT NETTOYAGE)

### ❌ Problèmes Identifiés

1. **203 fichiers modifiés non commités**
   - Tout le travail Phases P0, P1.1, P1.2 (i18n 100%)
   - Risque de perte si non sauvegardé

2. **60+ fichiers documentation non suivis**
   - Rapports éparpillés (root du projet)
   - Pas d'organisation claire

3. **Fichiers générés non ignorés**
   - `lib/l10n/` (fichiers générés par Flutter)
   - `scripts/`, `phase6_*`, `nouvelles_cles_*`
   - Pollution du `git status`

4. **Branche develop au lieu de main**
   - Convention GitHub : `main` est standard
   - `develop` peut prêter à confusion

5. **Documentation incohérente**
   - Fichiers MD à la racine ET dans docs/
   - Guides obsolètes mélangés aux récents

---

## 🎯 OBJECTIFS FINAUX

✅ **Un seul commit** regroupant tout le travail récent  
✅ **Documentation organisée** dans `docs/`  
✅ **`.gitignore` optimisé** (0 fichier généré visible)  
✅ **Branche `main` propre** synchronisée avec GitHub  
✅ **Guide simple** pour non-développeur  

---

## 📋 PLAN D'ACTION (7 ÉTAPES)

### ✅ ÉTAPE 1 : Sauvegarder l'État Actuel

**Durée :** 30 secondes

```bash
cd /home/guifo/Bureau
cp -r rabbit_farm_app rabbit_farm_app_BACKUP_20260108
echo "✅ Copie de sécurité créée : rabbit_farm_app_BACKUP_20260108"
```

**Résultat attendu :** Dossier complet de backup au cas où

---

### ✅ ÉTAPE 2 : Optimiser .gitignore

**Durée :** 2 minutes

**Ajouts nécessaires :**
```gitignore
# Documentation temporaire/travail
RAPPORT_*.md
PHASE*.md
INVENTAIRE_*.md
AUDIT_*.md
GUIDE_TEST_*.md
*.arb.tmp
*_summary.json
i18n_extraction_report.json
phase6_*
nouvelles_cles_*.arb
patch_cles_*.arb

# Fichiers générés Flutter
lib/l10n/
l10n.yaml

# Scripts temporaires
scripts/
test_langue.sh

# Documentation obsolète (à archiver)
cahier_charges_v2.md
```

**Résultat attendu :** `git status` affiche seulement 20-30 fichiers pertinents

---

### ✅ ÉTAPE 3 : Organiser la Documentation

**Durée :** 5 minutes

**Structure cible :**
```
docs/
├── guides/
│   ├── GUIDE_GITHUB_SIMPLE.md       (nouveau - non-dev)
│   ├── GUIDE_UTILISATEUR.md
│   ├── GUIDE_DEVELOPPEUR.md
│   └── GUIDE_SYNCHRONISATION_SUPABASE.md
├── rapports/
│   ├── RAPPORT_FINAL_GO_NOGO_V1.md
│   ├── RAPPORT_PHASE_P1.1_I18N_DIALOGUES.md
│   ├── RAPPORT_PHASE_P1.2_I18N_COMPLETE.md
│   └── RAPPORT_AUDIT_TECHNIQUE_COMPLET.md
├── specifications/
│   ├── cahier_charges_app_elevage.md
│   └── GUIDE_REGLES_METIER.md
└── archives/
    └── (anciens rapports/audits obsolètes)
```

**Commandes :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app

# Créer structure
mkdir -p docs/{guides,rapports,specifications,archives}

# Déplacer fichiers
mv GUIDE_GITHUB_SIMPLE.md docs/guides/
mv RAPPORT_FINAL_GO_NOGO_V1.md docs/rapports/
mv RAPPORT_PHASE_P*.md docs/rapports/
mv cahier_charges_app_elevage.md docs/specifications/

# Archiver obsolètes
mv AUDIT_*.md docs/archives/ 2>/dev/null || true
mv INVENTAIRE_*.md docs/archives/ 2>/dev/null || true
```

**Résultat attendu :** Racine projet propre, docs/ organisé

---

### ✅ ÉTAPE 4 : Mettre à Jour README Principal

**Durée :** 3 minutes

**README.md cible :**
```markdown
# 🐰 BunnyManager - Gestion d'Élevage Cunicole

**Version :** 1.2.0+5  
**Date :** 8 janvier 2026  
**Status :** ✅ Production Ready (i18n 100% FR/EN)

## 📱 Application Mobile Flutter

Application complète de gestion d'élevage de lapins avec :
- 🌍 Support multilingue (Français, Anglais)
- 📊 Suivi santé, reproduction, finances
- 📈 Tableau de bord avec KPI temps réel
- 🔒 Mode offline-first (SQLite local)
- 📄 Exports PDF professionnels

## 🚀 Démarrage Rapide

### Prérequis
- Flutter 3.9.2+
- Dart 3.9+
- Android SDK (pour build Android)

### Installation
```bash
git clone https://github.com/DevGuifo/rabbit_farm_app.git
cd rabbit_farm_app
flutter pub get
flutter run
```

## 📚 Documentation

- **[Guide Utilisateur](docs/guides/GUIDE_UTILISATEUR.md)** - Pour utilisateurs finaux
- **[Guide GitHub Simple](docs/guides/GUIDE_GITHUB_SIMPLE.md)** - Pour propriétaire non-dev
- **[Guide Développeur](docs/guides/GUIDE_DEVELOPPEUR.md)** - Setup technique
- **[Cahier des Charges](docs/specifications/cahier_charges_app_elevage.md)** - Specs complètes
- **[CHANGELOG](CHANGELOG.md)** - Historique versions

## 🏆 Accomplissements Récents

✅ **Internationalisation 100%** (Phase P1.2)  
✅ **30 chaînes dialogues** FR/EN internationalisées  
✅ **Build release validé** (79.7 MB APK)  
✅ **0 erreur compilation**  

Voir [Rapport Final GO/NO-GO](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md)

## 🛠️ Stack Technique

- **Framework :** Flutter 3.9.2+ / Dart 3.9+
- **Architecture :** MVVM avec Provider (17 providers)
- **Base de données :** SQLite (offline-first)
- **Internationalisation :** flutter_localizations (5306+ clés FR/EN)
- **Backend optionnel :** Supabase (sync cloud)

## 📦 Build Production

```bash
flutter clean
flutter pub get
flutter build apk --release
# APK disponible : build/app/outputs/flutter-apk/app-release.apk
```

## 🤝 Contribution

Projet privé - Contact : [DevGuifo](https://github.com/DevGuifo)

## 📄 Licence

Propriétaire © 2024-2026 BunnyManager
```

---

### ✅ ÉTAPE 5 : Commit Global (Tout le Travail P0-P1.2)

**Durée :** 1 minute

```bash
cd /home/guifo/Bureau/rabbit_farm_app

# Ajouter TOUS les changements
git add .

# Commit descriptif complet
git commit -m "feat: Internationalisation 100% + Optimisation environnement (Phases P0-P1.2)

- ✅ Phase P0: Corrections compilation (6 fichiers), kDebugMode, i18n initiale (8 chaînes)
- ✅ Phase P1.1: Dialogues i18n (15 chaînes - Annuler/Confirmer/Modifier/Supprimer)
- ✅ Phase P1.2: i18n complète (7 chaînes - Quarantaine/Pharmacie) = 100% total
- 🧹 Optimisation .gitignore (fichiers générés exclus)
- 📚 Organisation documentation (docs/guides, docs/rapports)
- 📖 Guide GitHub Simple pour propriétaire non-développeur
- 🎯 30 chaînes internationalisées FR/EN (0 hardcodée restante)
- ✅ Build release validé: 79.7 MB APK, 0 erreur

Fichiers modifiés: 203
Fichiers ajoutés (docs): 15
Score i18n final: 100%
Version: 1.2.0+5"
```

**Résultat attendu :** 1 commit contenant TOUT le travail

---

### ✅ ÉTAPE 6 : Synchroniser avec GitHub

**Durée :** 30 secondes

```bash
git push origin develop
```

**Résultat attendu :** Tout le travail envoyé sur GitHub

---

### ✅ ÉTAPE 7 : Passer à la Branche Main (Optionnel)

**Durée :** 1 minute

⚠️ **ATTENTION :** Seulement si vous voulez utiliser `main` comme branche principale

```bash
# Renommer develop → main localement
git branch -m develop main

# Pousser la nouvelle branche main
git push origin main

# Définir main comme branche par défaut sur GitHub
# (À faire manuellement sur GitHub.com : Settings → Branches → Default branch → main)

# Supprimer l'ancienne branche develop sur GitHub
git push origin --delete develop
```

**Alternative simple :** Garder `develop` (déjà fonctionnel)

---

## 🎓 MAINTENANCE CONTINUE

### Checklist Hebdomadaire (5 min)

```bash
# 1. Vérifier status
git status

# 2. Si modifications non commités
git add .
git commit -m "Travail de la semaine du [date]"
git push

# 3. Vérifier synchronisation
git status
# Doit afficher : "Votre branche est à jour avec 'origin/develop'"
```

### Checklist Mensuelle (10 min)

1. **Backup complet**
   ```bash
   cp -r /home/guifo/Bureau/rabbit_farm_app /home/guifo/Bureau/BACKUP_$(date +%Y%m)
   ```

2. **Vérifier build release**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

3. **Mettre à jour CHANGELOG**
   - Ajouter nouvelles fonctionnalités/corrections
   - Incrémenter version dans `pubspec.yaml`

---

## 🆘 GUIDE DÉPANNAGE

### Problème : "203 fichiers modifiés"

**Solution :** Suivre ÉTAPE 5 (commit global)

### Problème : ".gitignore ne fonctionne pas"

**Solution :**
```bash
# Supprimer le cache Git
git rm -r --cached .
git add .
git commit -m "fix: Réappliquer .gitignore"
git push
```

### Problème : "Conflit de fusion"

**Solution sûre :**
1. Créer backup : `cp -r rabbit_farm_app rabbit_farm_app_CONFLICT`
2. Abandonner fusion : `git merge --abort`
3. Contacter développeur avec copie du backup

---

## ✅ VALIDATION FINALE

### Checklist Post-Nettoyage

- [ ] Backup créé (ÉTAPE 1)
- [ ] .gitignore optimisé (ÉTAPE 2)
- [ ] Documentation organisée docs/ (ÉTAPE 3)
- [ ] README mis à jour (ÉTAPE 4)
- [ ] Commit global effectué (ÉTAPE 5)
- [ ] Push sur GitHub réussi (ÉTAPE 6)
- [ ] `git status` affiche "à jour" ✅

### Résultat Attendu Final

```bash
$ git status
Sur la branche develop
Votre branche est à jour avec 'origin/develop'.

rien à valider, la copie de travail est propre
```

---

## 📞 SUPPORT

**En cas de blocage :** Envoyer screenshot de `git status` au développeur

**Commande diagnostic complète :**
```bash
echo "=== Git Status ===" && git status && echo -e "\n=== Last Commits ===" && git log --oneline -5 && echo -e "\n=== Remote ===" && git remote -v
```

---

**Dernière mise à jour :** 8 janvier 2026  
**Responsable :** Lead Flutter Developer  
**Prochaine révision :** Février 2026
