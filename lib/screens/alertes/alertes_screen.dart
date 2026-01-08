import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/alerte.dart';
import '../../providers/alerte_provider.dart';
import 'widgets/alertes_app_bar.dart';
import 'widgets/alertes_filter_chips.dart';
import 'widgets/alertes_notification_card.dart';
import 'widgets/alertes_empty_state.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Écran Notifications - Design Stitch (Neon Green)
/// Orchestrateur léger avec widgets modulaires
class AlertesScreen extends StatefulWidget {
  const AlertesScreen({super.key});

  @override
  State<AlertesScreen> createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  String _filtrePriorite = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerAlertes();
    });
  }

  Future<void> _chargerAlertes() async {
    final alerteProvider = context.read<AlerteProvider>();
    await alerteProvider.scannerAlertes();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AlertesAppBar(
          onBack: () => Navigator.of(context).pop(),
          onSync: _chargerAlertes,
          onNotifications:
              null, // Masquer car on est déjà sur la page des notifications
          onSettings: () {
            // Navigation vers paramètres
          },
          hasUnreadNotifications: _hasUnreadNotifications(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          AlertesFilterChips(
            selectedFilter: _filtrePriorite,
            onFilterChanged: (filter) {
              setState(() {
                _filtrePriorite = filter;
              });
            },
          ),

          // Liste des notifications
          Expanded(
            child: Consumer<AlerteProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  );
                }

                // Filtrer par priorité
                List<Alerte> alertes;
                if (_filtrePriorite == '' ||
                    _filtrePriorite ==
                        AppLocalizations.of(context).alertesTous) {
                  alertes = provider.alertes;
                } else if (_filtrePriorite ==
                    AppLocalizations.of(context).alertesStock) {
                  // Filtre custom "Stock" = stockFaible + peremption
                  alertes = provider.alertes
                      .where(
                        (a) =>
                            a.type == TypeAlerte.stockFaible ||
                            a.type == TypeAlerte.peremption,
                      )
                      .toList();
                } else {
                  final priorite = PrioriteAlerte.values.firstWhere(
                    (p) => p.label == _filtrePriorite,
                  );
                  alertes = provider.getAlertesByPriorite(priorite);
                }

                if (alertes.isEmpty) {
                  return const AlertesEmptyState();
                }

                // Grouper par date (Today, Yesterday)
                final today = DateTime.now();
                final yesterday = today.subtract(const Duration(days: 1));

                final todayAlertes = alertes
                    .where((a) => _isSameDay(a.dateCreation, today))
                    .toList();
                final yesterdayAlertes = alertes
                    .where((a) => _isSameDay(a.dateCreation, yesterday))
                    .toList();
                final olderAlertes = alertes
                    .where(
                      (a) =>
                          !_isSameDay(a.dateCreation, today) &&
                          !_isSameDay(a.dateCreation, yesterday),
                    )
                    .toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // Section: Today
                    if (todayAlertes.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context).alertesAujourdhui,
                        hasMarkAllRead: true,
                        onMarkAllRead: () =>
                            _markAllAsRead(provider, todayAlertes),
                      ),
                      const SizedBox(height: 12),
                      ...todayAlertes.map((alerte) {
                        return AlertesNotificationCard(
                          alerte: alerte,
                          timeAgo: _formatTimeAgo(alerte.dateCreation),
                          onTap: () {
                            provider.marquerCommeLue(alerte.id);
                          },
                          onDelete: () {
                            provider.supprimerAlerte(alerte.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).alerteSupprimee,
                                ),
                                backgroundColor: isDark
                                    ? AppTheme.backgroundDark
                                    : AppTheme.textSecondary,
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Section: Yesterday
                    if (yesterdayAlertes.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context).alertesHier,
                      ),
                      const SizedBox(height: 12),
                      ...yesterdayAlertes.map((alerte) {
                        return AlertesNotificationCard(
                          alerte: alerte,
                          timeAgo: _formatTimeAgo(alerte.dateCreation),
                          onTap: () {
                            provider.marquerCommeLue(alerte.id);
                          },
                          onDelete: () {
                            provider.supprimerAlerte(alerte.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).alerteSupprimee,
                                ),
                                backgroundColor: isDark
                                    ? AppTheme.backgroundDark
                                    : AppTheme.textSecondary,
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Section: Older
                    if (olderAlertes.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Older'),
                      const SizedBox(height: 12),
                      ...olderAlertes.map((alerte) {
                        return AlertesNotificationCard(
                          alerte: alerte,
                          timeAgo: _formatTimeAgo(alerte.dateCreation),
                          onTap: () {
                            provider.marquerCommeLue(alerte.id);
                          },
                          onDelete: () {
                            provider.supprimerAlerte(alerte.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).alerteSupprimee,
                                ),
                                backgroundColor: isDark
                                    ? AppTheme.bgDark
                                    : AppTheme.neutral800,
                              ),
                            );
                          },
                        );
                      }),
                    ],

                    const SizedBox(height: 80), // Bottom padding
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool hasMarkAllRead = false,
    VoidCallback? onMarkAllRead,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(color: textColor, height: 1.2),
        ),
        if (hasMarkAllRead)
          GestureDetector(
            onTap: onMarkAllRead,
            child: Text(
              AppLocalizations.of(context).alertesMarquerLues,
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return 'Yesterday, $displayHour:$minute $period';
    } else {
      final day = date.day;
      final month = date.month;
      final year = date.year;
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year at $hour:$minute';
    }
  }

  bool _hasUnreadNotifications() {
    final provider = context.read<AlerteProvider>();
    return provider.alertes.any((a) => !a.estLue);
  }

  void _markAllAsRead(AlerteProvider provider, List<Alerte> alertes) {
    for (final alerte in alertes) {
      if (!alerte.estLue) {
        provider.marquerCommeLue(alerte.id);
      }
    }
  }
}
