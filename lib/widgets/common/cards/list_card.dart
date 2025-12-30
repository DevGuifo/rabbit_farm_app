import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Composant Card réutilisable pour les listes (Cheptel style)
/// 
/// Usage:
/// ```dart
/// ListCard(
///   isDark: isDark,
///   onTap: () => _navigateToDetail(),
///   child: RabbitCard(rabbit: rabbit),
/// )
/// ```
class ListCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ListCard({
    super.key,
    required this.isDark,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: AppTheme.cardDecoration(isDark: isDark),
        child: child,
      ),
    );
  }
}

