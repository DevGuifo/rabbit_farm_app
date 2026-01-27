import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/enums/sexe.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../providers/reproduction_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/pdf_app_theme.dart';

/// Analyse détaillée des performances des reproducteurs
class PerformancesRapport extends StatelessWidget {
  const PerformancesRapport({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).titleRapportPerformances,
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Analyse détaillée des reproducteurs',
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
    final reproProvider = Provider.of<ReproductionProvider>(
      context,
      listen: false,
    );

    final reproducteurs = lapinProvider.lapins
        .where(
          (l) => l.sexe == Sexe.femelle,
        )
        .toList();

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
                    'RAPPORT DE PERFORMANCES',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfAppTheme.info900,
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

            // Statistiques globales
            pw.Text(
              'Vue d\'ensemble du cheptel',
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
                      child: pw.Text(l10n.pdfTotalRabbits),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${lapinProvider.lapins.length}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfBreedingFemales),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${reproducteurs.length}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfMatingRecorded),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${reproProvider.accouplements.length}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(l10n.pdfLittersRecorded),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${reproProvider.portees.length}'),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Top reproductrices
            pw.Text(
              'Top 5 des meilleures reproductrices',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            ...reproducteurs.take(5).map((lapin) {
              final accouplementsLapin = reproProvider.accouplements
                  .where((a) => a.femelleId == lapin.id)
                  .toList();
              final porteesLapin = reproProvider.portees
                  .where(
                    (p) =>
                        accouplementsLapin.any((a) => a.id == p.accouplementId),
                  )
                  .toList();
              final totalLapereaux = porteesLapin.fold<int>(
                0,
                (sum, p) => sum + p.nombreVivants,
              );

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfAppTheme.neutral500400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          lapin.nom,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Race: ${lapin.race}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfAppTheme.neutral500700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          '$totalLapereaux lapereaux',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfAppTheme.success700,
                          ),
                        ),
                        pw.Text(
                          '${porteesLapin.length} portées',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfAppTheme.neutral500700,
                          ),
                        ),
                      ],
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
