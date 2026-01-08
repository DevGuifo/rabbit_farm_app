import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../providers/sante_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/pdf_app_theme.dart';

/// Rapport annuel de suivi sanitaire du cheptel
class SuiviSanitaireRapport extends StatelessWidget {
  const SuiviSanitaireRapport({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).titleSuiviSanitaire,
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Rapport annuel de santé',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return ElevatedButton.icon(
                  onPressed: () => _genererPDF(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(l10n.genererPdf),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _genererPDF(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RAPPORT DE SUIVI SANITAIRE',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfAppTheme.accentPink900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfAppTheme.neutral500700,
                    ),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Statistiques sanitaires globales
            pw.Text(
              'Vue d\'ensemble sanitaire',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfAppTheme.neutral500400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfAppTheme.neutral500300,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Indicateur',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Valeur',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfCarePerformed),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${santeProvider.soins.length}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfWeighingsRecorded),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${santeProvider.pesees.length}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfActiveRabbits),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${lapinProvider.lapins.length}'),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Soins récents
            pw.Text(
              'Derniers soins effectués (15 derniers)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            ...santeProvider.soins.take(15).map((soin) {
              final lapin = lapinProvider.lapins.firstWhere(
                (l) => l.id == soin.lapinId,
                orElse: () => lapinProvider.lapins.first,
              );

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfAppTheme.neutral500300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            lapin.nom,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          pw.Text(
                            soin.type,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfAppTheme.neutral500700,
                            ),
                          ),
                          if (soin.notes != null && soin.notes!.isNotEmpty)
                            pw.Text(
                              soin.notes!,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfAppTheme.neutral500600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy').format(soin.date),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfAppTheme.neutral500700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgRapportGenere)),
      );
    }
  }
}
