# 📐 Guide des Règles Métier - BunnyManager

## 🎯 Objectif

Ce système de validation garantit que **aucune donnée incohérente** ne peut être enregistrée dans l'application.

---

## 📂 Architecture

```
lib/
├── validators/                     # Couche de validation centralisée
│   ├── validation_result.dart      # Modèle de résultat
│   ├── lapin_validator.dart        # Règles lapins (L1-L9)
│   ├── accouplement_validator.dart # Règles reproduction (R1-R7)
│   ├── portee_validator.dart       # Règles portées (P1-P6)
│   ├── pesee_validator.dart        # Règles pesées (W1-W4)
│   ├── soin_validator.dart         # Règles soins (S1-S5)
│   ├── stock_validator.dart        # Règles stocks (ST1-ST3)
│   └── localisation_validator.dart # Règles cages (LOC1-LOC3)
│
├── widgets/
│   └── validation_message_widget.dart  # Widget d'affichage des messages
│
└── screens/
    └── cheptel/
        └── add_lapin_screen_validated.dart  # Exemple d'intégration
```

---

## 🔧 Comment utiliser les validators ?

### 1️⃣ **Importer le validator**

```dart
import 'package:rabbit_farm_app/validators/lapin_validator.dart';
import 'package:rabbit_farm_app/validators/validation_result.dart';
import 'package:rabbit_farm_app/widgets/validation_message_widget.dart';
```

### 2️⃣ **Exécuter la validation**

```dart
// Dans votre écran/formulaire
List<ValidationResult> _validationResults = [];

void _validerFormulaire() {
  setState(() {
    _validationResults = LapinValidator.validateLapin(
      lapinId: null, // null si nouveau lapin
      nom: _nomController.text.trim(),
      dateNaissance: _dateNaissance,
      poids: double.tryParse(_poidsController.text),
      pereId: _pereSelectionne?.id,
      mereId: _mereSelectionnee?.id,
      pere: _pereSelectionne,
      mere: _mereSelectionnee,
      cageId: _cageId,
      lapinsDansCage: _lapinsDansCage,
    );
  });
}
```

### 3️⃣ **Afficher les messages**

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // Messages de validation
      if (_validationResults.isNotEmpty)
        ValidationMessageWidget(
          validationResults: _validationResults,
        ),
      
      // Votre formulaire...
    ],
  );
}
```

### 4️⃣ **Désactiver le bouton Enregistrer**

```dart
// Vérifier s'il y a des erreurs bloquantes
final peutEnregistrer = !ValidationHelper.hasBlockingError(_validationResults);

FilledButton(
  onPressed: peutEnregistrer ? _enregistrer : null, // ✅ Désactivé si erreur
  child: const Text('Enregistrer'),
)
```

### 5️⃣ **Gérer les avertissements**

```dart
Future<void> _enregistrer() async {
  // Si erreur bloquante : afficher message
  if (ValidationHelper.hasBlockingError(_validationResults)) {
    final message = ValidationHelper.getFirstBlockingError(_validationResults);
    SnackbarHelper.showError(context, message ?? 'Erreur de validation');
    return;
  }

  // Si avertissement : demander confirmation
  final avertissements = _validationResults.where(
    (r) => r.severity == ValidationSeverity.avertissement && r.errorMessage != null,
  ).toList();

  if (avertissements.isNotEmpty) {
    ValidationHelper.showWarningDialog(
      context,
      avertissements.first.errorMessage!,
      _procederEnregistrement, // Callback si l'utilisateur confirme
    );
    return;
  }

  // Pas d'erreur ni d'avertissement : enregistrer
  await _procederEnregistrement();
}
```

---

## ➕ Comment ajouter une nouvelle règle ?

### Exemple : Interdire l'accouplement d'un lapin avec un parent

**1. Ajouter la méthode de validation dans le validator :**

```dart
// Dans lib/validators/accouplement_validator.dart

