import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour la section profil avec avatar, nom, email et bouton Edit Profile
class SettingsProfileSection extends StatelessWidget {
  final String? profileName;
  final String? profileEmail;
  final String? avatarUrl;
  final VoidCallback? onEditProfilePressed;

  const SettingsProfileSection({
    super.key,
    this.profileName,
    this.profileEmail,
    this.avatarUrl,
    this.onEditProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.stitchSurfaceDark
            : AppTheme.stitchSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
              : AppTheme.textPrimary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryNeonGreen,
                width: 2,
              ),
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppTheme.primaryNeonGreen,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Nom, email et bouton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  profileName ?? 'Green Valley Rabbits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textOnPrimary
                        : AppTheme.stitchTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profileEmail ?? 'john@greenvalley.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.stitchTextSecDark
                        : AppTheme.stitchTextSecLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Bouton Edit Profile
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onEditProfilePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primaryNeonGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

