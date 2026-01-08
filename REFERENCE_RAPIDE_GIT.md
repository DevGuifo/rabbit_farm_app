# ⚡ RÉFÉRENCE RAPIDE GIT - 3 Commandes Essentielles

**Pour :** Propriétaire BunnyManager (non-développeur)  
**Temps nécessaire :** 5 minutes/jour  
**Pré-requis :** Avoir lu [GUIDE_GITHUB_SIMPLE.md](docs/guides/GUIDE_GITHUB_SIMPLE.md)

---

## 🎯 WORKFLOW QUOTIDIEN (Copier-Coller)

### 1️⃣ Ouvrir le Terminal

**Sur Linux :**
- Appuyez sur `Ctrl + Alt + T`
- **OU** Menu Applications → Terminal

### 2️⃣ Aller dans le Dossier Projet

```bash
cd /home/guifo/Bureau/rabbit_farm_app
```

### 3️⃣ Exécuter les 3 Commandes

```bash
# Étape 1 : Vérifier l'état (lecture seule, sans danger)
git status

# Étape 2 : Ajouter tous les changements
git add .

# Étape 3 : Enregistrer avec un message
git commit -m "Travail du $(date +%d/%m/%Y)"

# Étape 4 : Envoyer sur GitHub
git push
```

**C'est tout !** 🎉

---

## ✅ RÉSULTATS ATTENDUS

### Si Tout Va Bien

Après `git push`, vous devez voir :
```
Écriture des objets: 100% (X/X)
To https://github.com/DevGuifo/rabbit_farm_app.git
   abc1234..def5678  develop -> develop
```

✅ **Message de réussite : "100%"**

Puis vérifiez avec :
```bash
git status
```

Résultat attendu :
```
Sur la branche develop
Votre branche est à jour avec 'origin/develop'.

rien à valider, la copie de travail est propre
```

✅ **Parfait ! Copie propre = Tout est sauvegardé**

---

## ⚠️ DÉPANNAGE RAPIDE

### Problème 1 : "rien à valider"

**Message :**
```
Sur la branche develop
rien à valider, la copie de travail est propre
```

**Signification :** ✅ Aucun changement depuis le dernier commit = **Normal**

**Action :** Rien à faire ! Tout est déjà sauvegardé.

---

### Problème 2 : "Your branch is ahead of..."

**Message :**
```
Votre branche est en avance sur 'origin/develop' de 1 commit.
```

**Signification :** Vous avez fait un commit mais pas encore poussé sur GitHub

**Solution :**
```bash
git push
```

---

### Problème 3 : "conflict"

**Message :**
```
CONFLICT (content): Merge conflict in ...
```

**Signification :** Quelqu'un d'autre a modifié le projet en même temps

**Solution SÉCURISÉE :**
```bash
# 1. Créer un backup
cp -r /home/guifo/Bureau/rabbit_farm_app /home/guifo/Bureau/rabbit_farm_app_CONFLIT_$(date +%Y%m%d)

# 2. Abandonner la fusion
git merge --abort

# 3. Contacter le développeur avec le backup
echo "✅ Backup créé dans : rabbit_farm_app_CONFLIT_$(date +%Y%m%d)"
```

⚠️ **NE PAS** résoudre les conflits manuellement si vous n'êtes pas développeur.

---

### Problème 4 : "Permission denied"

**Message :**
```
Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Signification :** GitHub ne reconnaît pas votre ordinateur

**Solution :**
1. Vérifier que vous êtes connecté à GitHub sur votre navigateur
2. Contacter le développeur pour re-configurer l'authentification SSH/HTTPS

---

## 🆘 COMMANDE D'URGENCE

Si vous êtes complètement bloqué, copiez/collez cette commande :

```bash
echo "=== DIAGNOSTIC GIT ===" && \
cd /home/guifo/Bureau/rabbit_farm_app && \
echo -e "\n1. Git Status:" && git status && \
echo -e "\n2. Derniers Commits:" && git log --oneline -5 && \
echo -e "\n3. Connexion GitHub:" && git remote -v && \
echo -e "\n4. Branche Active:" && git branch
```

**Envoyez le résultat complet au développeur** (copier tout le texte affiché).

---

## 📅 CHECKLIST HEBDOMADAIRE (Vendredis 17h)

- [ ] Ouvrir Terminal (`Ctrl + Alt + T`)
- [ ] `cd /home/guifo/Bureau/rabbit_farm_app`
- [ ] `git status` (vérifier)
- [ ] `git add .` (ajouter)
- [ ] `git commit -m "Travail semaine du $(date +%d/%m/%Y)"` (enregistrer)
- [ ] `git push` (envoyer GitHub)
- [ ] Vérifier : `git status` → "copie propre" ✅

**Durée totale :** 5 minutes

---

## 🔐 RÈGLES DE SÉCURITÉ (À NE JAMAIS OUBLIER)

### ✅ TOUJOURS FAIRE

1. **Backup avant tout** : `cp -r rabbit_farm_app rabbit_farm_app_BACKUP_$(date +%Y%m%d)`
2. **Commit régulièrement** : Au moins 1 fois/semaine
3. **Lire les messages** : Git explique toujours ce qui se passe

### ❌ NE JAMAIS FAIRE

1. ❌ **git push --force** (efface l'historique GitHub)
2. ❌ **rm -rf .git** (détruit tout l'historique)
3. ❌ **Modifier directement sur GitHub.com** sans pull avant

---

## 📞 AIDE & SUPPORT

### Documentation Complète
- **[Guide GitHub Simple](docs/guides/GUIDE_GITHUB_SIMPLE.md)** - Guide complet (20 pages)
- **[Plan Nettoyage Git](PLAN_NETTOYAGE_GIT.md)** - Référence technique
- **[Rapport DevOps](RAPPORT_NETTOYAGE_GIT_DEVOPS.md)** - Audit complet

### Contact Développeur
- **GitHub Issues** : https://github.com/DevGuifo/rabbit_farm_app/issues
- **Email** : (à configurer si besoin)

---

## 💡 ASTUCES PRO

### Personnaliser le Message de Commit

Au lieu de :
```bash
git commit -m "Travail du $(date +%d/%m/%Y)"
```

Vous pouvez être plus précis :
```bash
git commit -m "Ajout de 5 lapins + correction bug santé"
```

### Voir l'Historique des Commits

```bash
git log --oneline -10
```

Affiche les 10 derniers commits (lecture seule, sans danger).

### Vérifier la Connexion GitHub

```bash
git remote -v
```

Doit afficher :
```
origin  https://github.com/DevGuifo/rabbit_farm_app.git (fetch)
origin  https://github.com/DevGuifo/rabbit_farm_app.git (push)
```

---

**Version :** 1.0 (8 janvier 2026)  
**Auteur :** Lead Flutter Developer  
**Prochaine révision :** Février 2026

---

💾 **Astuce :** Imprimez cette page ou gardez-la ouverte pendant votre travail !
