import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/portee.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget pour afficher une carte de portée dans l'arbre généalogique
class LitterCard extends StatelessWidget {
  final Portee portee;
  final VoidCallback? onTap;

  const LitterCard({super.key, required this.portee, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.textSecondary, width: 1),
        ),
        child: Row(
          children: [
            // Stacked avatars
            SizedBox(
              width: 56,
              height: 48,
              child: Stack(
                children: [
                  Positioned(left: 0, child: _buildCircleAvatar(isDark, 0)),
                  if (portee.nombreVivants > 1)
                    Positioned(left: 16, child: _buildCircleAvatar(isDark, 1)),
                  if (portee.nombreVivants > 2)
                    Positioned(
                      left: 32,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.backgroundDark
                                : AppTheme.cardLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+${portee.nombreVivants - 2}',
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Litter #${portee.id}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(portee.dateMiseBasReelle),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Kit count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${portee.nombreVivants}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.pets, size: 14, color: AppTheme.primaryGreen),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAvatar(bool isDark, int index) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
          width: 2,
        ),
      ),
      child: Icon(Icons.pets, size: 18, color: AppTheme.textSecondary),
    );
  }
}
