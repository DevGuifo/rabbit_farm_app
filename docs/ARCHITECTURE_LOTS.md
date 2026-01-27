# Architecture Gestion par Lots

## Vue d'ensemble

L'application supporte désormais la **gestion par lots** pour les élevages à grande échelle (500-1000+ sujets), tout en conservant la possibilité de gérer des individus spécifiques.

## Structure de l'identifiant

Format: `LP-YYYY-MM-NNN`

- **LP** : Préfixe "Lot"
- **YYYY** : Année (4 chiffres)
- **MM** : Mois (2 chiffres)
- **NNN** : Numéro séquentiel (001-999)

Exemple: `LP-2026-01-001` = Premier lot créé en janvier 2026

## Types de lots

| Type | Description | Usage typique |
|------|-------------|---------------|
| `engraissement` | Lots destinés à la vente/consommation | Lapins de chair |
| `reproduction` | Lots de reproducteurs | Mâles et femelles sélectionnés |
| `mixte` | Lots polyvalents | Migration, lots temporaires |

## Statuts des lots

| Statut | Description |
|--------|-------------|
| `actif` | Lot en cours de gestion |
| `en_attente` | Lot en préparation |
| `termine` | Lot clôturé (tous vendus/transférés) |
| `vendu` | Lot entièrement vendu |
| `reforme` | Lot réformé |

## Relation Lot ↔ Individu

```
┌─────────────────────────────────────────────────────────┐
│                         LOT                             │
│  - identifiant: LP-2026-01-001                         │
│  - effectifInitial: 50                                  │
│  - effectifActuel: 45                                   │
│  - type: engraissement                                  │
│  - hasIndividus: true/false                             │
└─────────────────────────────────────────────────────────┘
          │
          │ (optionnel)
          ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   INDIVIDU 1  │  │   INDIVIDU 2  │  │   INDIVIDU 3  │
│ (reproducteur)│  │ (malade)      │  │ (suivi spécial)│
│  lotId: 1     │  │  lotId: 1     │  │  lotId: 1     │
└───────────────┘  └───────────────┘  └───────────────┘
```

### Règles métier

1. **Un lot peut exister sans individus détaillés**
   - L'effectif est géré numériquement
   - Pas besoin de créer 500 fiches individuelles

2. **Les individus sont créés uniquement pour :**
   - Reproducteurs (suivi généalogique)
   - Lapins malades (suivi sanitaire)
   - Suivi exceptionnel (marquage, performances)

3. **Cascade logique :**
   - Suppression d'un lot → suppression des individus liés
   - Vente d'individu → décrémentation effectif du lot

## Schéma base de données

### Table `lots` (nouvelle)

```sql
CREATE TABLE lots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    identifiant TEXT NOT NULL UNIQUE,
    date_creation TEXT NOT NULL,
    effectif_initial INTEGER NOT NULL,
    effectif_actuel INTEGER NOT NULL,
    type TEXT NOT NULL,  -- engraissement, reproduction, mixte
    statut TEXT NOT NULL, -- actif, en_attente, termine, vendu, reforme
    cage_id INTEGER,
    metadata TEXT,  -- JSON: race, origine, poids, notes
    photo_path TEXT,
    has_individus INTEGER NOT NULL DEFAULT 0
);
```

### Modification table `lapins`

```sql
ALTER TABLE lapins ADD COLUMN lot_id INTEGER;
```

## Migration des données existantes

### Processus automatique

Lors de la première ouverture après mise à jour :

1. Migration BDD vers version 24
2. Création table `lots`
3. Ajout colonne `lot_id` sur `lapins`

### Migration manuelle des lapins existants

```dart
// Dans LotProvider
final lotMigration = await lotProvider.migrerLapinsExistants();
// Crée un lot "Migration" contenant tous les lapins sans lot
```

## Utilisation

### Créer un lot

```dart
final lot = await lotProvider.ajouterLot(
  effectif: 50,
  type: TypeLot.engraissement,
  cageId: 1,
  metadata: LotMetadata(
    race: 'Néo-Zélandais',
    origine: 'Fournisseur XYZ',
    poidsEntree: 1.2,
  ),
);
// lot.identifiant == 'LP-2026-01-001'
```

### Enregistrer mortalité

```dart
await lotProvider.enregistrerMortalite(
  lotId, 
  5,  // 5 décès
  notes: 'Épidémie respiratoire',
);
```

### Enregistrer vente

```dart
await lotProvider.enregistrerVente(
  lotId,
  20,  // 20 vendus
  prixTotal: 200.0,
);
```

### Assigner un individu à un lot

```dart
// Créer le lapin avec lotId
final lapin = Lapin(
  nom: 'Luna',
  race: 'Néo-Zélandais',
  sexe: 'Femelle',
  dateNaissance: DateTime.now().subtract(Duration(days: 120)),
  lotId: lot.id,
);

// Ou assigner un lapin existant
await lotProvider.assignerLapinAuLot(lapinId, lotId);
```

## Interface utilisateur

### Navigation

```
Plus > Lots > [Liste des lots]
                    │
                    ├── Nouveau lot
                    │
                    └── Détail lot
                          ├── Résumé
                          ├── Individus (optionnel)
                          └── Historique
```

### Actions rapides sur un lot

- Enregistrer mortalité
- Enregistrer vente
- Mettre à jour effectif
- Ajouter un individu
- Terminer le lot
- Supprimer le lot

## Indicateurs et alertes

| Indicateur | Seuil | Alerte |
|------------|-------|--------|
| Mortalité | > 10% | ⚠️ Mortalité élevée |
| Mortalité | > 5% | Lot à surveiller |
| Effectif | < 10% restant | Lot presque vide |

## Bonnes pratiques

1. **Créer des lots homogènes** : même âge, même origine
2. **Utiliser les métadonnées** : race, origine, notes
3. **Suivi individuel minimal** : uniquement reproducteurs et malades
4. **Clôturer les lots terminés** : éviter accumulation
5. **Migrer progressivement** : convertir anciens lapins en lots

## Fichiers impactés

### Nouveaux fichiers

- `lib/models/lot.dart` - Modèle Lot
- `lib/providers/lot_provider.dart` - Provider Lot
- `lib/services/database/lot_database_mixin.dart` - Mixin BDD
- `lib/screens/lots/lots_screen.dart` - Écran liste
- `lib/screens/lots/add_lot_screen.dart` - Écran ajout
- `lib/screens/lots/lot_detail_screen.dart` - Écran détail
- `lib/screens/lots/widgets/lot_card.dart` - Widget carte

### Fichiers modifiés

- `lib/models/lapin.dart` - Ajout `lotId`
- `lib/services/database_helper.dart` - Migration v24 + mixin
- `lib/core/providers/app_providers.dart` - Ajout LotProvider
- `lib/screens/plus/plus_screen.dart` - Lien navigation

## Version

- **Version BDD** : 24
- **Date implémentation** : Janvier 2026
- **Rétrocompatible** : ✅ Oui (lapins existants conservés)
