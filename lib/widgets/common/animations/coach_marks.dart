import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 COACH MARKS - Système d'onboarding léger et contextuel
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Ce fichier implémente un système de "coach marks" (bulles d'aide) qui
/// guide l'utilisateur lors de sa première utilisation de l'application.
///
/// PRINCIPES :
/// - Non-intrusif : l'utilisateur peut ignorer ou passer
/// - Contextuel : apparaît au bon moment, au bon endroit
/// - Mémorisé : ne réapparaît pas après avoir été vu
/// - Progressif : 1 à 3 bulles max par écran
///
/// USAGE :
/// ```dart
/// // 1. Définir une clé GlobalKey pour l'élément cible
/// final _fabKey = GlobalKey();
///
/// // 2. Attacher la clé au widget
/// FloatingActionButton(key: _fabKey, ...)
///
/// // 3. Afficher le coach mark (dans initState)
/// CoachMarkController.showIfFirstTime(
///   context: context,
///   id: 'cheptel_fab',
///   targetKey: _fabKey,
///   title: 'Ajouter un lapin',
///   message: 'Appuyez ici pour ajouter votre premier lapin',
/// );
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// 🎮 COACH MARK CONTROLLER - Gestion centralisée des coach marks
// ═══════════════════════════════════════════════════════════════════════════

/// Contrôleur centralisé pour gérer les coach marks
///
/// **Responsabilités :**
/// - Mémoriser les coach marks déjà vus
/// - Afficher les coach marks au bon moment
/// - Gérer les séquences de coach marks
class CoachMarkController {
  /// Préfixe pour les clés SharedPreferences
  static const String _prefixKey = 'coach_mark_seen_';

  /// Vérifie si un coach mark a été vu
  static Future<bool> hasBeenSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefixKey$id') ?? false;
  }

  /// Marque un coach mark comme vu
  static Future<void> markAsSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefixKey$id', true);
  }

  /// Réinitialise tous les coach marks (pour les tests)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefixKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Affiche un coach mark si c'est la première fois
  ///
  /// **Exemple :**
  /// ```dart
  /// CoachMarkController.showIfFirstTime(
  ///   context: context,
  ///   id: 'cheptel_fab',
  ///   targetKey: _fabKey,
  ///   title: 'Ajouter un lapin',
  ///   message: 'Appuyez ici pour commencer',
  /// );
  /// ```
  static Future<void> showIfFirstTime({
    required BuildContext context,
    required String id,
    required GlobalKey targetKey,
    required String title,
    required String message,
    CoachMarkPosition position = CoachMarkPosition.auto,
    VoidCallback? onDismiss,
    VoidCallback? onAction,
    String? actionLabel,
  }) async {
    if (await hasBeenSeen(id)) return;

    if (!context.mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;

    CoachMark.show(
      context: context,
      targetKey: targetKey,
      title: title,
      message: message,
      position: position,
      onDismiss: () async {
        await markAsSeen(id);
        onDismiss?.call();
      },
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Affiche une séquence de coach marks
  ///
  /// **Exemple :**
  /// ```dart
  /// CoachMarkController.showSequence(
  ///   context: context,
  ///   sequenceId: 'cheptel_intro',
  ///   marks: [
  ///     CoachMarkData(id: 'step1', targetKey: _key1, title: 'Étape 1', ...),
  ///     CoachMarkData(id: 'step2', targetKey: _key2, title: 'Étape 2', ...),
  ///   ],
  /// );
  /// ```
  static Future<void> showSequence({
    required BuildContext context,
    required String sequenceId,
    required List<CoachMarkData> marks,
  }) async {
    if (await hasBeenSeen(sequenceId)) return;

    for (int i = 0; i < marks.length; i++) {
      final mark = marks[i];
      final isLast = i == marks.length - 1;

      if (!context.mounted) return;

      await CoachMark.showAsync(
        context: context,
        targetKey: mark.targetKey,
        title: mark.title,
        message: mark.message,
        position: mark.position,
        stepIndicator: '${i + 1}/${marks.length}',
        actionLabel: isLast ? 'Terminer' : 'Suivant',
      );
    }

    await markAsSeen(sequenceId);
  }
}

/// Données pour un coach mark dans une séquence
class CoachMarkData {
  final String id;
  final GlobalKey targetKey;
  final String title;
  final String message;
  final CoachMarkPosition position;

  const CoachMarkData({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.message,
    this.position = CoachMarkPosition.auto,
  });
}

/// Position du coach mark par rapport à la cible
enum CoachMarkPosition {
  /// Calcule automatiquement la meilleure position
  auto,

  /// Au-dessus de la cible
  above,

  /// En-dessous de la cible
  below,

  /// À gauche de la cible
  left,

  /// À droite de la cible
  right,
}

// ═══════════════════════════════════════════════════════════════════════════
// 💬 COACH MARK - Widget de bulle d'aide
// ═══════════════════════════════════════════════════════════════════════════

/// Widget overlay qui affiche une bulle d'aide pointant vers un élément
class CoachMark {
  /// Affiche un coach mark (fire and forget)
  static void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required String title,
    required String message,
    CoachMarkPosition position = CoachMarkPosition.auto,
    VoidCallback? onDismiss,
    VoidCallback? onAction,
    String? actionLabel,
    String? stepIndicator,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CoachMarkOverlay(
        targetKey: targetKey,
        title: title,
        message: message,
        position: position,
        stepIndicator: stepIndicator,
        actionLabel: actionLabel,
        onDismiss: () {
          entry.remove();
          onDismiss?.call();
        },
        onAction: () {
          entry.remove();
          onAction?.call();
        },
      ),
    );

    overlay.insert(entry);
  }

  /// Affiche un coach mark et attend qu'il soit fermé
  static Future<void> showAsync({
    required BuildContext context,
    required GlobalKey targetKey,
    required String title,
    required String message,
    CoachMarkPosition position = CoachMarkPosition.auto,
    String? stepIndicator,
    String? actionLabel,
  }) async {
    final completer = _Completer();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CoachMarkOverlay(
        targetKey: targetKey,
        title: title,
        message: message,
        position: position,
        stepIndicator: stepIndicator,
        actionLabel: actionLabel ?? 'OK',
        onDismiss: () {
          entry.remove();
          completer.complete();
        },
        onAction: () {
          entry.remove();
          completer.complete();
        },
      ),
    );

    overlay.insert(entry);
    await completer.future;
  }
}

