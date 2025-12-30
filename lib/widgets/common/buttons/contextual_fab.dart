import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Composant FAB standard avec actions multiples
/// 
/// Usage:
/// ```dart
/// ContextualFAB(
///   isDark: isDark,
///   actions: [
///     FABAction(
///       icon: Icons.add,
///       tooltip: 'Ajouter',
///       onPressed: () => _add(),
///     ),
///   ],
/// )
/// ```
class ContextualFAB extends StatefulWidget {
  final bool isDark;
  final List<FABAction> actions;

  const ContextualFAB({
    super.key,
    required this.isDark,
    required this.actions,
  });

  @override
  State<ContextualFAB> createState() => _ContextualFABState();
}

class FABAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  FABAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
  });
}

class _ContextualFABState extends State<ContextualFAB> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.length == 1) {
      // Single FAB
      return FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: widget.actions[0].onPressed,
        tooltip: widget.actions[0].tooltip,
        child: Icon(widget.actions[0].icon),
      );
    }

    // Multiple FABs
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded)
          ...List.generate(widget.actions.length, (index) {
            final action = widget.actions[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor:
                      action.backgroundColor ??
                      AppTheme.primaryGreen.withValues(alpha: 0.7),
                  onPressed: () {
                    action.onPressed();
                    setState(() => _isExpanded = false);
                  },
                  tooltip: action.tooltip,
                  child: Icon(action.icon),
                ),
                const SizedBox(height: AppTheme.spacing8),
              ],
            );
          }),
        FloatingActionButton(
          backgroundColor: AppTheme.primaryGreen,
          onPressed: () {
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Icon(_isExpanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

