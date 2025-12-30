import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../providers/reproduction_provider.dart';
import '../../../../providers/finance_provider.dart';
import '../../../../theme/app_theme.dart';

/// Bilan mensuel complet avec synthèse du mois
class BilanMensuelRapport extends StatefulWidget {
  const BilanMensuelRapport({super.key});

  @override
  State<BilanMensuelRapport> createState() => _BilanMensuelRapportState();
}

class _BilanMensuelRapportState extends State<BilanMensuelRapport> {
  int _moisSelectionne = DateTime.now().month;
  int _anneeSelectionnee = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Consumer3<LapinProvider, ReproductionProvider, FinanceProvider>(
      builder: (context, lapinProvider, reproProvider, financeProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Bilan mensuel complet',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Sélection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue:  _moisSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Mois',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          DateFormat('MMMM', 'fr_FR').format(DateTime(2024, m)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _moisSelectionne = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue:  _anneeSelectionnee,
                    decoration: const InputDecoration(
                      labelText: 'Année',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (i) => DateTime.now().year - i).map(
                      (y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _anneeSelectionnee = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _genererPDF(context),
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

  Future<void> _genererPDF(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'BILAN MENSUEL',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bilan généré')));
    }
  }
}
