# Guide du Tableau de Bord - BunnyManager

## 🎯 Objectif

Le tableau de bord vous permet de **comprendre l'état de votre élevage en moins de 5 secondes** grâce à un système de **code couleur simple** :

- 🟢 **Vert** : Tout va bien, aucune action requise
- 🟠 **Orange** : Nécessite surveillance ou action dans les prochains jours
- 🔴 **Rouge** : Action immédiate requise

## 📊 Structure du Dashboard

### 1️⃣ Message d'accueil

Affiche un salut personnalisé selon l'heure de la journée et une phrase d'accroche.

### 2️⃣ Statistiques rapides (3 cartes horizontales)

Vue d'ensemble du cheptel en un coup d'œil :
- **Total Rabbits** : Nombre total de lapins actifs
- **Breeding Does** : Femelles reproductrices
- **Kits (0-8 wks)** : Lapereaux de moins de 8 semaines

### 3️⃣ Points d'attention (Cartes critiques) ⚠️

**Affiche uniquement les indicateurs nécessitant votre attention.**

Si tout va bien, vous verrez : ✨ **"Tout va bien ! Aucune action urgente requise."**

Sinon, vous verrez des cartes colorées (orange/rouge) avec :
- **Icône** : Type d'alerte
- **Nombre** : Quantité concernée
- **Label** : Description claire
- **Sous-titre** : Information complémentaire
- **"Voir détails"** : Bouton pour accéder à l'écran détaillé

#### Indicateurs critiques surveillés

| Indicateur | Seuil d'alerte | Couleur | Action |
|------------|---------------|---------|--------|
| **Femelles gestantes** | > 0 | 🟠 Orange si > 5 | Suivi gestation |
| **Mises bas prévues** (14j) | > 0 | 🟠 Orange si > 3 | Préparer matériel |
| **Soins urgents** (<3j) | > 0 | 🔴 Rouge | Action immédiate |
| **Vaccins en retard** | > 0 | 🔴 Rouge | Vacciner d'urgence |
| **Médicaments critiques** | Rupture/seuil | 🔴 Rouge | Réapprovisionner |
| **Aliments en alerte** | Stock faible/expiration | 🟠 Orange | Commander |
| **Lapins sous-poids** | < 80% attendu | 🟠/🔴 (si > 3) | Vérifier alimentation |
| **Lapins malades** | > 0 | 🟠/🔴 (si > 2) | Soigner/isoler |
| **Taux mortalité élevé** | > 5% | 🟠/🔴 (si > 10%) | Analyse causes |

**💡 Astuce** : Appuyez sur une carte pour accéder directement à l'écran détaillé (ex : carte "Soins urgents" → écran Santé).

### 4️⃣ Performance globale (4 indicateurs)

Vue synthétique de la santé de l'élevage :

#### 🐰 Lapins actifs
- **Valeur** : Nombre total de lapins actifs (non vendus, non décédés)
- **Sous-titre** : Nombre de femelles reproductrices
- **Navigation** : Vers Cheptel

#### 📈 GMQ moyen (Gain Moyen Quotidien)
- **Valeur** : GMQ en grammes (indicateur de croissance)
- **Objectif** : ~35-40g/jour pour lapins moyens
- **Sous-titre** : Nombre de pesées ce mois
- **Navigation** : Vers Cheptel

#### 👨‍👩‍👧‍👦 Taux de reproduction
- **Valeur** : % d'accouplements réussis
- **Objectif** : > 80%
- **Sous-titre** : Nombre d'accouplements actifs
- **Pas de navigation**

#### 💰 Bénéfice mensuel
- **Valeur** : Recettes - (Dépenses + Coûts alimentation)
- **Couleur** : Vert si positif, rouge si négatif
- **Sous-titre** : Recettes mensuelles
- **Navigation** : Vers Finances

#### 📊 Détails financiers (barre horizontale)
- **Dépenses** : Total des dépenses du mois (rouge)
- **Alimentation** : Coût alimentation estimé (orange)

### 5️⃣ Prochaines tâches (Upcoming Tasks)

