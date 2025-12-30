import 'dart:io';
import 'package:flutter/material.dart';
import '../models/lapin.dart';
import 'animations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget de carte pour afficher un lapin
class LapinCard extends StatelessWidget {
  final Lapin lapin;
  final VoidCallback? onTap;

  const LapinCard({super.key, required this.lapin, this.onTap});

  /// Obtenir l'icône selon le sexe
  IconData _getIconeSexe() {
    return lapin.sexe.toLowerCase() == 'mâle' ? Icons.male : Icons.female;
  }

  /// Obtenir la couleur selon le sexe
  Color _getCouleurSexe(BuildContext context) {
    return lapin.sexe.toLowerCase() == 'mâle'
        ? AppTheme.info
        : AppTheme.accentPink;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTapButton(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar du lapin avec photo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: ClipOval(
                    child: lapin.photoPath != null
                        ? Image.file(
                            File(lapin.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.pets,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Informations du lapin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom et icône sexe
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lapin.nom,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            _getIconeSexe(),
                            color: _getCouleurSexe(context),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Race
                      Text(
                        lapin.race,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Âge et poids
                      Row(
                        children: [
                          Icon(
                            Icons.cake,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lapin.ageFormate,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                          if (lapin.poids != null) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.monitor_weight,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lapin.poids!.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                      // Statut et localisation
                      if (lapin.statut != null || lapin.localisation != null)
                        const SizedBox(height: 4),
                      if (lapin.statut != null || lapin.localisation != null)
                        Row(
                          children: [
                            if (lapin.statut != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lapin.statut!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ),
                            ],
                            if (lapin.localisation != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                lapin.localisation!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                // Flèche
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