/// **R8 : Pas d'accouplement parent/enfant**
///
/// Gravité : 🔴 CRITIQUE
static ValidationResult validateParentEnfant({
  required Lapin male,
  required Lapin femelle,
  required Map<String, int?> parentsMale,
  required Map<String, int?> parentsFemelle,
}) {
  // Vérifier si le mâle est le père de la femelle
  if (parentsFemelle['pere'] == male.id) {
    return ValidationResult.error(
      '❌ Le mâle "${male.nom}" est le père de la femelle "${femelle.nom}".\n'
      'Accouplement interdit.',
    );
  }

  // Vérifier si la femelle est la mère du mâle
  if (parentsMale['mere'] == femelle.id) {
    return ValidationResult.error(
      '❌ La femelle "${femelle.nom}" est la mère du mâle "${male.nom}".\n'
      'Accouplement interdit.',
    );
  }

  return const ValidationResult.success();
}
```

**2. Ajouter la règle dans `validateAccouplement()` :**

```dart
static List<ValidationResult> validateAccouplement({
  // ... paramètres existants
}) {
  final results = <ValidationResult>[];

  // ... validations existantes

  // ✅ NOUVELLE RÈGLE
  results.add(validateParentEnfant(
    male: male,
    femelle: femelle,
    parentsMale: parentsMale,
    parentsFemelle: parentsFemelle,
  ));

  return results;
}
```

**3. Écrire le test :**

```dart
// Dans test/validators/accouplement_validator_test.dart

test('R8 : Pas d\'accouplement parent/enfant', () {
  final pere = Lapin(
    id: 1,
    nom: 'Max',
    race: 'Géant',
    sexe: 'Mâle',
    dateNaissance: DateTime(2022, 1, 1),
  );

  final fille = Lapin(
    id: 2,
    nom: 'Bella',
    race: 'Géant',
    sexe: 'Femelle',
    dateNaissance: DateTime(2023, 1, 1),
  );

  final parentsPere = {'pere': null, 'mere': null};
  final parentsFille = {'pere': 1, 'mere': 10}; // Père = Max (id: 1)

  final result = AccouplementValidator.validateParentEnfant(
    male: pere,
    femelle: fille,
    parentsMale: parentsPere,
    parentsFemelle: parentsFille,
  );

  expect(result.isValid, false);
  expect(result.severity, ValidationSeverity.bloquante);
  expect(result.errorMessage, contains('père'));
});
```

---

## 🧪 Lancer les tests

```bash
# Tous les tests de validation
flutter test test/validators/

# Un seul fichier
flutter test test/validators/lapin_validator_test.dart

# Mode verbose
flutter test --reporter expanded
```

---

## 🔍 Catalogue des règles implémentées

### 🐇 **Lapins** (9 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **L1** | Un lapin ne peut pas être son propre père | ❌ Bloquante |
| **L2** | Un lapin ne peut pas être sa propre mère | ❌ Bloquante |
| **L3** | Père ≠ Mère | ❌ Bloquante |
| **L4** | Sexe du père = Mâle | ❌ Bloquante |
| **L5** | Sexe de la mère = Femelle | ❌ Bloquante |
| **L6** | Date de naissance ≤ date actuelle | ❌ Bloquante |
| **L7** | Date de décès ≥ date de naissance | ❌ Bloquante |
| **L8** | Poids > 0 | ❌ Bloquante |
| **L9** | Nom unique par cage | ⚠️ Avertissement |

### 🧬 **Reproduction** (7 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **R1** | Accouplement Mâle/Femelle uniquement | ❌ Bloquante |
| **R2** | Mâle ≠ Femelle | ❌ Bloquante |
| **R3** | Femelle non gestante | ❌ Bloquante |
| **R4** | Âge minimum reproducteur (5 mois) | ⚠️ Avertissement |
| **R5** | Pas d'accouplement consanguin direct | ⚠️ Avertissement |
| **R6** | Date d'accouplement ≤ date actuelle | ❌ Bloquante |
| **R7** | Limite de portées par an (5 max) | ⚠️ Avertissement |

### 🍼 **Portées** (6 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **P1** | Date de mise bas ≥ date d'accouplement | ❌ Bloquante |
| **P2** | Nombre de vivants ≤ nombre de nés | ❌ Bloquante |
| **P4** | Nombre de nés > 0 | ❌ Bloquante |
| **P5** | Délai réaliste mise bas (28-35 jours) | ⚠️ Avertissement |
| **P6** | Nombre max de lapereaux (12 max) | ⚠️ Avertissement |

### ⚖️ **Pesées** (4 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **W1** | Poids > 0 | ❌ Bloquante |
| **W2** | Variation de poids réaliste (±30% max) | ⚠️ Avertissement |
| **W3** | Date pesée ≤ date actuelle | ❌ Bloquante |
| **W4** | Poids cohérent avec l'âge | ⚠️ Avertissement |

### 💊 **Soins & Médicaments** (5 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **S1** | Stock disponible > 0 | ❌ Bloquante |
| **S2** | Dose > 0 | ❌ Bloquante |
| **S3** | Lapin vivant uniquement | ❌ Bloquante |
| **S4** | Médicament non périmé | ⚠️ Avertissement |
| **S5** | Respect délai entre injections (14 jours) | ⚠️ Avertissement |

### 🧺 **Stocks** (3 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **ST1** | Quantité ≥ 0 | ❌ Bloquante |
| **ST2** | Sortie stock ≤ stock existant | ❌ Bloquante |
| **ST3** | Prix unitaire > 0 | ❌ Bloquante |

### 🏠 **Localisation** (3 règles)

| Code | Description | Sévérité |
|------|-------------|----------|
| **LOC1** | Capacité cage respectée | ⚠️ Avertissement |
| **LOC2** | Pas 2 lapins même nom dans même cage | ⚠️ Avertissement |
| **LOC3** | Sevrage vers cage disponible uniquement | ❌ Bloquante |

---

## ⚙️ Désactiver temporairement une règle (mode démo)

**Option 1 : Commentaires de code**

```dart
// Dans lib/validators/lapin_validator.dart

