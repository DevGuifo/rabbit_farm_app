import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget de sélection du type de matériau pour le nid
/// Utilise materiauId FK (1=Paille, 2=Foin, 3=Copeaux, 4=Mixte)
class MateriauSelector extends StatefulWidget {
  final int? materiauIdInitial; // 1-4 ou null
  final Function(int?, String?) onMateriauSelected; // (materiauId, materiauNom)

  const MateriauSelector({
    super.key,
    this.materiauIdInitial,
    required this.onMateriauSelected,
  });

  @override
  State<MateriauSelector> createState() => _MateriauSelectorState();
}

class _MateriauSelectorState extends State<MateriauSelector> {
  int? _selectedId;

  // Mapping materiaux table: id → (code, nom)
  static const Map<int, Map<String, String>> _materiaux = {
    1: {'code': 'paille', 'nom': 'Paille'},
    2: {'code': 'foin', 'nom': 'Foin'},
    3: {'code': 'copeaux', 'nom': 'Copeaux de bois'},
    4: {'code': 'mixte', 'nom': 'Mixte'},
  };

  @override
  void initState() {
    super.initState();
    _selectedId = widget.materiauIdInitial;
  }

  void _onSelectionChanged(int? id) {
    setState(() {
      _selectedId = id;
    });
    final code = id != null ? _materiaux[id]!['code'] : null;
    widget.onMateriauSelected(id, code);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final borderColor = isDark
        ? AppTheme.surfaceDarkElevated
        : AppTheme.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Type de matériau',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Radio buttons (2x2 grid)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      1,
                      _materiaux[1]!['nom']!,
                      Icons.grass,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRadioOption(
                      2,
                      _materiaux[2]!['nom']!,
                      Icons.eco,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      3,
                      _materiaux[3]!['nom']!,
                      Icons.carpenter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRadioOption(
                      4,
                      _materiaux[4]!['nom']!,
                      Icons.auto_awesome_mosaic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(int id, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedId == id;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.success100
        : AppTheme.textSecondary;

    return InkWell(
      onTap: () => _onSelectionChanged(id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNeonGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryNeonGreen
                : (isDark ? AppTheme.surfaceDarkElevated : AppTheme.surfaceLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryNeonGreen : textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryNeonGreen : textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppTheme.primaryNeonGreen,
              ),
          ],
        ),
      ),
    );
  }
}
