# 📘 VOCABULAIRE OFFICIEL - Mon Élevage Lapins

**Version** : 2.0  
**Date** : 19 janvier 2026  
**Statut** : Standard UX/UI  

---

## 🎯 PRINCIPE DIRECTEUR

> **Chaque mot de l'interface doit être immédiatement compréhensible par un éleveur de lapins, qu'il soit débutant ou expérimenté. Nous privilégions le langage métier concret plutôt que les abstractions.**

---

## ✅ TERMINOLOGIE AUTORISÉE

### Gestion quotidienne

| Terme | Contexte d'utilisation | Exemple UI |
|-------|------------------------|-----------|
| **Tâches du jour** | Titre principal, navigation | "Tâches du jour" (section dashboard) |
| **Tâches quotidiennes** | Documentation, paramètres | "Configurer vos tâches quotidiennes" |
| **Tâches du matin** | Section temporelle spécifique | "Tâches du matin : 4 actions à faire" |
| **Tâches du soir** | Section temporelle spécifique | "Tâches du soir terminées ✓" |
| **Vérification** | Alternative contextuelle | "Vérification du matin", "Vérification sanitaire" |
| **Tour du matin/soir** | Langage oral naturel | "C'est l'heure du tour du soir" (notification) |
| **Actions quotidiennes** | Paramétrage technique | "Personnaliser les actions quotidiennes" |

### Actions spécifiques

| Action | Description | Icône |
|--------|-------------|-------|
| **Observation générale** | Contrôle visuel de l'état des lapins | 👁️ |
| **Nourrissage** | Distribution de la nourriture | 🥕 |
| **Abreuvement** | Vérification et remplissage des abreuvoirs | 💧 |
| **Vérification sanitaire** | Détection des signes de maladie | 🏥 |
| **Nettoyage** | Retrait des déjections | 🧹 |
| **Sécurisation** | Fermeture et verrouillage du clapier | 🔒 |

### Statuts et états

| Statut | Affichage utilisateur | Contexte |
|--------|----------------------|----------|
| **À faire** | "À faire" ou "En attente" | Action non commencée |
| **En cours** | "En cours (3/5)" | Progression partielle |
| **Terminé** | "✓ Fait" ou "✓ Terminé" | Action complétée |
| **Reporté** | "⏰ Reporté" | Action différée |
| **Problème** | "⚠️ Problème signalé" | Anomalie détectée |

---

## ❌ TERMINOLOGIE INTERDITE

### Mots abstraits

| Terme interdit | Raison | Alternative |
|----------------|--------|-------------|
| **Rituel** | Connotation mystique/religieuse, abstrait | "Tâches quotidiennes" |
| **Routine** | Trop général, manque de précision | "Tâches du matin/soir" |
| **Workflow** | Anglicisme technique | "Processus" ou "Étapes" |
| **Pipeline** | Jargon technique | "Enchaînement" |

### Anglicismes

| Terme interdit | Alternative française |
|----------------|----------------------|
| **Checklist** | "Liste de vérification" |
| **To-do** | "À faire" |
| **Check** | "Vérification" |
| **Daily check** | "Contrôle quotidien" |
| **Morning routine** | "Tâches du matin" |
| **Task** | "Tâche" |

### Jargon technique

| Terme interdit | Raison | Alternative |
|----------------|--------|-------------|
| **Batch processing** | Incompréhensible | "Traitement groupé" |
| **Trigger** | Anglicisme | "Déclencher" |
| **Scheduler** | Anglicisme | "Planificateur" |
| **Log** | Anglicisme | "Journal" ou "Historique" |

---

## 🎨 RÈGLES DE RÉDACTION

### Titres et navigation

```
✅ BON                           ❌ MAUVAIS
"Tâches du jour"                 "Rituels quotidiens"
"Vérification du matin"          "Morning check"
"Historique des tâches"          "Task log"
"Actions à faire"                "To-do list"
```

### Boutons d'action

```
✅ BON                           ❌ MAUVAIS
"Commencer les tâches"           "Démarrer le rituel"
"Valider l'action"               "Check action"
"Signaler un problème"           "Report issue"
"Reporter à plus tard"           "Snooze"
```

### Messages et notifications

