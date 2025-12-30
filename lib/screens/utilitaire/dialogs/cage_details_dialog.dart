import 'package:flutter/material.dart';
import '../../../models/cage.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Dialog pour afficher les détails d'une cage
class CageDetailsDialog {
  static void show(
    BuildContext context,
    Map<String, dynamic> cageData,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    final cage = cageData['cage'] as Cage;
    final occupants = cageData['occupants'] as int;
    final statut = cageData['statut'] as String;
    final couleur = Color(cageData['couleur'] as int);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.backgroundDark
          : AppTheme.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cottage_rounded,
                      color: couleur,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cage ${cage.numero}',
                          style: AppTheme.titleLarge,
                        ),
                        Text(
                          statut.toUpperCase(),
                          style: AppTheme.bodyMedium.copyWith(color: couleur),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Type', cage.type),
              _buildInfoRow('Capacité', '${cage.capacite} lapin(s)'),
              _buildInfoRow('Occupants', '$occupants lapin(s)'),
              _buildInfoRow(
                'Places disponibles',
                '${cage.capacite - occupants}',
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
