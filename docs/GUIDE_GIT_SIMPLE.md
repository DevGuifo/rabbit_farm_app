# 📚 Guide Git Simple - BunnyManager

Ce guide explique comment utiliser Git pour ce projet, **sans être expert**.

---

## 🎯 Stratégie de Branches

Le projet utilise une stratégie simple avec **2 branches principales** :

- **`master`** : Code stable, prêt pour production
- **`develop`** : Branche de travail quotidien, où vous développez

### Règle d'or
- ✅ Toujours travailler sur `develop`
- ✅ Ne jamais modifier directement `master`
- ✅ Fusionner `develop` → `master` seulement quand le code est stable

---

## 🔄 Commandes Git Essentielles

### Voir l'état actuel
```bash
git status
```
Affiche les fichiers modifiés, ajoutés ou supprimés.

### Voir sur quelle branche vous êtes
```bash
git branch
```
L'étoile (*) indique la branche actuelle.

### Changer de branche
```bash
# Aller sur develop (travail quotidien)
git checkout develop

# Aller sur master (stable)
git checkout master
```

### Créer une nouvelle branche (optionnel)
```bash
# Créer une branche pour une fonctionnalité
git checkout -b feature/nom-fonctionnalite

# Revenir sur develop après
git checkout develop
```

---

## 💾 Sauvegarder vos modifications (Commit)

### Étape 1 : Voir ce qui a changé
```bash
git status
```

### Étape 2 : Ajouter les fichiers modifiés
```bash
# Ajouter tous les fichiers modifiés
git add .

# OU ajouter un fichier spécifique
git add lib/screens/cheptel/cheptel_screen.dart
```

### Étape 3 : Créer un commit avec un message clair
```bash
git commit -m "fix: Corriger le bug d'affichage des lapins"
```

### Messages de commit recommandés
- `fix:` pour corriger un bug
- `feat:` pour ajouter une fonctionnalité
- `chore:` pour maintenance (nettoyage, config)
- `docs:` pour documentation
- `refactor:` pour refactorisation

**Exemples :**
```bash
git commit -m "fix: Corriger BuildContext asynchrone dans localisation_screen"
git commit -m "feat: Ajouter détection automatique des femelles gestantes"
git commit -m "chore: Nettoyer fichiers temporaires"
```

---

## 📤 Envoyer vos modifications (Push)

### Envoyer sur la branche actuelle
```bash
git push origin develop
```

**⚠️ Important :** Remplacez `develop` par le nom de votre branche si vous êtes sur une autre.

---

## 📥 Récupérer les modifications (Pull)

### Récupérer les dernières modifications
```bash
git pull origin develop
```

Faites cela **avant** de commencer à travailler pour être à jour.

---

## 🔍 Voir l'historique

### Voir les derniers commits
```bash
git log --oneline -10
```

Affiche les 10 derniers commits avec leurs messages.

---

## ⚠️ Situations Courantes

### J'ai modifié des fichiers par erreur
```bash
# Annuler les modifications d'un fichier
git checkout -- nom-du-fichier.dart

# Annuler TOUTES les modifications non commitées
git checkout .
```

### J'ai oublié d'ajouter un fichier dans mon commit
```bash
# Ajouter le fichier oublié
git add fichier-oublie.dart

# Modifier le dernier commit (sans créer un nouveau)
git commit --amend --no-edit
```

### Je veux annuler mon dernier commit (mais garder les modifications)
```bash
git reset --soft HEAD~1
```

### Je veux annuler mon dernier commit (et supprimer les modifications)
```bash
git reset --hard HEAD~1
```

**⚠️ Attention :** Cette commande supprime définitivement vos modifications !

---

## 🚫 Fichiers à ne JAMAIS commiter

Ces fichiers sont automatiquement ignorés par Git (grâce au `.gitignore`) :

- ✅ Dossiers `build/` (générés par Flutter)
- ✅ Fichiers `.metadata`, `.flutter-plugins`
- ✅ Bases de données `.db`, `.sqlite`
- ✅ Fichiers de configuration locaux `.env`
- ✅ Scripts temporaires `fix_*.py`, `run_*.sh`

**Si vous voyez ces fichiers dans `git status`, c'est normal qu'ils soient ignorés.**

---

## 📋 Workflow Quotidien Recommandé

1. **Le matin, avant de commencer :**
   ```bash
   git checkout develop
   git pull origin develop
   ```

2. **Pendant le développement :**
   - Modifiez vos fichiers
   - Testez avec `flutter run`
   - Vérifiez avec `flutter analyze`

3. **Quand vous avez fini une fonctionnalité/correction :**
   ```bash
   git status                    # Voir ce qui a changé
   git add .                     # Ajouter tous les fichiers
   git commit -m "fix: ..."      # Créer un commit
   git push origin develop       # Envoyer sur le serveur
   ```

4. **Quand le code est stable :**
   ```bash
   git checkout master           # Aller sur master
   git merge develop             # Fusionner develop dans master
   git push origin master        # Envoyer master
   git checkout develop          # Revenir sur develop
   ```

---

## 🆘 Besoin d'aide ?

### Voir toutes les commandes Git disponibles
```bash
git help
```

### Voir l'aide d'une commande spécifique
```bash
git help commit
git help push
```

---

## ✅ Checklist Avant de Commiter

- [ ] Le code compile (`flutter analyze` sans erreur)
- [ ] L'application se lance (`flutter run`)
- [ ] Les modifications fonctionnent comme prévu
- [ ] Le message de commit est clair et descriptif
- [ ] Aucun fichier généré n'est inclus (build/, .metadata, etc.)

---

**Rappel :** Git est un outil de sauvegarde et de collaboration. 
Commitez souvent, avec des messages clairs, et vous ne perdrez jamais votre travail ! 🎉

