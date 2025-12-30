import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

/// AppBar personnalisée pour l'écran de détail (Stitch Design)
class DetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onViewGenealogie;
  final VoidCallback? onExportPDF;
  final VoidCallback? onMarkQuarantaine;
  final VoidCallback? onMarkDecede;

  const DetailAppBar({
    super.key,
    required this.onBack,
    required this.onSync,
    this.onNotifications,
    this.onViewGenealogie,
    this.onExportPDF,
    this.onMarkQuarantaine,
    this.onMarkDecede,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = StitchTheme.getBackgroundColor(context);
    final textColor = StitchTheme.getTextColor(context);

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
          Expanded(child: Text('Rabbit Details', style: AppTheme.titleLarge)),
          // Sync button
          _buildIconButton(
            context: context,
            isDark: isDark,
            icon: Icons.sync,
            onPressed: onSync,
          ),
          const SizedBox(width: 8),
          // Notifications button
          _buildIconButton(
            context: context,
            isDark: isDark,
            icon: Icons.notifications,
            onPressed: onNotifications ?? () {},
          ),
          const SizedBox(width: 8),
          // Settings menu
          _buildSettingsMenu(context, isDark, textColor),
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
            : Colors.black.withValues(alpha: 0.05),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isDark ? AppTheme.textLight : AppTheme.stitchTextMainLight,
          size: icon == Icons.arrow_back ? 20 : 22,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSettingsMenu(
    BuildContext context,
    bool isDark,
    Color textColor,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? AppTheme.textLight.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.settings,
          color: isDark ? AppTheme.textLight : AppTheme.stitchTextMainLight,
          size: 22,
        ),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          if (value == 'genealogie' && onViewGenealogie != null) {
            onViewGenealogie!();
          } else if (value == 'pdf' && onExportPDF != null) {
            onExportPDF!();
          } else if (value == 'quarantaine' && onMarkQuarantaine != null) {
            onMarkQuarantaine!();
          } else if (value == 'decede' && onMarkDecede != null) {
            onMarkDecede!();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'genealogie',
            child: Row(
              children: [
                Icon(Icons.account_tree, size: 20),
                SizedBox(width: 12),
                Text('Généalogie'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'pdf',
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, size: 20),
                SizedBox(width: 12),
                Text('Exporter PDF'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'quarantaine',
            child: Row(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 20,
                  color: AppTheme.warning,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mettre en quarantaine',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.warning),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'decede',
            child: Row(
              children: [
                Icon(Icons.cancel, size: 20, color: AppTheme.error),
                const SizedBox(width: 12),
                Text(
                  'Marquer décédé',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
