import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour la section hero avec l'image du lapin et le branding "BUNNYTRACK"
class AuthHeroSection extends StatelessWidget {
  const AuthHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            // Image de fond avec gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image du lapin (utilise une image réseau depuis Stitch)
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBS8qgXOTU83dfJAQAG5ok1YQ8R1E9uwnLfqKxyerAnegTO63jV1J98zYLZqjpA4JkyCIrDywnkm8fTi14mD_1Ip9S2X-cg4zaH29AXXTQC8ocHwAVn_G_bozxKGVMY6pe7Nbz2k6hrjNyzyrSIngllp7-LcAsJzG4x2tNcxx10wdeNpQnxayLZqRJqfGXnQ4riCPzowupJFwTgxCQclFfmYpjdX-YDOyDcwpA81HgKdpjVfy3RUYH8nE31wAUl7OAZUvKoaU4DWO4',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback : placeholder avec icône
                      return Container(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay (du bas vers le haut)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.textPrimary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Branding "BUNNYTRACK" (bottom-left)
            Positioned(
              left: 16,
              bottom: 12,
              child: Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    color: AppTheme.primaryNeonGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BUNNYTRACK',
                    style: TextStyle(
                      color: AppTheme.textOnPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

