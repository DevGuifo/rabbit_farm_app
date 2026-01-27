import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/tache_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_variations.dart';
import '../../services/database_helper.dart';
import '../../screens/sante/sante_screen.dart';

/// Section Discipline Opérationnelle du Dashboard
///
/// Affiche un miroir de rigueur avec :
/// - Jours consécutifs d'observation
/// - % rituels respectés cette semaine
/// - Anomalies ouvertes
/// - Dernière observation
class DisciplineSection extends StatefulWidget {
  final bool isDark;

  const DisciplineSection({super.key, required this.isDark});

  @override
  State<DisciplineSection> createState() => _DisciplineSectionState();
}

class _DisciplineSectionState extends State<DisciplineSection> {
  int _joursConsecutifs = 0;
  int _pourcentageRituels = 0;
  int _anomaliesOuvertes = 0;
  int _lotsSousVeille = 0;
  DateTime? _derniereObservation;
  int _joursSansActivite = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    try {
      final tacheProvider = context.read<TacheProvider>();
      final anomalieProvider = context.read<AnomalieProvider>();
      final db = DatabaseHelper.instance;

      // Charger les statistiques
      final statsTaches = await tacheProvider.getStatistiquesRituels(
        jours: 7,
      );
      final joursConsec = await _calculerJoursConsecutifs(db);
      final derniereObs = await _getDerniereObservation(db);

      if (mounted) {
        setState(() {
          _joursConsecutifs = joursConsec;
          _pourcentageRituels = statsTaches['tauxCompletion'] ?? 0;
          _anomaliesOuvertes = anomalieProvider.nombreNonResolues;
          _lotsSousVeille = anomalieProvider.nombreCritiques;
          _derniereObservation = derniereObs;
          _joursSansActivite = _calculerJoursSansActivite(derniereObs);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<int> _calculerJoursConsecutifs(DatabaseHelper db) async {
    try {
      final historique = await db.getHistoriqueTaches(limite: 30);
      if (historique.isEmpty) return 0;

      int consecutifs = 0;

      // Grouper par date et vérifier si au moins un rituel est complet par jour
      final Map<String, bool> joursAvecTache = {};

      for (final tache in historique) {
        final dateKey =
            '${tache.date.year}-${tache.date.month}-${tache.date.day}';
        if (tache.estComplet) {
          joursAvecTache[dateKey] = true;
        } else {
          joursAvecTache.putIfAbsent(dateKey, () => false);
        }
      }

      // Compter les jours consécutifs depuis aujourd'hui
      final aujourdhui = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = aujourdhui.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (joursAvecTache[dateKey] == true) {
          consecutifs++;
        } else if (i == 0) {
          // Aujourd'hui pas encore fait, vérifier hier
          continue;
        } else {
          break;
        }
      }

      return consecutifs;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime?> _getDerniereObservation(DatabaseHelper db) async {
    try {
      final historique = await db.getHistoriqueTaches(limite: 1);
      if (historique.isNotEmpty && historique.first.dateCompletion != null) {
        return historique.first.dateCompletion;
      }
      // Fallback: utiliser la dernière entrée du journal
      final journal = await db.getJournalAujourdhui();
      if (journal.isNotEmpty) {
        return journal.first.timestamp;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  int _calculerJoursSansActivite(DateTime? derniereObs) {
    if (derniereObs == null) return 99; // Jamais d'activité
    final diff = DateTime.now().difference(derniereObs);
    return diff.inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Row(
            children: [
              Icon(
                Icons.insights,
                size: 20,
                color: widget.isDark
                    ? AppTheme.textLight
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).dashDiscipline,
                style: AppTheme.titleLarge.copyWith(
                  fontSize: 18,
                  color: widget.isDark
                      ? AppTheme.textLight
                      : AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              // Raccourci rapide "Ajouter Pesée"
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SanteScreen()),
                  );
                },
                icon: Icon(ThemeVariations.sante.icon),
                tooltip: AppLocalizations.of(context).dashActionAjouterPesee,
                color: ThemeVariations.sante.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid 2x3 des indicateurs
          Container(
            decoration: BoxDecoration(
              color: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDark
                    ? AppTheme.neutral800
                    : AppTheme.neutral100,
              ),
            ),
            child: Column(
              children: [
                // Ligne 1: Discipline
                _buildRow([
                  _buildIndicator(
                    emoji: _getStreakEmoji(_joursConsecutifs),
                    label: AppLocalizations.of(context).dashSerie,
                    value: AppLocalizations.of(
                      context,
                    ).dashJours(_joursConsecutifs),
                    color: _getStreakColor(_joursConsecutifs),
                  ),
                  _buildIndicator(
                    emoji: _getRituelEmoji(_pourcentageRituels),
                    label: AppLocalizations.of(context).dashCetteSemaine,
                    value: '$_pourcentageRituels%',
                    color: _getRituelColor(_pourcentageRituels),
                  ),
                ]),

                Divider(
                  height: 1,
                  color: widget.isDark
                      ? AppTheme.neutral800
                      : AppTheme.neutral100,
                ),

                // Ligne 2: Observation
                _buildRow([
                  _buildIndicator(
                    emoji: _anomaliesOuvertes > 0 ? '⚠️' : '✅',
                    label: AppLocalizations.of(context).dashAnomalies,
                    value: _anomaliesOuvertes == 0
                        ? AppLocalizations.of(context).dashAucune
                        : '$_anomaliesOuvertes',
                    color: _anomaliesOuvertes > 0
                        ? AppTheme.warning
                        : AppTheme.success,
                  ),
                  _buildIndicator(
                    emoji: _lotsSousVeille > 0 ? '👁️' : '🐰',
                    label: AppLocalizations.of(context).dashSousVeille,
                    value: _lotsSousVeille == 0
                        ? AppLocalizations.of(context).dashRAS
                        : '$_lotsSousVeille',
                    color: _lotsSousVeille > 0
                        ? AppTheme.info
                        : AppTheme.neutral500,
                  ),
                ]),

                Divider(
                  height: 1,
                  color: widget.isDark
                      ? AppTheme.neutral800
                      : AppTheme.neutral100,
                ),

                // Ligne 3: Comportement
                _buildRow([
                  _buildIndicator(
                    emoji: _getLastObsEmoji(_joursSansActivite),
                    label: AppLocalizations.of(context).dashDerniereObs,
                    value: _formatDerniereObs(_derniereObservation),
                    color: _getLastObsColor(_joursSansActivite),
                  ),
                  _buildIndicator(
                    emoji: _getActivityEmoji(_joursSansActivite),
                    label: AppLocalizations.of(context).dashInactivite,
                    value: _joursSansActivite == 0
                        ? AppLocalizations.of(context).dashActif
                        : AppLocalizations.of(
                            context,
                          ).dashJours(_joursSansActivite),
                    color: _getActivityColor(_joursSansActivite),
                  ),
                ]),
              ],
            ),
          ),

          // Message pédagogique discret
          const SizedBox(height: 8),
          _buildPedagogicalMessage(),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return IntrinsicHeight(
      child: Row(
        children: children.map((child) {
          final isLast = children.indexOf(child) == children.length - 1;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        right: BorderSide(
                          color: widget.isDark
                              ? AppTheme.neutral800
                              : AppTheme.neutral100,
                        ),
                      ),
              ),
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIndicator({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color:
                        (widget.isDark
                                ? AppTheme.textLight
                                : AppTheme.textSecondary)
                            .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedagogicalMessage() {
    final conseil = _getConseilContextuel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: conseil.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: conseil.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(conseil.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conseil.message,
                  style: AppTheme.bodySmall.copyWith(
                    color: widget.isDark
                        ? AppTheme.textLight
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (conseil.astuce != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    conseil.astuce!,
                    style: AppTheme.caption.copyWith(
                      color:
                          (widget.isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textSecondary)
                              .withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Génère un conseil contextuel selon la situation de l'éleveur
  _ConseilPedagogique _getConseilContextuel() {
    // Priorité 1: Alerte inactivité prolongée (risque sanitaire)
    if (_joursSansActivite >= 3) {
      return _ConseilPedagogique(
        emoji: '🏥',
        message: '3 jours sans observation = risque sanitaire',
        astuce: AppLocalizations.of(context).dashProblemeInapercu,
        color: AppTheme.error,
      );
    }

    // Priorité 2: Anomalies non résolues
    if (_anomaliesOuvertes >= 3) {
      return _ConseilPedagogique(
        emoji: '⚠️',
        message: AppLocalizations.of(context).dashPlusieursPoints,
        astuce: AppLocalizations.of(context).dashTraiterUnParUn,
        color: AppTheme.warning,
      );
    }

    // Priorité 3: Encouragement série courte
    if (_joursConsecutifs == 0 && _joursSansActivite >= 1) {
      return _ConseilPedagogique(
        emoji: '🐰',
        message: AppLocalizations.of(context).dashLapinsAttendent,
        astuce: '5 minutes suffisent pour un contrôle visuel.',
        color: AppTheme.info,
      );
    }

    // Priorité 4: Félicitations série longue
    if (_joursConsecutifs >= 7) {
      return _ConseilPedagogique(
        emoji: '🏆',
        message: AppLocalizations.of(context).dashBravo7Jours,
        astuce: AppLocalizations.of(context).dashObserver2Fois,
        color: AppTheme.success,
      );
    }

    // Priorité 5: Encouragement série en cours
    if (_joursConsecutifs >= 3) {
      return _ConseilPedagogique(
        emoji: '🔥',
        message: '$_joursConsecutifs jours consécutifs !',
        astuce: AppLocalizations.of(context).dashRegulariteDifference,
        color: AppTheme.success,
      );
    }

    // Priorité 6: Rituels faibles cette semaine
    if (_pourcentageRituels < 50) {
      return _ConseilPedagogique(
        emoji: '📊',
        message: AppLocalizations.of(context).dashSemaineAmeliorer,
        astuce: AppLocalizations.of(context).dashTourRapide,
        color: AppTheme.warning,
      );
    }

    // Priorité 7: Bonne performance rituels
    if (_pourcentageRituels >= 80) {
      return _ConseilPedagogique(
        emoji: '✨',
        message: AppLocalizations.of(context).dashExcellentSuivi,
        astuce: AppLocalizations.of(context).dashEleveurAttentif,
        color: AppTheme.success,
      );
    }

    // Priorité 8: Anomalie unique
    if (_anomaliesOuvertes == 1) {
      return _ConseilPedagogique(
        emoji: '👁️',
        message: AppLocalizations.of(context).dashPointSurveiller,
        astuce: AppLocalizations.of(context).dashVerifierAujourdhui,
        color: AppTheme.info,
      );
    }

    // Par défaut: Tout va bien
    return _ConseilPedagogique(
      emoji: '👍',
      message: AppLocalizations.of(context).dashToutEnOrdre,
      astuce: AppLocalizations.of(context).dashContinuerObserver,
      color: AppTheme.success,
    );
  }

  // === Helpers couleurs et emojis ===

  String _getStreakEmoji(int jours) {
    if (jours >= 7) return '🔥';
    if (jours >= 3) return '⭐';
    if (jours >= 1) return '👍';
    return '💤';
  }

  Color _getStreakColor(int jours) {
    if (jours >= 7) return AppTheme.success;
    if (jours >= 3) return AppTheme.info;
    if (jours >= 1) return AppTheme.neutral500;
    return AppTheme.warning;
  }

  String _getRituelEmoji(int pourcentage) {
    if (pourcentage >= 80) return '🏆';
    if (pourcentage >= 50) return '📈';
    if (pourcentage >= 25) return '📊';
    return '📉';
  }

  Color _getRituelColor(int pourcentage) {
    if (pourcentage >= 80) return AppTheme.success;
    if (pourcentage >= 50) return AppTheme.info;
    if (pourcentage >= 25) return AppTheme.warning;
    return AppTheme.error;
  }

  String _getLastObsEmoji(int jours) {
    if (jours == 0) return '✅';
    if (jours == 1) return '🕐';
    if (jours <= 3) return '⏰';
    return '⚠️';
  }

  Color _getLastObsColor(int jours) {
    if (jours == 0) return AppTheme.success;
    if (jours <= 1) return AppTheme.info;
    if (jours <= 3) return AppTheme.warning;
    return AppTheme.error;
  }

  String _getActivityEmoji(int jours) {
    if (jours == 0) return '💪';
    if (jours == 1) return '🙂';
    if (jours <= 3) return '😴';
    return '🚨';
  }

  Color _getActivityColor(int jours) {
    if (jours == 0) return AppTheme.success;
    if (jours <= 1) return AppTheme.neutral500;
    if (jours <= 3) return AppTheme.warning;
    return AppTheme.error;
  }

  String _formatDerniereObs(DateTime? date) {
    if (date == null) return AppLocalizations.of(context).dashJamais;

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return AppLocalizations.of(context).dashIlYaMinutes(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return AppLocalizations.of(context).dashIlYaHeures(diff.inHours);
    } else if (diff.inDays == 1) {
      return AppLocalizations.of(context).dashHier;
    } else {
      return AppLocalizations.of(context).dashIlYaJours(diff.inDays);
    }
  }
}

/// Classe helper pour les conseils pédagogiques contextuels
class _ConseilPedagogique {
  final String emoji;
  final String message;
  final String? astuce;
  final Color color;

  const _ConseilPedagogique({
    required this.emoji,
    required this.message,
    this.astuce,
    required this.color,
  });
}

