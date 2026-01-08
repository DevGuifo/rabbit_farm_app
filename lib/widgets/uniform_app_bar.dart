import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget AppBar uniforme pour toute l'application.
///
/// Utilisation:
/// ```dart
/// appBar: UniformAppBar(
///   title: 'Mon Titre',
///   icon: Icons.pets, // optionnel
///   actions: [...], // optionnel
/// ),
/// ```
class UniformAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? iconColor;

  const UniformAppBar({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.onBackPressed,
    this.iconColor,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppTheme.primaryGreen;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
      foregroundColor: isDark ? AppTheme.textLight : AppTheme.textPrimary,
      centerTitle: false,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

/// AppBar simple sans icône décorative (pour les écrans secondaires)
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
      foregroundColor: isDark ? AppTheme.textLight : AppTheme.textPrimary,
      centerTitle: false,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
