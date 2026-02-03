import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lot.dart';

void main() {
  group('TypeLot', () {
    test('has correct values', () {
      expect(TypeLot.engraissement.value, 'engraissement');
      expect(TypeLot.reproduction.value, 'reproduction');
      expect(TypeLot.mixte.value, 'mixte');
    });

    test('has correct labels', () {
      expect(TypeLot.engraissement.label, 'Engraissement');
      expect(TypeLot.reproduction.label, 'Reproduction');
      expect(TypeLot.mixte.label, 'Mixte');
    });

    test('fromString parses valid values', () {
      expect(TypeLot.fromString('engraissement'), TypeLot.engraissement);
      expect(TypeLot.fromString('reproduction'), TypeLot.reproduction);
      expect(TypeLot.fromString('mixte'), TypeLot.mixte);
    });

    test('fromString is case insensitive', () {
      expect(TypeLot.fromString('ENGRAISSEMENT'), TypeLot.engraissement);
      expect(TypeLot.fromString('Reproduction'), TypeLot.reproduction);
    });

    test('fromString returns mixte for unknown values', () {
      expect(TypeLot.fromString('unknown'), TypeLot.mixte);
      expect(TypeLot.fromString(''), TypeLot.mixte);
    });
  });

  group('StatutLot', () {
    test('has correct values', () {
      expect(StatutLot.actif.value, 'actif');
      expect(StatutLot.enAttente.value, 'en_attente');
      expect(StatutLot.termine.value, 'termine');
      expect(StatutLot.vendu.value, 'vendu');
      expect(StatutLot.reforme.value, 'reforme');
    });

    test('fromString parses valid values', () {
      expect(StatutLot.fromString('actif'), StatutLot.actif);
      expect(StatutLot.fromString('en_attente'), StatutLot.enAttente);
      expect(StatutLot.fromString('termine'), StatutLot.termine);
    });

    test('fromString returns actif for unknown values', () {
      expect(StatutLot.fromString('unknown'), StatutLot.actif);
    });
  });

  group('LotMetadata', () {
    test('creates with default empty values', () {
      const metadata = LotMetadata();
      expect(metadata.ageMoyenJours, isNull);
      expect(metadata.origine, isNull);
      expect(metadata.race, isNull);
      expect(metadata.notes, isNull);
    });

    test('creates with provided values', () {
      const metadata = LotMetadata(
        ageMoyenJours: 45,
        origine: 'Achat',
        race: 'Géant des Flandres',
        notes: 'Lot de qualité',
      );

      expect(metadata.ageMoyenJours, 45);
      expect(metadata.origine, 'Achat');
      expect(metadata.race, 'Géant des Flandres');
      expect(metadata.notes, 'Lot de qualité');
    });

    test('toMap and fromMap roundtrip', () {
      const original = LotMetadata(
        ageMoyenJours: 30,
        origine: 'Naissance',
        race: 'Rex',
        poidsMoyen: 3.5,
      );

      final map = original.toMap();
      final restored = LotMetadata.fromMap(map);

      expect(restored.ageMoyenJours, original.ageMoyenJours);
      expect(restored.origine, original.origine);
      expect(restored.race, original.race);
      expect(restored.poidsMoyen, original.poidsMoyen);
    });

    test('fromJson handles empty string', () {
      final metadata = LotMetadata.fromJson('');
      expect(metadata.ageMoyenJours, isNull);
    });

    test('fromJson handles invalid JSON', () {
      final metadata = LotMetadata.fromJson('not valid json');
      expect(metadata.ageMoyenJours, isNull);
    });

    test('copyWith creates new instance with changes', () {
      const original = LotMetadata(ageMoyenJours: 30, race: 'Rex');
      final modified = original.copyWith(ageMoyenJours: 45);

      expect(modified.ageMoyenJours, 45);
      expect(modified.race, 'Rex'); // Unchanged
    });
  });

  group('Lot', () {
    test('creates with required fields', () {
      final lot = Lot(
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime(2026, 1, 15),
        effectifInitial: 10,
        effectifActuel: 8,
        type: TypeLot.engraissement,
        statut: StatutLot.actif,
      );

      expect(lot.identifiant, 'LP-2026-01-001');
      expect(lot.effectifInitial, 10);
      expect(lot.effectifActuel, 8);
      expect(lot.type, TypeLot.engraissement);
      expect(lot.statut, StatutLot.actif);
    });

    test('genererIdentifiant formats correctly', () {
      final date = DateTime(2026, 1, 15);
      expect(Lot.genererIdentifiant(date, 1), 'LP-2026-01-001');
      expect(Lot.genererIdentifiant(date, 42), 'LP-2026-01-042');
      expect(Lot.genererIdentifiant(date, 999), 'LP-2026-01-999');
    });

    test('parseIdentifiant extracts components', () {
      final parsed = Lot.parseIdentifiant('LP-2026-01-042');
      expect(parsed, isNotNull);
      expect(parsed!['annee'], 2026);
      expect(parsed['mois'], 1);
      expect(parsed['sequence'], 42);
    });

    test('parseIdentifiant returns null for invalid format', () {
      expect(Lot.parseIdentifiant('invalid'), isNull);
      expect(Lot.parseIdentifiant('LP-2026-01'), isNull);
      expect(Lot.parseIdentifiant(''), isNull);
    });

    test('tauxMortalite calculates correctly', () {
      final lot = Lot(
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime.now(),
        effectifInitial: 100,
        effectifActuel: 90,
        type: TypeLot.engraissement,
        statut: StatutLot.actif,
      );

      expect(lot.tauxMortalite, 10.0);
    });

    test('tauxMortalite returns 0 for empty lot', () {
      final lot = Lot(
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime.now(),
        effectifInitial: 0,
        effectifActuel: 0,
        type: TypeLot.engraissement,
        statut: StatutLot.actif,
      );

      expect(lot.tauxMortalite, 0.0);
    });

    test('variationEffectif calculates correctly', () {
      final lot = Lot(
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime.now(),
        effectifInitial: 10,
        effectifActuel: 8,
        type: TypeLot.engraissement,
        statut: StatutLot.actif,
      );

      expect(lot.variationEffectif, -2);
    });

    test('toMap and fromMap roundtrip', () {
      final original = Lot(
        id: 1,
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime(2026, 1, 15),
        effectifInitial: 20,
        effectifActuel: 18,
        type: TypeLot.reproduction,
        statut: StatutLot.actif,
        cageId: 5,
        hasIndividus: true,
      );

      final map = original.toMap();
      final restored = Lot.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.identifiant, original.identifiant);
      expect(restored.type, original.type);
      expect(restored.statut, original.statut);
      expect(restored.hasIndividus, original.hasIndividus);
    });

    test('equality based on id and identifiant', () {
      final lot1 = Lot(
        id: 1,
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime.now(),
        effectifInitial: 10,
        effectifActuel: 10,
        type: TypeLot.engraissement,
        statut: StatutLot.actif,
      );

      final lot2 = Lot(
        id: 1,
        identifiant: 'LP-2026-01-001',
        dateCreation: DateTime.now(),
        effectifInitial: 20, // Different
        effectifActuel: 20,
        type: TypeLot.reproduction, // Different
        statut: StatutLot.actif,
      );

      expect(lot1 == lot2, true);
    });
  });

  group('LotOperations extension', () {
    test('effectifTotal sums all lots', () {
      final lots = [
        Lot(
          identifiant: 'LP-2026-01-001',
          dateCreation: DateTime.now(),
          effectifInitial: 10,
          effectifActuel: 8,
          type: TypeLot.engraissement,
          statut: StatutLot.actif,
        ),
        Lot(
          identifiant: 'LP-2026-01-002',
          dateCreation: DateTime.now(),
          effectifInitial: 20,
          effectifActuel: 18,
          type: TypeLot.engraissement,
          statut: StatutLot.actif,
        ),
      ];

      expect(lots.effectifTotal, 26);
    });

    test('actifs filters only active lots', () {
      final lots = [
        Lot(
          identifiant: 'LP-2026-01-001',
          dateCreation: DateTime.now(),
          effectifInitial: 10,
          effectifActuel: 8,
          type: TypeLot.engraissement,
          statut: StatutLot.actif,
        ),
        Lot(
          identifiant: 'LP-2026-01-002',
          dateCreation: DateTime.now(),
          effectifInitial: 20,
          effectifActuel: 0,
          type: TypeLot.engraissement,
          statut: StatutLot.vendu,
        ),
      ];

      expect(lots.actifs.length, 1);
      expect(lots.actifs.first.identifiant, 'LP-2026-01-001');
    });
  });
}
