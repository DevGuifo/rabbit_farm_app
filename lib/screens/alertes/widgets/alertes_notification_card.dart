import 'package:flutter/material.dart';
import '../../../models/alerte.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Card notification individuelle - Design Stitch
class AlertesNotificationCard extends StatelessWidget {
  final Alerte alerte;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String timeAgo;

  const AlertesNotificationCard({
    super.key,
    required this.alerte,
    required this.onTap,
    this.onDelete,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !alerte.estLue;
    final isUrgent = alerte.priorite == PrioriteAlerte.urgent;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null ? () => _showDeleteMenu(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _buildDecoration(isDark, isUnread, isUrgent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône catégorisée
            _buildIcon(isDark, isUnread),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Titre + Badge unread
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          alerte.titre,
                          style: AppTheme.titleSmall.copyWith(
                            color: _getTextColor(isDark, isUnread),
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Description (max 2 lignes)
                  Text(
                    alerte.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyMedium.copyWith(
                      color: _getSubtextColor(isDark, isUnread),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Timestamp + Catégorie
                  Text(
                    '$timeAgo • ${_mapTypeToCategory(alerte.type)}',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getSubtextColor(isDark, isUnread),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark, bool isUnread, bool isUrgent) {
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final surfaceDimColor = isDark
        ? AppTheme.cardDark
        : AppTheme.backgroundLight;
    final shadowColor = isDark ? Colors.black45 : Colors.black12;

    // État "read" : fond dim + opacité réduite
    if (!isUnread) {
      return BoxDecoration(
        color: surfaceDimColor.withValues(alpha: isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(12),
        border: const Border(),
      );
    }

    // État "unread urgent" : border-left primaire + shadow
    if (isUrgent) {
      return BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppTheme.primaryGreen, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      );
    }

    // État "unread normal" : fond surface + subtle ring
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildIcon(bool isDark, bool isUnread) {
    final iconBgColor = _getIconBackgroundColor(alerte.type, isDark, isUnread);
    final iconColor = _getIconColor(alerte.type, isDark, isUnread);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(_getIconData(alerte.type), size: 20, color: iconColor),
      ),
    );
  }

  Color _getTextColor(bool isDark, bool isUnread) {
    if (!isUnread) {
      return isDark
          ? AppTheme.textLight.withValues(alpha: 0.8)
          : AppTheme.textPrimary.withValues(alpha: 0.8);
    }
    return isDark ? AppTheme.textLight : AppTheme.textPrimary;
  }

  Color _getSubtextColor(bool isDark, bool isUnread) {
    if (!isUnread) {
      return isDark
          ? AppTheme.textSecondary.withValues(alpha: 0.8)
          : AppTheme.textSecondary.withValues(alpha: 0.8);
    }
    return isDark ? AppTheme.textSecondary : AppTheme.textSecondary;
  }

  Color _getIconBackgroundColor(TypeAlerte type, bool isDark, bool isUnread) {
    if (!isUnread) {
      return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    }

    switch (type) {
      case TypeAlerte.vaccination:
      case TypeAlerte.traitement:
      case TypeAlerte.symptomes:
        return isDark
            ? AppTheme.error.withValues(alpha: 0.3)
            : AppTheme.error.withValues(alpha: 0.1);
      case TypeAlerte.miseBas:
      case TypeAlerte.sevrage:
      case TypeAlerte.palpation:
        return AppTheme.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1);
      case TypeAlerte.pesee:
      case TypeAlerte.quarantaine:
        return isDark
            ? AppTheme.warning.withValues(alpha: 0.3)
            : AppTheme.warning.withValues(alpha: 0.1);
      case TypeAlerte.stockFaible:
      case TypeAlerte.peremption:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    }
  }

  Color _getIconColor(TypeAlerte type, bool isDark, bool isUnread) {
    if (!isUnread) {
      return isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    }

    switch (type) {
      case TypeAlerte.vaccination:
      case TypeAlerte.traitement:
      case TypeAlerte.symptomes:
        return isDark ? AppTheme.error.withValues(alpha: 0.8) : AppTheme.error;
      case TypeAlerte.miseBas:
      case TypeAlerte.sevrage:
      case TypeAlerte.palpation:
        return isDark ? AppTheme.primaryGreen : AppTheme.success;
      case TypeAlerte.pesee:
      case TypeAlerte.quarantaine:
        return isDark
            ? AppTheme.warning.withValues(alpha: 0.8)
            : AppTheme.warning;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  IconData _getIconData(TypeAlerte type) {
    switch (type) {
      case TypeAlerte.vaccination:
        return Icons.warning_rounded;
      case TypeAlerte.miseBas:
      case TypeAlerte.palpation:
      case TypeAlerte.sevrage:
        return Icons.pets;
      case TypeAlerte.traitement:
      case TypeAlerte.symptomes:
      case TypeAlerte.quarantaine:
        return Icons.medical_services_outlined;
      case TypeAlerte.pesee:
      case TypeAlerte.poidsAnormal:
        return Icons.monitor_weight_outlined;
      case TypeAlerte.stockFaible:
      case TypeAlerte.peremption:
        return Icons.inventory_2_outlined;
      case TypeAlerte.preparationNid:
        return Icons.home_outlined;
      case TypeAlerte.consanguinite:
        return Icons.info_outline;
      case TypeAlerte.reforme:
        return Icons.recycling_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _mapTypeToCategory(TypeAlerte type) {
    switch (type) {
      case TypeAlerte.vaccination:
      case TypeAlerte.traitement:
      case TypeAlerte.symptomes:
      case TypeAlerte.pesee:
      case TypeAlerte.poidsAnormal:
      case TypeAlerte.quarantaine:
        return 'Health Alert';
      case TypeAlerte.miseBas:
      case TypeAlerte.palpation:
      case TypeAlerte.sevrage:
      case TypeAlerte.preparationNid:
      case TypeAlerte.consanguinite:
        return 'Breeding';
      case TypeAlerte.stockFaible:
      case TypeAlerte.peremption:
        return 'Inventory';
      case TypeAlerte.reforme:
      case TypeAlerte.mortaliteAnormale:
        return 'Task';
    }
  }

  void _showDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.backgroundDark
              : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.error),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
