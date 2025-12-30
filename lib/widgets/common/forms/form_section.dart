import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Section de formulaire avec titre et champs groupés
/// 
/// Usage:
/// ```dart
/// FormSection(
///   title: 'Informations de base',
///   isDark: isDark,
///   children: [
///     TextField(...),
///     TextField(...),
///   ],
/// )
/// ```
class FormSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;
  final IconData? icon;

  const FormSection({
    super.key,
    required this.title,
    required this.isDark,
    required this.children,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: AppTheme.spacing8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: AppTheme.spacing16),
      ],
    );
  }
}

