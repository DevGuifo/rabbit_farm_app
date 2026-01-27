import 'package:flutter/material.dart';
import '../../../models/batiment.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Section horizontale scrollable des bâtiments
/// Design Stitch avec cartes colorées et bouton "Add Barn"
class LocalisationBuildingCards extends StatelessWidget {
  final List<Batiment> batiments;
  final Map<int, int> cagesCountPerBatiment;
  final Map<int, int> emptyCagesPerBatiment;
  final Batiment? selectedBatiment;
  final Function(Batiment) onBatimentSelected;
  final Function(Batiment) onBatimentMenu;
  final VoidCallback onAddBatiment;
  final VoidCallback? onManage;

  const LocalisationBuildingCards({
    super.key,
    required this.batiments,
    required this.cagesCountPerBatiment,
    required this.emptyCagesPerBatiment,
    this.selectedBatiment,
    required this.onBatimentSelected,
    required this.onBatimentMenu,
    required this.onAddBatiment,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buildings',
                style: AppTheme.titleMedium.copyWith(
                  color: isDark
                      ? AppTheme.textOnPrimary
                      : AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onManage,
                child: Text(
                  'Manage',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.successVivid,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: batiments.length + 1,
            itemBuilder: (context, index) {
              if (index == batiments.length) {
                return _buildAddBarnCard(context, isDark);
              }

              final batiment = batiments[index];
              final cagesCount = cagesCountPerBatiment[batiment.id] ?? 0;
              final emptyCages = emptyCagesPerBatiment[batiment.id] ?? 0;
              final isSelected = batiment.id == selectedBatiment?.id;

              return _buildBatimentCard(
                context,
                batiment: batiment,
                cagesCount: cagesCount,
                emptyCages: emptyCages,
                isSelected: isSelected,
                isDark: isDark,
                color: _getBatimentColor(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBatimentCard(
    BuildContext context, {
    required Batiment batiment,
    required int cagesCount,
    required int emptyCages,
    required bool isSelected,
    required bool isDark,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onBatimentSelected(batiment),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.textOnPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.greyDarkest : AppTheme.greyE5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.divider,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warehouse_rounded,
                      color: color,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onBatimentMenu(batiment),
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: isDark
                          ? AppTheme.accentGreen
                          : AppTheme.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                batiment.nom,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.textOnPrimary
                      : AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$cagesCount Cages',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                emptyCages == 0 ? 'Full' : '$emptyCages Empty',
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddBarnCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onAddBatiment,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.greyDarkAlt : AppTheme.greyMedium,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.greyDark
                    : AppTheme.greyE5,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: isDark
                    ? AppTheme.greyMuted
                    : AppTheme.grey999,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Barn',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.accentGreen
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatimentColor(int index) {
    final colors = [
      AppTheme.success500, // Green
      AppTheme.accentOrangeVivid, // Orange
      AppTheme.info, // Blue
      AppTheme.accentPurple500, // Purple
      AppTheme.accentPink500, // Pink
    ];
    return colors[index % colors.length];
  }
}
