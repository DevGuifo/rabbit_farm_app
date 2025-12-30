import 'package:flutter/material.dart';
import '../constants/stitch_theme_constants.dart';

/// Floating Action Button pour l'édition (Stitch Design)
class DetailFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DetailFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = StitchTheme.getSurfaceColor(context);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: StitchTheme.primaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: surfaceColor, width: 4),
        boxShadow: StitchTheme.fabShadow(StitchTheme.primaryYellow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(Icons.edit, color: Colors.black, size: 28),
          ),
        ),
      ),
    );
  }
}
