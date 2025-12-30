import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/recette.dart';
import '../../models/depense.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/dialog_helper.dart';
import '../../services/pdf_service.dart';
import 'ajouter_recette_screen.dart';
import 'ajouter_depense_screen.dart';
import 'edit_recette_screen.dart';
import 'edit_depense_screen.dart';

/// Écran Finance - Design System Unifié
/// Pas de TabBar (incohérent avec autres écrans)
/// Utilise pattern Cheptel: header + contenu scrollable
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');
  final NumberFormat _formatMontant = NumberFormat.currency(
    symbol: '€',
    decimalDigits: 2,
    locale: 'fr_FR',
  );
  final String _selectedView = 'dashboard'; // dashboard, recettes, depenses

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().chargerTout();
    });
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
          Expanded(
            child: Consumer<FinanceProvider>(
        builder: (context, financeProvider, _) {
          if (_selectedView == 'dashboard') {
            return _buildDashboard(financeProvider, isDark);
          } else if (_selectedView == 'recettes') {
            return _buildRecettesList(financeProvider, isDark);
          } else {
            return _buildDepensesList(financeProvider, isDark);
          }
        },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header - Utilise StandardHeader
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: 'Finances',
      isDark: isDark,
      onSync: () {
        context.read<FinanceProvider>().chargerTout();
      },
      onNotifications: null,
      onSettings: _exporterRapport,
    );
  }

  Widget _buildDashboard(FinanceProvider provider, bool isDark) {
    final totalRecettes = provider.totalRecettes;
    final totalDepenses = provider.totalDepenses;
    final benefice = totalRecettes - totalDepenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  isDark: isDark,
                  label: 'Recettes',
                  value: _formatMontant.format(totalRecettes),
                  icon: Icons.trending_up,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  isDark: isDark,
                  label: 'Dépenses',
                  value: _formatMontant.format(totalDepenses),
                  icon: Icons.trending_down,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatsCard(
            isDark: isDark,
            label: 'Bénéfice',
            value: _formatMontant.format(benefice),
            icon: Icons.account_balance_wallet,
            color: benefice >= 0 ? AppTheme.primaryGreen : AppTheme.error,
          ),
          const SizedBox(height: 32),

          // Graphique Recettes si données
          if (provider.recettes.isNotEmpty) ...[
            SectionHeader(
              title: 'Recettes par catégorie',
              isDark: isDark,
              icon: Icons.pie_chart,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: SizedBox(
                height: 200,
                child: FutureBuilder<Map<String, double>>(
                  future: provider.getTotalRecettesByCategorie(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucune donnée'));
                    }
                    return _buildPieChart(snapshot.data!, isDark);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Actions rapides
          SectionHeader(
            title: 'Actions rapides',
            isDark: isDark,
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  isDark,
                  Icons.add,
                  'Ajouter Recette',
                  AppTheme.success,
                  () => _ajouterRecette(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  isDark,
                  Icons.remove,
                  'Ajouter Dépense',
                  AppTheme.error,
                  () => _ajouterDepense(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecettesList(FinanceProvider provider, bool isDark) {
    if (provider.recettes.isEmpty) {
      return const EmptyState(
        isDark: false,
        icon: Icons.inbox_outlined,
        title: 'Aucune recette',
        subtitle: 'Ajoutez une recette pour commencer',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: provider.recettes.length,
      itemBuilder: (context, index) {
        final recette = provider.recettes[index];
        return _buildTransactionCard(
          isDark,
          recette.montant.toString(),
          recette.categorie,
          recette.date,
          Colors.green,
          () => _editRecette(recette),
          () => _deleteRecette(recette.id!),
        );
      },
    );
  }

  Widget _buildDepensesList(FinanceProvider provider, bool isDark) {
    if (provider.depenses.isEmpty) {
      return const EmptyState(
        isDark: false,
        icon: Icons.inbox_outlined,
        title: 'Aucune dépense',
        subtitle: 'Ajoutez une dépense pour suivre vos coûts',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: provider.depenses.length,
      itemBuilder: (context, index) {
        final depense = provider.depenses[index];
        return _buildTransactionCard(
          isDark,
          depense.montant.toString(),
          depense.categorie,
          depense.date,
          AppTheme.error,
          () => _editDepense(depense),
          () => _deleteDepense(depense.id!),
        );
      },
    );
  }

  Widget _buildActionButton(
    bool isDark,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    bool isDark,
    String montant,
    String categorie,
    DateTime date,
    Color color,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onEdit,
        onLongPress: onDelete,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  color == AppTheme.success ? Icons.add : Icons.remove,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categorie,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate.format(date),
                      style: AppTheme.caption.copyWith(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${color == Colors.green ? '+' : '-'}${_formatMontant.format(double.tryParse(montant) ?? 0)}',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, bool isDark) {
    // Mock simple pie chart
    return Center(
      child: Text(
        '${data.length} catégories',
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: AppTheme.error,
          onPressed: _ajouterDepense,
          tooltip: 'Ajouter dépense',
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          backgroundColor: AppTheme.success,
          onPressed: _ajouterRecette,
          tooltip: 'Ajouter recette',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _ajouterRecette() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjouterRecetteScreen()),
    ).then((_) {
      if (!mounted) return;
      context.read<FinanceProvider>().chargerTout();
    });
  }

  void _ajouterDepense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjouterDepenseScreen()),
    ).then((_) {
      if (!mounted) return;
      context.read<FinanceProvider>().chargerTout();
    });
  }

  void _editRecette(Recette recette) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditRecetteScreen(recette: recette)),
    ).then((_) {
      if (!mounted) return;
      context.read<FinanceProvider>().chargerTout();
    });
  }

  void _editDepense(Depense depense) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDepenseScreen(depense: depense)),
    ).then((_) {
      if (!mounted) return;
      context.read<FinanceProvider>().chargerTout();
    });
  }

  void _deleteRecette(int id) {
    DialogHelper.showConfirmDialog(
      context,
      'Supprimer recette',
      'Confirmer la suppression?',
      () async {
        try {
          await context.read<FinanceProvider>().supprimerRecette(id);
          if (!mounted) return;
          SnackbarHelper.showSuccess(context, 'Recette supprimée');
        } catch (e) {
          if (!mounted) return;
          SnackbarHelper.showError(context, 'Erreur: $e');
        }
      },
    );
  }

  void _deleteDepense(int id) {
    DialogHelper.showConfirmDialog(
      context,
      'Supprimer dépense',
      'Confirmer la suppression?',
      () async {
        try {
          await context.read<FinanceProvider>().supprimerDepense(id);
          if (!mounted) return;
          SnackbarHelper.showSuccess(context, 'Dépense supprimée');
        } catch (e) {
          if (!mounted) return;
          SnackbarHelper.showError(context, 'Erreur: $e');
        }
      },
    );
  }

  Future<void> _exporterRapport() async {
    try {
      final financeProvider = context.read<FinanceProvider>();
      final recettes = financeProvider.recettes;
      final depenses = financeProvider.depenses;

      if (recettes.isEmpty && depenses.isEmpty) {
        SnackbarHelper.showInfo(context, 'Aucune donnée financière à exporter');
        return;
      }

      // Déterminer la période (du premier au dernier enregistrement)
      DateTime? debut;
      DateTime? fin;

      if (recettes.isNotEmpty) {
        final datesRecettes = recettes.map((r) => r.date).toList()..sort();
        if (datesRecettes.first.isBefore(debut ?? datesRecettes.first)) {
          debut = datesRecettes.first;
        }
        if (datesRecettes.last.isAfter(fin ?? datesRecettes.last)) {
          fin = datesRecettes.last;
        }
      }

      if (depenses.isNotEmpty) {
        final datesDepenses = depenses.map((d) => d.date).toList()..sort();
        if (datesDepenses.first.isBefore(debut ?? datesDepenses.first)) {
          debut = datesDepenses.first;
        }
        if (datesDepenses.last.isAfter(fin ?? datesDepenses.last)) {
          fin = datesDepenses.last;
        }
      }

      // Utiliser la période complète si disponible, sinon la période actuelle
      final dateDebut = debut ?? DateTime.now().subtract(const Duration(days: 30));
      final dateFin = fin ?? DateTime.now();

      SnackbarHelper.show(context, 'Génération du rapport PDF...');

      final pdfService = PdfService();
      await pdfService.genererRapportFinancier(
        debut: dateDebut,
        fin: dateFin,
        recettes: recettes,
        depenses: depenses,
      );

      if (mounted) {
        SnackbarHelper.showSuccess(context, '✅ Rapport financier généré avec succès');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur lors de la génération: $e');
      }
    }
  }
}
