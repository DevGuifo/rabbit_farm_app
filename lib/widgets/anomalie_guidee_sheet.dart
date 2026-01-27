import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/anomalie_tache.dart';
import '../models/tache_quotidienne.dart';
import '../providers/anomalie_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Bottom sheet guidé pour signaler une anomalie
///
/// UX optimisée éleveur africain :
/// - Checkboxes pré-remplies (pas de texte à saisir)
/// - Association automatique date/rituel
/// - Sélection portée (individu ou lot)
/// - Action suggérée automatique
/// - Note libre optionnelle
class AnomalieGuideeSheet extends StatefulWidget {
  final int? tacheId;
  final TypeTacheQuotidienne typeTache;
  final ActionTache action;
  final AnomalieTache? anomalieInitiale;
  final VoidCallback? onAnomalieEnregistree;

  const AnomalieGuideeSheet({
    super.key,
    this.tacheId,
    required this.typeTache,
    required this.action,
    this.anomalieInitiale,
    this.onAnomalieEnregistree,
  });

  @override
  State<AnomalieGuideeSheet> createState() => _AnomalieGuideeSheetState();
}

class _AnomalieGuideeSheetState extends State<AnomalieGuideeSheet> {
  // État de sélection des types d'anomalies
  final Map<TypeAnomalie, bool> _typesSelectionnes = {};

  // Portée sélectionnée
  PorteeAnomalie _portee = PorteeAnomalie.individu;

  // Note libre (optionnelle)
  final TextEditingController _noteController = TextEditingController();

  // Est en cours de soumission
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialiser tous les types comme non sélectionnés
    for (final type in TypeAnomalie.values) {
      _typesSelectionnes[type] = false;
    }

