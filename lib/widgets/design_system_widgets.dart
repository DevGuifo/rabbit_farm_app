import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Composant Header standard pour tous les écrans
/// Remplace les headers custom répétitifs
class StandardHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final bool showNotificationBadge;
  final int notificationCount;

  const StandardHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSync,
    this.onNotifications,
    this.onSettings,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.headerDecoration(isDark: isDark),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  if (onSync != null)
                    IconButton(
                      icon: Icon(
                        Icons.sync,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                      onPressed: onSync,
                    ),
                  if (onNotifications != null)
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                          onPressed: onNotifications,
                        ),
                        if (showNotificationBadge && notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                notificationCount.toString(),
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (onSettings != null)
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                      onPressed: onSettings,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Composant Card réutilisable (Cheptel style: rabbit list)
class ListCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ListCard({
    super.key,
    required this.isDark,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: AppTheme.cardDecoration(isDark: isDark),
        child: child,
      ),
    );
  }
}

/// Composant FAB standard avec actions multiples
class ContextualFAB extends StatefulWidget {
  final bool isDark;
  final List<FABAction> actions;

  const ContextualFAB({super.key, required this.isDark, required this.actions});

  @override
  State<ContextualFAB> createState() => _ContextualFABState();
}

class FABAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  FABAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
  });
}

class _ContextualFABState extends State<ContextualFAB> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.length == 1) {
      // Single FAB
      return FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: widget.actions[0].onPressed,
        tooltip: widget.actions[0].tooltip,
        child: Icon(widget.actions[0].icon),
      );
    }

    // Multiple FABs
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded)
          ...List.generate(widget.actions.length, (index) {
            final action = widget.actions[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor:
                      action.backgroundColor ??
                      AppTheme.primaryGreen.withValues(alpha: 0.7),
                  onPressed: () {
                    action.onPressed();
                    setState(() => _isExpanded = false);
                  },
                  tooltip: action.tooltip,
                  child: Icon(action.icon),
                ),
                const SizedBox(height: AppTheme.spacing8),
              ],
            );
          }),
        FloatingActionButton(
          backgroundColor: AppTheme.primaryGreen,
          onPressed: () {
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Icon(_isExpanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

/// Composant Hero Section (Santé style)
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

/// Composant Stats Card (infos chiffrées)
class StatsCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: AppTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 🔍 SEARCH BAR WIDGET
// ============================================

/// Barre de recherche standardisée
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    this.hintText = 'Rechercher...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                  .withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🏷️ FILTER PILL WIDGET
// ============================================

/// Pastille de filtre sélectionnable
class FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.textLight : AppTheme.textPrimary)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
          boxShadow: isSelected ? AppTheme.shadowSmall : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🎯 ACTION CARD WIDGET (Santé style)
// ============================================

/// Card d'action avec icône colorée et cercle décoratif
class ActionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final double? height;

  const ActionCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: AppTheme.actionCardDecoration(isDark: isDark),
        child: Stack(
          children: [
            // Cercle décoratif
            Positioned(
              right: -16,
              top: -16,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.1 : 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.3 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// 📭 EMPTY STATE WIDGET
// ============================================

/// État vide standardisé
class EmptyState extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 🔷 DIVIDER WIDGET
// ============================================

/// Séparateur standardisé
class DividerWidget extends StatelessWidget {
  final bool isDark;

  const DividerWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.shade200,
    );
  }
}

// ============================================
// 🏷️ BADGE WIDGET
// ============================================

/// Badge coloré pour indicateurs
class BadgeWidget extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;

  const BadgeWidget({
    super.key,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ============================================
// 📋 SECTION HEADER WIDGET
// ============================================

/// En-tête de section avec titre et bouton "Voir plus"
class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final IconData? icon;
  final VoidCallback? onMoreTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.icon,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: AppTheme.spacing8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (onMoreTap != null)
            GestureDetector(
              onTap: onMoreTap,
              child: const Text(
                'Voir plus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// ⏱️ TASK ITEM WIDGET
// ============================================

/// Item de tâche programmée
class TaskItem extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final String? badgeText;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: AppTheme.cardDecoration(isDark: isDark),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: badgeColor),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textLight.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeText != null)
              BadgeWidget(text: badgeText!, color: badgeColor, isDark: isDark),
          ],
        ),
      ),
    );
  }
}
