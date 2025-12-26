// Tests de l'application Mon Élevage Lapins

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rabbit_farm_app/main.dart';
import 'package:rabbit_farm_app/providers/theme_provider.dart';

void main() {
  testWidgets('Test de chargement de l\'application', (
    WidgetTester tester,
  ) async {
    // Create ThemeProvider for test
    final themeProvider = ThemeProvider();
    await themeProvider.loadTheme();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: BunnyManagerApp(themeProvider: themeProvider),
      ),
    );

    // Attendre que l'application se charge
    await tester.pumpAndSettle();

    // Vérifier que le titre de l'application est présent dans la navigation
    expect(find.text('Cheptel'), findsOneWidget);
  });
}
