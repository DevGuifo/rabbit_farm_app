import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/core/services/error_service.dart';
import 'package:rabbit_farm_app/core/exceptions/database_exception.dart';
import 'package:rabbit_farm_app/core/exceptions/validation_exception.dart';
import 'package:rabbit_farm_app/core/utils/logger.dart';

void main() {
  setUpAll(() {
    logger.initialize(isProduction: true);
  });

  group('ErrorService - Catégorisation', () {
    test('identifie les erreurs de base de données', () {
      final error = DatabaseException.insertError('test');
      final info = errorService.handleError(error);

      expect(info.category, ErrorCategory.database);
      expect(info.isRecoverable, true);
      expect(info.userMessage.isNotEmpty, true);
    });

    test('identifie les erreurs de validation', () {
      final error = ValidationException(
        field: 'nom',
        reason: 'Le nom est requis',
      );
      final info = errorService.handleError(error);

      expect(info.category, ErrorCategory.validation);
      expect(info.isRecoverable, true);
    });

    test('gère les erreurs inconnues', () {
      final error = Exception('Erreur test');
      final info = errorService.handleError(error);

      expect(info.category, ErrorCategory.unknown);
      expect(info.userMessage, contains('inattendue'));
    });

    test('gère les StateError', () {
      final error = StateError('No element');
      final info = errorService.handleError(error);

      expect(info.category, ErrorCategory.unknown);
      expect(info.isRecoverable, false);
    });
  });

  group('ErrorService - Messages utilisateur', () {
    test('fournit un message lisible pour insert', () {
      final error = DatabaseException.insertError();
      final info = errorService.handleError(error);

      expect(info.userMessage.contains('enregistrer'), true);
    });

    test('fournit un message lisible pour update', () {
      final error = DatabaseException.updateError();
      final info = errorService.handleError(error);

      expect(info.userMessage.contains('modifier'), true);
    });

    test('fournit un message lisible pour delete', () {
      final error = DatabaseException.deleteError();
      final info = errorService.handleError(error);

      expect(info.userMessage.contains('supprimer'), true);
    });
  });

  group('ErrorService - tryExecute', () {
    test('retourne le résultat en cas de succès', () async {
      final result = await errorService.tryExecute(() async => 42);

      expect(result, 42);
    });

    test('retourne defaultValue en cas d\'erreur', () async {
      final result = await errorService.tryExecute<int>(
        () async => throw Exception('test'),
        defaultValue: -1,
      );

      expect(result, -1);
    });

    test('appelle onError en cas d\'erreur', () async {
      ErrorInfo? capturedInfo;

      await errorService.tryExecute(
        () async => throw DatabaseException.insertError(),
        onError: (info) => capturedInfo = info,
      );

      expect(capturedInfo, isNotNull);
      expect(capturedInfo!.category, ErrorCategory.database);
    });
  });
}
