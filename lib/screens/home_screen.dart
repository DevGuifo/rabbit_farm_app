import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'dashboard/dashboard_screen.dart';
import 'cheptel/cheptel_screen.dart';
import 'reproduction/reproduction_screen.dart';
import 'sante/sante_screen.dart';
import 'plus/plus_screen.dart';
import '../theme/app_theme.dart';

/// Écran principal avec navigation par onglets
/// Navigation Phase 2 : Dashboard, Cheptel, Reproduction, Santé, Plus
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
      const PlusScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
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
        child: HeroControllerScope(
          controller: HeroController(),
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: screens[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(context),
    );
  }

  Widget _buildModernNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.textSecondary.withValues(alpha: 0.4)
                : AppTheme.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.navDashboard,
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.pets_rounded,
                label: l10n.navCheptel,
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.family_restroom,
                label: l10n.navReproduction,
                index: 2,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.monitor_heart_rounded,
                label: l10n.navSante,
                index: 3,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.apps_rounded,
                label: l10n.navPlus,
                index: 4,
                isDark: isDark,
              ),
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
    required bool isDark,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentGreen.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? (isDark ? AppTheme.textLight : AppTheme.textPrimary)
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppTheme.textLight : AppTheme.textPrimary)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
