import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/common/common_widgets.dart' show SimpleAppBar;

/// Écran de consultation du journal automatique
///
/// Affiche l'historique des actions par jour/semaine/mois
/// L'utilisateur peut ajouter des notes (optionnelles, jamais obligatoires)
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalProvider>(
        context,
        listen: false,
      ).chargerJournal(PeriodeJournal.aujourdhui);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).titleJournal,
        actions: [
          // Badge non lus
          Consumer<JournalProvider>(
            builder: (context, provider, _) {
              if (provider.countNonLus > 0) {
                return TextButton.icon(
                  onPressed: () => provider.chargerNonLus(),
                  icon: Badge(
                    label: Text('${provider.countNonLus}'),
                    child: const Icon(Icons.mail_outline),
                  ),
                  label: Text(AppLocalizations.of(context).journalNonLus),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Marquer tout comme lu
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: AppLocalizations.of(context).journalMarquerToutLu,
            onPressed: () {
              Provider.of<JournalProvider>(
                context,
                listen: false,
              ).marquerToutLu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de période
          _buildPeriodeSelector(),

          // Filtres rapides
          _buildFiltresRapides(),

          // Liste des entrées
          Expanded(child: _buildJournalList()),
        ],
      ),
    );
  }

  Widget _buildPeriodeSelector() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              for (final periode in PeriodeJournal.values.where(
                (p) => p != PeriodeJournal.personnalisee,
              ))
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        periode.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: provider.periodeActuelle == periode,
                      onSelected: (_) => provider.chargerJournal(periode),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltresRapides() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Réinitialiser les filtres
              if (provider.filtreEntite != null ||
                  provider.filtreStatut != null)
                ActionChip(
                  label: Text(AppLocalizations.of(context).filtres),
                  onPressed: () => provider.reinitialiserFiltres(),
                ),
              const SizedBox(width: 8),

              // Filtres par statut
              FilterChip(
                label: Text(AppLocalizations.of(context).anomalies),
                selected: provider.filtreStatut == StatutEvenement.anomalie,
                onSelected: (_) => provider.filtrerParStatut(
                  provider.filtreStatut == StatutEvenement.anomalie
                      ? null
                      : StatutEvenement.anomalie,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context).labelActions),
                selected: provider.filtreStatut == StatutEvenement.action,
                onSelected: (_) => provider.filtrerParStatut(
                  provider.filtreStatut == StatutEvenement.action
                      ? null
                      : StatutEvenement.action,
                ),
              ),
              const SizedBox(width: 8),

              // Filtres par entité les plus courants
              FilterChip(
                label: Text(AppLocalizations.of(context).lapinsFiltre),
                selected: provider.filtreEntite == TypeEntite.lapin,
                onSelected: (_) => provider.filtrerParEntite(
                  provider.filtreEntite == TypeEntite.lapin
                      ? null
                      : TypeEntite.lapin,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context).reproductionFiltre),
                selected: provider.filtreEntite == TypeEntite.accouplement,
                onSelected: (_) => provider.filtrerParEntite(
                  provider.filtreEntite == TypeEntite.accouplement
                      ? null
                      : TypeEntite.accouplement,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context).santeFiltre),
                selected: provider.filtreEntite == TypeEntite.soin,
                onSelected: (_) => provider.filtrerParEntite(
                  provider.filtreEntite == TypeEntite.soin
                      ? null
                      : TypeEntite.soin,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context).financesFiltre),
                selected:
                    provider.filtreEntite == TypeEntite.recette ||
                    provider.filtreEntite == TypeEntite.depense,
                onSelected: (_) => provider.filtrerParEntite(
                  provider.filtreEntite == TypeEntite.recette
                      ? null
                      : TypeEntite.recette,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJournalList() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.erreur != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.erreur!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.effacerErreur();
                    provider.chargerJournal();
                  },
                  child: Text(AppLocalizations.of(context).journalReessayer),
                ),
              ],
            ),
          );
        }

        final entriesParDate = provider.entriesParDate;

        if (entriesParDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).journalAucunEvenement,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).journalActionsEnregistrees,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.chargerJournal(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: entriesParDate.length,
            itemBuilder: (context, index) {
              final dateKey = entriesParDate.keys.elementAt(index);
              final entries = entriesParDate[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de date
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDateLabel(dateKey),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entries.length} événement${entries.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Entrées de cette date
                  ...entries.map((entry) => _buildEntryCard(entry)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _showEntryDetails(entry),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: !entry.lu
                ? Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icône de l'entité
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatutColor(entry.statut).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    entry.typeEntite.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.resumeAuto,
                            style: TextStyle(
                              fontWeight: entry.lu
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          entry.heureFormatee,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Badge statut
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatutColor(
                              entry.statut,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.statut.emoji} ${entry.typeAction.label}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStatutColor(entry.statut),
                            ),
                          ),
                        ),

                        // Indicateur de note
                        if (entry.noteUtilisateur != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.sticky_note_2,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Flèche
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatutColor(StatutEvenement statut) {
    switch (statut) {
      case StatutEvenement.normal:
        return Colors.green;
      case StatutEvenement.anomalie:
        return Colors.red;
      case StatutEvenement.action:
        return Colors.orange;
      case StatutEvenement.info:
        return Colors.blue;
      case StatutEvenement.succes:
        return Colors.teal;
    }
  }

  String _formatDateLabel(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) return dateStr;

    final aujourdhui = DateTime.now();
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final diff = aujourdhui.difference(date).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return AppLocalizations.of(context).journalHier;
    if (diff < 7) return AppLocalizations.of(context).journalIlYaJours(diff);

    return dateStr;
  }

  void _showEntryDetails(JournalEntry entry) {
    final provider = Provider.of<JournalProvider>(context, listen: false);

    // Marquer comme lu
    if (!entry.lu && entry.id != null) {
      provider.marquerLu(entry.id!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntryDetailsSheet(entry: entry),
    );
  }
}

/// Bottom sheet avec les détails d'une entrée
class _EntryDetailsSheet extends StatefulWidget {
  final JournalEntry entry;

  const _EntryDetailsSheet({required this.entry});

  @override
  State<_EntryDetailsSheet> createState() => _EntryDetailsSheetState();
}

class _EntryDetailsSheetState extends State<_EntryDetailsSheet> {
  late TextEditingController _noteController;
  bool _showNoteField = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.entry.noteUtilisateur ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // En-tête avec emoji et résumé
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      entry.typeEntite.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.resumeAuto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.dateFormatee} à ${entry.heureFormatee}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informations
            _buildInfoRow(
              AppLocalizations.of(context).journalType,
              entry.typeEntite.label,
            ),
            _buildInfoRow(
              AppLocalizations.of(context).journalAction,
              entry.typeAction.label,
            ),
            _buildInfoRow(
              AppLocalizations.of(context).journalStatut,
              '${entry.statut.emoji} ${entry.statut.label}',
            ),

            // Contexte si présent
            if (entry.contexte.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).journalContexte,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.contexte.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Text(
                              '${e.value}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Note utilisateur (optionnelle)
            const SizedBox(height: 24),
            if (entry.noteUtilisateur != null && !_showNoteField) ...[
              const Text(
                '📝 Votre note',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(entry.noteUtilisateur!),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _showNoteField = true),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(AppLocalizations.of(context).journalModifierNote),
              ),
            ] else if (_showNoteField || entry.noteUtilisateur == null) ...[
              // Champ pour ajouter/modifier une note
              Row(
                children: [
                  const Text(
                    '📝 Note (optionnelle)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  if (_showNoteField)
                    TextButton(
                      onPressed: () => setState(() => _showNoteField = false),
                      child: Text(
                        AppLocalizations.of(context).quarantaineAnnuler,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).journalAjouterNote,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    if (entry.id != null && _noteController.text.isNotEmpty) {
                      await Provider.of<JournalProvider>(
                        context,
                        listen: false,
                      ).ajouterNote(entry.id!, _noteController.text);
                      if (mounted) {
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('📝 Note enregistrée'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else if (_noteController.text.isEmpty) {
                      navigator.pop();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(
                    AppLocalizations.of(context).journalEnregistrerNote,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