Liste des actions à venir (conservée de l'ancienne version).

## 🔄 Actualisation des données

- **Pull-to-refresh** : Tirez vers le bas depuis le haut de l'écran pour recharger
- **Synchronisation automatique** : Au lancement de l'application
- **Bouton sync** : Dans le header (icône cloud)

## 🎨 Mode clair/sombre

Le dashboard s'adapte automatiquement au thème choisi dans les paramètres :
- **Mode clair** : Fond blanc, couleurs vives
- **Mode sombre** : Fond gris foncé, couleurs adoucies

## 📱 Navigation rapide

Chaque carte actionnable vous redirige vers l'écran approprié :

| Carte | Destination | Onglet |
|-------|-------------|--------|
| Femelles gestantes | Reproduction | Accouplements |
| Mises bas prévues | Reproduction | Portées |
| Soins urgents | Santé | - |
| Vaccins en retard | Santé | - |
| Médicaments critiques | Stock | Médicaments |
| Aliments en alerte | Stock | Aliments |
| Lapins sous-poids | Cheptel | - |
| Lapins malades | Santé | - |
| Lapins actifs | Cheptel | - |
| GMQ moyen | Cheptel | - |
| Bénéfice mensuel | Finances | - |

## 🆘 Que faire en cas de carte rouge ?

### 🔴 Soins urgents (<3 jours)
1. Appuyez sur la carte
2. Consultez les soins avec rappel proche
3. Effectuez les soins nécessaires
4. Cochez le soin comme "effectué" ou reportez le rappel

### 🔴 Vaccins en retard
1. Appuyez sur la carte
2. Identifiez les lapins concernés
3. Planifiez la vaccination d'urgence
4. Enregistrez le soin dans l'application

### 🔴 Médicaments critiques
1. Appuyez sur la carte (→ Stock > Médicaments)
2. Identifiez les produits en rupture ou sous seuil
3. Passez commande immédiatement
4. Mettez à jour le stock à réception

### 🔴 Taux mortalité > 10%
1. Appuyez sur la carte (→ Santé)
2. Analysez les causes (âge, maladie, conditions)
3. Vérifiez hygiène, alimentation, température
4. Consultez un vétérinaire si nécessaire

## 🟠 Que faire en cas de carte orange ?

### 🟠 Mises bas prévues (14 jours)
1. Vérifiez le matériel (nid, paille, lampe chauffante)
2. Surveillez les femelles gestantes
3. Préparez les cages de mise bas
4. Notez les dates dans votre agenda

### 🟠 Aliments en alerte
1. Vérifiez les dates d'expiration
2. Utilisez en priorité les aliments proches expiration
3. Commandez du stock si niveau faible
4. Mettez à jour les quantités dans l'app

### 🟠 Lapins sous-poids
1. Identifiez les lapins concernés
2. Vérifiez leur alimentation (quantité, qualité)
3. Pesez-les régulièrement (1x/semaine)
4. Isolez si nécessaire pour observation

## 📌 Bonnes pratiques

✅ **Consultez le dashboard chaque matin** (5 secondes suffisent)
✅ **Traitez les cartes rouges en priorité** (action immédiate)
✅ **Planifiez les cartes oranges** (action dans les 7 jours)
✅ **Utilisez la navigation rapide** (1 tap sur la carte)
✅ **Actualisez après chaque action** (pull-to-refresh)

❌ **Ne négligez pas les alertes rouges** (risque sanitaire/financier)
❌ **Ne reportez pas indéfiniment les alertes oranges** (elles deviennent rouges)
❌ **N'oubliez pas de mettre à jour les données** (stock, pesées, soins)

## 🎓 Comprendre les indicateurs

### GMQ (Gain Moyen Quotidien)
- **Calcul** : (Poids final - Poids initial) × 1000 / Nombre de jours
- **Interprétation** :
  - 30-35g/j : Moyen
  - 35-40g/j : Bon
  - >40g/j : Excellent
  - <30g/j : Problème (alimentation, maladie)

### Taux de reproduction
- **Calcul** : (Accouplements réussis / Total accouplements) × 100
- **Interprétation** :
  - >80% : Excellent
  - 60-80% : Bon
  - <60% : À améliorer (vérifier mâles, femelles, conditions)

### Bénéfice mensuel
- **Calcul** : Recettes - (Dépenses + Coût alimentation)
- **Interprétation** :
  - Positif : Élevage rentable
  - Négatif : Ajuster coûts ou prix de vente

### Lapins sous-poids
- **Seuil** : < 80% du poids attendu selon l'âge
- **Poids attendus** :
  - 0-8 semaines : ~100g + (50g × semaines)
  - 2-6 mois : 2.5-3.3kg
  - >6 mois : 3.5kg (moyenne)

## 💬 Support

Si vous avez des questions sur le dashboard ou besoin d'aide pour interpréter un indicateur, consultez le [Guide Utilisateur complet](GUIDE_UTILISATEUR.md) ou contactez le support.

---

**Version** : 1.0 (Dashboard enrichi - Phase P0.7)
**Dernière mise à jour** : Janvier 2025
