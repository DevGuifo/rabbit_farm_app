# Changelog Stabilisation MVP - Rabbit Farm App

> **Date** : 2026-02-01  
> **Version** : 1.0.0

---

## 🔴 Corrections Critiques

### PRAGMA foreign_keys = ON
- **Fichier** : `lib/services/database_helper.dart`
- **Problème** : Les contraintes FK étaient déclarées mais non appliquées au runtime
- **Solution** : Ajout `onConfigure` dans `openDatabase` avec `PRAGMA foreign_keys = ON`
- **Impact** : Les FK sont maintenant enforced sur chaque connexion SQLite

---

## 🟠 Améliorations Haute Priorité

### Garde-fou suppression Lot
- **Fichier** : `lib/providers/lot_provider.dart`
- **Changement** : `supprimerLot()` vérifie `compterIndividusDuLot()` avant suppression
- **Comportement** : Lance `StateError` si lapins associés

### LotValidator
- **Nouveau fichier** : `lib/validators/lot_validator.dart`
- **Règles** :
  - LT1 : Empêche suppression lot avec lapins
  - LT2 : Vérifie effectif non négatif
  - LT3 : Valide format identifiant LP-YYYY-MM-XXX

### Méthode retirerLapinDuLot
- **Fichier** : `lib/providers/lot_provider.dart`
- **Fonction** : Retire un lapin du lot proprement (lot_id = null)
- **Impact** : Pas de perte de données, journal mis à jour

---

## 🟡 Nouvelles Fonctionnalités

### SyncIndicator Widget
- **Nouveau fichier** : `lib/widgets/sync_indicator.dart`
- **États affichés** :
  - ✓ Vert : Synchronisé
  - 🔄 Orange : N opérations en attente
  - ⚠️ Gris : Mode hors-ligne
  - ❌ Rouge : Erreur sync
- **Intégration** : Prêt pour UniformAppBar

### SeedDataService
- **Nouveau fichier** : `lib/services/seed_data_service.dart`
- **Fonction** : Génère données de test (lapins, lots)
- **Sécurité** : Actif uniquement en `kDebugMode`

---

## 📄 Documentation Produite

| Document | Contenu |
|----------|---------|
| `docs/AUDIT_ECRANS.md` | Inventaire complet des écrans |
| `docs/AUDIT_DONNEES.md` | Schéma SQLite, entités, relations |
| `docs/SYNC_OFFLINE_FIRST.md` | Architecture synchronisation |
| `docs/CHECKLIST_MVP.md` | Validation finale |

---

## 📊 Métriques

| Métrique | Avant | Après |
|----------|-------|-------|
| FK appliquées runtime | ❌ | ✅ |
| Suppression lot protégée | ❌ | ✅ |
| Indicateur sync UI | ❌ | ✅ |
| Documentation données | Partielle | Complète |
| Tests seed data | ❌ | ✅ |

---

## 🔄 Migration

Aucune migration de données requise. Les changements sont rétro-compatibles.

**Version SQLite** : 27 (inchangée)

---

## ⚠️ Breaking Changes

Aucun breaking change pour les utilisateurs finaux.

**Note développeurs** : La suppression d'un lot avec lapins associés lance maintenant une exception.
