import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../../models/lapin.dart';
import '../../../../models/soin.dart';

/// Item compact pour l'historique (Design Stitch)
class HistoryItemCard extends StatelessWidget {
  final Lapin lapin;
  final Soin soin;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const HistoryItemCard({
    super.key,
    required this.lapin,
    required this.soin,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (soin.type) {
      case 'vaccination':
        icon = Icons.vaccines;
        iconColor = AppTheme.info;
        iconBg = AppTheme.info.withValues(alpha: 0.15);
        break;
      case 'traitement':
        icon = Icons.medication;
        iconColor = AppTheme.primaryGreen;
        iconBg = AppTheme.primaryGreen.withValues(alpha: 0.15);
        break;
      default:
        icon = Icons.check;
        iconColor = AppTheme.textSecondary;
        iconBg = AppTheme.textSecondary.withValues(alpha: 0.15);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.05)
                : AppTheme.backgroundDark.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lapin.nom,
                    style: AppTheme.titleSmall.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${soin.description} • Completed',
                    style: AppTheme.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(soin.date),
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(soin.date),
                  style: AppTheme.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('MMM dd').format(date);
  }
}
