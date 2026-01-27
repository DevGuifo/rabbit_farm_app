import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/lapin.dart';
import '../../../../models/enums/sexe.dart';
import '../../../../theme/app_theme.dart';

/// Header de profil avec photo, nom, race, et statuts (Stitch Design)
class DetailProfileHeader extends StatelessWidget {
  final Lapin lapin;

  const DetailProfileHeader({super.key, required this.lapin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Profile Image with Status Badge
          _buildProfileImage(isDark),
          const SizedBox(height: 20),
          // Name
          Text(
            lapin.nom,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Race + Sex
          Text(
            '${lapin.race} • ${lapin.sexe == Sexe.male ? 'Male' : 'Female'}',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.neutral400 : AppTheme.neutral500,
            ),
          ),
          const SizedBox(height: 16),
          // Status Chips
          _buildStatusChips(context, isDark),
        ],
      ),
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return Stack(
      children: [
        // Profile Circle
        Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppTheme.neutral800 : AppTheme.neutral200,
            border: Border.all(
              color: isDark ? AppTheme.surfaceDark : AppTheme.cardLight,
              width: 6,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.borderDark.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child:
                lapin.photoPath != null && File(lapin.photoPath!).existsSync()
                ? Image.file(
                    File(lapin.photoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderIcon();
                    },
                  )
                : _buildPlaceholderIcon(),
          ),
        ),
        // Status Badge
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundLight,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dividerDark.withValues(alpha: 0.8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.pets, size: 64, color: AppTheme.neutral400),
    );
  }

  Widget _buildStatusChips(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        // Active Breeder Chip
        Container(
          padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppTheme.dividerDark.withValues(alpha: 0.8),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).cheptelActiveBreeder,
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? AppTheme.stitchTextMainDark
                      : AppTheme.cardLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Healthy Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.green900 : AppTheme.green50,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: isDark
                  ? AppTheme.green900.withValues(alpha: 0.5)
                  : AppTheme.green100,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.borderDark.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.health_and_safety,
                size: 16,
                color: isDark ? AppTheme.green300 : AppTheme.green700,
              ),
              const SizedBox(width: 4),
              Text(
                'HEALTHY',
                style: AppTheme.caption.copyWith(
                  color: isDark ? AppTheme.green300 : AppTheme.green700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
