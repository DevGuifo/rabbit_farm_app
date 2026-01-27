import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/accouplement.dart';
import '../../models/enums/sexe.dart';
import '../../models/enums/statut_accouplement.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../utils/logger.dart';
import '../../core/constants/error_messages.dart';

/// Écran d'accouplement rapide (workflow simplifié)
///
/// Permet de créer un accouplement en 3 clics :
/// 1. Sélection du mâle (avec suggestions intelligentes)
/// 2. Confirmation
/// 3. Validation
class QuickMatingScreen extends StatefulWidget {
  final Lapin femelle;

  const QuickMatingScreen({super.key, required this.femelle});

  @override
  State<QuickMatingScreen> createState() => _QuickMatingScreenState();
}

class _QuickMatingScreenState extends State<QuickMatingScreen> {
  Lapin? _maleSelectionne;
  DateTime _dateAccouplement = DateTime.now();
  bool _isLoading = false;
  List<Lapin> _malesDisponibles = [];
  Map<int, double> _scoresMales = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerMalesDisponibles();
    });
  }

  Future<void> _chargerMalesDisponibles() async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final reproProvider = Provider.of<ReproductionProvider>(
      context,
      listen: false,
    );
    final db = DatabaseHelper.instance;

    // Tous les mâles vivants et adultes
    final tousMales = lapinProvider.lapins
        .where(
          (l) =>
              l.sexe == Sexe.male &&
              l.statut != 'vendu' &&
              l.statut != 'decede' &&
              l.ageEnMois >= 5,
        )
        .toList();

    // Obtenir les parents de la femelle pour éviter la consanguinité
    final parentsFemelle = await db.getParents(widget.femelle.id!);
    final pereFemelle = parentsFemelle['pere'];
    final mereFemelle = parentsFemelle['mere'];

    // Filtrer les mâles consanguins
    final malesNonConsanguins = <Lapin>[];
    for (final male in tousMales) {
      // Vérifier si c'est le père
      if (pereFemelle != null && male.id == pereFemelle.id) continue;

      // Vérifier si même mère (frère)
      final parentsMale = await db.getParents(male.id!);
      final mereMale = parentsMale['mere'];
      if (mereMale != null &&
          mereFemelle != null &&
          mereMale.id == mereFemelle.id) {
        continue;
      }

      malesNonConsanguins.add(male);
    }

    // Calculer un score pour chaque mâle
    final scores = <int, double>{};
    for (final male in malesNonConsanguins) {
      double score = 0.0;

      // Critère 1 : Âge optimal (1-3 ans)
      final ageMois = male.ageEnMois;
      if (ageMois >= 12 && ageMois <= 36) {
        score += 30.0;
      } else if (ageMois > 36 && ageMois <= 48) {
        score += 20.0;
      } else {
        score += 10.0;
      }

      // Critère 2 : Poids (bonus si > 3kg)
      if (male.poids != null && male.poids! > 3.0) {
        score += 20.0;
      }

      // Critère 3 : Nombre d'accouplements réussis
      final accouplementsReussis = reproProvider.accouplements
          .where(
            (a) =>
                a.maleId == male.id &&
                (a.statut == StatutAccouplement.confirme ||
                    a.statut == StatutAccouplement.termine),
          )
          .length;
      score += accouplementsReussis * 10.0;

      // Critère 4 : Moins d'accouplements récents (éviter la surcharge)
      final accouplementsRecents = reproProvider.accouplements
          .where(
            (a) =>
                a.maleId == male.id &&
                DateTime.now().difference(a.dateAccouplement).inDays < 30,
          )
          .length;
      if (accouplementsRecents == 0) {
        score += 20.0;
      } else if (accouplementsRecents == 1) {
        score += 10.0;
      }

      scores[male.id!] = score;
    }

    // Trier par score décroissant
    malesNonConsanguins.sort((a, b) {
      final scoreA = scores[a.id] ?? 0.0;
      final scoreB = scores[b.id] ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    setState(() {
      _malesDisponibles = malesNonConsanguins;
      _scoresMales = scores;
    });
  }

  Future<void> _validerAccouplement() async {
    if (_maleSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).erreurSelectionnerMale),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reproProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );

      final accouplement = Accouplement(
        maleId: _maleSelectionne!.id!,
        femelleId: widget.femelle.id!,
        dateAccouplement: _dateAccouplement,
        dateMiseBasPrevue: _dateAccouplement.add(const Duration(days: 31)),
        statut: StatutAccouplement.enAttente,
      );

      await reproProvider.ajouterAccouplement(accouplement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Accouplement planifié : ${widget.femelle.nom} × ${_maleSelectionne!.nom}',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      logger.error('Erreur lors de la création de l\'accouplement', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.genericError),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.of(
          context,
        ).reproAccouplerAvec(widget.femelle.nom),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte femelle
                  _buildFemelleCard(isDark),
                  const SizedBox(height: 20),

                  // Titre sélection mâle
                  Text(
                    'Sélectionner le mâle',
                    style: AppTheme.titleMedium.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Liste des mâles
                  if (_malesDisponibles.isEmpty)
                    _buildEmptyState(isDark)
                  else
                    ..._malesDisponibles.map(
                      (male) => _buildMaleCard(male, isDark),
                    ),

                  const SizedBox(height: 20),

                  // Date d'accouplement
                  _buildDatePicker(isDark),
                  const SizedBox(height: 20),

                  // Résumé et validation
                  if (_maleSelectionne != null) _buildSummaryCard(isDark),
                ],
              ),
            ),
      bottomNavigationBar: _maleSelectionne != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validerAccouplement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Valider l\'accouplement',
                        style: AppTheme.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFemelleCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.female_rounded, color: AppTheme.accentPink, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.femelle.nom,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.accentPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.femelle.race} • ${widget.femelle.ageFormate}',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                  ),
                ),
                if (widget.femelle.poids != null)
                  Text(
                    '${widget.femelle.poids!.toStringAsFixed(2)} kg',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark
                          ? AppTheme.textLight
                          : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaleCard(Lapin male, bool isDark) {
    final isSelected = _maleSelectionne?.id == male.id;
    final score = _scoresMales[male.id] ?? 0.0;
    final isRecommended = _malesDisponibles.indexOf(male) == 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _maleSelectionne = male;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.male_rounded,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.info,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          male.nom,
                          style: AppTheme.titleSmall.copyWith(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : (isDark
                                      ? AppTheme.textLight
                                      : AppTheme.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppTheme.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Recommandé',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${male.race} • ${male.ageFormate}',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark
                          ? AppTheme.textLight
                          : AppTheme.textSecondary,
                    ),
                  ),
                  if (male.poids != null)
                    Text(
                      '${male.poids!.toStringAsFixed(2)} kg • Score: ${score.toInt()}/100',
                      style: AppTheme.caption.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun mâle disponible',
            style: AppTheme.titleSmall.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tous les mâles sont soit consanguins, soit indisponibles',
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: AppTheme.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date d\'accouplement',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateAccouplement.day == DateTime.now().day &&
                          _dateAccouplement.month == DateTime.now().month &&
                          _dateAccouplement.year == DateTime.now().year
                      ? 'Aujourd\'hui'
                      : '${_dateAccouplement.day.toString().padLeft(2, '0')}/${_dateAccouplement.month.toString().padLeft(2, '0')}/${_dateAccouplement.year}',
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateAccouplement,
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _dateAccouplement = date;
                });
              }
            },
            child: Text(AppLocalizations.of(context).actionModifier),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    final dateMiseBas = _dateAccouplement.add(const Duration(days: 31));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Résumé',
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('♀ Femelle', widget.femelle.nom, isDark),
          _buildSummaryRow('♂ Mâle', _maleSelectionne!.nom, isDark),
          _buildSummaryRow(
            'Date accouplement',
            _dateAccouplement.day == DateTime.now().day &&
                    _dateAccouplement.month == DateTime.now().month &&
                    _dateAccouplement.year == DateTime.now().year
                ? 'Aujourd\'hui'
                : '${_dateAccouplement.day.toString().padLeft(2, '0')}/${_dateAccouplement.month.toString().padLeft(2, '0')}/${_dateAccouplement.year}',
            isDark,
          ),
          _buildSummaryRow(
            'Mise bas prévue',
            '${dateMiseBas.day.toString().padLeft(2, '0')}/${dateMiseBas.month.toString().padLeft(2, '0')}/${dateMiseBas.year}',
            isDark,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aucun problème détecté (non consanguins)',
                  style: AppTheme.caption.copyWith(color: AppTheme.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
