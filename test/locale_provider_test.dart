import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/providers/locale_provider.dart';
import 'package:rabbit_farm_app/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialiser le logger et SharedPreferences pour les tests
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    logger.initialize(isProduction: false);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocaleProvider change la locale correctement', () async {
    final provider = LocaleProvider();

    // État initial
    expect(provider.locale.languageCode, 'fr');

    // Changement vers anglais
    await provider.setLocaleByName('English');
    expect(provider.locale.languageCode, 'en');

    // Changement vers français
    await provider.setLocaleByName('Français');
    expect(provider.locale.languageCode, 'fr');
  });

  test('LocaleProvider notifie les listeners', () async {
    final provider = LocaleProvider();
    int notificationCount = 0;

    provider.addListener(() {
      notificationCount++;
    });

    await provider.setLocaleByName('English');

    expect(notificationCount, greaterThan(0));
    expect(provider.locale.languageCode, 'en');
  });
}
