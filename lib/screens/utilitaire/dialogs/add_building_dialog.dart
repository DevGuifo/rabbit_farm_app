import 'package:flutter/material.dart';
import '../../../models/batiment.dart';
import '../../../repositories/localisation_repository.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/error_service.dart';

/// Dialog Stitch pour ajout d'un nouveau bâtiment
/// Design: Google Stitch - palette neon green #13EC25
///
/// Fonctionnalités:
/// - Building Name (requis)
/// - Capacity (optionnel) - NOUVEAU vs ancien
/// - Description (optionnel) - PRÉSERVÉ
/// - Hero image (décoratif)
class AddBuildingDialog extends StatefulWidget {
  final VoidCallback onBuildingAdded;

  const AddBuildingDialog({super.key, required this.onBuildingAdded});

  @override
  State<AddBuildingDialog> createState() => _AddBuildingDialogState();
}

class _AddBuildingDialogState extends State<AddBuildingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LocalisationRepository.instance;

  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBuilding() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _repository.insertBatiment(
        Batiment(
          nom: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onBuildingAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).msgBatimentAjoute(_nameController.text),
            ),
            backgroundColor: AppTheme.primaryNeonGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorService.showError(context, e);
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
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
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
                      // Hero Image
                      _buildHeroImage(),
                      const SizedBox(height: 24),

                      _buildNameField(isDark),
                      const SizedBox(height: 20),

                      _buildCapacityField(isDark),
                      const SizedBox(height: 20),

                      _buildDescriptionField(isDark),
                      const SizedBox(height: 24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              AppLocalizations.of(context).titleAddNewBuilding,
              style: AppTheme.titleMedium.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Simulate sync action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).msgSyncBientot,
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.sync, size: 20),
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).msgPasNouvellesNotifs,
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, size: 20),
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).msgParametresNonDispo,
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.settings, size: 20),
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.textPrimary.withValues(alpha: 0.8),
            AppTheme.textPrimary,
          ],
        ),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=800&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppTheme.textPrimary.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          AppLocalizations.of(context).titleBuildingInformation,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).labelBuildingName,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppTheme.error, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintBreedingBarnA,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(Icons.warehouse, color: AppTheme.textSecondary),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
          validator: (value) => value?.trim().isEmpty ?? true
              ? AppLocalizations.of(context).validationBuildingNameRequired
              : null,
        ),
      ],
    );
  }

  Widget _buildCapacityField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).labelCapacity,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(Icons.grid_view, color: AppTheme.textSecondary),
            suffixText: AppLocalizations.of(context).suffixUnits,
            suffixStyle: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estimated maximum rabbit capacity.',
          style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintLocationDetails,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
            border: _buildInputBorder(isDark, false),
            enabledBorder: _buildInputBorder(isDark, false),
            focusedBorder: _buildInputBorder(isDark, true),
            contentPadding: const EdgeInsets.all(14),
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
        color: isDark
            ? AppTheme.backgroundDark.withValues(alpha: 0.8)
            : AppTheme.cardLight.withValues(alpha: 0.8),
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
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return ElevatedButton.icon(
                  onPressed: _saveBuilding,
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: Text(l10n.ajouterBatiment, style: AppTheme.titleSmall),
                  style: AppTheme.primaryButtonStyle,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return TextButton(
                onPressed: () => Navigator.pop(context),
                style: AppTheme.textButtonStyle,
                child: Text(l10n.annuler),
              );
            },
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
