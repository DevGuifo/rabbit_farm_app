import 'package:flutter/material.dart';

/// Service de navigation global pour l'application
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Obtenir le contexte de navigation actuel
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Naviguer vers un écran avec un MaterialPageRoute
  Future<T?> navigateTo<T>(Widget screen) async {
    if (navigatorKey.currentState == null) return null;
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Naviguer et remplacer l'écran actuel
  Future<T?> navigateAndReplace<T>(Widget screen) async {
    if (navigatorKey.currentState == null) return null;
    return navigatorKey.currentState!.pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Retourner à l'écran précédent
  void goBack<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop(result);
    }
  }

  /// Naviguer vers la racine
  void popToRoot() {
    if (navigatorKey.currentState == null) return;
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

/// Instance globale du service de navigation
final navigationService = NavigationService();
