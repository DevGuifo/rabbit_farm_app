import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicament.dart';
import '../../providers/medicament_provider.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

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
      _typeController.text = widget.medicament!.type;
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
        type: _typeController.text.trim(),
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
            const SnackBar(content: Text('Médicament ajouté avec succès')),
          );
        }
      } else {
        await medicamentProvider.modifierMedicament(medicament);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Médicament modifié avec succès')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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
    final primaryColor = AppTheme.info; // Blue
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.border : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.medicament == null
              ? 'Ajouter un médicament'
              : 'Modifier le médicament',
          style: AppTheme.titleMedium.copyWith(color: textPrimary),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _nomController,
              label: 'Nom du médicament *',
              icon: Icons.medication,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _typeController,
              label: 'Type * (Vaccin, Antibiotique, Antiparasitaire...)',
              icon: Icons.category,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le type est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _posologieController,
              label: 'Posologie (ex: 0.5ml/kg, 2 fois par jour)',
              icon: Icons.medical_information,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _quantiteStockController,
                    label: 'Quantité en stock *',
                    icon: Icons.inventory,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantité obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _uniteController,
                    label: 'Unité *',
                    icon: Icons.scale,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unité requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _seuilAlerteController,
                    label: 'Seuil d\'alerte',
                    icon: Icons.warning_amber,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _prixUnitaireController,
                    label: 'Prix unitaire (€)',
                    icon: Icons.euro,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateField(isDark, surfaceColor, textPrimary),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Notes supplémentaires',
              icon: Icons.note,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppTheme.cardLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
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
                        widget.medicament == null ? 'Ajouter' : 'Enregistrer',
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
        : Colors.black.withValues(alpha: 0.1);

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
          labelText: 'Date d\'expiration',
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
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        child: Text(
          _dateExpiration != null
              ? '${_dateExpiration!.day}/${_dateExpiration!.month}/${_dateExpiration!.year}'
              : 'Sélectionner une date',
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
        : Colors.black.withValues(alpha: 0.1);
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
    );
  }
}
