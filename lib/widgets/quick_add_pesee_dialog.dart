import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/lapin.dart';
import '../models/pesee.dart';
import '../services/database_helper.dart';
import '../theme/app_theme.dart';

/// Dialog rapide pour ajouter une pesée
class QuickAddPeseeDialog extends StatefulWidget {
  final Lapin lapin;

  const QuickAddPeseeDialog({super.key, required this.lapin});

  @override
  State<QuickAddPeseeDialog> createState() => _QuickAddPeseeDialogState();
}

class _QuickAddPeseeDialogState extends State<QuickAddPeseeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _poidsController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _poidsController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final pesee = Pesee(
        lapinId: widget.lapin.id!,
        poids: double.parse(_poidsController.text.replaceAll(',', '.')),
        date: _date,
      );

      await DatabaseHelper.instance.insertPesee(pesee);

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
          Icon(Icons.monitor_weight, color: AppTheme.info),
          const SizedBox(width: 12),
          Text(
            'Nouvelle pesée',
            style: AppTheme.titleMedium.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info lapin
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, size: 20, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Text(
                    widget.lapin.nom,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Champ poids
            TextFormField(
              controller: _poidsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Poids (kg)',
                hintText: AppLocalizations.of(context).hintExPoids,
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le poids';
                }
                final poids = double.tryParse(value.replaceAll(',', '.'));
                if (poids == null || poids <= 0) {
                  return 'Poids invalide';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: AppTheme.info),
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
            backgroundColor: AppTheme.info,
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
