import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/theme/theme_variations.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemeVariations', () {
    test('toutes les variations ont des couleurs valides', () {
      for (final variation in ThemeVariations.all) {
        expect(variation.accentColor, isNotNull);
        expect(variation.accentLight, isNotNull);
        expect(variation.accentDark, isNotNull);
        expect(variation.icon, isNotNull);
        expect(variation.name, isNotEmpty);
      }
    });

    test('getTacheVariation retourne la bonne variation', () {
      final matin = ThemeVariations.getTacheVariation(true);
      final soir = ThemeVariations.getTacheVariation(false);

      expect(matin, equals(ThemeVariations.tacheMatin));
      expect(soir, equals(ThemeVariations.tacheSoir));
    });

    test('variations spécifiques ont les bonnes propriétés', () {
      // Cheptel
      expect(ThemeVariations.cheptel.name, 'Cheptel');
      expect(ThemeVariations.cheptel.icon, Icons.pets_rounded);

      // Santé
      expect(ThemeVariations.sante.name, 'Santé');
      expect(
        ThemeVariations.sante.icon,
        Icons.medical_services_rounded,
      );

      // Reproduction
      expect(ThemeVariations.reproduction.name, 'Reproduction');
      expect(
        ThemeVariations.reproduction.icon,
        Icons.family_restroom_rounded,
      );

      // Tâches
      expect(ThemeVariations.tacheMatin.icon, Icons.wb_sunny_rounded);
      expect(ThemeVariations.tacheSoir.icon, Icons.nights_stay_rounded);
    });

    test('cardDecoration génère une décoration valide', () {
      final variation = ThemeVariations.sante;

      // Mode clair
      final lightDecoration = variation.cardDecoration(isDark: false);
      expect(lightDecoration, isA<BoxDecoration>());
      expect(lightDecoration.borderRadius, isNotNull);
      expect(lightDecoration.border, isNotNull);

      // Mode sombre
      final darkDecoration = variation.cardDecoration(isDark: true);
      expect(darkDecoration, isA<BoxDecoration>());

      // Mode highlighted
      final highlightedDecoration = variation.cardDecoration(
        isDark: false,
        highlighted: true,
      );
      expect(highlightedDecoration, isA<BoxDecoration>());
    });

    test('toutes les variations ont une iconAlt optionnelle', () {
      for (final variation in ThemeVariations.all) {
        // iconAlt est optionnel, vérifie juste qu'il est null ou IconData
        expect(
          variation.iconAlt == null || variation.iconAlt is IconData,
          isTrue,
        );
      }
    });

    test('all contient toutes les variations', () {
      expect(ThemeVariations.all.length, greaterThanOrEqualTo(9));
      expect(ThemeVariations.all, contains(ThemeVariations.cheptel));
      expect(ThemeVariations.all, contains(ThemeVariations.sante));
      expect(ThemeVariations.all, contains(ThemeVariations.reproduction));
      expect(ThemeVariations.all, contains(ThemeVariations.finance));
      expect(ThemeVariations.all, contains(ThemeVariations.tacheMatin));
      expect(ThemeVariations.all, contains(ThemeVariations.tacheSoir));
      expect(ThemeVariations.all, contains(ThemeVariations.alertes));
      expect(ThemeVariations.all, contains(ThemeVariations.parametres));
      expect(ThemeVariations.all, contains(ThemeVariations.alimentation));
    });
  });

  group('EmojiToIconMapper', () {
    test('mapper les emojis rituels', () {
      expect(EmojiToIconMapper.getIcon('🌅'), Icons.wb_sunny_rounded);
      expect(EmojiToIconMapper.getIcon('🌙'), Icons.nights_stay_rounded);
      expect(EmojiToIconMapper.getIcon('🎉'), Icons.celebration_rounded);
    });

    test('mapper les emojis d\'action', () {
      expect(EmojiToIconMapper.getIcon('💧'), Icons.water_drop_rounded);
      expect(EmojiToIconMapper.getIcon('🥤'), Icons.local_drink_rounded);
      expect(EmojiToIconMapper.getIcon('🍽️'), Icons.restaurant_rounded);
      expect(EmojiToIconMapper.getIcon('🔍'), Icons.search_rounded);
      expect(EmojiToIconMapper.getIcon('🧹'), Icons.cleaning_services_rounded);
    });

    test('mapper les emojis de statut', () {
      expect(EmojiToIconMapper.getIcon('✅'), Icons.check_circle_rounded);
      expect(EmojiToIconMapper.getIcon('⚠️'), Icons.warning_rounded);
      expect(EmojiToIconMapper.getIcon('⏰'), Icons.schedule_rounded);
    });

    test('retourne null pour emoji non mappé', () {
      expect(EmojiToIconMapper.getIcon('❓'), isNull);
      expect(EmojiToIconMapper.getIcon('🚀'), isNull);
    });

    test('getIconOrDefault utilise le fallback', () {
      expect(
        EmojiToIconMapper.getIconOrDefault('❓', fallback: Icons.help_rounded),
        Icons.help_rounded,
      );

      expect(
        EmojiToIconMapper.getIconOrDefault('🌅', fallback: Icons.help_rounded),
        Icons.wb_sunny_rounded,
      );
    });

    test('tous les emojis mappés sont valides', () {
      for (final entry in EmojiToIconMapper.mapping.entries) {
        expect(entry.key, isNotEmpty);
        expect(entry.value, isA<IconData>());
      }
    });
  });
}
