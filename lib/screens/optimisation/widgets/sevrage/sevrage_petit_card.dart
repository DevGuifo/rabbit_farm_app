import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../models/lapin.dart';
import '../../../../repositories/localisation_repository.dart';
import '../../../../l10n/app_localizations.dart';

class SevragePetitCard extends StatefulWidget {
  final Lapin petit;
  final int? cageId;
  final double? poids;
  final String sexe;
  final ValueChanged<double?> onPoidsChanged;
  final ValueChanged<String> onSexeChanged;
  final VoidCallback onSelectCage;

  const SevragePetitCard({
    super.key,
    required this.petit,
    required this.cageId,
    required this.poids,
    required this.sexe,
    required this.onPoidsChanged,
    required this.onSexeChanged,
    required this.onSelectCage,
  });

  @override
  State<SevragePetitCard> createState() => _SevragePetitCardState();
}

class _SevragePetitCardState extends State<SevragePetitCard> {
  String? _cageNumero;
  bool _loadingCage = false;

  @override
  void initState() {
    super.initState();
    if (widget.cageId != null) {
      _chargerCageNumero();
    }
  }

  @override
  void didUpdateWidget(SevragePetitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cageId != oldWidget.cageId) {
      if (widget.cageId != null) {
        _chargerCageNumero();
      } else {
        setState(() => _cageNumero = null);
      }
    }
  }

  Future<void> _chargerCageNumero() async {
    if (widget.cageId == null) return;

    setState(() => _loadingCage = true);
    try {
      final cage = await LocalisationRepository.instance.getCageById(
        widget.cageId!,
      );
      if (mounted) {
        setState(() {
          _cageNumero = cage?.numero;
          _loadingCage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cageNumero = null;
          _loadingCage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sexeIcon =
        (widget.sexe.toLowerCase() == 'male' ||
            widget.sexe.toLowerCase() == 'm' ||
            widget.sexe.toLowerCase() == 'mâle')
        ? Icons.male
        : Icons.female;
    final sexeColor =
        (widget.sexe.toLowerCase() == 'male' ||
            widget.sexe.toLowerCase() == 'm' ||
            widget.sexe.toLowerCase() == 'mâle')
        ? AppTheme.accentCyan
        : AppTheme.accentPink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: widget.cageId != null
              ? AppTheme.primaryGreen
              : (isDark ? AppTheme.borderDark : AppTheme.border),
          width: 2,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: sexeColor.withValues(alpha: 0.2),
                child: Icon(sexeIcon, color: sexeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.petit.nom,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.sexe} • ${widget.petit.ageEnJours} jours',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark
                            ? AppTheme.textLight.withValues(alpha: 0.7)
                            : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.cageId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: _loadingCage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _cageNumero != null ? 'Cage $_cageNumero' : 'Cage...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Sélection du sexe
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onSexeChanged('Mâle'),
                  icon: const Icon(Icons.male, size: 18),
                  label: Text(AppLocalizations.of(context).labelSexeMale),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor:
                        (widget.sexe.toLowerCase() == 'male' ||
                            widget.sexe.toLowerCase() == 'm' ||
                            widget.sexe.toLowerCase() == 'mâle')
                        ? AppTheme.accentCyan.withValues(alpha: 0.1)
                        : null,
                    foregroundColor:
                        (widget.sexe.toLowerCase() == 'male' ||
                            widget.sexe.toLowerCase() == 'm' ||
                            widget.sexe.toLowerCase() == 'mâle')
                        ? AppTheme.accentCyan
                        : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
                    side: BorderSide(
                      color:
                          (widget.sexe.toLowerCase() == 'male' ||
                              widget.sexe.toLowerCase() == 'm' ||
                              widget.sexe.toLowerCase() == 'mâle')
                          ? AppTheme.accentCyan
                          : (isDark ? AppTheme.borderDark : AppTheme.border),
                      width:
                          (widget.sexe.toLowerCase() == 'male' ||
                              widget.sexe.toLowerCase() == 'm' ||
                              widget.sexe.toLowerCase() == 'mâle')
                          ? 2
                          : 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onSexeChanged('Femelle'),
                  icon: const Icon(Icons.female, size: 18),
                  label: Text(AppLocalizations.of(context).labelSexeFemelle),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor:
                        (widget.sexe.toLowerCase() == 'femelle' ||
                            widget.sexe.toLowerCase() == 'f')
                        ? AppTheme.accentPink.withValues(alpha: 0.1)
                        : null,
                    foregroundColor:
                        (widget.sexe.toLowerCase() == 'femelle' ||
                            widget.sexe.toLowerCase() == 'f')
                        ? AppTheme.accentPink
                        : (isDark ? AppTheme.textLight : AppTheme.textPrimary),
                    side: BorderSide(
                      color:
                          (widget.sexe.toLowerCase() == 'femelle' ||
                              widget.sexe.toLowerCase() == 'f')
                          ? AppTheme.accentPink
                          : (isDark ? AppTheme.borderDark : AppTheme.border),
                      width:
                          (widget.sexe.toLowerCase() == 'femelle' ||
                              widget.sexe.toLowerCase() == 'f')
                          ? 2
                          : 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.poids?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormPoids,
                    prefixIcon: Icon(
                      Icons.monitor_weight,
                      color: isDark
                          ? AppTheme.textLight.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.surfaceDark : AppTheme.bgLight,
                  ),
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                  onChanged: (value) {
                    widget.onPoidsChanged(double.tryParse(value));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onSelectCage,
                  icon: const Icon(Icons.home, size: 18),
                  label: Text(widget.cageId != null ? 'Changer' : 'Cage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.cageId != null
                        ? AppTheme.primaryGreen
                        : AppTheme.info,
                    foregroundColor: AppTheme.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
