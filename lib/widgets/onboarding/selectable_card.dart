import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Carte sélectionnable pour les choix d'onboarding
/// 
/// Utilisée pour les sélections visuelles comme :
/// - Type d'élevage (familial, semi-pro, pro)
/// - Objectifs (rentabilité, croissance, qualité, suivi)
/// - Niveau d'expérience
class SelectableCard extends StatelessWidget {
  /// Titre principal de la carte
  final String title;
  
  /// Sous-titre ou description courte
  final String? subtitle;
  
  /// Emoji ou icône à afficher
  final String? emoji;
  
  /// Icône Material optionnelle (utilisée si emoji est null)
  final IconData? icon;
  
  /// La carte est-elle sélectionnée ?
  final bool isSelected;
  
  /// Callback lors du tap
  final VoidCallback? onTap;
  
  /// Hauteur minimale de la carte
  final double? minHeight;

  const SelectableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.icon,
    required this.isSelected,
    this.onTap,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          minHeight: minHeight ?? 100,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppTheme.success900.withValues(alpha: 0.3) : AppTheme.success50)
              : (isDark ? AppTheme.cardDark : AppTheme.surfaceWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : (isDark ? AppTheme.neutral700 : AppTheme.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppTheme.textPrimary).withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji ou icône
                  if (emoji != null)
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 32),
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected ? AppTheme.primary : (isDark ? AppTheme.neutral400 : AppTheme.textSecondary),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Titre
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primary : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Sous-titre
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Check animé en haut à droite
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppTheme.textOnPrimary,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
