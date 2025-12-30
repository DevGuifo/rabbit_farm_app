# Mon Élevage Lapins - AI Agent Instructions

## Architecture Overview

This is a **Flutter mobile app** for rabbit farm management with **100% offline-first** SQLite architecture. Key components:

- **MVVM Pattern**: Providers (state) → Services (business logic) → Models (data)
- **Singleton Services**: `DatabaseHelper.instance`, `LocalisationService()`, `NavigationService()`, `NotificationService()`, `PdfService()`, `PhotoService()`
- **Provider State**: **17 providers** (`LapinProvider`, `ReproductionProvider`, `SanteProvider`, `FinanceProvider`, `ThemeProvider`, `DecesProvider`, `AlimentationProvider`, `AlerteProvider`, `FumierProvider`, `MedicamentProvider`, `QuarantaineProvider`, `ReformeProvider`, `SevrageProvider`, `PalpationProvider`, `PreparationNidProvider`, `ProtocoleSoinProvider`, `EvenementPersonnaliseProvider`)
- **SQLite Database**: Version 5 schema with 9 tables, cascading foreign keys, automatic migrations
- **Logger Pattern**: Phase P0.6 established - Use `logger.info()` / `logger.warning()` / `logger.error()` instead of `print()`. Initialized in `main()` with `logger.initialize(isProduction: false)`

## Critical Pattern: Provider Initialization

⚠️ **ALWAYS** use `addPostFrameCallback` when loading provider data in `initState()` to avoid "setState during build" errors:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _chargerDonnees(); // Calls Provider.of<T>(context, listen: false)
  });
}
```

See: `lib/screens/reproduction/reproduction_screen.dart:24`, `lib/screens/sante/sante_screen.dart:21`

## Logger Pattern (Phase P0.6)

⚠️ **NEVER** use `print()` - Use logger instead:

```dart
import 'package:rabbit_farm_app/utils/logger.dart';

// In main.dart
logger.initialize(isProduction: false);
logger.info('🚀 Démarrage BunnyManager');

// In any file
logger.info('User action: $_action');
logger.warning('Empty list returned from $_method');
logger.error('Failed to $_operation: $error');
```

39 `print()` statements replaced in Phase P0.6. Follow this pattern for all new code.

## Database Architecture

**DatabaseHelper** (1020 lines) manages SQLite with:
- **9 related tables**: `lapins`, `pesees`, `soins`, `accouplements`, `portees`, `recettes`, `depenses`, `ventes`, `relations`
- **Version migrations**: Each version adds schema changes (current: v5)
- **Relations table**: Stores genealogy (`lapin_id`, `pere_id`, `mere_id`) with `getRelationByLapinId()` returning `Map<String, int?>`
- **Cascade deletes**: ON DELETE CASCADE on all foreign keys

Key methods pattern:
```dart
Future<List<Lapin>> getAllLapins() // Returns all
Future<Lapin?> getLapinById(int id) // Returns one or null
Future<int> insertLapin(Lapin lapin) // Returns new ID
Future<void> updateLapin(Lapin lapin)
Future<void> deleteLapin(int id)
```

## Model Conventions

All models in `lib/models/` follow this pattern:
```dart
class Lapin {
  final int? id; // Nullable ID for new records
  final String nom; // Required fields
  final double? poids; // Optional nullable fields
  
  Lapin({this.id, required this.nom, this.poids});
  
  Map<String, dynamic> toMap() // For DB insert/update
  factory Lapin.fromMap(Map<String, dynamic> map) // For DB read
}
```

⚠️ **Computed properties** like `ageEnJours`, `ageEnMois`, `ageFormate` are in models, NOT database fields.

## Screen Structure Pattern

Standard screen layout (see `lib/screens/cheptel/cheptel_screen.dart`):
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyProvider>(context, listen: false).chargerTout();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Consumer<MyProvider>(
        builder: (context, provider, child) {
          return ListView.builder(...);
        },
      ),
      floatingActionButton: FloatingActionButton(...),
    );
  }
}
```

## Navigation & Localization

- **Material 3** theming with light/dark modes via `ThemeProvider`
- **French localization** required: `flutter_localizations` SDK with `Locale('fr', 'FR')`
- **Bottom Navigation**: 5 sections (Cheptel, Santé, Reproduction, Finances, Paramètres)
- Navigation via `Navigator.push(context, MaterialPageRoute(builder: (_) => Screen()))`

## Services Integration

**NotificationService** (singleton):
- Initialize in `main()`: `await NotificationService().initialize()`
- Schedule reminders: `planifierRappelVaccination(lapin, DateTime)`, `planifierRappelMiseBas(accouplement)`
- Channels: 'sante' and 'reproduction' with distinct priorities

**PdfService** (singleton):
- Methods: `genererFicheLapin()`, `genererRapportFinancier()`, `genererPedigree()`, `genererRapportReproduction()`
- Uses `printing_lib.Printing.layoutPdf()` with `pdf_lib.PdfPageFormat.a4`
- French number formatting: `NumberFormat('#,##0.00 €', 'fr_FR')`

