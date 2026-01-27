import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Utilitaire pour déterminer le statut (couleur) d'un KPI selon des seuils
/// Retourne : 'success' (vert), 'warning' (orange), ou 'error' (rouge)
class KpiThresholds {
  /// Évalue le taux de mortalité
  /// - Vert : < 5%
  /// - Orange : 5-15%
  /// - Rouge : > 15%
  static String mortalityStatus(double tauxMortalite) {
    if (tauxMortalite < 5.0) return 'success';
    if (tauxMortalite < 15.0) return 'warning';
    return 'error';
  }

  /// Évalue le GMQ (Gain Moyen Quotidien)
  /// - Vert : > 35g/jour (excellent)
  /// - Orange : 25-35g/jour (acceptable)
  /// - Rouge : < 25g/jour (problème croissance)
  static String gmqStatus(double gmqMoyen) {
    if (gmqMoyen > 35.0) return 'success';
    if (gmqMoyen >= 25.0) return 'warning';
    return 'error';
  }

  /// Évalue le taux de reproduction
  /// - Vert : > 80% (excellent)
  /// - Orange : 60-80% (acceptable)
  /// - Rouge : < 60% (problème fertilité)
  static String reproductionStatus(double tauxReproduction) {
    if (tauxReproduction > 80.0) return 'success';
    if (tauxReproduction >= 60.0) return 'warning';
    return 'error';
  }

  /// Évalue le ROI (Return On Investment)
  /// - Vert : > 20% (rentable)
  /// - Orange : 0-20% (équilibre)
  /// - Rouge : < 0% (déficitaire)
  static String roiStatus(double roi) {
    if (roi > 20.0) return 'success';
    if (roi >= 0.0) return 'warning';
    return 'error';
  }

  /// Évalue le bénéfice mensuel
  /// - Vert : > 200€ (profitable)
  /// - Orange : 0-200€ (faible marge)
  /// - Rouge : < 0€ (perte)
  static String beneficeStatus(double beneficeMensuel) {
    if (beneficeMensuel > 200.0) return 'success';
    if (beneficeMensuel >= 0.0) return 'warning';
    return 'error';
  }

  /// Retourne la couleur associée au statut
  static Color getColor(String status, {required bool isDark}) {
    switch (status) {
      case 'success':
        return AppTheme.success600;
      case 'warning':
        return AppTheme.warning600;
      case 'error':
        return AppTheme.error600;
      default:
        return isDark ? AppTheme.neutral500 : AppTheme.neutral400;
    }
  }

  /// Retourne l'icône associée au statut
  static IconData getIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  /// Retourne une description textuelle du statut
  static String getLabel(String status) {
    switch (status) {
      case 'success':
        return 'Excellent';
      case 'warning':
        return 'Attention';
      case 'error':
        return 'Critique';
      default:
        return 'Normal';
    }
  }

  /// Badge de statut avec couleur et label
  static Widget buildStatusBadge(String status, {required bool isDark}) {
    final color = getColor(status, isDark: isDark);
    final icon = getIcon(status);
    final label = getLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
