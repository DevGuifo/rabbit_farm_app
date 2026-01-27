import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎬 PAGE TRANSITIONS - Transitions d'écrans fluides et pédagogiques
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Ce fichier définit les transitions utilisées dans toute l'application.
/// Les transitions aident l'utilisateur à comprendre la navigation.
///
/// USAGE :
/// ```dart
/// Navigator.push(
///   context,
///   PageTransitions.slideUp(const MonEcran()),
/// );
/// ```
///
/// TYPES DE TRANSITIONS :
/// - slideUp : Pour ouvrir un formulaire/détail (monte du bas)
/// - slideRight : Pour aller "plus profond" dans la navigation
/// - fadeScale : Pour les modales/popups importants
/// - fade : Pour les changements de contexte
/// ═══════════════════════════════════════════════════════════════════════════

class PageTransitions {
  /// Durée standard des transitions (300ms = naturel)
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Durée rapide pour les actions fréquentes
  static const Duration fastDuration = Duration(milliseconds: 200);

  /// Courbe d'animation fluide (ease out = décélère naturellement)
  static const Curve standardCurve = Curves.easeOutCubic;

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 SLIDE UP - Monte du bas (formulaires, détails)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition slide + fade depuis le bas
  ///
  /// **Quand l'utiliser :**
  /// - Ouvrir un formulaire d'ajout
  /// - Afficher les détails d'un élément
  /// - Ouvrir un écran secondaire
  ///
  /// **Exemple :**
  /// ```dart
  /// Navigator.push(context, PageTransitions.slideUp(AjouterLapinScreen()));
  /// ```
  static Route<T> slideUp<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: standardDuration,
      reverseTransitionDuration: standardDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation combinée : slide + fade
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1), // Petit décalage (10% de l'écran)
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➡️ SLIDE RIGHT - Glisse vers la droite (navigation profonde)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition slide depuis la droite
  ///
  /// **Quand l'utiliser :**
  /// - Naviguer vers un sous-écran
  /// - Aller "plus profond" dans une hiérarchie
  ///
  /// **Exemple :**
  /// ```dart
  /// Navigator.push(context, PageTransitions.slideRight(DetailScreen()));
  /// ```
  static Route<T> slideRight<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: standardDuration,
      reverseTransitionDuration: standardDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.2, 0), // 20% depuis la droite
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 FADE SCALE - Zoom + fade (modales, détails importants)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition scale + fade (effet "zoom in")
  ///
  /// **Quand l'utiliser :**
  /// - Afficher une modale importante
  /// - Ouvrir un détail avec emphase
  /// - Confirmer une action
  ///
  /// **Exemple :**
  /// ```dart
  /// Navigator.push(context, PageTransitions.fadeScale(ConfirmScreen()));
  /// ```
  static Route<T> fadeScale<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: standardDuration,
      reverseTransitionDuration: fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.95, // Commence légèrement plus petit
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: standardCurve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💨 FADE - Simple fondu (changement de contexte)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition fade simple
  ///
  /// **Quand l'utiliser :**
  /// - Changer complètement de contexte
  /// - Transitions entre onglets
  /// - Remplacer l'écran actuel
  ///
  /// **Exemple :**
  /// ```dart
  /// Navigator.pushReplacement(context, PageTransitions.fade(HomeScreen()));
  /// ```
  static Route<T> fade<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: fastDuration,
      reverseTransitionDuration: fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 HERO DETAIL - Pour les cartes avec Hero animation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition optimisée pour les Hero animations
  ///
  /// **Quand l'utiliser :**
  /// - Avec des widgets Hero (cartes qui s'agrandissent)
  /// - Détails d'un lapin depuis la liste
  ///
  /// **Exemple :**
  /// ```dart
  /// // Dans la liste :
  /// Hero(tag: 'lapin_${lapin.id}', child: LapinCard(lapin))
  ///
  /// // Navigation :
  /// Navigator.push(context, PageTransitions.heroDetail(LapinDetailScreen()));
  /// ```
  static Route<T> heroDetail<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade léger pour accompagner le Hero
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧩 EXTENSION NAVIGATOR - Méthodes pratiques
// ═══════════════════════════════════════════════════════════════════════════

/// Extension pour simplifier les navigations avec transitions
///
/// **Exemple :**
/// ```dart
/// context.pushSlideUp(MonEcran());
/// context.pushSlideRight(DetailScreen());
/// ```
extension NavigatorTransitions on BuildContext {
  /// Push avec transition slide up
  Future<T?> pushSlideUp<T>(Widget page) {
    return Navigator.push<T>(this, PageTransitions.slideUp(page));
  }

  /// Push avec transition slide right
  Future<T?> pushSlideRight<T>(Widget page) {
    return Navigator.push<T>(this, PageTransitions.slideRight(page));
  }

  /// Push avec transition fade scale
  Future<T?> pushFadeScale<T>(Widget page) {
    return Navigator.push<T>(this, PageTransitions.fadeScale(page));
  }

  /// Push replacement avec fade
  Future<T?> pushReplacementFade<T>(Widget page) {
    return Navigator.pushReplacement<T, void>(this, PageTransitions.fade(page));
  }

  /// Push avec Hero transition
  Future<T?> pushHeroDetail<T>(Widget page) {
    return Navigator.push<T>(this, PageTransitions.heroDetail(page));
  }
}
