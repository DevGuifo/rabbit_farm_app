# Architecture Synchronisation Offline-First

> **Date** : 2026-02-01  
> **Phase** : D — Offline + Sync Supabase

---

## 1. Principes Architecturaux

### Offline-First = SQLite maître

```text
┌────────────────┐         ┌────────────────┐         ┌────────────────┐
│   UI Flutter   │◄───────►│   SQLite       │◄───────►│   Supabase     │
│   (read/write) │         │   (source of   │  async  │   (backup)     │
│                │         │    truth)      │  sync   │                │
└────────────────┘         └────────────────┘         └────────────────┘
```

**Règles fondamentales :**
1. L'app fonctionne **sans réseau** à 100%
2. SQLite est la **source de vérité** pour les données locales
3. Supabase est un **miroir asynchrone** pour backup et partage multi-device
4. Les conflits se résolvent par **horodatage** (last-write-wins)

---

## 2. Tables Synchronisées

| Table locale | Table Supabase | Stratégie sync |
|--------------|----------------|----------------|
| `lapins` | `lapins` | Push & Pull |
| `lots` | `lots` | Push & Pull |
| `accouplements` | `accouplements` | Push only |
| `portees` | `portees` | Push only |
| `soins` | `soins` | Push only |
| `pesees` | `pesees` | Push only |
| `deces` | `deces` | Push only |
| `quarantaines` | `quarantaines` | Push only |
| `cages` | `cages` | Push & Pull |
| `clapiers` | `clapiers` | Push & Pull |
| `batiments` | `batiments` | Push & Pull |

---

## 3. Queue de Synchronisation

### Table `sync_queue`

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  local_id INTEGER NOT NULL,        -- ID SQLite
  operation TEXT NOT NULL,          -- INSERT, UPDATE, DELETE
  payload TEXT,                     -- JSON des données
  status TEXT DEFAULT 'pending',    -- pending, syncing, synced, failed
  retry_count INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TEXT NOT NULL,
  synced_at TEXT,
  UNIQUE(table_name, local_id, operation, status)
);
```

### Cycle de vie

```text
PENDING → SYNCING → SYNCED
              ↓
           FAILED (retry_count++)
              ↓
      (retry après délai)
```

---

## 4. Mapping ID Local ↔ UUID Supabase

### Stratégie

```dart
// Structure SQLite
{
  "id": 42,                                    // local_id (INTEGER auto)
  "numero_identification": "LP-2026-01-042"    // business_id (TEXT unique)
}

// Structure Supabase
{
  "id": "a1b2c3d4-e5f6-...",                   // UUID Supabase
  "local_id": 42,                              // pour mapping retour
  "numero_identification": "LP-2026-01-042"    // business_id identique
}
```

### Synchronisation

```dart
// PUSH (SQLite → Supabase)
await supabase.from('lapins').upsert({
  ...lapinData,
  'local_id': lapin.id,  // Envoyer l'ID SQLite
});

// PULL (Supabase → SQLite)
final remote = await supabase.from('lapins').select();
for (final item in remote) {
  await db.update('lapins', item, where: 'id = ?', whereArgs: [item['local_id']]);
}
```

---

## 5. SyncService - API

```dart
class SyncService {
  /// Ajouter une opération à la queue
  Future<void> enqueue(String tableName, int localId, SyncOperation op, Map? payload);

  /// Nombre d'opérations en attente
  Stream<int> get pendingCountStream;

  /// Synchroniser maintenant
  Future<void> syncNow();

  /// Forcer sync + pull
  Future<void> fullSync();
}
```

---

## 6. Contraintes Référentielles

### PRAGMA foreign_keys

```dart
// database_helper.dart - _initDB()
return await openDatabase(
  path,
  version: 27,
  onConfigure: (db) async {
    await db.execute('PRAGMA foreign_keys = ON');  // ✅ Phase D
  },
  onCreate: _createDB,
  onUpgrade: _upgradeDB,
);
```

### Actions FK définies

| Relation | Action ON DELETE |
|----------|-----------------|
| `lapins.lot_id` → `lots` | RESTRICT (empêche suppression lot occupé) |
| `lapins.cage_id` → `cages` | SET NULL (lapin reste sans cage) |
| `lots.cage_id` → `cages` | SET NULL |
| `accouplements.male_id` → `lapins` | CASCADE |
| `accouplements.femelle_id` → `lapins` | CASCADE |
| `portees.accouplement_id` → `accouplements` | CASCADE |
| `soins.lapin_id` → `lapins` | CASCADE |
| `pesees.lapin_id` → `lapins` | CASCADE |

---

## 7. Gestion Erreurs & Retry

```dart
Future<void> _syncItem(SyncQueueItem item) async {
  try {
    switch (item.operation) {
      case SyncOperation.insert:
        await client.from(item.tableName).upsert(item.payload!);
        break;
      case SyncOperation.update:
        await client.from(item.tableName).update(item.payload!)
          .eq('local_id', item.localId);
        break;
      case SyncOperation.delete:
        await client.from(item.tableName).delete()
          .eq('local_id', item.localId);
        break;
    }
    await _markSynced(item.id);
  } catch (e) {
    await _markFailed(item.id, e.toString());
    if (item.retryCount < 3) {
      // Retry automatique
    }
  }
}
```

---

## 8. Indicateur UI

L'`UniformAppBar` affiche l'état de synchronisation :

| État | Icône | Couleur |
|------|-------|---------|
| Connecté, sync OK | ✓ | Vert |
| N opérations en attente | 🔄 (N) | Orange |
| Offline | ⚠️ | Gris |
| Erreur sync | ❌ | Rouge |

---

## 9. Vérification (Checklist Phase D)

- [x] `PRAGMA foreign_keys = ON` dans `onConfigure`
- [x] `sync_queue` créée via `CREATE TABLE IF NOT EXISTS`
- [x] Enqueue disponible dans `SyncService`
- [x] Mapping `local_id` ↔ UUID fonctionnel
- [ ] Pull minimal implémenté (à améliorer)
- [ ] Stratégie conflits documentée (à améliorer)