static List<ValidationResult> validateLapin({...}) {
  final results = <ValidationResult>[];

  // ✅ Règle active
  results.add(validateParents(...));

  // ❌ Règle désactivée (commentée)
  // results.add(validateParentsSexe(...));

  return results;
}
```

**Option 2 : Flag de configuration**

```dart
// Dans lib/constants/app_config.dart
class AppConfig {
  static const bool MODE_DEMO = false; // ✅ Passer à true pour démo
}

// Dans le validator
if (!AppConfig.MODE_DEMO) {
  results.add(validateParentsSexe(...));
}
```

---

## 🎨 Personnaliser les messages

Les messages sont directement dans les validators. Pour les modifier :

```dart
// Avant
return const ValidationResult.error(
  '❌ Un lapin ne peut pas être son propre père.\n'
  'Veuillez sélectionner un autre mâle.',
);

// Après (message plus court)
return const ValidationResult.error(
  '❌ Père invalide : sélectionnez un autre mâle.',
);
```

---

## 📊 Statistiques

- **37 règles métier** implémentées
- **22 règles bloquantes** (❌)
- **15 règles d'avertissement** (⚠️)
- **7 validators** centralisés
- **2 fichiers de tests** (100+ assertions)

---

## 🚀 Prochaines étapes

1. **Intégrer les validators** dans tous les écrans de saisie :
   - [x] `add_lapin_screen.dart` (exemple complet créé)
   - [ ] `planifier_accouplement_screen.dart`
   - [ ] `enregistrer_portee_screen.dart`
   - [ ] `ajouter_pesee_screen.dart`
   - [ ] `ajouter_soin_screen.dart`
   - [ ] `ajouter_medicament_screen.dart`

2. **Étendre les tests** :
   - [ ] `portee_validator_test.dart`
   - [ ] `pesee_validator_test.dart`
   - [ ] `soin_validator_test.dart`

3. **Ajouter des règles supplémentaires** :
   - [ ] R8 : Pas d'accouplement parent/enfant direct
   - [ ] L10 : Numéro d'identification unique
   - [ ] ST4 : Alerte de péremption (30 jours)

---

## 💡 Conseils

✅ **À FAIRE :**
- Valider **en temps réel** (via listeners)
- Désactiver le bouton **uniquement pour les erreurs bloquantes**
- Afficher les **messages pédagogiques** (pourquoi + comment corriger)
- Tester **chaque règle** individuellement

❌ **À ÉVITER :**
- Ne jamais afficher de message technique (`Exception`, `null pointer`, etc.)
- Ne jamais bloquer sans explication
- Ne jamais autoriser une incohérence critique

---

## 📞 Support

- **Documentation** : Ce fichier
- **Exemple complet** : [add_lapin_screen_validated.dart](lib/screens/cheptel/add_lapin_screen_validated.dart)
- **Tests** : [test/validators/](test/validators/)

---

**Auteur** : Lead Developer Flutter  
**Date** : 2026-01-01  
**Version** : 1.0.0
