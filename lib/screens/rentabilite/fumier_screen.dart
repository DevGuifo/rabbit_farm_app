import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fumier_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../models/collecte_fumier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../l10n/app_localizations.dart';

class FumierScreen extends StatefulWidget {
  const FumierScreen({super.key});

  @override
  State<FumierScreen> createState() => _FumierScreenState();
}

class _FumierScreenState extends State<FumierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FumierProvider>().chargerCollectes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenGestionFumier,
        icon: Icons.eco_rounded,
        iconColor: AppTheme.accentAmber,
      ),
      body: Consumer<FumierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.collectes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 80,
                    color: AppTheme.accentAmber.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune collecte enregistrée',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.neutral500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour en ajouter',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.neutral500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.collectes.length,
            itemBuilder: (context, index) {
              final collecte = provider.collectes[index];
              return _buildCollecteCard(collecte);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_fumier',
        onPressed: () => _showAjouterCollecteDialog(context),
        backgroundColor: AppTheme.accentAmber,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCollecteCard(CollecteFumier collecte) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(collecte.type),
          child: Icon(
            _getTypeIcon(collecte.type),
            color: AppTheme.textOnPrimary,
          ),
        ),
        title: Text(
          '${collecte.quantite} kg - ${_getTypeLabel(collecte.type)}',
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(collecte.dateCollecte)),
            if (collecte.destination != null)
              Text(
                'Destination: ${_getDestinationLabel(collecte.destination!)}',
              ),
            if (collecte.prixVente != null)
              Text(
                'Vendu: ${collecte.prixVente!.toStringAsFixed(2)} €',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppTheme.error),
          onPressed: () => _confirmDelete(collecte),
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'crottes':
        return 'Crottes';
      case 'urine':
        return 'Urine';
      case 'mixte':
        return 'Mixte';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'crottes':
        return AppTheme.accentOrange;
      case 'urine':
        return AppTheme.warning;
      case 'mixte':
        return AppTheme.accentTeal;
      default:
        return AppTheme.neutral500;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'crottes':
        return Icons.eco;
      case 'urine':
        return Icons.water_drop;
      case 'mixte':
        return Icons.layers;
      default:
        return Icons.help;
    }
  }

  String _getDestinationLabel(String destination) {
    switch (destination) {
      case 'vente':
        return 'Vendu';
      case 'compost':
        return 'Compost';
      case 'utilisation_personnelle':
        return 'Utilisation personnelle';
      default:
        return destination;
    }
  }

  Future<void> _confirmDelete(CollecteFumier collecte) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Supprimer la collecte',
      message: 'Voulez-vous vraiment supprimer cette collecte ?',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      try {
        await context.read<FumierProvider>().supprimerCollecte(collecte.id!);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Collecte supprimée');
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, 'Erreur: $e');
        }
      }
    }
  }

  Future<void> _showAjouterCollecteDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'crottes';
    String? selectedDestination;
    double? prixVente;
    double quantite = 0;
    String? notes;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleNouvelleCollecteFumier),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      selectedDate = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),

                // Quantité
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormQuantite,
                    prefixIcon: const Icon(Icons.scale),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).validationRequis;
                    }
                    if (double.tryParse(value) == null) {
                      return AppLocalizations.of(
                        context,
                      ).validationNombreInvalide;
                    }
                    return null;
                  },
                  onSaved: (value) => quantite = double.parse(value!),
                ),

                // Type
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).rentabiliteFormType,
                    prefixIcon: const Icon(Icons.eco),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'crottes',
                      child: Text(
                        AppLocalizations.of(context).fumierTypeCrottes,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'urine',
                      child: Text(AppLocalizations.of(context).fumierTypeUrine),
                    ),
                    DropdownMenuItem(
                      value: 'mixte',
                      child: Text(AppLocalizations.of(context).fumierTypeMixte),
                    ),
                  ],
                  onChanged: (value) => selectedType = value!,
                ),

                // Destination
                DropdownButtonFormField<String>(
                  initialValue: selectedDestination,
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).rentabiliteFormDestination} (optionnel)',
                    prefixIcon: const Icon(Icons.near_me),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'vente', child: Text('Vente')),
                    DropdownMenuItem(value: 'compost', child: Text('Compost')),
                    DropdownMenuItem(
                      value: 'utilisation_personnelle',
                      child: Text('Utilisation personnelle'),
                    ),
                  ],
                  onChanged: (value) => selectedDestination = value,
                ),

                // Prix de vente (si vente)
                if (selectedDestination == 'vente')
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).rentabiliteFormPrixVente,
                      prefixIcon: const Icon(Icons.euro),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        prixVente = value != null && value.isNotEmpty
                        ? double.parse(value)
                        : null,
                  ),

                // Notes
                TextFormField(
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).rentabiliteFormNotes} (optionnel)',
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
                  onSaved: (value) => notes = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final collecte = CollecteFumier(
                  dateCollecte: selectedDate,
                  quantite: quantite,
                  type: selectedType,
                  destination: selectedDestination,
                  prixVente: prixVente,
                  notes: notes,
                );

                try {
                  await context.read<FumierProvider>().ajouterCollecte(
                    collecte,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Collecte enregistrée'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(AppLocalizations.of(context).commonSave),
          ),
        ],
      ),
    );
  }
}