**PhotoService** (singleton):
- `prendrePhoto()` / `choisirPhoto()` return compressed images (quality 85%, max 800x800)
- Stores in app documents: `path_provider.getApplicationDocumentsDirectory()`

## Key Commands

```bash
# Development
flutter run                           # Hot reload enabled
flutter build apk --release          # Production build (~53 MB)

# Database inspection
flutter run --debug                   # Access DevTools → Database Inspector

# Dependencies
flutter pub get                       # After pubspec changes
flutter pub outdated                  # Check version updates

# Testing
flutter test                          # Unit tests (lib/test/)
flutter analyze                       # Linting (expect ~80 info warnings)
```

## Common Patterns

**Form Validation**: All forms use `GlobalKey<FormState>` with `validator: (value) => value?.isEmpty ?? true ? 'Champ obligatoire' : null`

**Date Formatting**: Use `intl` package: `DateFormat('dd/MM/yyyy').format(date)` for French dates

**Photo Display**: 
```dart
lapin.photoPath != null && File(lapin.photoPath!).existsSync()
  ? Image.file(File(lapin.photoPath!), fit: BoxFit.cover)
  : Icon(Icons.pets, size: 50)
```

**Provider Access**:
- **Read once**: `Provider.of<T>(context, listen: false)` in methods
- **Rebuild on change**: `Consumer<T>(builder: (context, provider, _) => ...)`

## Testing Considerations

- **Test data**: `LapinProvider.initialiserDonneesTest()` creates sample lapins on first launch
- **Database reset**: Settings screen has "Réinitialiser l'application" (drops all tables)
- **Backup/Restore**: Export creates `elevage_backup_[date].db` in Documents folder

## Dependencies Version Constraints

⚠️ **Pinned by flutter_localizations**:
- `intl: ^0.20.2` (NOT 0.19.x)
- Keep `flutter_localizations` from SDK, never from pub

## File Organization

```
lib/
├── main.dart                    # Entry point, 17 MultiProvider setup
├── models/                      # 9 data models with toMap/fromMap
├── providers/                   # 17 ChangeNotifier classes
├── services/                    # 7 singletons (DatabaseHelper, LocalisationService, NavigationService, NotificationService, PdfService, PhotoService, photo_exceptions)
├── screens/                     # Feature-organized (cheptel/, sante/, reproduction/, parametres/, optimisation/, utilitaire/)
├── widgets/                     # Reusable (lapin_card.dart, animations.dart, cage_selector.dart)
├── constants/                   # App-wide constants
├── theme/                       # app_theme.dart (simple design, green #4CAF50 palette)
└── utils/                       # Helper functions (logger, snackbar_helper, pdf_generator)
```

## CRUD Pattern - LocalisationManagerScreen Example

**Contextual FloatingActionButton**: Display multiple FABs based on context (e.g., add Building, add Clapier, add Cage):

```dart
Widget _buildFAB() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FloatingActionButton(
        onPressed: _ajouterBatiment,
        backgroundColor: Colors.blue,
        tooltip: 'Bâtiment',
        child: const Icon(Icons.domain),
      ),
      const SizedBox(height: 8),
      FloatingActionButton(
        onPressed: _ajouterClapier,
        backgroundColor: Colors.purple,
        tooltip: 'Clapier',
        child: const Icon(Icons.meeting_room),
      ),
    ],
  );
}
```

**Long Press Menu for Edit/Delete**:
```dart
onLongPress: () => _showContextMenu(context, item)
```

**getCagesDisponibles() Format** (sevrage workflow):
```dart
// Returns List<Map<String, dynamic>> with keys:
// 'cageId', 'batimentNom', 'clapierNom', 'cageNumero', 'cageCapacite', 'occupantCount'
final cagesDisponibles = await LocalisationService().getCagesDisponibles();
```

## UI/UX Known Issues (Phase P0 Complete, but gaps vs requirements)

⚠️ **Critical Gaps** (note 5.3/10 vs cahier des charges):
- **Dashboard**: Pas de tableau de bord actionnable central (navigation fragmentée dans bottom bar)
- **Workflow complexe**: Reproduction nécessite 7 clics vs optimal 3 (pas de boutons rapides)
- **Localisation**: 3 niveaux (Bâtiment → Clapier → Cage) trop profonds, pas de recherche globale
- **Conformité**: ~60% cahier des charges (10 sections attendues)

**Recommended actions for future agents**:
1. Prioriser dashboard central avec KPIs et actions rapides
2. Ajouter recherche globale (lapins, cages, accouplements)
3. Simplifier workflow reproduction (boutons contextuels)
4. Implémenter bottom navigation bar (Cheptel, Santé, Reproduction, Finances, Paramètres)

## When Debugging

1. **"setState during build"**: Check `initState()` uses `addPostFrameCallback`
2. **"No MaterialLocalizations"**: Verify `flutter_localizations` in `pubspec.yaml` and `localizationsDelegates` in `MaterialApp`
3. **Database errors**: Check version migrations in `DatabaseHelper._onUpgrade()`
4. **Null safety**: All models use `?` for optional fields, check `??` operators in UI code
