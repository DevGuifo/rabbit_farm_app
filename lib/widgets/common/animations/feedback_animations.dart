import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════════════
/// ✨ FEEDBACK ANIMATIONS - Animations de retour visuel
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Ce fichier contient les animations de feedback qui informent l'utilisateur
/// du résultat de ses actions (succès, erreur, chargement, validation).
///
/// PRINCIPES :
/// - Court et non-bloquant (< 1 seconde)
/// - Signification claire (vert = succès, rouge = erreur)
/// - Accessible (pas juste la couleur, aussi une icône/mouvement)
///
/// USAGE :
/// ```dart
/// // Afficher un succès
/// SuccessAnimation.show(context);
///
/// // Dans un widget
/// const SuccessCheckmark()
/// const ErrorShake(child: Icon(Icons.error))
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// ✅ SUCCESS CHECKMARK - Animation de succès (coche animée)
// ═══════════════════════════════════════════════════════════════════════════

/// Widget qui affiche une coche animée de succès
///
/// **Quand l'utiliser :**
/// - Après une sauvegarde réussie
/// - Confirmation d'une action
/// - Validation d'un formulaire
///
/// **Exemple :**
/// ```dart
/// SuccessCheckmark(
///   size: 60,
///   color: Colors.green,
///   onComplete: () => Navigator.pop(context),
/// )
/// ```
class SuccessCheckmark extends StatefulWidget {
  /// Taille de l'animation (par défaut 48)
  final double size;

  /// Couleur de la coche (par défaut vert)
  final Color? color;

  /// Callback quand l'animation est terminée
  final VoidCallback? onComplete;

  /// Afficher le cercle autour ?
  final bool showCircle;

  const SuccessCheckmark({
    super.key,
    this.size = 48,
    this.color,
    this.onComplete,
    this.showCircle = true,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();

  /// Affiche une animation de succès en overlay
  static void show(BuildContext context, {String? message}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) =>
          _SuccessOverlay(message: message, onDismiss: () => entry.remove()),
    );

    overlay.insert(entry);
  }
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Cercle apparaît d'abord (0% -> 50%)
    _circleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Puis la coche se dessine (40% -> 100%)
    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SuccessCheckPainter(
            circleProgress: widget.showCircle ? _circleAnimation.value : 0,
            checkProgress: _checkAnimation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _SuccessCheckPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;

  _SuccessCheckPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Dessiner le cercle
    if (circleProgress > 0) {
      final circlePaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius * circleProgress, circlePaint);

      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * circleProgress,
        false,
        borderPaint,
      );
    }

    // Dessiner la coche
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();

      // Points de la coche (relatifs au centre)
      final startPoint = Offset(center.dx - radius * 0.35, center.dy);
      final midPoint = Offset(
        center.dx - radius * 0.05,
        center.dy + radius * 0.3,
      );
      final endPoint = Offset(
        center.dx + radius * 0.4,
        center.dy - radius * 0.25,
      );

      path.moveTo(startPoint.dx, startPoint.dy);

      // Première partie de la coche (0% -> 50%)
      if (checkProgress <= 0.5) {
        final progress = checkProgress * 2;
        final currentPoint = Offset.lerp(startPoint, midPoint, progress)!;
        path.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        path.lineTo(midPoint.dx, midPoint.dy);
        // Seconde partie de la coche (50% -> 100%)
        final progress = (checkProgress - 0.5) * 2;
        final currentPoint = Offset.lerp(midPoint, endPoint, progress)!;
        path.lineTo(currentPoint.dx, currentPoint.dy);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessCheckPainter oldDelegate) {
    return circleProgress != oldDelegate.circleProgress ||
        checkProgress != oldDelegate.checkProgress;
  }
}

class _SuccessOverlay extends StatefulWidget {
  final String? message;
  final VoidCallback onDismiss;

  const _SuccessOverlay({this.message, required this.onDismiss});

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
        reverseCurve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _controller.reverse().then((_) => widget.onDismiss());
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SuccessCheckmark(
                        size: 64,
                        color: Colors.green.shade600,
                        showCircle: true,
                      ),
                      if (widget.message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          widget.message!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ❌ ERROR SHAKE - Animation d'erreur (secousse)
// ═══════════════════════════════════════════════════════════════════════════

/// Widget qui secoue son enfant pour indiquer une erreur
///
/// **Quand l'utiliser :**
/// - Erreur de validation de formulaire
/// - Action impossible
/// - Champ invalide
///
/// **Exemple :**
/// ```dart
/// ErrorShake(
///   shake: _hasError,
///   child: TextField(...),
/// )
/// ```
class ErrorShake extends StatefulWidget {
  /// Widget enfant à secouer
  final Widget child;

  /// Déclencher la secousse ?
  final bool shake;

  /// Callback quand l'animation est terminée
  final VoidCallback? onComplete;

  /// Intensité de la secousse (par défaut 10 pixels)
  final double intensity;

  const ErrorShake({
    super.key,
    required this.child,
    this.shake = false,
    this.onComplete,
    this.intensity = 10,
  });

  @override
  State<ErrorShake> createState() => _ErrorShakeState();
}

class _ErrorShakeState extends State<ErrorShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    if (widget.shake) {
      _startShake();
    }
  }

