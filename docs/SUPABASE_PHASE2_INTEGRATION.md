# Phase 2 - Intégration Supabase Propre

## Résumé

Cette phase a mis en place une architecture Supabase **propre et offline-first** pour BunnyManager.

## Fichiers Créés

### 1. Configuration Supabase
**Fichier** : [lib/config/supabase_config.dart](lib/config/supabase_config.dart)

- Singleton `SupabaseConfig` centralisant toute la config
- Variables d'environnement pour URL et clé anon (`--dart-define`)
- Initialisation conditionnelle (l'app fonctionne sans Supabase)
- Getters sécurisés : `client`, `clientOrThrow`, `currentUser`, `isAuthenticated`

**Usage** :
```dart
// Dans main.dart
await supabaseConfig.initialize();

// N'importe où
if (supabaseConfig.isInitialized) {
  final user = supabaseConfig.currentUser;
}
```

### 2. Schéma SQL Supabase
**Fichier** : [supabase/schema.sql](supabase/schema.sql)

Tables créées :
| Table | Description |
|-------|-------------|
| `user_profiles` | Profil utilisateur étendu |
| `farms` | Informations élevage (1 par user) |
| `sync_queue` | Queue de synchronisation |
| `sync_logs` | Historique des syncs (analytics) |
| `analytics_events` | Événements anonymisables |

**Sécurité RLS** : Chaque table a des policies Row Level Security pour que chaque utilisateur ne voie que SES données.

### 3. Service de Synchronisation
**Fichier** : [lib/services/sync_service.dart](lib/services/sync_service.dart)

Architecture offline-first :
1. Opérations CRUD locales (SQLite) en premier
2. Enregistrement dans `sync_queue` locale
3. Sync vers Supabase quand disponible
4. Gestion des retry (max 3 tentatives)
5. Auto-sync toutes les 5 minutes

**API** :
```dart
// Ajouter à la queue
await SyncService().enqueue(
  tableName: 'lapins',
  localId: lapin.id!,
  operation: SyncOperation.update,
  payload: lapin.toMap(),
);

// Synchroniser maintenant
final result = await SyncService().syncNow();
```

### 4. Provider de Synchronisation
**Fichier** : [lib/providers/sync_provider.dart](lib/providers/sync_provider.dart)

- Intégration avec l'onboarding (sync seulement après onboarding terminé)
- États : `idle`, `syncing`, `success`, `error`, `unavailable`, `waitingForNetwork`
- Messages explicatifs pour chaque état
- Contrôle auto-sync depuis les paramètres

### 5. Widget Indicateur de Statut
**Fichier** : [lib/widgets/sync_status_indicator.dart](lib/widgets/sync_status_indicator.dart)

Composants UI :
- `SyncStatusIndicator` : Icône avec badge pour AppBar
- `SyncStatusTile` : ListTile pour écran Paramètres
- `SyncStatusDialog` : Dialog détaillé avec actions

## Configuration Requise

### Variables d'environnement

Pour activer Supabase, lancer l'app avec :
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Ou créer un fichier `.env` (nécessite package `flutter_dotenv`).

### Supabase Dashboard

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Aller dans SQL Editor
3. Exécuter le contenu de `supabase/schema.sql`
4. Activer Email Auth dans Authentication > Providers
5. Récupérer URL et anon key dans Settings > API

## Architecture Finale

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ SyncStatusIndicator │ SyncStatusTile │ SyncStatusDialog ││
│  └─────────────────────────────────────────────────────────┘│
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                      Provider Layer                          │
│  ┌──────────────────┐  ┌──────────────────────────────────┐ │
│  │   SyncProvider   │  │      OnboardingProvider          │ │
│  │ (état sync UI)   │◄─│ (autorise sync si terminé)       │ │
│  └────────┬─────────┘  └──────────────────────────────────┘ │
└───────────┼─────────────────────────────────────────────────┘
            │
┌───────────▼─────────────────────────────────────────────────┐
│                     Service Layer                            │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                    SyncService                            ││
│  │  • Queue locale (sync_queue SQLite)                       ││
│  │  • Sync vers Supabase si disponible                       ││
│  │  • Auto-sync timer                                        ││
│  │  • Retry logic                                            ││
│  └────────────────────────┬─────────────────────────────────┘│
└───────────────────────────┼─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                     Storage Layer                            │
│  ┌──────────────────┐    ┌──────────────────────────────────┐│
│  │ SQLite (local)   │    │ Supabase (cloud, optionnel)      ││
│  │ • Données métier │    │ • Backup                         ││
│  │ • sync_queue     │───▶│ • Multi-device sync              ││
│  │ • 100% offline   │    │ • Analytics                      ││
│  └──────────────────┘    └──────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Flux de Synchronisation

```
1. Utilisateur modifie un lapin localement
   └── LapinProvider.updateLapin()
       └── DatabaseHelper.updateLapin() (SQLite)
       └── SyncService.enqueue(operation: update)
           └── sync_queue.insert (SQLite)
           └── pendingCount++

2. Auto-sync timer (toutes les 5 min) OU utilisateur clique "Sync"
   └── SyncService.syncNow()
       └── getPendingItems() from sync_queue
       └── Pour chaque item:
           └── supabase.from(table).upsert(payload)
           └── Si succès: markItemSynced()
           └── Si échec: incrementRetryCount()
       └── Écrire sync_logs pour analytics

3. UI reflète l'état via SyncProvider
   └── SyncStatusIndicator affiche badge avec pendingCount
   └── SyncStatusDialog montre détails et permet sync manuelle
```

## Intégration Onboarding

La synchronisation ne s'active qu'après :
1. **Onboarding terminé** (`OnboardingStatus.estTermine = true`)
2. **Utilisateur autorise** (`OnboardingStatus.synchronisationAutorisee = true`)
3. **Supabase configuré** (`supabaseConfig.isInitialized`)

```dart
// Dans OnboardingProvider après fin d'onboarding:
final syncProvider = Provider.of<SyncProvider>(context, listen: false);
syncProvider.onOnboardingCompleted(
  syncAuthorized: _status!.synchronisationAutorisee,
);
```

## Prochaines Étapes Recommandées

1. **Initialisation dans main.dart** :
   - Ajouter `await supabaseConfig.initialize();`
   - Charger état onboarding et appeler `syncProvider.setOnboardingState()`

2. **Intégrer SyncStatusIndicator dans l'AppBar** :
   ```dart
   AppBar(
     actions: [
       SyncStatusIndicator(),
     ],
   )
   ```

3. **Connecter les opérations CRUD** :
   - Après chaque insert/update/delete, appeler `SyncService().enqueue()`

4. **Tests** :
   - Tester avec et sans configuration Supabase
   - Vérifier que l'app fonctionne 100% offline
   - Tester la sync après rétablissement connexion

## Résumé des Changements

| Fichier | Action |
|---------|--------|
| `pubspec.yaml` | ✅ Ajouté `supabase_flutter: ^2.5.0` |
| `lib/config/supabase_config.dart` | ✅ Créé |
| `supabase/schema.sql` | ✅ Créé |
| `lib/services/sync_service.dart` | ✅ Réécrit (queue complète) |
| `lib/providers/sync_provider.dart` | ✅ Réécrit (intégration Supabase + onboarding) |
| `lib/widgets/sync_status_indicator.dart` | ✅ Créé |

**Résultat** : 0 erreurs, 19 warnings/infos (principalement `withOpacity` deprecated).
