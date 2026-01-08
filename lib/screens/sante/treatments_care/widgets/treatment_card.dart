import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../../models/lapin.dart';
import '../../../../models/soin.dart';
import '../../../../l10n/app_localizations.dart';

/// Carte de traitement détaillée (Design Stitch)
/// Affiche: badge statut, progress bar, info next dose, bouton edit
class TreatmentCard extends StatelessWidget {
  final Lapin lapin;
  final Soin soin;
  final bool isDark;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const TreatmentCard({
    super.key,
    required this.lapin,
    required this.soin,
    required this.isDark,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = soin.dateRappel != null
        ? soin.dateRappel!.difference(DateTime.now()).inDays
        : 0;
    final progress = soin.dateRappel != null && daysRemaining < 7
        ? ((7 - daysRemaining) / 7 * 100).clamp(0, 100)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.backgroundDark.withValues(
                alpha: isDark ? 0.3 : 0.06,
              ),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with status and edit button
            Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Active',
                                  style: AppTheme.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (daysRemaining > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              'In ${daysRemaining}d',
                              style: AppTheme.caption.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lapin.nom,
                        style: AppTheme.titleLarge.copyWith(color: textPrimary),
                      ),
                      Text(
                        soin.description,
                        style: AppTheme.bodyMedium.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: textSecondary),
                  onPressed: onEdit ?? () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Next dose info
            if (soin.dateRappel != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.cardLight.withValues(alpha: 0.05)
                      : AppTheme.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.of(context).santeNext}: ${DateFormat('MMM dd, yyyy').format(soin.dateRappel!)}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (soin.notes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 18,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              soin.notes!,
                              style: AppTheme.caption.copyWith(
                                color: textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            if (progress > 0) ...[
              const SizedBox(height: 12),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppTheme.caption.copyWith(color: textSecondary),
                      ),
                      Text(
                        '${progress.toInt()}%',
                        style: AppTheme.caption.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppTheme.cardLight.withValues(alpha: 0.1)
                          : AppTheme.border.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