```
✅ BON                                          ❌ MAUVAIS
"Vos tâches du matin vous attendent"           "Time for your morning ritual"
"C'est l'heure du tour du soir"                "Evening routine reminder"
"5 minutes suffisent pour un contrôle visuel"  "Quick check needed"
```

### Statistiques et rapports

```
✅ BON                           ❌ MAUVAIS
"Tâches complétées : 85%"        "Ritual completion rate: 85%"
"7 jours consécutifs"            "7-day streak"
"Dernière vérification : hier"   "Last check: yesterday"
```

---

## 📱 EXEMPLES D'ÉCRANS

### Dashboard principal

```
┌────────────────────────────────────┐
│  🏠 Mon Élevage                    │
├────────────────────────────────────┤
│                                    │
│  📋 Tâches du jour                 │
│  ┌──────────────────────────────┐ │
│  │ 🌅 Matin : ✓ Fait            │ │
│  │ 🌙 Soir : En cours (2/5)     │ │
│  └──────────────────────────────┘ │
│                                    │
│  🐰 Cheptel : 24 lapins            │
│  💰 Finances : +145€ ce mois       │
└────────────────────────────────────┘
```

### Écran Tâches du matin

```
┌────────────────────────────────────┐
│  ← Tâches du matin                 │
│     4 actions à valider            │
├────────────────────────────────────┤
│                                    │
│  1. 👁️ Observation générale       │
│     ✓ OK  ⚠️ Problème  ⏰ Reporter │
│                                    │
│  2. 🥕 Nourrissage                 │
│     ✓ OK  ⚠️ Problème  ⏰ Reporter │
│                                    │
│  3. 💧 Abreuvement                 │
│     ✓ OK  ⚠️ Problème  ⏰ Reporter │
│                                    │
│  4. 🏥 Vérification sanitaire      │
│     ✓ OK  ⚠️ Problème  ⏰ Reporter │
│                                    │
└────────────────────────────────────┘
```

### Notification

```
┌────────────────────────────────────┐
│  🐰 Mon Élevage Lapins             │
│                                    │
│  🌅 Tâches du matin                │
│  Vos lapins vous attendent !       │
│                                    │
│  5 minutes suffisent pour un       │
│  contrôle visuel.                  │
│                                    │
│  [Commencer]  [Plus tard]          │
└────────────────────────────────────┘
```

---

## 🌐 TRADUCTIONS

### Français → Anglais

| Français | English | Notes |
|----------|---------|-------|
| Tâches du jour | Daily tasks | Pas "Daily rituals" |
| Tâches du matin | Morning tasks | Ou "Morning rounds" |
| Vérification | Check | Acceptable en anglais |
| Tour du soir | Evening rounds | Langage naturel |
| À faire | To do | Séparé en 2 mots |
| Terminé | Done / Complete | Selon contexte |

### Cohérence multilingue

- Toujours utiliser le même terme pour un concept identique
- Éviter les variations régionales (ex: "contrôle" vs "vérification" selon région)
- Privilégier les termes courts (< 20 caractères) pour l'UI mobile

---

## 🔍 TEST DE VALIDATION

### Checklist UX Writer

Avant de valider un nouveau texte, vérifier :

- [ ] Le terme est-il compris par un débutant ?
- [ ] Le terme évoque-t-il l'action concrète attendue ?
- [ ] Le terme est-il cohérent avec le reste de l'app ?
- [ ] Le terme est-il dans la liste "autorisée" ?
- [ ] Le terme n'est-il PAS dans la liste "interdite" ?
- [ ] Le terme est-il traduisible naturellement ?

### Exemples de validation

| Texte proposé | ✅/❌ | Raison | Correction |
|---------------|------|--------|------------|
| "Rituel du matin" | ❌ | Terme interdit "Rituel" | "Tâches du matin" |
| "Morning check" | ❌ | Anglicisme | "Vérification du matin" |
| "Tâches du jour" | ✅ | Clair et concret | - |
| "Checklist soins" | ❌ | Anglicisme "Checklist" | "Liste de vérification soins" |
| "Tour du soir" | ✅ | Langage naturel | - |

---

## 📞 CONTACT

Pour toute question sur la terminologie :
- **Product Owner** : Vérification des termes métier
- **UX Writer** : Validation de la clarté
- **Développeur** : Implémentation cohérente

**Dernière mise à jour** : 19 janvier 2026  
**Prochaine révision** : Juin 2026
