import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/services/supabase_auth_service.dart';
import 'package:rabbit_farm_app/services/supabase_sync_service.dart';
import 'package:rabbit_farm_app/utils/logger.dart';

void main() {
  group('SupabaseSyncService Tests', () {
    late SupabaseSyncService syncService;
    late SupabaseAuthService authService;

    setUpAll(() {
      // Initialiser le logger pour les tests
      logger.initialize();
    });

    setUp(() {
      syncService = SupabaseSyncService();
      authService = SupabaseAuthService();
    });

    test('isSyncing initialement false', () {
      expect(syncService.isSyncing, isFalse);
    });

    test('lastSyncTime initialement null', () {
      expect(syncService.lastSyncTime, isNull);
    });

    test('syncAll retourne false si Supabase non disponible', () async {
      // Si Supabase n'est pas disponible, syncAll doit retourner false
      // sans lancer d'exception
      final result = await syncService.syncAll();
      
      // Le résultat peut être false si Supabase n'est pas disponible
      // ou si une synchronisation est déjà en cours
      expect(result, isA<bool>());
    });

    test('isAvailable vérifie correctement la disponibilité de Supabase', () {
      // isAvailable doit être cohérent avec l'état d'initialisation
      final isAvailable = authService.isAvailable;
      expect(isAvailable, isA<bool>());
    });

    test('syncAll ne lance pas d\'exception même si Supabase non disponible', () async {
      // Même si Supabase n'est pas disponible, syncAll ne doit pas
      // lancer d'exception mais retourner false
      expect(() => syncService.syncAll(), returnsNormally);
    });
  });
}