    final initiale = widget.anomalieInitiale;
    if (initiale != null) {
      for (final t in initiale.typesAnomalies) {
        _typesSelectionnes[t] = true;
      }
      _portee = initiale.portee;
      _noteController.text = initiale.noteLibre ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Types sélectionnés
  List<TypeAnomalie> get _selectedTypes {
    return _typesSelectionnes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  /// Au moins un type sélectionné ?
  bool get _hasSelection => _selectedTypes.isNotEmpty;

  /// Sévérité max des types sélectionnés
  int get _severiteMax {
    if (!_hasSelection) return 0;
    return _selectedTypes
        .map((t) => t.severiteDefaut)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Action suggérée basée sur la sélection
  ActionSuggeree get _actionSuggeree {
    if (!_hasSelection) return ActionSuggeree.aucune;

    if (_portee == PorteeAnomalie.lot) {
      return ActionSuggeree.surveiller;
    }

    // Pour individu, prendre l'action du type le plus sévère
    final typePlusSevere = _selectedTypes.reduce(
      (a, b) => a.severiteDefaut > b.severiteDefaut ? a : b,
    );
    return typePlusSevere.actionSuggeree;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        mediaQuery.viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée de défilement
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // En-tête
          _buildHeader(isDark),
          const SizedBox(height: 8),

          // Contexte automatique
          _buildContexteAuto(isDark),
          const SizedBox(height: 20),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section : Qu'avez-vous observé ?
                  _buildSectionTitle('Qu\'avez-vous observé ?', '👁️'),
                  const SizedBox(height: 12),
                  _buildTypesCheckboxes(isDark),
                  const SizedBox(height: 24),

                  // Section : Combien de sujets ?
                  _buildSectionTitle('Combien de sujets concernés ?', '🐰'),
                  const SizedBox(height: 12),
                  _buildPorteeSelector(isDark),
                  const SizedBox(height: 24),

                  // Action suggérée (si sélection)
                  if (_hasSelection) ...[
                    _buildActionSuggeree(isDark),
                    const SizedBox(height: 24),
                  ],

                  // Note libre (optionnelle)
                  _buildNoteOptionnelle(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Boutons d'action
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: AppTheme.error,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signaler une anomalie',
                style: AppTheme.titleLarge.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sélectionnez ce que vous avez observé',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContexteAuto(bool isDark) {
    final now = DateTime.now();
    final heureStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark
            ? AppTheme.backgroundDarkMode
            : AppTheme.backgroundLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildContexteChip(
            widget.typeTache == TypeTacheQuotidienne.matin ? '🌅' : '🌙',
            'Rituel ${widget.typeTache == TypeTacheQuotidienne.matin ? "matin" : "soir"}',
          ),
          const SizedBox(width: 12),
          _buildContexteChip('📋', widget.action.titre),
          const SizedBox(width: 12),
          _buildContexteChip('🕐', heureStr),
        ],
      ),
    );
  }

  Widget _buildContexteChip(String emoji, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTypesCheckboxes(bool isDark) {
    // Exclure "autre" pour le mettre à part
    final typesStandards = TypeAnomalie.values
        .where((t) => t != TypeAnomalie.autre)
        .toList();

    return Column(
      children: [
        // Types standards en grille
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.2,
          children: typesStandards.map((type) {
            return _buildTypeCheckbox(type, isDark);
          }).toList(),
        ),
        const SizedBox(height: 8),
        // "Autre" en pleine largeur
        _buildTypeCheckbox(TypeAnomalie.autre, isDark, fullWidth: true),
      ],
    );
  }

  Widget _buildTypeCheckbox(
    TypeAnomalie type,
    bool isDark, {
    bool fullWidth = false,
  }) {
    final isSelected = _typesSelectionnes[type] ?? false;
    final severite = type.severiteDefaut;

    // Couleur selon sévérité
    Color severiteColor;
    switch (severite) {
      case 1:
        severiteColor = AppTheme.warning;
        break;
      case 2:
        severiteColor = Colors.orange;
        break;
      case 3:
        severiteColor = AppTheme.error;
        break;
      default:
        severiteColor = AppTheme.textSecondary;
    }

    return Material(
      color: isSelected
          ? severiteColor.withValues(alpha: 0.15)
          : (isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _typesSelectionnes[type] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? severiteColor
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox custom
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? severiteColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? severiteColor : AppTheme.textSecondary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 10),
              // Emoji + Label
              Text(type.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  type.label,
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPorteeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildPorteeOption(PorteeAnomalie.individu, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildPorteeOption(PorteeAnomalie.lot, isDark)),
      ],
    );
  }

  Widget _buildPorteeOption(PorteeAnomalie portee, bool isDark) {
    final isSelected = _portee == portee;
    final color = portee == PorteeAnomalie.individu
        ? AppTheme.info
        : AppTheme.warning;

    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.15)
          : (isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _portee = portee;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(portee.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                portee.label,
                style: AppTheme.labelMedium.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSuggeree(bool isDark) {
    final action = _actionSuggeree;
    final severite = _severiteMax;

    // Couleur selon sévérité
    Color bgColor;
    switch (severite) {
      case 1:
        bgColor = AppTheme.warning;
        break;
      case 2:
        bgColor = Colors.orange;
        break;
      case 3:
        bgColor = AppTheme.error;
        break;
      default:
        bgColor = AppTheme.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(action.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action suggérée',
                  style: AppTheme.caption.copyWith(color: bgColor),
                ),
                const SizedBox(height: 4),
                Text(
                  action.label,
                  style: AppTheme.titleSmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_portee == PorteeAnomalie.lot)
                  Text(
                    'Lot marqué "Sous surveillance"',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Badge sévérité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severite == 3 ? 'CRITIQUE' : (severite == 2 ? 'MOYEN' : 'FAIBLE'),
              style: AppTheme.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteOptionnelle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📝', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Note (optionnel)',
              style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintDetailsSupplementaires,
            filled: true,
            fillColor: isDark
                ? AppTheme.backgroundDarkMode
                : AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return SafeArea(
      child: Row(
        children: [
          // Annuler
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
          ),
          const SizedBox(width: 12),
          // Enregistrer
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _hasSelection && !_isSubmitting
                  ? _enregistrerAnomalie
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Signaler (${_selectedTypes.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enregistrerAnomalie() async {
    if (!_hasSelection) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final provider = context.read<AnomalieProvider>();

      final noteLibre = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null;

      final initiale = widget.anomalieInitiale;
      if (initiale != null) {
        final ok = await provider.mettreAJourAnomalie(
          anomalie: initiale,
          typesSelectionnes: _selectedTypes,
          portee: _portee,
          noteLibre: noteLibre,
        );

        if (ok && mounted) {
          Navigator.pop(context);
          widget.onAnomalieEnregistree?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).labelDetails),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        final anomalie = await provider.enregistrerAnomalie(
          tacheId: widget.tacheId,
          actionRituelId: widget.action.id,
          actionRituelTitre: widget.action.titre,
          typesSelectionnes: _selectedTypes,
          portee: _portee,
          noteLibre: noteLibre,
        );

        if (anomalie != null && mounted) {
          Navigator.pop(context);
          widget.onAnomalieEnregistree?.call();

          // Afficher un message de confirmation avec l'action suggérée
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(anomalie.actionSuggeree.emoji),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${anomalie.resumeLabel} signalée • ${anomalie.actionSuggeree.label}',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).msgErreurGenerique(e.toString()),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

