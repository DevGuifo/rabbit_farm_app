import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Floating Action Button pour l'édition (Stitch Design)
class DetailFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DetailFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppTheme.getSurfaceColor(context);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: surfaceColor, width: 4),
        boxShadow: AppTheme.fabShadow(AppTheme.primaryYellow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(Icons.edit, color: AppTheme.textPrimary, size: 28),
          ),
        ),
      ),
    );
  }
}