/// Simple completer pour gérer l'attente
class _Completer {
  bool _isCompleted = false;
  final List<VoidCallback> _callbacks = [];

  void complete() {
    if (_isCompleted) return;
    _isCompleted = true;
    for (final callback in _callbacks) {
      callback();
    }
  }

  Future<void> get future async {
    if (_isCompleted) return;
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return !_isCompleted;
    });
  }
}

class _CoachMarkOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String title;
  final String message;
  final CoachMarkPosition position;
  final String? stepIndicator;
  final String? actionLabel;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  const _CoachMarkOverlay({
    required this.targetKey,
    required this.title,
    required this.message,
    required this.position,
    this.stepIndicator,
    this.actionLabel,
    required this.onDismiss,
    this.onAction,
  });

  @override
  State<_CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<_CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Rect? _targetRect;
  CoachMarkPosition _actualPosition = CoachMarkPosition.below;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _calculateTargetRect();
    _controller.forward();
  }

  void _calculateTargetRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final position = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _targetRect = Rect.fromLTWH(
            position.dx,
            position.dy,
            renderBox.size.width,
            renderBox.size.height,
          );
          _actualPosition = _calculateBestPosition();
        });
      }
    });
  }

  CoachMarkPosition _calculateBestPosition() {
    if (widget.position != CoachMarkPosition.auto) {
      return widget.position;
    }

    if (_targetRect == null) return CoachMarkPosition.below;

    final screenHeight = MediaQuery.of(context).size.height;
    final targetCenterY = _targetRect!.center.dy;

    // Si la cible est dans la moitié supérieure, afficher en dessous
    if (targetCenterY < screenHeight / 2) {
      return CoachMarkPosition.below;
    } else {
      return CoachMarkPosition.above;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Fond semi-transparent avec découpe
              Positioned.fill(
                child: GestureDetector(
                  onTap: _handleDismiss,
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      targetRect: _targetRect,
                      opacity: _fadeAnimation.value * 0.7,
                    ),
                  ),
                ),
              ),

              // Bulle de coach mark
              if (_targetRect != null)
                Positioned(
                  left: _calculateBubbleX(screenSize),
                  top: _calculateBubbleY(),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildBubble(theme),
                    ),
                  ),
                ),

              // Bouton fermer en haut à droite
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 8,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _handleDismiss,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateBubbleX(Size screenSize) {
    if (_targetRect == null) return 16;

    const bubbleWidth = 280.0;
    const margin = 16.0;

    // Centrer par rapport à la cible
    double x = _targetRect!.center.dx - bubbleWidth / 2;

    // S'assurer que la bulle reste dans l'écran
    x = x.clamp(margin, screenSize.width - bubbleWidth - margin);

    return x;
  }

  double _calculateBubbleY() {
    if (_targetRect == null) return 100;

    const bubbleMargin = 16.0;

    if (_actualPosition == CoachMarkPosition.above) {
      return _targetRect!.top - 150 - bubbleMargin;
    } else {
      return _targetRect!.bottom + bubbleMargin;
    }
  }

  Widget _buildBubble(ThemeData theme) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur d'étape
          if (widget.stepIndicator != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.stepIndicator!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Titre
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            widget.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // Bouton d'action
          if (widget.actionLabel != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: widget.onAction ?? _handleDismiss,
                child: Text(widget.actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Peintre pour l'effet "spotlight" (projecteur)
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double opacity;

  _SpotlightPainter({required this.targetRect, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: opacity);

    // Dessiner le fond sombre
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Découper un trou autour de la cible
    if (targetRect != null) {
      final holePaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;

      // Agrandir légèrement la zone visible
      final padding = 8.0;
      final expandedRect = targetRect!.inflate(padding);

      // Dessiner un rectangle arrondi
      canvas.drawRRect(
        RRect.fromRectAndRadius(expandedRect, const Radius.circular(12)),
        holePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        opacity != oldDelegate.opacity;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💡 TOOLTIP AMÉLIORÉ - Tooltip contextuel plus riche
// ═══════════════════════════════════════════════════════════════════════════

/// Tooltip amélioré avec plus de contenu
///
/// **Quand l'utiliser :**
/// - Expliquer une icône ou un bouton
/// - Fournir des informations supplémentaires
/// - Aide contextuelle ponctuelle
///
/// **Exemple :**
/// ```dart
/// RichTooltip(
///   message: 'Cette icône indique un lapin malade',
///   child: Icon(Icons.medical_services),
/// )
/// ```
class RichTooltip extends StatelessWidget {
  /// Contenu à afficher dans le tooltip
  final String message;

  /// Widget enfant qui déclenche le tooltip
  final Widget child;

  /// Titre optionnel
  final String? title;

  /// Durée d'affichage
  final Duration showDuration;

  const RichTooltip({
    super.key,
    required this.message,
    required this.child,
    this.title,
    this.showDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      richMessage: TextSpan(
        children: [
          if (title != null) ...[
            TextSpan(
              text: '$title\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ],
          TextSpan(
            text: message,
            style: TextStyle(color: theme.colorScheme.onInverseSurface),
          ),
        ],
      ),
      showDuration: showDuration,
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎬 FEATURE DISCOVERY - Animation de découverte de fonctionnalité
// ═══════════════════════════════════════════════════════════════════════════

/// Widget qui met en évidence une nouvelle fonctionnalité
///
/// **Quand l'utiliser :**
/// - Nouvelle fonctionnalité ajoutée
/// - Fonctionnalité importante peu utilisée
///
/// **Exemple :**
/// ```dart
/// FeatureDiscovery(
///   featureId: 'new_export_feature',
///   title: 'Nouveau !',
///   description: 'Exportez vos données en PDF',
///   child: IconButton(...),
/// )
/// ```
class FeatureDiscovery extends StatefulWidget {
  /// Identifiant unique de la fonctionnalité
  final String featureId;

  /// Titre court
  final String title;

  /// Description
  final String description;

  /// Widget enfant
  final Widget child;

  /// Afficher le badge "Nouveau" ?
  final bool showBadge;

  const FeatureDiscovery({
    super.key,
    required this.featureId,
    required this.title,
    required this.description,
    required this.child,
    this.showBadge = true,
  });

  @override
  State<FeatureDiscovery> createState() => _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _checkIfNew();
  }

  Future<void> _checkIfNew() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('feature_${widget.featureId}') ?? false;

    if (!seen && mounted) {
      setState(() => _isNew = true);
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feature_${widget.featureId}', true);

    if (mounted) {
      setState(() => _isNew = false);
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isNew) return widget.child;

    return GestureDetector(
      onTap: _markAsSeen,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Effet de pulsation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + _pulseController.value * 0.1;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: 0.3 * (1 - _pulseController.value),
                  child: widget.child,
                ),
              );
            },
          ),

          // Widget enfant
          widget.child,

          // Badge "Nouveau"
          if (widget.showBadge)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
