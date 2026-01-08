# 🧮 Calculatrices Avancées - Rations et Dosages

## ✅ Implémentation Complétée

Un système avancé de calculatrices pour les rations alimentaires et les dosages de médicaments a été implémenté.

---

## 🎯 Fonctionnalités Implémentées

### 1. **Service de Calculs Avancés** (`AdvancedCalculatorService`)

#### Calculs de Dosages
- ✅ **Dosage simple** : Calcul selon poids × dosage/kg
- ✅ **Dosage avec dilution** : Calcul avec concentration du produit mère
- ✅ **Calcul de dilution** : Calcul des volumes de produit et diluant
- ✅ **Dosage pour groupe** : Calcul pour plusieurs lapins
- ✅ **Coût de traitement** : Calcul du coût selon dose utilisée

#### Calculs de Rations
- ✅ **Ration individuelle** : Calcul selon statut physiologique
- ✅ **Ration de groupe** : Calcul pour plusieurs lapins
- ✅ **Ajustement activité** : Facteur selon niveau d'activité
- ✅ **Coût mensuel** : Calcul du coût d'alimentation

#### Conversions d'Unités
- ✅ **ml ↔ mg** : Conversion selon concentration
- ✅ **kg ↔ grammes** : Conversion de poids

---

## 📊 Calculs Disponibles

### Dosages Médicaux

#### 1. Dosage Simple
```
Dose = Poids (kg) × Dosage (ml/kg ou mg/kg)
```

#### 2. Dosage avec Dilution
```
Volume à prélever = (Poids × Dosage/kg) / Concentration (mg/ml)
```

#### 3. Calcul de Dilution
```
Volume produit = (Concentration souhaitée × Volume final) / Concentration initiale
Volume diluant = Volume final - Volume produit
```

#### 4. Dosage pour Groupe
```
Dose totale = Poids total (kg) × Dosage (ml/kg)
```

### Rations Alimentaires

#### Ration Quotidienne par Statut

| Statut | Granulés | Foin | Eau |
|--------|----------|------|-----|
| **Lapereau** (0-8 sem) | 8% du poids | 50-80 g | 120 ml/kg |
| **Jeune** (8 sem - 5 mois) | 5% du poids | 80-120 g | 100 ml/kg |
| **Adulte** (entretien) | 3% du poids | 100-150 g | 100 ml/kg |
| **Gestante** | 6% du poids | 100-150 g | 150 ml/kg |
| **Allaitante** | 8% du poids | 150-200 g | 200 ml/kg |

#### Ajustement selon Activité
- **Faible** : -10% (facteur 0.9)
- **Normal** : 100% (facteur 1.0)
- **Élevé** : +15% (facteur 1.15)

---

## 🔧 Architecture Technique

### Service Créé

#### `AdvancedCalculatorService`
- **Fichier** : `lib/services/advanced_calculator_service.dart`
- **Rôle** : Fournir toutes les méthodes de calcul avancées
- **Singleton** : Instance unique partagée

### Classes Utilitaires

#### `RationResult`
Structure pour les résultats de calcul de ration :
```dart
class RationResult {
  final double granules;      // en grammes
  final double foinMin;       // en grammes
  final double foinMax;       // en grammes
  final double eau;           // en ml
  final Map<String, String> details;
}
```

---

## 📱 Interface Utilisateur

### Onglets de la Calculatrice

#### 1. **Santé** (Amélioré)
- ✅ Utilise maintenant `AdvancedCalculatorService`
- ✅ Calcul de dosage simple selon poids

#### 2. **Alimentation** (Amélioré)
- ✅ Utilise maintenant `AdvancedCalculatorService`
- ✅ Calcul de ration avec ajustement activité
- ✅ Support de tous les statuts physiologiques

#### 3. **Dosages Avancés** (Nouveau)
- ✅ **Mode simple** : Dosage basique
- ✅ **Mode dilution** : Dosage avec concentration
- ✅ **Mode groupe** : Dosage pour plusieurs lapins
- ✅ Interface intuitive avec sélection de mode

#### 4. **Performance** (Existant)
- ✅ Calcul du GMQ (Gain Moyen Quotidien)

#### 5. **Finance** (Existant)
- ✅ Calcul des besoins mensuels
- ✅ Coûts d'alimentation

---

## 💡 Exemples d'Utilisation

### Exemple 1 : Dosage Simple
```
Lapin : 2.5 kg
Dosage : 0.5 ml/kg
→ Dose = 2.5 × 0.5 = 1.25 ml
```

### Exemple 2 : Dosage avec Dilution
```
Lapin : 3.0 kg
Dosage : 10 mg/kg
Concentration produit mère : 50 mg/ml
→ Dose nécessaire = 3.0 × 10 = 30 mg
→ Volume à prélever = 30 / 50 = 0.6 ml
```

### Exemple 3 : Ration pour Lapin Gestante
```
Poids : 3.5 kg
Statut : Gestante
→ Granulés : 3.5 × 1000 × 0.06 = 210 g
→ Foin : 100-150 g
→ Eau : 3.5 × 150 = 525 ml
```

### Exemple 4 : Ration de Groupe
```
3 lapins adultes : 2.5 kg, 3.0 kg, 2.8 kg
→ Granulés totaux : ~240 g
→ Foin total : ~300-450 g
→ Eau totale : ~830 ml
```

---

## 🎨 Améliorations de l'Interface

### Nouvel Onglet "Dosages Avancés"
- **Sélection de mode** : Dropdown pour choisir le type de calcul
- **Champs dynamiques** : Les champs s'adaptent au mode sélectionné
- **Résultats détaillés** : Affichage clair avec toutes les informations

### Améliorations des Onglets Existants
- **Santé** : Utilise maintenant le service avancé
- **Alimentation** : Utilise maintenant le service avancé avec ajustements

---

## 🔄 Intégration

### Utilisation dans l'Application

#### Dans la Calculatrice
```dart
final calculator = AdvancedCalculatorService();

// Calcul de dosage
final dose = calculator.calculerDose(
  poidsKg: 2.5,
  dosageParKg: 0.5,
);

// Calcul de ration
final ration = calculator.calculerRation(
  poidsKg: 3.0,
  statutPhysiologique: 'gestante',
  niveauActivite: 'normal',
);
```

#### Dans d'autres Écrans
Le service peut être utilisé partout dans l'application pour :
- Calculer les dosages lors de l'ajout de soins
- Calculer les rations lors de la distribution d'aliments
- Calculer les coûts de traitements

---

## 📈 Fonctionnalités Futures Possibles

### À Implémenter
- [ ] Base de données de médicaments avec dosages standards
- [ ] Historique des calculs
- [ ] Export des calculs en PDF
- [ ] Calculs de rations pour portées
- [ ] Calculs de conversion d'aliments
- [ ] Calculs de besoins énergétiques (ME)

---

## 🎉 Résultat

L'application dispose maintenant d'un **système complet de calculatrices avancées** qui :

- ✅ **Calcule automatiquement** les dosages selon différents modes
- ✅ **Gère les dilutions** et concentrations
- ✅ **Calcule les rations** selon le statut physiologique
- ✅ **Ajuste selon l'activité** du lapin
- ✅ **Calcule pour des groupes** de lapins
- ✅ **Estime les coûts** de traitements et d'alimentation

**L'utilisateur peut maintenant effectuer tous les calculs nécessaires directement dans l'application !** 🎯

---

**Date de création** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Implémenté et fonctionnel

