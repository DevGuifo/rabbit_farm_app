import 'package:flutter/material.dart';
import '../../models/lapin.dart';
import 'quarantaine_quick_dialog.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Bouton d'action rapide pour mettre un lapin en quarantaine
/// Widget réutilisable dans toute l'application
class QuarantaineActionButton extends StatelessWidget {
  final Lapin lapin;
  final VoidCallback? onSuccess;
  final ButtonStyle? style;
  final bool isIconOnly;
  final Color? iconColor;

  const QuarantaineActionButton({
    super.key,
    required this.lapin,
    this.onSuccess,
    this.style,
    this.isIconOnly = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      return IconButton(
        icon: Icon(
          Icons.health_and_safety,
          color: iconColor ?? AppTheme.warning,
        ),
        onPressed: () => _showQuarantaineDialog(context),
        tooltip: 'Mettre en quarantaine',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showQuarantaineDialog(context),
      icon: const Icon(Icons.health_and_safety),
      label: const Text('Quarantaine'),
      style:
          style ??
          ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warning,
            foregroundColor: AppTheme.textLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
    );
  }

  Future<void> _showQuarantaineDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuarantaineQuickDialog(lapin: lapin),
    );

    if (result == true && onSuccess != null) {
      onSuccess!();
    }
  }
}

/// Bouton compact pour menu contextuel
class QuarantaineMenuButton extends StatelessWidget {
  final Lapin lapin;
  final VoidCallback? onSuccess;

  const QuarantaineMenuButton({super.key, required this.lapin, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.health_and_safety, color: AppTheme.warning),
      title: const Text('Mettre en quarantaine'),
      onTap: () async {
        Navigator.pop(context); // Fermer le menu
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => QuarantaineQuickDialog(lapin: lapin),
        );

        if (result == true && onSuccess != null) {
          onSuccess!();
        }
      },
    );
  }
}