  @override
  void didUpdateWidget(covariant ErrorShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _startShake();
    }
  }

  void _startShake() {
    _controller.forward(from: 0).then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Crée un mouvement de secousse sinusoïdal
        final shakeOffset =
            math.sin(_shakeAnimation.value * math.pi * 4) *
            widget.intensity *
            (1 - _shakeAnimation.value);

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: widget.child,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💫 PULSE ANIMATION - Effet de pulsation (attention, validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Widget qui pulse pour attirer l'attention
///
/// **Quand l'utiliser :**
/// - Attirer l'attention sur un élément important
/// - Indiquer une validation en cours
/// - Mettre en évidence une nouveauté
///
/// **Exemple :**
/// ```dart
/// PulseAnimation(
///   child: Icon(Icons.notification_important),
///   repeat: true,
/// )
/// ```
class PulseAnimation extends StatefulWidget {
  /// Widget enfant à animer
  final Widget child;

  /// Répéter l'animation ?
  final bool repeat;

  /// Durée d'un cycle
  final Duration duration;

  /// Échelle minimale
  final double minScale;

  /// Échelle maximale
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.repeat = true,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 LOADING SPINNER - Indicateur de chargement stylisé
// ═══════════════════════════════════════════════════════════════════════════

/// Spinner de chargement personnalisé
///
/// **Quand l'utiliser :**
/// - Pendant une opération de sauvegarde
/// - Chargement de données
/// - Attente d'une réponse
///
/// **Exemple :**
/// ```dart
/// if (isLoading) LoadingSpinner() else Content()
/// ```
class LoadingSpinner extends StatefulWidget {
  /// Taille du spinner
  final double size;

  /// Couleur du spinner
  final Color? color;

  /// Épaisseur du trait
  final double strokeWidth;

  const LoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              progress: _controller.value,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Arc qui tourne avec longueur variable
    final startAngle = progress * 2 * math.pi;
    final sweepAngle = math.sin(progress * math.pi) * math.pi + math.pi / 4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎉 CELEBRATION - Animation de célébration (confettis légers)
// ═══════════════════════════════════════════════════════════════════════════

/// Animation de célébration pour les réussites importantes
///
/// **Quand l'utiliser :**
/// - Première action réussie
/// - Badge débloqué
/// - Objectif atteint
///
/// **Exemple :**
/// ```dart
/// CelebrationAnimation.show(context);
/// ```
class CelebrationAnimation {
  /// Affiche une animation de célébration
  static void show(BuildContext context, {String? message}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        message: message,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _CelebrationOverlay extends StatefulWidget {
  final String? message;
  final VoidCallback onDismiss;

  const _CelebrationOverlay({this.message, required this.onDismiss});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Générer des particules
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.5,
          size: _random.nextDouble() * 8 + 4,
          color: _celebrationColors[_random.nextInt(_celebrationColors.length)],
          velocity: _random.nextDouble() * 2 + 1,
          angle: _random.nextDouble() * math.pi - math.pi / 2,
        ),
      );
    }

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _mainController.forward();
    _particleController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), widget.onDismiss);
    });
  }

  static const List<Color> _celebrationColors = [
    Color(0xFF4CAF50), // Vert
    Color(0xFF2196F3), // Bleu
    Color(0xFFFFC107), // Jaune
    Color(0xFFE91E63), // Rose
    Color(0xFF9C27B0), // Violet
  ];

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return IgnorePointer(
          child: Stack(
            children: [
              // Particules
              ..._particles.map((particle) {
                final progress = _particleController.value;
                final y =
                    particle.y +
                    progress * particle.velocity * 0.5 +
                    progress * progress * 0.3; // Gravité
                final x =
                    particle.x + math.sin(particle.angle) * progress * 0.2;
                final opacity = 1.0 - progress;

                return Positioned(
                  left: x * MediaQuery.of(context).size.width,
                  top: y * MediaQuery.of(context).size.height,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: progress * math.pi * 2,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          color: particle.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Message central
              if (widget.message != null)
                Center(
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      final scale = Curves.elasticOut.transform(
                        _mainController.value.clamp(0.0, 1.0),
                      );
                      final opacity = _mainController.value < 0.8
                          ? 1.0
                          : 1.0 - (_mainController.value - 0.8) * 5;

                      return Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.message!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocity;
  final double angle;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
  });
}
