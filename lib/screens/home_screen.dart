import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'cheptel/cheptel_screen.dart';
import 'reproduction/reproduction_screen.dart';
import 'sante/sante_screen.dart';
import 'utilitaire/utilitaire_screen.dart';
import '../theme/app_theme.dart';

/// Écran principal avec navigation par onglets
/// Navigation réorganisée : Dashboard en premier, Paramètres retiré (accessible via icône ⚙️)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Liste des écrans correspondant aux onglets
    final List<Widget> screens = [
      ModernDashboardScreen(onNavigate: _navigateToTab),
      const CheptelScreen(),
      const ReproductionScreen(),
      const SanteScreen(),
      const UtilitaireScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(context),
    );
  }

  Widget _buildModernNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2329) : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(color: AppTheme.border.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Tableau',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.pets_rounded,
                label: 'Cheptel',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_rounded,
                label: 'Repro',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.medical_services_rounded,
                label: 'Santé',
                index: 3,
              ),
              _buildNavItem(icon: Icons.apps_rounded, label: 'Plus', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 10 : 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 26 : 24,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTheme.labelSmall.copyWith(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
