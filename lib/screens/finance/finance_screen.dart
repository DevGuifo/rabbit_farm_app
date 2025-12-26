import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/finance_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/recette.dart';
import '../../models/depense.dart';
import '../../services/pdf_service.dart';
import '../../widgets/bunny_widgets.dart';
import '../../theme/app_theme.dart';
import 'ajouter_recette_screen.dart';
import 'ajouter_depense_screen.dart';
import 'edit_recette_screen.dart';
import 'edit_depense_screen.dart';

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
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).chargerTout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Finances'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Exporter le rapport',
              onPressed: _exporterRapportPDF,
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: AppTheme.labelLarge,
            tabs: const [
              Tab(text: 'Tableau de bord'),
              Tab(text: 'Recettes'),
              Tab(text: 'Dépenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTableauDeBord(),
            _buildListeRecettes(),
            _buildListeDepenses(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButtons(),
      ),
    );
  }

  Widget _buildTableauDeBord() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final totalRecettes = financeProvider.totalRecettes;
        final totalDepenses = financeProvider.totalDepenses;
        final benefice = financeProvider.benefice;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cartes statistiques modernes
              FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Recettes',
                        value: _formatMontant.format(totalRecettes),
                        icon: Icons.trending_up_rounded,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: StatCard(
                        label: 'Dépenses',
                        value: _formatMontant.format(totalDepenses),
                        icon: Icons.trending_down_rounded,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: StatCard(
                  label: 'Bénéfice',
                  value: _formatMontant.format(benefice),
                  icon: Icons.account_balance_wallet_rounded,
                  color: benefice >= 0 ? AppTheme.info : AppTheme.warning,
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Graphique recettes
              if (financeProvider.recettes.isNotEmpty) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: SectionHeader(
                    title: 'Recettes par catégorie',
                    icon: Icons.pie_chart_rounded,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: BunnyCard(
                    child: SizedBox(
                      height: 200,
                      child: FutureBuilder<Map<String, double>>(
                        future: financeProvider.getTotalRecettesByCategorie(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Aucune donnée'));
                          }
                          return _buildPieChart(
                            snapshot.data!,
                            _getCategorieRecetteColor,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
              ],

              // Graphique des dépenses par catégorie
              if (financeProvider.depenses.isNotEmpty) ...[
                Text(
                  'Dépenses par catégorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<Map<String, double>>(
                    future: financeProvider.getTotalDepensesByCategorie(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Aucune donnée'));
                      }
                      return _buildPieChart(
                        snapshot.data!,
                        _getCategorieDepenseColor,
                      );
                    },
                  ),
                ),
              ],

              // Message si pas de données
              if (financeProvider.recettes.isEmpty &&
                  financeProvider.depenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aucune donnée financière.\nAjoutez une recette ou une dépense pour commencer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(
    Map<String, double> data,
    Color Function(String) getColor,
  ) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.entries.map((entry) {
          final percentage = (entry.value / total * 100);
          final color = getColor(entry.key);

          return PieChartSectionData(
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            color: color,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getCategorieRecetteColor(String categorie) {
    switch (categorie) {
      case 'vente_lapin':
        return Colors.green.shade600;
      case 'vente_portee':
        return Colors.green.shade400;
      case 'autre':
        return Colors.green.shade800;
      default:
        return Colors.green;
    }
  }

  Color _getCategorieDepenseColor(String categorie) {
    switch (categorie) {
      case 'alimentation':
        return Colors.red.shade600;
      case 'veterinaire':
        return Colors.red.shade400;
      case 'equipement':
        return Colors.orange.shade600;
      case 'autre':
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  Widget _buildListeRecettes() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        if (financeProvider.recettes.isEmpty) {
          return const Center(child: Text('Aucune recette enregistrée'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: financeProvider.recettes.length,
          itemBuilder: (context, index) {
            final recette = financeProvider.recettes[index];
            return _buildRecetteCard(recette, financeProvider);
          },
        );
      },
    );
  }

  Widget _buildRecetteCard(Recette recette, FinanceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategorieRecetteColor(recette.categorie),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        title: Text(recette.description),
        subtitle: Text(
          '${_formatDate.format(recette.date)} • ${_getNomCategorieRecette(recette.categorie)}',
        ),
        trailing: Text(
          _formatMontant.format(recette.montant),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        onTap: () => _modifierRecette(recette),
        onLongPress: () => _confirmerSuppression(
          context,
          'Supprimer cette recette ?',
          () => provider.supprimerRecette(recette.id!),
        ),
      ),
    );
  }

  Widget _buildListeDepenses() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        if (financeProvider.depenses.isEmpty) {
          return const Center(child: Text('Aucune dépense enregistrée'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: financeProvider.depenses.length,
          itemBuilder: (context, index) {
            final depense = financeProvider.depenses[index];
            return _buildDepenseCard(depense, financeProvider);
          },
        );
      },
    );
  }

  Widget _buildDepenseCard(Depense depense, FinanceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategorieDepenseColor(depense.categorie),
          child: const Icon(Icons.remove, color: Colors.white),
        ),
        title: Text(depense.description),
        subtitle: Text(
          '${_formatDate.format(depense.date)} • ${_getNomCategorieDepense(depense.categorie)}',
        ),
        trailing: Text(
          _formatMontant.format(depense.montant),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        onTap: () => _modifierDepense(depense),
        onLongPress: () => _confirmerSuppression(
          context,
          'Supprimer cette dépense ?',
          () => provider.supprimerDepense(depense.id!),
        ),
      ),
    );
  }

  String _getNomCategorieRecette(String categorie) {
    switch (categorie) {
      case 'vente_lapin':
        return 'Vente lapin';
      case 'vente_portee':
        return 'Vente portée';
      case 'autre':
        return 'Autre';
      default:
        return categorie;
    }
  }

  String _getNomCategorieDepense(String categorie) {
    switch (categorie) {
      case 'alimentation':
        return 'Alimentation';
      case 'veterinaire':
        return 'Vétérinaire';
      case 'equipement':
        return 'Équipement';
      case 'autre':
        return 'Autre';
      default:
        return categorie;
    }
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'add_recette',
          backgroundColor: AppTheme.success,
          onPressed: () => _ajouterRecette(),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add_depense',
          backgroundColor: AppTheme.error,
          onPressed: () => _ajouterDepense(),
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }

  void _ajouterRecette() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AjouterRecetteScreen()),
    );
  }

  void _ajouterDepense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AjouterDepenseScreen()),
    );
  }

  void _modifierRecette(Recette recette) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecetteScreen(recette: recette),
      ),
    );

    if (result == true && mounted) {
      // Recharger les données si modification réussie
      await Provider.of<FinanceProvider>(context, listen: false).chargerTout();
    }
  }

  void _modifierDepense(Depense depense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDepenseScreen(depense: depense),
      ),
    );

    if (result == true && mounted) {
      // Recharger les données si modification réussie
      await Provider.of<FinanceProvider>(context, listen: false).chargerTout();
    }
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmation',
      message: message,
      isDangerous: true,
    );

    if (confirm == true && context.mounted) {
      onConfirm();
    }
  }

  Future<void> _exporterRapportPDF() async {
    // Sélection de la période
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => _SelectionPeriodeDialog(),
    );

    if (result == null) return;

    final debut = result['debut']!;
    final fin = result['fin']!;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      final recettes = await financeProvider.getRecettesByPeriode(debut, fin);
      final depenses = await financeProvider.getDepensesByPeriode(debut, fin);

      await _pdfService.genererRapportFinancier(
        debut: debut,
        fin: fin,
        recettes: recettes,
        depenses: depenses,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rapport PDF généré avec succès'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF : $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

class _SelectionPeriodeDialog extends StatefulWidget {
  @override
  State<_SelectionPeriodeDialog> createState() =>
      _SelectionPeriodeDialogState();
}

class _SelectionPeriodeDialogState extends State<_SelectionPeriodeDialog> {
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');
  DateTime _debut = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fin = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner la période'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date de début'),
            subtitle: Text(_formatDate.format(_debut)),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _debut,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _debut = date);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date de fin'),
            subtitle: Text(_formatDate.format(_fin)),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _fin,
                firstDate: _debut,
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _fin = date);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {'debut': _debut, 'fin': _fin});
          },
          child: const Text('Générer'),
        ),
      ],
    );
  }
}
