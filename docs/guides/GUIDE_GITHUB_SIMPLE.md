# 🚀 GUIDE GITHUB SIMPLE - BunnyManager

**Pour propriétaire non-développeur** | Dernière màj: 8 janvier 2026

---

## 📚 TABLE DES MATIÈRES

1. [Concepts Simples](#-concepts-simples)
2. [Commandes Essentielles](#-commandes-essentielles-3-commandes-seulement)
3. [Workflow Quotidien](#-workflow-quotidien)
4. [En Cas de Problème](#-en-cas-de-problme)
5. [Glossaire](#-glossaire)

---

## 🎯 CONCEPTS SIMPLES

### Qu'est-ce que Git/GitHub ?

**Git** = Logiciel qui garde l'historique de tous vos changements (comme un "Ctrl+Z" infini)  
**GitHub** = Site web qui stocke votre code en ligne (comme Google Drive pour développeurs)

### Les 3 Zones

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Votre Ordi     │───▶│   Git Local     │───▶│  GitHub.com     │
│  (fichiers)     │    │  (historique)   │    │  (cloud)        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Règle d'or :** On sauvegarde toujours dans ces 3 zones, dans cet ordre.

---

## 💡 COMMANDES ESSENTIELLES (3 commandes seulement !)

### ✅ COMMANDE 1 : Sauvegarder votre travail local

```bash
git add .
git commit -m "Description courte de ce que vous avez fait"
```

**Exemple :**
```bash
git add .
git commit -m "Ajout internationalisation anglais"
```

**Quand l'utiliser ?** Après chaque session de travail (1-2 fois par jour minimum)

---

### ✅ COMMANDE 2 : Envoyer sur GitHub

```bash
git push
```

**Quand l'utiliser ?** Après CHAQUE commit (règle absolue)

---

### ✅ COMMANDE 3 : Vérifier l'état

```bash
git status
```

**Quand l'utiliser ?** Quand vous avez un doute

**Interprétation simple :**
- ✅ `Votre branche est à jour` = Tout est sauvegardé, vous pouvez dormir tranquille
- ⚠️ `Modifications qui ne seront pas validées` = Vous avez des changements non sauvegardés
- ⚠️ `Votre branche est en avance de X commits` = Vous devez faire `git push`

---

## 📅 WORKFLOW QUOTIDIEN

### Début de journée (5 secondes)

```bash
git status
```

Si ça dit **"Votre branche est à jour"** ✅ → Vous pouvez travailler

### Fin de journée (15 secondes)

```bash
# 1. Sauvegarder
git add .
git commit -m "Travail du [date] : [ce que vous avez fait]"

# 2. Envoyer sur GitHub
git push

# 3. Vérifier
git status
```

**Exemple complet :**
```bash
git add .
git commit -m "Travail du 8 jan : correction bugs quarantaine"
git push
git status
```

---

## 🆘 EN CAS DE PROBLÈME

### ❌ Erreur "Vous avez des modifications non sauvegardées"

**Solution :** Sauvegardez d'abord !
```bash
git add .
git commit -m "Sauvegarde avant correction"
git push
```

---

### ❌ Erreur "Conflit de fusion"

**⚠️ NE TOUCHEZ À RIEN** - Contactez votre développeur

**En attendant (solution temporaire) :**
```bash
# Créer une copie de sécurité
cp -r /home/guifo/Bureau/rabbit_farm_app /home/guifo/Bureau/rabbit_farm_app_BACKUP_$(date +%Y%m%d)

# Puis dire au développeur où est la copie
```

---

### ❌ "J'ai supprimé un fichier par erreur"

**Solution :**
```bash
# Annuler TOUS les changements non sauvegardés (attention !)
git restore .
```

⚠️ **ATTENTION :** Ceci supprime TOUT ce qui n'est pas dans un commit !

---

### ❌ "J'ai modifié trop de fichiers et je veux tout annuler"

**Solution sûre (recommandée) :**
```bash
# 1. Créer une copie de vos changements
cp -r /home/guifo/Bureau/rabbit_farm_app /home/guifo/Bureau/rabbit_farm_app_BACKUP

# 2. Annuler les changements
git restore .

# 3. Vérifier
git status
```

---

## 🔒 RÈGLES DE SÉCURITÉ

### ✅ À FAIRE

1. **Toujours** faire `git status` avant de travailler
2. **Toujours** faire `git push` après `git commit`
3. **Sauvegarder** minimum 1 fois par jour
4. **Ne jamais** fermer le terminal pendant une commande git

### ❌ À NE JAMAIS FAIRE

1. **NE PAS** utiliser `git reset --hard` (dangereux)
2. **NE PAS** utiliser `git force` (destructif)
3. **NE PAS** modifier l'historique (`git rebase`)
4. **NE PAS** supprimer le dossier `.git/`

---

## 📖 GLOSSAIRE

| Terme | Explication Simple |
|-------|-------------------|
| **Commit** | Une sauvegarde dans l'historique (comme une photo à un instant T) |
| **Push** | Envoyer vos commits sur GitHub |
| **Pull** | Récupérer les derniers changements depuis GitHub |
| **Branch** | Version parallèle du code (comme un brouillon) |
| **Merge** | Fusionner deux versions du code |
| **Clone** | Télécharger un projet depuis GitHub |
| **Remote** | Lien vers GitHub (appelé "origin") |
| **Status** | État actuel de votre code |

---

## 🎓 ALLER PLUS LOIN (OPTIONNEL)

### Voir l'historique

```bash
git log --oneline -10
```

Affiche les 10 dernières sauvegardes

### Créer une branche (fonctionnalité avancée)

```bash
# Créer et aller sur une nouvelle branche
git checkout -b ma-nouvelle-fonctionnalite

# Revenir sur la branche principale
git checkout develop
```

⚠️ **Recommandation :** Demandez à votre développeur avant de créer des branches

---

## 📞 CONTACT DÉVELOPPEUR

**En cas de doute :** Ne tentez rien d'avancé, faites une copie et contactez votre développeur

**Copie de sécurité rapide :**
```bash
cp -r /home/guifo/Bureau/rabbit_farm_app /home/guifo/Bureau/BACKUP_$(date +%Y%m%d_%H%M)
```

---

## ✅ CHECKLIST QUOTIDIENNE

- [ ] `git status` en début de journée
- [ ] Travailler sur le code
- [ ] `git add .` + `git commit -m "..."` en fin de journée
- [ ] `git push` pour envoyer sur GitHub
- [ ] `git status` pour vérifier que tout est OK
- [ ] **Résultat attendu :** "Votre branche est à jour avec 'origin/develop'"

---

**📌 MÉMO RAPIDE À IMPRIMER :**

```
┌────────────────────────────────────────────┐
│  COMMANDES GITHUB QUOTIDIENNES             │
├────────────────────────────────────────────┤
│  1. git status        (vérifier)           │
│  2. git add .         (préparer)           │
│  3. git commit -m "message" (sauvegarder)  │
│  4. git push          (envoyer)            │
│  5. git status        (confirmer)          │
└────────────────────────────────────────────┘
```

---

**Dernière mise à jour :** 8 janvier 2026  
**Version du guide :** 1.0 (Version Simple pour Non-Développeur)
