import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/permission_service.dart';
import '../../../theme/app_theme.dart';

/// Widget pour afficher une carte d'utilisateur
class UserCard extends StatelessWidget {
  final User user;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final bool canManage;

  const UserCard({
    super.key,
    required this.user,
    required this.isDark,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
    this.canManage = false,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      child: InkWell(
        onTap: canManage ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: user.isActive
                    ? AppTheme.primaryNeonGreen.withValues(alpha: 0.2)
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                child: Text(
                  user.nomComplet.isNotEmpty
                      ? user.nomComplet[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: user.isActive
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.nomComplet,
                            style: AppTheme.titleMedium.copyWith(
                              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!user.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Inactif',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        permissionService.getRoleName(user.role),
                        style: AppTheme.bodySmall.copyWith(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              if (canManage)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                  onSelected: (value) {
                    if (value == 'toggle') {
                      onToggleActive();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 20,
                            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Désactiver' : 'Activer'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Désactiver',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.error;
      case UserRole.eleveur:
        return AppTheme.primaryNeonGreen;
      case UserRole.assistant:
        return AppTheme.info;
      case UserRole.observateur:
        return AppTheme.textSecondary;
    }
  }
}

