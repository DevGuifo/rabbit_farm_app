import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/accouplement.dart';
import '../../../../models/portee.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

/// Onglet Reproduction - Préserve la logique existante avec style Stitch
class ReproductionTab extends StatelessWidget {
  final List<Accouplement> accouplements;
  final List<Portee> portees;

  const ReproductionTab({
    super.key,
    required this.accouplements,
    required this.portees,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (accouplements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: isDark ? StitchTheme.neutral600 : StitchTheme.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun accouplement enregistré',
              style: AppTheme.bodyLarge.copyWith(
                color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé
          _buildSummaryCard(context, isDark),
          const SizedBox(height: 24),
          Text(
            'Historique des accouplements',
            style: AppTheme.titleMedium.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.stitchTextMainLight,
            ),
          ),
          const SizedBox(height: 12),
          // Liste des accouplements
          ...accouplements.map((accouplement) {
            final portee = portees
                .where((p) => p.accouplementId == accouplement.id)
                .firstOrNull;
            return _buildAccouplementCard(
              context,
              isDark,
              accouplement,
              portee,
            );
          }),
          const SizedBox(height: 120), // Espace pour FAB
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isDark) {
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StitchTheme.radiusLarge),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStatCard(
              context,
              isDark,
              'Total',
              accouplements.length.toString(),
              AppTheme.accentPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStatCard(
              context,
              isDark,
              'Confirmés',
              accouplements
                  .where((a) => a.statut == 'confirme')
                  .length
                  .toString(),
              AppTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStatCard(
              context,
              isDark,
              'Portées',
              portees.length.toString(),
              AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.caption.copyWith(
            color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildAccouplementCard(
    BuildContext context,
    bool isDark,
    Accouplement accouplement,
    Portee? portee,
  ) {
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final formatDate = DateFormat('dd/MM/yyyy');

    Color statutColor;
    switch (accouplement.statut) {
      case 'confirme':
        statutColor = AppTheme.success;
        break;
      case 'echec':
        statutColor = AppTheme.error;
        break;
      case 'termine':
        statutColor = AppTheme.primaryGreen;
        break;
      default:
        statutColor = AppTheme.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StitchTheme.radiusDefault),
        border: Border.all(color: statutColor.withValues(alpha: 0.3), width: 2),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statutColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  accouplement.statut.toUpperCase(),
                  style: TextStyle(
                    color: statutColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.favorite, color: statutColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            isDark,
            Icons.calendar_today,
            'Accouplement',
            formatDate.format(accouplement.dateAccouplement),
          ),
          _buildInfoRow(
            isDark,
            Icons.event,
            'Mise-bas prévue',
            formatDate.format(accouplement.dateMiseBasPrevue),
          ),
          if (portee != null) ...[
            Divider(
              color: isDark
                  ? StitchTheme.outlineDark
                  : StitchTheme.outlineLight,
              height: 24,
            ),
            _buildInfoRow(
              isDark,
              Icons.pets,
              'Portée',
              '${portee.nombreVivants} vivants / ${portee.nombreNes} nés',
            ),
            _buildInfoRow(
              isDark,
              Icons.event_available,
              'Date réelle',
              formatDate.format(portee.dateMiseBasReelle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral500,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? StitchTheme.neutral400 : StitchTheme.neutral600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? StitchTheme.neutral200 : StitchTheme.neutral800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
