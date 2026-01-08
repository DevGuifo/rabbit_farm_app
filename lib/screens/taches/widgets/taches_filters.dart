import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/tache_provider.dart';
import '../../../theme/app_theme.dart';

/// Widget de filtres pour les tâches
class TachesFilters extends StatelessWidget {
  final bool isDark;

  const TachesFilters({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<TacheProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppTheme.textSecondary.withValues(alpha: 0.1)
                    : AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une tâche...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: provider.recherche.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => provider.setRecherche(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.backgroundDarkMode
                      : AppTheme.backgroundLight,
                ),
                onChanged: (value) => provider.setRecherche(value),
              ),
              const SizedBox(height: 12),
              // Filtres rapides
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'Tous',
                      provider.filtreStatut == 'tous',
                      () => provider.setFiltreStatut('tous'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'À faire',
                      provider.filtreStatut == 'a_faire',
                      () => provider.setFiltreStatut('a_faire'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'En cours',
                      provider.filtreStatut == 'en_cours',
                      () => provider.setFiltreStatut('en_cours'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Terminées',
                      provider.filtreStatut == 'terminee',
                      () => provider.setFiltreStatut('terminee'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Aujourd\'hui',
                      provider.vue == 'aujourdhui',
                      () => provider.setVue('aujourdhui'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Cette semaine',
                      provider.vue == 'semaine',
                      () => provider.setVue('semaine'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryNeonGreen,
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.primaryNeonGreen
            : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

