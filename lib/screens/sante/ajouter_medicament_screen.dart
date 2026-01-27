import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medicament.dart';
import '../../models/enums/medicament_enums.dart';
import '../../providers/medicament_provider.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../services/error_service.dart';

/// Écran d'ajout/édition de médicament
class AjouterMedicamentScreen extends StatefulWidget {
  final Medicament? medicament; // Si non null, mode édition

  const AjouterMedicamentScreen({super.key, this.medicament});

  @override
  State<AjouterMedicamentScreen> createState() =>
      _AjouterMedicamentScreenState();
}

class _AjouterMedicamentScreenState extends State<AjouterMedicamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _typeController = TextEditingController();
  final _posologieController = TextEditingController();
  final _quantiteStockController = TextEditingController();
  final _uniteController = TextEditingController();
  final _seuilAlerteController = TextEditingController();
  final _prixUnitaireController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dateExpiration;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicament != null) {
      _nomController.text = widget.medicament!.nom;
      _typeController.text = widget.medicament!.type.label;
      _posologieController.text = widget.medicament!.posologie ?? '';
      _quantiteStockController.text = widget.medicament!.quantiteStock
          .toString();
      _uniteController.text = widget.medicament!.unite;
      _seuilAlerteController.text =
          widget.medicament!.seuilAlerte?.toString() ?? '';
      _prixUnitaireController.text =
          widget.medicament!.prixUnitaire?.toString() ?? '';
      _notesController.text = widget.medicament!.notes ?? '';
      _dateExpiration = widget.medicament!.dateExpiration;
    } else {
      // Valeurs par défaut pour nouveau médicament
      _seuilAlerteController.text = '10';
      _uniteController.text = 'ml';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _typeController.dispose();
    _posologieController.dispose();
    _quantiteStockController.dispose();
    _uniteController.dispose();
    _seuilAlerteController.dispose();
    _prixUnitaireController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final medicamentProvider = Provider.of<MedicamentProvider>(
        context,
        listen: false,
      );

      final medicament = Medicament(
        id: widget.medicament?.id,
        nom: _nomController.text.trim(),
        type: TypeMedicament.fromString(_typeController.text.trim()),
        quantiteStock:
            double.tryParse(_quantiteStockController.text.trim()) ?? 0.0,
        unite: _uniteController.text.trim(),
        seuilAlerte: _seuilAlerteController.text.trim().isEmpty
            ? null
            : double.tryParse(_seuilAlerteController.text.trim()),
        dateExpiration: _dateExpiration,
        prixUnitaire: _prixUnitaireController.text.trim().isEmpty
            ? null
            : double.tryParse(_prixUnitaireController.text.trim()),
        posologie: _posologieController.text.trim().isEmpty
            ? null
            : _posologieController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.medicament == null) {
        await medicamentProvider.ajouterMedicament(medicament);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).santeMedicamentAjoute),
            ),
          );
        }
      } else {
        await medicamentProvider.modifierMedicament(medicament);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).santeMedicamentModifie,
              ),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorService.showError(context, e);
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
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.border : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: SimpleAppBar(
        title: widget.medicament == null
            ? AppLocalizations.of(context).santeAjouterSoin
            : AppLocalizations.of(context).santeModifierSoin,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppTheme.paddingAllMedium,
          children: [
            _buildTextField(
              controller: _nomController,
              label: AppLocalizations.of(context).santeNomMedicament,
              icon: Icons.medication,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).erreurNomMedicamentRequis;
                }
                return null;
              },
            ),
            AppTheme.verticalSpace16,
            _buildTextField(
              controller: _typeController,
              label: AppLocalizations.of(context).santeTypeSoin,
              icon: Icons.category,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).erreurDescriptionRequise;
                }
                return null;
              },
            ),
            AppTheme.verticalSpace16,
            _buildTextField(
              controller: _posologieController,
              label: AppLocalizations.of(context).santePosologie,
              icon: Icons.medical_information,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              maxLines: 2,
            ),
            AppTheme.verticalSpace16,
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _quantiteStockController,
                    label: AppLocalizations.of(context).santeQuantite,
                    icon: Icons.inventory,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).erreurQuantiteInvalide;
                      }
                      if (double.tryParse(value) == null) {
                        return AppLocalizations.of(
                          context,
                        ).erreurQuantiteInvalide;
                      }
                      return null;
                    },
                  ),
                ),
                AppTheme.horizontalSpace12,
                Expanded(
                  child: _buildTextField(
                    controller: _uniteController,
                    label: AppLocalizations.of(context).santeUnite,
                    icon: Icons.scale,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).erreurDescriptionRequise;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            AppTheme.verticalSpace16,
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _seuilAlerteController,
                    label: AppLocalizations.of(context).santeSeuilAlerte,
                    icon: Icons.warning_amber,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return AppLocalizations.of(context).erreurSeuilInvalide;
                      }
                      return null;
                    },
                  ),
                ),
                AppTheme.horizontalSpace12,
                Expanded(
                  child: _buildTextField(
                    controller: _prixUnitaireController,
                    label: AppLocalizations.of(context).santePrixUnitaire,
                    icon: Icons.euro,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return AppLocalizations.of(context).erreurPrixInvalide;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            AppTheme.verticalSpace16,
            _buildDateField(isDark, surfaceColor, textPrimary),
            AppTheme.verticalSpace16,
            _buildTextField(
              controller: _notesController,
              label: AppLocalizations.of(context).santeNotes,
              icon: Icons.note,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              maxLines: 4,
            ),
            AppTheme.verticalSpace32,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enregistrer,
                style: AppTheme.primaryButtonStyle,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.cardLight,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.medicament == null
                            ? AppLocalizations.of(context).santeAjouter
                            : AppLocalizations.of(context).santeEnregistrer,
                        style: AppTheme.titleSmall,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(bool isDark, Color surfaceColor, Color textPrimary) {
    final borderColor = isDark
        ? AppTheme.cardLight.withValues(alpha: 0.1)
        : AppTheme.textPrimary.withValues(alpha: 0.1);

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              _dateExpiration ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (date != null) {
          setState(() => _dateExpiration = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).santeDateExpiration,
          labelStyle: AppTheme.bodyMedium.copyWith(
            color: textPrimary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: textPrimary.withValues(alpha: 0.7),
            size: 20,
          ),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: AppTheme.borderRadiusMedium,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTheme.borderRadiusMedium,
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        child: Text(
          _dateExpiration != null
              ? '${_dateExpiration!.day}/${_dateExpiration!.month}/${_dateExpiration!.year}'
              : AppLocalizations.of(context).santeSelectionnerDate,
          style: AppTheme.bodyLarge.copyWith(
            color: _dateExpiration != null
                ? textPrimary
                : textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color surfaceColor,
    required Color textPrimary,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final borderColor = isDark
        ? AppTheme.cardLight.withValues(alpha: 0.1)
        : AppTheme.textPrimary.withValues(alpha: 0.1);
    final focusedBorderColor = AppTheme.info;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTheme.bodyLarge.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyMedium.copyWith(
          color: textPrimary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(
          icon,
          color: textPrimary.withValues(alpha: 0.7),
          size: 20,
        ),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMedium,
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
    );
  }
}
