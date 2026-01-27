import 'package:flutter/material.dart';

/// Widget affichant un effet de chargement "squelette" (Shimmer)
///
/// Utilise une animation de gradient linéaire pour simuler un scintillement.
/// À utiliser pour les états de chargement à la place des spinners.
class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final ShapeBorder shape;
  final Color? baseColor;
  final Color? highlightColor;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.shape = const RoundedRectangleBorder(),
    this.baseColor,
    this.highlightColor,
  });

  /// Squelette rectangulaire standard avec coins arrondis
  const Skeleton.rect({
    super.key,
    this.width,
    required this.height,
    double borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  }) : shape = const RoundedRectangleBorder(
         borderRadius: BorderRadius.all(Radius.circular(12)),
       );

  /// Squelette circulaire (ex: avatars)
  const Skeleton.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       shape = const CircleBorder();

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs par défaut adaptées au thème
    final base =
        widget.baseColor ?? (isDark ? Colors.grey[850]! : Colors.grey[200]!);
    final highlight =
        widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: ShapeDecoration(
            shape: widget.shape,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
