import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

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
            '${lapin.race} • ${lapin.sexe == 'Mâle' || lapin.sexe == 'male' ? 'Male' : 'Female'}',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
            ),
          ),
          const SizedBox(height: 16),
          // Status Chips
          _buildStatusChips(isDark),
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
            color: isDark ? StitchTheme.neutral800 : StitchTheme.neutral200,
            border: Border.all(
              color: isDark ? AppTheme.stitchSurfaceDark : AppTheme.cardLight,
              width: 6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
              color: StitchTheme.primaryYellow,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? StitchTheme.backgroundDark
                    : StitchTheme.backgroundLight,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.pets, size: 64, color: StitchTheme.neutral400),
    );
  }

  Widget _buildStatusChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        // Active Breeder Chip
        Container(
          padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.textLight : AppTheme.stitchTextMainLight,
            borderRadius: BorderRadius.circular(StitchTheme.radiusFull),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
                  color: StitchTheme.primaryYellow,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ACTIVE BREEDER',
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
            color: isDark ? StitchTheme.green900 : StitchTheme.green50,
            borderRadius: BorderRadius.circular(StitchTheme.radiusFull),
            border: Border.all(
              color: isDark
                  ? StitchTheme.green900.withValues(alpha: 0.5)
                  : StitchTheme.green100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                color: isDark ? StitchTheme.green300 : StitchTheme.green700,
              ),
              const SizedBox(width: 4),
              Text(
                'HEALTHY',
                style: AppTheme.caption.copyWith(
                  color: isDark ? StitchTheme.green300 : StitchTheme.green700,
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
