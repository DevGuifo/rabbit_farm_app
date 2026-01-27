## Sécurité & Configuration Supabase

### Objectifs

- Éviter de commiter des secrets dans le dépôt Git.
- Séparer clairement configuration de développement et de production.
- Garantir que l’application reste fonctionnelle en mode offline-first, même sans Supabase.

---

### 1. Clés Supabase dans le code

**Fichier** : `lib/config/supabase_config.dart`

- Les valeurs par défaut sont **des placeholders** :
  - URL : `https://example.supabase.co`
  - Clé anon : `sb_publishable_EXAMPLE_KEY_DO_NOT_USE`
- Ces valeurs permettent uniquement :
  - de documenter la configuration,
  - d’éviter que l’app plante si les `--dart-define` ne sont pas fournis.

**Règle** :  
Ne jamais commiter de vraies URL / clés Supabase (prod ou preprod) dans ce fichier.

---

### 2. Configuration en local / dev

Lancer l’application avec des variables d’environnement explicites :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxxxx
```

ou via `launch.json` / configuration IDE équivalente.

Pour éviter de dupliquer les valeurs :

- Option 1 : utiliser un script shell / PowerShell qui injecte les `--dart-define`.
- Option 2 : utiliser un fichier `.env` (avec un package type `flutter_dotenv`) **non commité**.

---

### 3. Configuration en production (builds)

Pour les builds de production (CI/CD ou manuels) :

- Utiliser toujours `--dart-define` ou les mécanismes de votre pipeline (GitHub Actions, GitLab CI, etc.).
- Stocker les vraies valeurs dans un gestionnaire de secrets (GitHub Secrets, Vault, etc.), jamais dans le code.

Exemple (build Android) :

```bash
flutter build appbundle \
  --release \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
```

---

### 4. Mode offline-first sans Supabase

Si aucune configuration Supabase n’est fournie :

- `SupabaseConfig.hasValidConfig` retourne `false`.
- `SupabaseConfig.initialize()` loggue un warning et retourne `false`.
- `SyncProvider` reste en état `unavailable` et l’app fonctionne en **mode 100 % local** :
  - Auth locale (PIN + `SecureStorageService`)
  - Données SQLite uniquement

Cela permet :

- d’utiliser l’app dans des environnements déconnectés ou sensibles,
- de tester sans dépendre du backend.

---

### 5. Rotation des clés (aperçu)

La rotation de clés Supabase suit les principes suivants (détails à compléter dans la section “Rotation des clés”) :

1. Créer une nouvelle clé anon dans le dashboard Supabase.
2. Mettre à jour les secrets de la CI/CD et de l’infra (sans toucher au code).
3. Déployer une nouvelle version de l’app avec les nouvelles `--dart-define`.
4. Révoquer l’ancienne clé une fois le déploiement stabilisé.

Voir la tâche “sec-key-rotation” pour la procédure détaillée.

