import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class FicheSanteHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onRefresh;
  final VoidCallback? onNotification;
  final VoidCallback? onSettings;

  const FicheSanteHeader({
    super.key,
    required this.onBack,
    this.onRefresh,
    this.onNotification,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppTheme.textLight : AppTheme.backgroundDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textMain),
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.cardLight.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Health Details',
              style: TextStyle(
                color: textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (onRefresh != null) ...[
            IconButton(
              icon: Icon(Icons.sync, size: 22, color: textMain),
              onPressed: onRefresh,
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.cardLight.withValues(alpha: 0.1)
                    : AppTheme.backgroundDark.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (onNotification != null) ...[
            IconButton(
              icon: Icon(Icons.notifications, size: 22, color: textMain),
              onPressed: onNotification,
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.cardLight.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (onSettings != null)
            IconButton(
              icon: Icon(Icons.settings, size: 22, color: textMain),
              onPressed: onSettings,
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.cardLight.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
        ],
      ),
    );
  }
}
