import 'package:flutter/material.dart';
import '../common/skeleton.dart';

/// Squelette de chargement complet pour le Dashboard
///
/// Reproduit la structure exacte du dashboard pour une transition fluide.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Salutations)
            const SizedBox(height: 20),
            const Skeleton.rect(width: 200, height: 32), // "Bonjour..."
            const SizedBox(height: 8),
            const Skeleton.rect(
              width: 300,
              height: 16,
            ), // "Voici ce qui se passe..."
            const SizedBox(height: 24),

            // 2. Rituels Card (Grande carte priority)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Skeleton.circle(size: 24),
                      SizedBox(width: 12),
                      Skeleton.rect(width: 120, height: 20),
                    ],
                  ),
                  const Spacer(),
                  const Skeleton.rect(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const Skeleton.rect(width: 200, height: 16),
                  const SizedBox(height: 16),
                  const Skeleton.rect(
                    width: double.infinity,
                    height: 40,
                  ), // Bouton
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Discipline Section (Grid 2x2 compacte)
            Row(
              children: [
                Expanded(child: _buildCompactCard(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildCompactCard(context)),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Stats Cards (Row scrollable)
            Row(
              children: [
                Expanded(child: _buildStatCard(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context)),
              ],
            ),
            const SizedBox(height: 24),

            // 5. KPIs / Graphiques
            const Skeleton.rect(width: 150, height: 24), // Titre section
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Skeleton.rect(width: 80, height: 14),
          Spacer(),
          Skeleton.rect(width: 40, height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Skeleton.circle(size: 24),
          Spacer(),
          Skeleton.rect(width: 60, height: 20),
          SizedBox(height: 4),
          Skeleton.rect(width: 40, height: 12),
        ],
      ),
    );
  }
}
