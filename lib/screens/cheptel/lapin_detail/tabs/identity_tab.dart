import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';
import 'basic_information_card.dart';
import 'lineage_card.dart';
import 'notes_card.dart';

/// Onglet Identity (Stitch Design)
/// Compose: Basic Information + Lineage + Notes + Actions
class IdentityTab extends StatelessWidget {
  final Lapin lapin;
  final Map<String, Lapin?> parents;
  final Function(Lapin) onParentTap;
  final VoidCallback? onViewGenealogie;
  final VoidCallback? onExportPDF;
  final VoidCallback? onMarkQuarantaine;
  final VoidCallback? onMarkDecede;

  const IdentityTab({
    super.key,
    required this.lapin,
    required this.parents,
    required this.onParentTap,
    this.onViewGenealogie,
    this.onExportPDF,
    this.onMarkQuarantaine,
    this.onMarkDecede,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Basic Information Card
          BasicInformationCard(lapin: lapin),
          const SizedBox(height: 16),
          // Lineage Card avec bouton généalogie
          _buildLineageSection(context, isDark),
          const SizedBox(height: 16),
          // Notes Card
          NotesCard(notes: lapin.notes, lastUpdateInfo: null),
          const SizedBox(height: 16),
          // Actions Card
          _buildActionsCard(context, isDark),
          const SizedBox(height: 120), // Espace pour FAB
        ],
      ),
    );
  }

  Widget _buildLineageSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        LineageCard(parents: parents, onParentTap: onParentTap),
        if (onViewGenealogie != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewGenealogie,
              icon: const Icon(Icons.account_tree_rounded, size: 18),
              label: Text(
                AppLocalizations.of(
                  context,
                ).cheptelVoirArbreGeneralogiqueComplet,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.info,
                side: BorderSide(color: AppTheme.info.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context, bool isDark) {
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    // Ne pas afficher si vendu ou décédé
    if (lapin.statut == 'vendu' || lapin.statut == 'decede') {
      return _buildExportOnlyCard(context, isDark, surfaceColor, outlineColor);
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Export PDF
          if (onExportPDF != null)
            _buildActionTile(
              icon: Icons.picture_as_pdf_rounded,
              label: AppLocalizations.of(context).labelExporterFichePDF,
              color: AppTheme.info,
              onTap: onExportPDF!,
            ),
          // Quarantaine
          if (onMarkQuarantaine != null && lapin.statut != 'quarantaine')
            _buildActionTile(
              icon: Icons.health_and_safety_rounded,
              label: AppLocalizations.of(context).labelMettreQuarantaine,
              color: AppTheme.warning,
              onTap: onMarkQuarantaine!,
            ),
          // Décès
          if (onMarkDecede != null)
            _buildActionTile(
              icon: Icons.cancel_rounded,
              label: AppLocalizations.of(context).labelEnregistrerDeces,
              color: AppTheme.error,
              onTap: onMarkDecede!,
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildExportOnlyCard(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color outlineColor,
  ) {
    if (onExportPDF == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.picture_as_pdf_rounded,
            label: AppLocalizations.of(context).labelExporterFichePDF,
            color: AppTheme.info,
            onTap: onExportPDF!,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDestructive ? color : null,
                  fontWeight: isDestructive
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
