// ═══════════════════════════════════════════════════════════════════════════
// 🎬 ANIMATIONS - Exports centralisés
// ═══════════════════════════════════════════════════════════════════════════
//
// Ce fichier exporte tous les composants d'animation de l'application.
// Utilisez cet import unique pour accéder à toutes les animations.
//
// USAGE :
// import 'package:rabbit_farm_app/widgets/common/animations/animations.dart';
//
// ═══════════════════════════════════════════════════════════════════════════

// Transitions de pages
export 'page_transitions.dart';

// Animations de feedback (succès, erreur, chargement)
export 'feedback_animations.dart';

// États vides animés (sans LoadingState/ErrorState pour éviter conflit)
export 'empty_states.dart'
    show
        AnimatedEmptyState,
        EmptyLapinsList,
        EmptyAccouplementsList,
        EmptySoinsList,
        EmptyFinancesList,
        EmptySearchResults,
        EmptyAlertesList,
        IllustratedEmptyState;

// Coach marks (onboarding)
export 'coach_marks.dart';

// Gamification (badges, progression, rituels)
export 'gamification.dart';
