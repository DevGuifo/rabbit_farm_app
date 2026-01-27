import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Wrapper pour adapter un Widget à fonctionner dans un bottom sheet modal
/// Retire les barres de navigation et appbar inutiles
class ModalScreenWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final List<Widget>? actions;

  const ModalScreenWrapper({
    required this.child,
    this.title,
    this.onClose,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de titre optionnelle
        if (title != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppTheme.textSecondary.withValues(alpha: 0.1)
                      : AppTheme.textSecondary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: AppTheme.titleLarge.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (actions != null) ...actions! else
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose ?? () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        // Contenu scrollable
        Flexible(
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      ],
    );
  }
}
