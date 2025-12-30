import 'package:flutter/material.dart';
import '../../../models/batiment.dart';
import '../../../models/clapier.dart';
import '../../../models/cage.dart';
import '../../../services/database_helper.dart';
import '../../../services/localisation_service.dart'; // Extension methods
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Dialog Stitch pour ajout d'une nouvelle cage
/// Design: Google Stitch - palette neon green #13EC25
///
/// Fonctionnalités:
/// - Cage ID/Name (requis)
/// - Sélection Bâtiment (requis)
/// - Type de cage (individuelle/collective/nid) - PRÉSERVÉ de l'ancien
/// - Capacité avec +/- (requis)
/// - Description optionnelle - PRÉSERVÉ de l'ancien
class AddCageDialog extends StatefulWidget {
  final List<Batiment> batiments;
  final int? selectedBatimentId;
  final VoidCallback onCageAdded;

  const AddCageDialog({
    super.key,
    required this.batiments,
    this.selectedBatimentId,
    required this.onCageAdded,
  });

  @override
  State<AddCageDialog> createState() => _AddCageDialogState();
}

class _AddCageDialogState extends State<AddCageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper.instance;

  final _cageIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedBatimentId;
  String _selectedType = 'individuelle';
  int _capacite = 1;

  @override
  void initState() {
    super.initState();
    _selectedBatimentId = widget.selectedBatimentId;
  }

  @override
  void dispose() {
    _cageIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCage() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Récupérer ou créer clapier
      final clapiers = await _dbHelper.getClapiersByBatiment(
        _selectedBatimentId!,
      );
      int clapierId;

      if (clapiers.isEmpty) {
        clapierId = await _dbHelper.ajouterClapier(
          Clapier(
            batimentId: _selectedBatimentId!,
            nom: 'Section A',
            type: 'interieur',
          ),
        );
      } else {
        clapierId = clapiers.first.id!;
      }

      // Créer la cage
      await _dbHelper.ajouterCage(
        Cage(
          clapierId: clapierId,
          numero: _cageIdController.text.trim(),
          type: _selectedType,
          capacite: _capacite,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onCageAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Cage "${_cageIdController.text}" ajoutée'),
            backgroundColor: AppTheme.primaryNeonGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 720),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.stitchBackgroundDark
              : AppTheme.stitchBackgroundLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isDark),

            // Scrollable Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Helper Text
                      Text(
                        'Enter details for the new cage. Ensure the ID is unique within the selected barn.',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildCageIdField(isDark),
                      const SizedBox(height: 20),

                      _buildLocationDropdown(isDark),
                      const SizedBox(height: 20),

                      _buildTypeDropdown(isDark),
                      const SizedBox(height: 20),

                      _buildCapacityCounter(isDark),
                      const SizedBox(height: 20),

                      _buildDescriptionField(isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            _buildActionBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            'Add New Cage',
            style: AppTheme.titleMedium.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCageIdField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cage ID / Name',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cageIdController,
          decoration: InputDecoration(
            hintText: 'e.g., C-101',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            suffixIcon: Icon(Icons.tag, color: AppTheme.textSecondary),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          validator: (value) =>
              value?.trim().isEmpty ?? true ? 'Cage ID requis' : null,
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location / Barn',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _selectedBatimentId,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          hint: Text(
            'Select a barn',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          icon: Icon(Icons.expand_more, color: AppTheme.textSecondary),
          dropdownColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          items: widget.batiments.map((bat) {
            return DropdownMenuItem<int>(value: bat.id, child: Text(bat.nom));
          }).toList(),
          onChanged: (value) => setState(() => _selectedBatimentId = value),
          validator: (value) =>
              value == null ? 'Sélectionnez un bâtiment' : null,
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cage Type',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedType,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          icon: Icon(Icons.expand_more, color: AppTheme.textSecondary),
          dropdownColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          items: const [
            DropdownMenuItem(value: 'individuelle', child: Text('Individual')),
            DropdownMenuItem(value: 'collective', child: Text('Collective')),
            DropdownMenuItem(value: 'nid', child: Text('Nest Box')),
          ],
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
      ],
    );
  }

  Widget _buildCapacityCounter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capacity',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _capacite > 1
                    ? () => setState(() => _capacite--)
                    : null,
                icon: Icon(Icons.remove),
                color: _capacite > 1
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
              Expanded(
                child: Text(
                  '$_capacite',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _capacite++),
                icon: Icon(Icons.add, color: AppTheme.primaryNeonGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Number of rabbits this cage can comfortably hold.',
          style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Additional notes...',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveCage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.textPrimary,
                elevation: 6,
                shadowColor: AppTheme.primaryNeonGreen.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add Cage', style: AppTheme.titleMedium),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildInputBorder(bool isDark, bool focused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focused
            ? AppTheme.primaryNeonGreen
            : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
        width: focused ? 1.5 : 1,
      ),
    );
  }
}
