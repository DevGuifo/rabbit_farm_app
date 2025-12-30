import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget pour dessiner les lignes de connexion de l'arbre généalogique
class TreeConnectors extends StatelessWidget {
  final bool isDark;

  const TreeConnectors({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textLight.withValues(alpha: 0.3);

    return CustomPaint(
      painter: _TreeConnectorPainter(lineColor: lineColor),
      child: const SizedBox.expand(),
    );
  }
}

class _TreeConnectorPainter extends CustomPainter {
  final Color lineColor;

  _TreeConnectorPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Lignes verticales des grands-parents vers les parents
    // Côté paternel (gauche)
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.35, size.height * 0.35),
      paint,
    );

    // Ligne horizontale reliant les grands-parents paternels
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.35),
      Offset(size.width * 0.35, size.height * 0.35),
      paint,
    );

    // Ligne vers le parent père
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.25, size.height * 0.45),
      paint,
    );

    // Côté maternel (droite)
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.15),
      Offset(size.width * 0.65, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.35),
      paint,
    );

    // Ligne horizontale reliant les grands-parents maternels
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.35),
      Offset(size.width * 0.85, size.height * 0.35),
      paint,
    );

    // Ligne vers le parent mère
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.45),
      paint,
    );

    // Lignes des parents vers le sujet
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.25, size.height * 0.65),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.65),
      paint,
    );

    // Ligne horizontale reliant les parents
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.65),
      Offset(size.width * 0.75, size.height * 0.65),
      paint,
    );

    // Ligne vers le sujet
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TreeConnectorPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
