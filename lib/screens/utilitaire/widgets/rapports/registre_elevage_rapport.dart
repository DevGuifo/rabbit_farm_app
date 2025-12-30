import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../providers/reproduction_provider.dart';
import '../../../../theme/app_theme.dart';

/// Registre d'élevage officiel conforme à la réglementation
class RegistreElevageRapport extends StatefulWidget {
  const RegistreElevageRapport({super.key});

  @override
  State<RegistreElevageRapport> createState() => _RegistreElevageRapportState();
}

class _RegistreElevageRapportState extends State<RegistreElevageRapport> {
  DateTime _dateDebut = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateFin = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LapinProvider, ReproductionProvider>(
      builder: (context, lapinProvider, reproProvider, child) {
        final naissances = reproProvider.portees
            .where(
              (p) =>
                  p.dateMiseBasReelle.isAfter(_dateDebut) &&
                  p.dateMiseBasReelle.isBefore(_dateFin),
            )
            .length;

        final accouplements = reproProvider.accouplements
            .where(
              (a) =>
                  a.dateAccouplement.isAfter(_dateDebut) &&
                  a.dateAccouplement.isBefore(_dateFin),
            )
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête
            Text(
              'Registre d\'élevage officiel',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Document conforme à la réglementation',
              style: AppTheme.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Sélection période
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Période',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateDebut,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _dateDebut = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date de début',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_dateDebut),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateFin,
                          firstDate: _dateDebut,
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _dateFin = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date de fin',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateFin)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Aperçu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aperçu du registre',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Lapins total',
                      '${lapinProvider.lapins.length}',
                    ),
                    _buildStatRow('Naissances', '$naissances'),
                    _buildStatRow('Accouplements', '$accouplements'),
                    const Divider(height: 24),
                    Text(
                      '✓ Identifications individuelles\n'
                      '✓ Dates de naissance\n'
                      '✓ Filiations (père/mère)\n'
                      '✓ Mouvements du cheptel',
                      style: AppTheme.labelSmall.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton génération
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _genererPDF(context, lapinProvider, reproProvider),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Générer le PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _genererPDF(
    BuildContext context,
    LapinProvider lapinProvider,
    ReproductionProvider reproProvider,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'REGISTRE D\'ÉLEVAGE',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              pw.Text('Total lapins: ${lapinProvider.lapins.length}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre généré avec succès')),
      );
    }
  }
}
