import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/lapin.dart';
import '../../../../models/enums/sexe.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget pour afficher une carte de lapin dans l'arbre généalogique
class RabbitGenealogyCard extends StatelessWidget {
  final Lapin? lapin;
  final bool isSubject;
  final bool isParent;
  final bool isUnknown;
  final VoidCallback? onTap;

  const RabbitGenealogyCard({
    super.key,
    this.lapin,
    this.isSubject = false,
    this.isParent = false,
    this.isUnknown = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSubject && lapin != null) {
      return _buildSubjectCard(context, isDark);
    } else if (isParent && lapin != null) {
      return _buildParentCard(context, isDark);
    } else if (isUnknown || lapin == null) {
      return _buildUnknownCard(context, isDark);
    } else {
      return _buildGrandparentCard(context, isDark);
    }
  }

  // Carte SUBJECT (grande card avec détails)
  Widget _buildSubjectCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppTheme.primaryGreen, width: 4),
        ),
        boxShadow: [BoxShadow(blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  lapin!.photoPath != null &&
                      File(lapin!.photoPath!).existsSync()
                  ? Image.file(File(lapin!.photoPath!), fit: BoxFit.cover)
                  : Icon(Icons.pets, size: 40, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lapin!.nom,
                        style: AppTheme.titleLarge.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: lapin!.sexe == Sexe.male
                            ? AppTheme.info.withValues(alpha: 0.2)
                            : AppTheme.accentPink.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        lapin!.sexe == Sexe.male ? Icons.male : Icons.female,
                        size: 20,
                        color: lapin!.sexe == Sexe.male
                            ? AppTheme.info
                            : AppTheme.accentPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lapin!.race,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('DOB', _formatDate(lapin!.dateNaissance)),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppTheme.textSecondary,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    _buildInfoChip(
                      'Weight',
                      '${lapin!.poids?.toStringAsFixed(1) ?? '?'} kg',
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppTheme.textSecondary,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    _buildInfoChip('Status', 'Active', hasIndicator: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Carte PARENT (taille moyenne avec badge sexe)
  Widget _buildParentCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.textSecondary : AppTheme.textLight,
          ),
          boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            // Image avec badge
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.cardLight,
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        lapin!.photoPath != null &&
                            File(lapin!.photoPath!).existsSync()
                        ? Image.file(File(lapin!.photoPath!), fit: BoxFit.cover)
                        : Icon(
                            Icons.pets,
                            size: 28,
                            color: AppTheme.textSecondary,
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: lapin!.sexe == Sexe.male
                          ? AppTheme.info.withValues(alpha: 0.2)
                          : AppTheme.accentPink.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : AppTheme.cardLight,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      lapin!.sexe == Sexe.male ? Icons.male : Icons.female,
                      size: 14,
                      color: lapin!.sexe == Sexe.male
                          ? AppTheme.info
                          : AppTheme.accentPink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lapin!.nom,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              lapin!.race,
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Carte GRANDPARENT (petite card compacte)
  Widget _buildGrandparentCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.textSecondary),
          boxShadow: [BoxShadow(blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
              ),
              child: ClipOval(
                child:
                    lapin!.photoPath != null &&
                        File(lapin!.photoPath!).existsSync()
                    ? Image.file(File(lapin!.photoPath!), fit: BoxFit.cover)
                    : Icon(Icons.pets, size: 20, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lapin!.nom,
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              lapin!.race,
              style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Carte UNKNOWN
  Widget _buildUnknownCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textSecondary),
        boxShadow: [BoxShadow(blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
                border: Border.all(
                  color: AppTheme.textSecondary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.question_mark,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).commonUnknown,
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '-',
              style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    String label,
    String value, {
    bool hasIndicator = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIndicator) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppTheme.caption.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
