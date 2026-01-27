import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/lapin.dart';
import '../models/soin.dart';
import '../models/enums/type_soin.dart';
import '../services/database_helper.dart';
import '../theme/app_theme.dart';

/// Dialog rapide pour ajouter un soin
class QuickAddSoinDialog extends StatefulWidget {
  final Lapin lapin;

  const QuickAddSoinDialog({super.key, required this.lapin});

  @override
  State<QuickAddSoinDialog> createState() => _QuickAddSoinDialogState();
}

class _QuickAddSoinDialogState extends State<QuickAddSoinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  TypeSoin _typeSoin = TypeSoin.vaccination;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _typesSoins = [
    {'value': TypeSoin.vaccination, 'label': 'Vaccination', 'icon': Icons.vaccines},
    {
      'value': TypeSoin.vermifuge,
      'label': 'Vermifuge',
      'icon': Icons.medication_liquid,
    },
    {'value': TypeSoin.traitement, 'label': 'Traitement', 'icon': Icons.healing},
    {'value': TypeSoin.autre, 'label': 'Autre', 'icon': Icons.medical_services},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final soin = Soin(
        lapinId: widget.lapin.id!,
        type: _typeSoin,
        description: _descriptionController.text.trim(),
        date: _date,
      );

      await DatabaseHelper.instance.insertSoin(soin);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).utilErreur(e.toString()),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      title: Row(
        children: [
          Icon(Icons.medical_services, color: AppTheme.accentTeal),
          const SizedBox(width: 12),
          Text(
            'Nouveau soin',
            style: AppTheme.titleMedium.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info lapin
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pets, size: 20, color: AppTheme.accentTeal),
                    const SizedBox(width: 8),
                    Text(
                      widget.lapin.nom,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Type de soin
              Text(
                'Type de soin',
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _typesSoins.map((type) {
                  final isSelected = _typeSoin == type['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.accentTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(type['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _typeSoin = type['value'] as TypeSoin);
                      }
                    },
                    selectedColor: AppTheme.accentTeal,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: AppLocalizations.of(context).hintExVaccin,
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today, color: AppTheme.accentTeal),
                title: Text(
                  'Date',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
                  ),
                ),
                subtitle: Text(
                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _date = date);
                    }
                  },
                  child: Text(AppLocalizations.of(context).widgetModifier),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _enregistrer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(AppLocalizations.of(context).widgetEnregistrer),
        ),
      ],
    );
  }
}
