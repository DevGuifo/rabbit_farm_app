import 'package:flutter/material.dart';
import '../../../models/lot.dart';
import '../../../theme/app_theme.dart';

/// Carte d'affichage d'un lot dans la liste
///
/// Affiche les informations essentielles du lot :
/// - Identifiant
/// - Type et statut
/// - Effectif avec indicateur visuel
/// - Âge et mortalité
class LotCard extends StatelessWidget {
  final Lot lot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LotCard({
    super.key,
    required this.lot,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // isDark disponible pour thème adaptatif futur
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: lot.statut != StatutLot.actif
            ? BorderSide(color: Colors.grey[300]!, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête: Identifiant + Type + Statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Icône type
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getTypeColor(lot.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTypeIcon(lot.type),
                            color: _getTypeColor(lot.type),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Identifiant et type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lot.identifiant,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                lot.type.label,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge statut
                  _buildStatutBadge(lot.statut),
                ],
              ),
              const SizedBox(height: 16),
              
              // Corps: Effectif avec barre de progression
              Row(
                children: [
                  // Effectif
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${lot.effectifActuel}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text(
                                '/ ${lot.effectifInitial}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'sujets',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicateurs
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Âge
                        _buildIndicateur(
                          Icons.calendar_today,
                          '${lot.ageEnJours} jours',
                        ),
                        const SizedBox(height: 8),
                        // Mortalité
                        _buildIndicateur(
                          Icons.trending_down,
                          '${lot.tauxMortalite.toStringAsFixed(1)}%',
                          color: lot.tauxMortalite > 10 
                              ? Colors.red 
                              : lot.tauxMortalite > 5 
                                  ? Colors.orange 
                                  : Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Barre de progression effectif
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: lot.effectifInitial > 0 
                      ? lot.effectifActuel / lot.effectifInitial 
                      : 1.0,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(lot),
                  minHeight: 6,
                ),
              ),
              
              // Race si disponible
              if (lot.metadata.race != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.pets, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      lot.metadata.race!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Indicateur d'alerte si mortalité élevée
              if (lot.tauxMortalite > 10 && lot.statut == StatutLot.actif) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Mortalité élevée',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatutBadge(StatutLot statut) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatutColor(statut),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIndicateur(IconData icon, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.grey[700],
            fontSize: 13,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(TypeLot type) {
    switch (type) {
      case TypeLot.engraissement:
        return Colors.orange;
      case TypeLot.reproduction:
        return Colors.pink;
      case TypeLot.mixte:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getTypeIcon(TypeLot type) {
    switch (type) {
      case TypeLot.engraissement:
        return Icons.restaurant;
      case TypeLot.reproduction:
        return Icons.favorite;
      case TypeLot.mixte:
        return Icons.blur_on;
    }
  }

  Color _getStatutColor(StatutLot statut) {
    switch (statut) {
      case StatutLot.actif:
        return Colors.green;
      case StatutLot.enAttente:
        return Colors.orange;
      case StatutLot.termine:
        return Colors.grey;
      case StatutLot.vendu:
        return Colors.blue;
      case StatutLot.reforme:
        return Colors.red[400]!;
    }
  }

  Color _getProgressColor(Lot lot) {
    final pourcentage = lot.effectifInitial > 0 
        ? lot.effectifActuel / lot.effectifInitial 
        : 1.0;
    
    if (pourcentage > 0.9) return Colors.green;
    if (pourcentage > 0.7) return Colors.orange;
    return Colors.red;
  }
}
