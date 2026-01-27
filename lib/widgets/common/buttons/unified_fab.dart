import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 UNIFIED FAB - Bouton d'action flottant standardisé
/// ═══════════════════════════════════════════════════════════════════════════
///
/// RÈGLES D'UTILISATION :
/// - Couleur UNIQUE : `AppTheme.primaryGreen`
/// - Icône par défaut : `Icons.add_rounded`
/// - Type simple OU extended (jamais les deux simultanément)
/// - Pour plusieurs actions : utiliser SpeedDial obligatoirement
///
/// USAGE SIMPLE :
/// ```dart
/// floatingActionButton: UnifiedFAB(
///   onPressed: _ajouterLapin,
///   tooltip: 'Ajouter un lapin',
/// )
/// ```
///
/// USAGE EXTENDED :
/// ```dart
/// floatingActionButton: UnifiedFAB.extended(
///   onPressed: _ajouterTache,
///   label: 'Nouvelle tâche',
///   tooltip: 'Ajouter une tâche',
/// )
/// ```
///
/// USAGE SPEED DIAL (plusieurs actions) :
/// ```dart
/// floatingActionButton: UnifiedFAB.speedDial(
///   actions: [
///     FABAction(
///       icon: Icons.pets,
///       label: 'Sevrage',
///       onPressed: _sevrage,
///     ),
///     FABAction(
///       icon: Icons.home_work,
///       label: 'Préparation nid',
///       onPressed: _preparationNid,
///     ),
///   ],
/// )
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class UnifiedFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final IconData? icon;
  final String? label;
  final String? heroTag;

  const UnifiedFAB({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.icon,
    this.heroTag,
  }) : label = null;

  const UnifiedFAB.extended({
    super.key,
    required this.onPressed,
    required this.label,
    this.tooltip,
    this.icon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? Icons.add_rounded;
    final effectiveTooltip = tooltip ?? 'Ajouter';

    if (label != null) {
      // Version extended
      return Semantics(
        button: true,
        label: effectiveTooltip,
        child: FloatingActionButton.extended(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.textOnPrimary,
          elevation: 4,
          icon: Icon(effectiveIcon),
          label: Text(
            label!,
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          tooltip: effectiveTooltip,
        ),
      );
    } else {
      // Version simple
      return Semantics(
        button: true,
        label: effectiveTooltip,
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.textOnPrimary,
          elevation: 4,
          tooltip: effectiveTooltip,
          child: Icon(effectiveIcon, size: 28),
        ),
      );
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🌀 UNIFIED FAB SPEED DIAL - Pour actions multiples
/// ═══════════════════════════════════════════════════════════════════════════

class UnifiedFABSpeedDial extends StatefulWidget {
  final List<UnifiedFABAction> actions;
  final String? tooltip;

  const UnifiedFABSpeedDial({super.key, required this.actions, this.tooltip});

  @override
  State<UnifiedFABSpeedDial> createState() => _UnifiedFABSpeedDialState();
}

class _UnifiedFABSpeedDialState extends State<UnifiedFABSpeedDial>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotation = Tween<double>(
      begin: 0,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Overlay semi-transparent
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(color: Colors.transparent),
          ),

        // Actions
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return ScaleTransition(
            scale: _scale,
            child: Container(
              margin: EdgeInsets.only(bottom: 16, top: index == 0 ? 8 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (_isOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.textPrimary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        action.label,
                        style: AppTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),

                  // Bouton
                  FloatingActionButton.small(
                    heroTag: 'speed_dial_${action.label}_$index',
                    onPressed: () {
                      _toggle();
                      action.onPressed();
                    },
                    backgroundColor:
                        action.backgroundColor ?? AppTheme.primaryGreen,
                    foregroundColor: AppTheme.textOnPrimary,
                    child: Icon(action.icon, size: 20),
                  ),
                ],
              ),
            ),
          );
        }),

        // FAB principal
        FloatingActionButton(
          heroTag: 'speed_dial_main',
          onPressed: _toggle,
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.textOnPrimary,
          elevation: 4,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotation.value * 3.14159 * 2,
                child: Icon(
                  _isOpen ? Icons.close_rounded : Icons.add_rounded,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Modèle d'action pour le SpeedDial
/// Modèle pour une action de SpeedDial
class UnifiedFABAction {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const UnifiedFABAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
  });
}
