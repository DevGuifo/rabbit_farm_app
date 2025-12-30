import 'package:flutter/material.dart';
import '../../../models/cage.dart';
import '../../../models/batiment.dart';
import '../../../models/clapier.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget pour afficher une carte de cage dans la liste
class CageCardWidget extends StatelessWidget {
  final Map<String, dynamic> cageData;
  final Map<int, Batiment> batimentsMap;
  final Map<int, Clapier> clapiersMap;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const CageCardWidget({
    super.key,
    required this.cageData,
    required this.batimentsMap,
    required this.clapiersMap,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cage = cageData['cage'] as Cage;
    final occupants = cageData['occupants'] as int;
    final statut = cageData['statut'] as String;
    final needsCleaning = cageData['needsCleaning'] as bool;
    final lastCleaned = cageData['lastCleaned'] as String?;

    final clapier = clapiersMap[cage.clapierId];
    final batiment = clapier != null ? batimentsMap[clapier.batimentId] : null;

    Color borderColor;
    if (needsCleaning) {
      borderColor = AppTheme.warning;
    } else if (statut == 'vide') {
      borderColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    } else {
      borderColor = AppTheme.primaryNeonGreen;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.stitchSurfaceDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCageIcon(isDark, statut),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _buildCageInfo(
                    isDark,
                    cage,
                    statut,
                    occupants,
                    needsCleaning,
                    lastCleaned,
                    batiment,
                  ),
                ),
              ),
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 24,
                  color: isDark
                      ? const Color(0xFF8BA88E)
                      : AppTheme.stitchTextSecLight,
                ),
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCageIcon(bool isDark, String statut) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: statut == 'vide'
            ? (isDark ? const Color(0xFF2E2D15) : const Color(0xFFF3F4F6))
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: statut == 'vide'
          ? Icon(
              Icons.cottage_rounded,
              size: 28,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const Icon(
                Icons.pets_rounded,
                size: 32,
                color: AppTheme.textSecondary,
              ),
            ),
    );
  }

  Widget _buildCageInfo(
    bool isDark,
    Cage cage,
    String statut,
    int occupants,
    bool needsCleaning,
    String? lastCleaned,
    Batiment? batiment,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Cage ${cage.numero}',
              style: AppTheme.titleSmall.copyWith(
                color: isDark
                    ? const Color(0xFFE0E6E0)
                    : AppTheme.stitchTextMainLight,
              ),
            ),
            if (needsCleaning) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Needs Cleaning',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
            if (statut == 'vide') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E2D15)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Empty',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${batiment?.nom ?? ''} • ${statut == 'vide' ? 'Available' : 'Occupied'}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFF8BA88E)
                : AppTheme.stitchTextSecLight,
          ),
        ),
        if (occupants > 0) ...[
          const SizedBox(height: 2),
          Text(
            'Doe + ${occupants - 1} Kits',
            style: AppTheme.caption.copyWith(
              color: isDark
                  ? const Color(0xFFE0E6E0).withValues(alpha: 0.8)
                  : AppTheme.stitchTextMainLight.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (statut == 'vide') ...[
          const SizedBox(height: 2),
          Text(
            'Ready for assignment',
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: Color(0xFF13EC25),
            ),
          ),
        ],
        if (lastCleaned != null && !needsCleaning) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(width: 4),
              Text(
                lastCleaned,
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? const Color(0xFFE0E6E0).withValues(alpha: 0.8)
                      : AppTheme.stitchTextMainLight.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
