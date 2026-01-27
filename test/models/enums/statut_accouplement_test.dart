import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/enums/statut_accouplement.dart';

/// Tests unitaires pour l'enum StatutAccouplement
void main() {
  group('StatutAccouplement Enum', () {
    group('fromString()', () {
      test('devrait convertir les valeurs normalisées', () {
        expect(StatutAccouplement.fromString('en_attente'), StatutAccouplement.enAttente);
        expect(StatutAccouplement.fromString('confirme'), StatutAccouplement.confirme);
        expect(StatutAccouplement.fromString('echec'), StatutAccouplement.echec);
        expect(StatutAccouplement.fromString('termine'), StatutAccouplement.termine);
      });

      test('devrait accepter anciennes valeurs avec espaces', () {
        expect(StatutAccouplement.fromString('En attente'), StatutAccouplement.enAttente);
        expect(StatutAccouplement.fromString('Confirmé'), StatutAccouplement.confirme);
        expect(StatutAccouplement.fromString('Échec'), StatutAccouplement.echec);
        expect(StatutAccouplement.fromString('Terminé'), StatutAccouplement.termine);
      });

      test('devrait gérer les variations de casse', () {
        expect(StatutAccouplement.fromString('EN_ATTENTE'), StatutAccouplement.enAttente);
        expect(StatutAccouplement.fromString('CONFIRME'), StatutAccouplement.confirme);
      });

      test('devrait retourner enAttente par défaut pour valeur invalide', () {
        expect(StatutAccouplement.fromString('invalide'), StatutAccouplement.enAttente);
        expect(StatutAccouplement.fromString(''), StatutAccouplement.enAttente);
      });
    });

    group('toDatabase()', () {
      test('devrait retourner la valeur normalisée', () {
        expect(StatutAccouplement.enAttente.toDatabase(), 'en_attente');
        expect(StatutAccouplement.confirme.toDatabase(), 'confirme');
        expect(StatutAccouplement.echec.toDatabase(), 'echec');
        expect(StatutAccouplement.termine.toDatabase(), 'termine');
      });
    });

    group('Propriétés', () {
      test('devrait avoir les bons labels français', () {
        expect(StatutAccouplement.enAttente.label, 'En attente');
        expect(StatutAccouplement.confirme.label, 'Confirmé');
        expect(StatutAccouplement.echec.label, 'Échec');
        expect(StatutAccouplement.termine.label, 'Terminé');
      });
    });

    group('Workflow', () {
      test('devrait suivre le cycle de vie correct', () {
        // Workflow normal : en_attente → confirme → termine
        var statut = StatutAccouplement.enAttente;
        expect(statut, StatutAccouplement.enAttente);

        statut = StatutAccouplement.confirme;
        expect(statut, StatutAccouplement.confirme);

        statut = StatutAccouplement.termine;
        expect(statut, StatutAccouplement.termine);
      });

      test('devrait permettre transition vers échec depuis toute étape', () {
        expect(StatutAccouplement.echec, StatutAccouplement.echec);
      });
    });
  });
}
