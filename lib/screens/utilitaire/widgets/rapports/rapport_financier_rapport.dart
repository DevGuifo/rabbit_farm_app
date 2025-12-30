import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../providers/finance_provider.dart';
import '../../../../theme/app_theme.dart';

/// Rapport financier avec comptabilité et résultats
class RapportFinancierRapport extends StatelessWidget {
  const RapportFinancierRapport({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Rapport Financier', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Comptabilité et résultats',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _genererPDF(context),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Générer le PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _genererPDF(BuildContext context) async {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );

    final totalRecettes = financeProvider.recettes.fold<double>(
      0,
      (sum, r) => sum + r.montant,
    );
    final totalDepenses = financeProvider.depenses.fold<double>(
      0,
      (sum, d) => sum + d.montant,
    );
    final benefice = totalRecettes - totalDepenses;

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
                    'RAPPORT FINANCIER',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Bilan global
            pw.Text(
              'Bilan Financier Global',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: benefice >= 0 ? PdfColors.green50 : PdfColors.red50,
                border: pw.Border.all(
                  color: benefice >= 0 ? PdfColors.green700 : PdfColors.red700,
                  width: 2,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Recettes',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${NumberFormat('#,##0.00', 'fr_FR').format(totalRecettes)} €',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.green700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Dépenses',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${NumberFormat('#,##0.00', 'fr_FR').format(totalDepenses)} €',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.red700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'BÉNÉFICE NET',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${NumberFormat('#,##0.00', 'fr_FR').format(benefice)} €',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: benefice >= 0
                              ? PdfColors.green900
                              : PdfColors.red900,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Dernières recettes
            pw.Text(
              'Dernières Recettes (10 dernières)',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...financeProvider.recettes.take(10).map((recette) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        recette.description,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Text(
                      '${NumberFormat('#,##0.00', 'fr_FR').format(recette.montant)} €',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 16),

            // Dernières dépenses
            pw.Text(
              'Dernières Dépenses (10 dernières)',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...financeProvider.depenses.take(10).map((depense) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${depense.categorie} - ${depense.description}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Text(
                      '${NumberFormat('#,##0.00', 'fr_FR').format(depense.montant)} €',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.red700,
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
        const SnackBar(content: Text('Rapport financier généré ✓')),
      );
    }
  }
}
