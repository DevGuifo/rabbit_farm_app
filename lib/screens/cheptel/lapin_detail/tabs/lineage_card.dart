import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';

/// Card "Lineage" pour afficher père et mère (Stitch Design)
class LineageCard extends StatelessWidget {
  final Map<String, Lapin?> parents;
  final Function(Lapin) onParentTap;

  const LineageCard({
    super.key,
    required this.parents,
    required this.onParentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.textLight.withValues(alpha: 0.05)
                  : AppTheme.neutral50.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(bottom: BorderSide(color: outlineColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).cheptelLineage,
                  style: AppTheme.titleMedium.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.textLight.withValues(alpha: 0.1)
                        : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_tree,
                    size: 20,
                    color: AppTheme.neutral400,
                  ),
                ),
              ],
            ),
          ),
          // Parents List
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Father
                if (parents['pere'] != null)
                  _buildParentTile(
                    context: context,
                    isDark: isDark,
                    label: AppLocalizations.of(context).cheptelFather,
                    parent: parents['pere']!,
                  ),
                // Divider
                if (parents['pere'] != null && parents['mere'] != null)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 48,
                    ),
                    color: isDark
                        ? AppTheme.outlineDark
                        : AppTheme.outlineLight,
                  ),
                // Mother
                if (parents['mere'] != null)
                  _buildParentTile(
                    context: context,
                    isDark: isDark,
                    label: AppLocalizations.of(context).cheptelMother,
                    parent: parents['mere']!,
                  ),
                // No parents message
                if (parents['pere'] == null && parents['mere'] == null)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      AppLocalizations.of(context).cheptelAucunParent,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark
                            ? AppTheme.neutral500
                            : AppTheme.neutral400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentTile({
    required BuildContext context,
    required bool isDark,
    required String label,
    required Lapin parent,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onParentTap(parent),
        borderRadius: BorderRadius.circular(48),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.neutral700 : AppTheme.neutral200,
                  border: Border.all(
                    color: isDark
                        ? AppTheme.stitchTextSecDark
                        : AppTheme.cardLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      parent.photoPath != null &&
                          File(parent.photoPath!).existsSync()
                      ? Image.file(
                          File(parent.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon();
                          },
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppTheme.neutral400
                            : AppTheme.neutral500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parent.nom,
                      style: AppTheme.titleSmall.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.stitchTextMainLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(Icons.chevron_right, color: AppTheme.neutral300, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.pets, size: 24, color: AppTheme.neutral400),
    );
  }
}
