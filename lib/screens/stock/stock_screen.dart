import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/sync_provider.dart';
import '../sante/pharmacie_screen.dart';
import '../alimentation/inventaire_aliments_screen.dart';

/// Écran unifié de gestion des stocks
/// Affiche les médicaments et aliments avec navigation par onglets
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildTabBar(isDark),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [PharmacieScreen(), InventaireAlimentsScreen()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).stockTitre,
      isDark: isDark,
      onSync: () async {
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
      },
      onNotifications: null,
      onSettings: null,
    );
  }

  Widget _buildTabBar(bool isDark) {
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textTertiary;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.neutral700 : AppTheme.neutral200)
                .withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.info,
        indicatorWeight: 3,
        labelColor: AppTheme.info,
        unselectedLabelColor: textSecondary,
        labelStyle: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.titleSmall.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.medication, size: 20), text: 'Médicaments'),
          Tab(icon: Icon(Icons.restaurant, size: 20), text: 'Aliments'),
        ],
      ),
    );
  }
}
