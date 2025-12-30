import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Header sticky pour l'écran Treatments & Care
/// Design: Stitch avec boutons actions (back, sync, more)
class TreatmentsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSync;
  final VoidCallback? onMore;
  final bool isDark;
  final Color textPrimary;
  final Color backgroundColor;

  const TreatmentsHeader({
    super.key,
    required this.onBack,
    required this.onSync,
    this.onMore,
    required this.isDark,
    required this.textPrimary,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : AppTheme.backgroundDark.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: textPrimary, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Treatments & Care',
                  style: AppTheme.titleLarge.copyWith(
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.sync, color: textPrimary, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: onSync,
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: textPrimary, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: onMore ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
