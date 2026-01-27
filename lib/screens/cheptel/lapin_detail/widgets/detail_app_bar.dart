import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';

/// AppBar personnalisée pour l'écran de détail (Stitch Design)
/// Actions simplifiées - les actions principales sont dans l'onglet Identity
class DetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSync;
  // Actions conservées dans l'AppBar (optionnel)
  final VoidCallback? onViewGenealogie;
  final VoidCallback? onExportPDF;
  final VoidCallback? onMarkQuarantaine;
  final VoidCallback? onMarkDecede;

  const DetailAppBar({
    super.key,
    required this.onBack,
    required this.onSync,
    this.onViewGenealogie,
    this.onExportPDF,
    this.onMarkQuarantaine,
    this.onMarkDecede,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppTheme.getBackgroundColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          _buildIconButton(
            context: context,
            isDark: isDark,
            icon: Icons.arrow_back,
            onPressed: onBack,
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              AppLocalizations.of(context).cheptelRabbitDetails,
              style: AppTheme.titleLarge,
            ),
          ),
          // Sync button
          _buildIconButton(
            context: context,
            isDark: isDark,
            icon: Icons.sync,
            onPressed: onSync,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? AppTheme.textLight.withValues(alpha: 0.1)
            : AppTheme.borderDark.withValues(alpha: 0.5),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          size: icon == Icons.arrow_back ? 20 : 22,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
