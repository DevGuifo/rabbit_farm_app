# Nettoyage Supabase & Nouvelle Architecture

## Résumé

L'ancienne intégration Supabase (défaillante) a été **entièrement supprimée**. L'application fonctionne maintenant en **mode 100% offline-first** avec une architecture prête pour une réintégration propre de Supabase.

## Ce qui a été supprimé

### Fichiers supprimés
- `lib/services/supabase_auth_service.dart` (376 lignes)
- `lib/services/supabase_sync_service.dart` (822 lignes)
- `lib/config/supabase_config.dart` (60 lignes)
- `test/services/supabase_sync_test.dart`

### Dépendance retirée
```yaml
# pubspec.yaml - SUPPRIMÉ
supabase_flutter: ^2.5.0
```

## Nouvelle architecture (offline-first)

### Nouveaux services créés

| Fichier | Description |
|---------|-------------|
| `lib/services/auth_service.dart` | Authentification 100% locale |
| `lib/services/sync_service.dart` | Queue de sync locale (préparation) |

### Providers mis à jour

| Provider | Changements |
|----------|-------------|
| `auth_provider.dart` | Utilise `AuthService` local au lieu de `SupabaseAuthService` |
| `sync_provider.dart` | Utilise `SyncService` local, état `unavailable` par défaut |

## Comment ça fonctionne maintenant

### Authentification
1. L'utilisateur crée un compte → ID local généré (`local_<timestamp>_<random>_<hash>`)
2. Email et ID stockés dans `SecureStorage`
3. PIN configuré et validé localement
4. Aucune dépendance réseau

### Synchronisation
1. État par défaut : `SyncState.unavailable`
2. Les modifications sont marquées `is_dirty = 1` en base locale
3. Compteur `pendingChanges` disponible pour affichage UI
4. Aucune synchronisation effective (préparation pour Phase 2)

## Ce qui continue de fonctionner

✅ Création de compte  
✅ Connexion locale  
✅ Configuration/validation PIN  
✅ Onboarding complet  
✅ Toutes les fonctionnalités métier  
✅ Stockage SQLite local  
✅ Navigation de l'application  

## Prochaine étape : Réintégration Supabase propre

L'architecture est prête pour réintégrer Supabase de manière propre :

1. **Ajouter la dépendance** `supabase_flutter` dans `pubspec.yaml`
2. **Créer** `lib/services/supabase_client_provider.dart` (point d'entrée unique)
3. **Implémenter** la vraie synchronisation dans `sync_service.dart`
4. **Respecter** le principe offline-first (sync ne bloque jamais l'UI)

## Tables Supabase à créer (Phase 2)

```sql
-- Table farms (onboarding)
CREATE TABLE farms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  nom TEXT,
  region TEXT,
  pays TEXT,
  type_elevage TEXT NOT NULL,
  taille_elevage TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Table user_profiles (onboarding)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  role TEXT,
  niveau_experience TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Table events (analytics anonymes)
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID REFERENCES farms(id),
  event_type TEXT NOT NULL,
  event_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table sync_logs (suivi sync)
CREATE TABLE sync_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  sync_type TEXT,
  records_synced INTEGER,
  status TEXT,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## RLS à appliquer (Phase 2)

```sql
-- Politique : Chaque utilisateur voit uniquement ses données
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own farms"
  ON farms FOR ALL
  USING (auth.uid() = user_id);

-- Répéter pour user_profiles, events, sync_logs
```

## Règles absolues pour la Phase 2

1. ❌ **Jamais** de sync avant onboarding terminé
2. ❌ **Jamais** de blocage UI pendant sync
3. ❌ **Jamais** de données sensibles synchronisées
4. ✅ **Toujours** offline-first
5. ✅ **Toujours** queue locale avec retry
6. ✅ **Toujours** indicateur de statut visible

---

*Document créé le 8 janvier 2026*
*Phase 1 du nettoyage Supabase terminée*
