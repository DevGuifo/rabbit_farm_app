/// Configuration Supabase
///
/// ⚠️ IMPORTANT : Ne pas commiter les vraies clés dans le repository
/// Utiliser des variables d'environnement au moment du build :
///
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
///
/// Ou créer un fichier .env (NON versionné) et utiliser un script de build.
class SupabaseConfig {
  /// URL de votre projet Supabase
  /// Définie via --dart-define=SUPABASE_URL=... ou valeur par défaut
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyufnlmelzzppqjgpxak.supabase.co',
  );

  /// Clé publique (anon) de votre projet Supabase
  /// Définie via --dart-define=SUPABASE_ANON_KEY=... ou valeur par défaut
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_sZ7zKSVmMzNfIbPtEGk7dA__JXcre3v',
  );

  /// Vérifier si la configuration est valide
  static bool get isValid {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }

  /// Vérifier si Supabase est configuré (non vide)
  static bool get isConfigured {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }

  /// Message d'erreur si configuration manquante
  static String get configurationError {
    if (url.isEmpty && anonKey.isEmpty) {
      return 'Configuration Supabase manquante. Définir SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define';
    }
    if (url.isEmpty) {
      return 'SUPABASE_URL manquant. Définir via --dart-define=SUPABASE_URL=...';
    }
    if (anonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY manquant. Définir via --dart-define=SUPABASE_ANON_KEY=...';
    }
    return '';
  }
}
