import 'package:logger/logger.dart';

/// Service de logging global pour l'application BunnyManager
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  /// Initialiser le logger avec la configuration appropriée
  void initialize({bool isProduction = false}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: isProduction ? Level.warning : Level.debug,
    );
  }

  /// Log debug (développement uniquement)
  void debug(dynamic message) {
    _logger.d(message);
  }

  /// Log info
  void info(dynamic message) {
    _logger.i(message);
  }

  /// Log warning
  void warning(dynamic message) {
    _logger.w(message);
  }

  /// Log erreur
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// Instance globale du logger
final logger = AppLogger();
