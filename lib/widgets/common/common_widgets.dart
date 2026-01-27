// Export centralisé de tous les widgets communs
//
// Usage:
// ```dart
// import 'package:rabbit_farm_app/widgets/common/common_widgets.dart';
//
// StandardHeader(...)
// SearchBarWidget(...)
// ActionCard(...)
// ConfirmDialog.show(...)
// FormActionBar(...)
// OfflineBanner(...)
// ```

// Headers
export 'headers/standard_header.dart';
export 'headers/section_header.dart';
export 'headers/hero_section.dart';
export '../uniform_app_bar.dart'; // SimpleAppBar & UniformAppBar

// Cards
export 'cards/action_card.dart';
export 'cards/list_card.dart';
export 'cards/stats_card.dart';

// Forms
export 'forms/search_bar.dart';
export 'forms/filter_pills.dart';
export 'forms/form_section.dart';
export 'forms/form_action_bar.dart'; // FormActionBar, StickyFormWrapper

// Lists
export 'lists/empty_state.dart';
export 'lists/loading_state.dart';
export 'lists/error_state.dart';

// Buttons
export 'buttons/contextual_fab.dart';
export 'buttons/primary_button.dart';
export 'buttons/unified_fab.dart'
    show UnifiedFAB, UnifiedFABSpeedDial, UnifiedFABAction;

// Dialogs
export 'dialogs/confirm_dialog.dart'; // ConfirmDialog
export 'dialogs/selector_dialog.dart'; // SelectorDialog, LapinSelectorDialog

// Indicators
export 'indicators/offline_banner.dart'; // OfflineBanner, SyncStatusChip

// Animations & Gamification
export 'animations/animations.dart'; // PageTransitions, FeedbackAnimations, EmptyStates, CoachMarks, Gamification

// Theme variations
export 'themed_icon_button.dart'; // ThemedIconButton, ThemedBadge, ThemedIconCircle
