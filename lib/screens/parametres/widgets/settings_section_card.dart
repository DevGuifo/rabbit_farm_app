import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour une carte de section avec titre et contenu
class SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark
                  ? AppTheme.stitchTextSecDark
                  : AppTheme.stitchTextSecLight,
            ),
          ),
        ),

        // Carte avec contenu
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.stitchSurfaceDark
                : AppTheme.stitchSurfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
                  : AppTheme.textPrimary.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _buildDividedChildren(children, isDark),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDividedChildren(List<Widget> children, bool isDark) {
    if (children.isEmpty) return [];
    if (children.length == 1) return children;

    final List<Widget> divided = [];
    for (int i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (i < children.length - 1) {
        divided.add(
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
                : AppTheme.textPrimary.withValues(alpha: 0.05),
          ),
        );
      }
    }
    return divided;
  }
}

