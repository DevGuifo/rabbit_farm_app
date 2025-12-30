import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../models/lapin.dart';

class SevragePetitCard extends StatelessWidget {
  final Lapin petit;
  final String? cageSelectionnee;
  final double? poids;
  final String sexe;
  final ValueChanged<double?> onPoidsChanged;
  final ValueChanged<String> onSexeChanged;
  final VoidCallback onSelectCage;

  const SevragePetitCard({
    super.key,
    required this.petit,
    required this.cageSelectionnee,
    required this.poids,
    required this.sexe,
    required this.onPoidsChanged,
    required this.onSexeChanged,
    required this.onSelectCage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sexeIcon =
        (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle')
        ? Icons.male
        : Icons.female;
    final sexeColor =
        (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle')
        ? AppTheme.accentCyan
        : AppTheme.accentPink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: cageSelectionnee != null
              ? AppTheme.primaryGreen
              : (isDark ? AppTheme.stitchBorderDark : AppTheme.border),
          width: 2,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: sexeColor.withValues(alpha: 0.2),
                child: Icon(sexeIcon, color: sexeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petit.nom,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$sexe • ${petit.ageEnJours} jours',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (cageSelectionnee != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: Text(
                    'Cage $cageSelectionnee',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Sélection du sexe
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onSexeChanged('Mâle'),
                  icon: const Icon(Icons.male, size: 18),
                  label: const Text('Mâle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle')
                        ? AppTheme.accentCyan.withValues(alpha: 0.1)
                        : null,
                    foregroundColor: (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle')
                        ? AppTheme.accentCyan
                        : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
                    side: BorderSide(
                      color: (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle')
                          ? AppTheme.accentCyan
                          : (isDark ? AppTheme.stitchBorderDark : AppTheme.border),
                      width: (sexe.toLowerCase() == 'male' || sexe.toLowerCase() == 'm' || sexe.toLowerCase() == 'mâle') ? 2 : 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onSexeChanged('Femelle'),
                  icon: const Icon(Icons.female, size: 18),
                  label: const Text('Femelle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: (sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f')
                        ? AppTheme.accentPink.withValues(alpha: 0.1)
                        : null,
                    foregroundColor: (sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f')
                        ? AppTheme.accentPink
                        : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
                    side: BorderSide(
                      color: (sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f')
                          ? AppTheme.accentPink
                          : (isDark ? AppTheme.stitchBorderDark : AppTheme.border),
                      width: (sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f') ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: poids?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Poids (g)',
                    prefixIcon: Icon(
                      Icons.monitor_weight,
                      color: isDark ? AppTheme.textLight.withValues(alpha: 0.7) : AppTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.stitchSurfaceDark : AppTheme.bgLight,
                  ),
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                  onChanged: (value) {
                    onPoidsChanged(double.tryParse(value));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSelectCage,
                  icon: const Icon(Icons.home, size: 18),
                  label: Text(cageSelectionnee != null ? 'Changer' : 'Cage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cageSelectionnee != null
                        ? AppTheme.primaryGreen
                        : AppTheme.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
