import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour un élément de liste dans les paramètres avec icône, texte et chevron
class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailingIcon;
  final VoidCallback? onTap;

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône dans un conteneur coloré
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryNeonGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Titre et sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF111812),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.stitchTextSecDark
                          : AppTheme.stitchTextSecLight,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Texte trailing ou icône
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onTap != null)
            trailingIcon ??
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
