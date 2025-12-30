import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Composant Hero Section (Santé style)
/// 
/// Usage:
/// ```dart
/// HeroSection(
///   title: 'Health Hub',
///   subtitle: 'Manage herd wellness and records',
///   isDark: isDark,
/// )
/// ```
class HeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

