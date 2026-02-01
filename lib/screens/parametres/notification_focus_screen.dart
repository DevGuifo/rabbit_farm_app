import 'package:flutter/material.dart';
import '../../models/mode_focus.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';

/// Écran de configuration du mode Focus pour les notifications
class NotificationFocusScreen extends StatefulWidget {
  const NotificationFocusScreen({super.key});

  @override
  State<NotificationFocusScreen> createState() =>
      _NotificationFocusScreenState();
}

class _NotificationFocusScreenState extends State<NotificationFocusScreen> {
  final NotificationService _notificationService = NotificationService();
  ModeFocus _currentMode = ModeFocus.normal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerModeFocus();
  }

  Future<void> _chargerModeFocus() async {
    try {
      final mode = await _notificationService.getModeFocus();
      if (mounted) {
        setState(() {
          _currentMode = mode;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('Erreur chargement mode focus: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changerMode(ModeFocus newMode) async {
    try {
      await _notificationService.setModeFocus(newMode);
      if (mounted) {
        setState(() => _currentMode = newMode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mode ${newMode.label} activé',
              style: const TextStyle(color: AppTheme.textOnPrimary),
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      logger.error('Erreur changement mode focus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mode Focus'),
        backgroundColor: AppTheme.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description générale
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔔 Contrôle des notifications',
                        style: AppTheme.titleMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choisissez le niveau de notifications que vous souhaitez recevoir.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options de mode
                ...ModeFocus.values.map((mode) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildModeCard(mode, isDark),
                  );
                }),

                const SizedBox(height: 32),

                // Information supplémentaire
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.info : AppTheme.info).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? AppTheme.info : AppTheme.info)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Les urgences critiques (mise bas difficile, symptômes graves) sont toujours notifiées, quel que soit le mode.',
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
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

  Widget _buildModeCard(ModeFocus mode, bool isDark) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () => _changerMode(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryGreen : AppTheme.primaryGreen)
                    .withValues(alpha: 0.15)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withValues(alpha: 0.2)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : (isDark ? AppTheme.backgroundDark : AppTheme.greyLight),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(mode.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: AppTheme.titleSmall.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: AppTheme.caption.copyWith(
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
