import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/pdf_app_theme.dart';

/// Certificat de vente officiel avec traçabilité complète
class CertificatVenteRapport extends StatefulWidget {
  const CertificatVenteRapport({super.key});

  @override
  State<CertificatVenteRapport> createState() => _CertificatVenteRapportState();
}

class _CertificatVenteRapportState extends State<CertificatVenteRapport> {
  Lapin? _lapinSelectionne;
  final _acheteurController = TextEditingController();
  final _montantController = TextEditingController();

  @override
  void dispose() {
    _acheteurController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LapinProvider>(
      builder: (context, lapinProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppLocalizations.of(context).titleSaleCertificate,
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<Lapin>(
              initialValue: _lapinSelectionne,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).labelRabbitToSell,
                prefixIcon: Icons.pets_rounded,
              ),
              items: lapinProvider.lapins.map((lapin) {
                return DropdownMenuItem(
                  value: lapin,
                  child: Text('${lapin.nom} - ${lapin.race}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _lapinSelectionne = value),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _acheteurController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).labelBuyerName,
                prefixIcon: Icons.person_rounded,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _montantController,
              decoration: AppTheme.inputDecoration(
                label: AppLocalizations.of(context).labelAmountEuro,
                prefixIcon: Icons.euro_rounded,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _lapinSelectionne != null &&
                            _acheteurController.text.isNotEmpty &&
                            _montantController.text.isNotEmpty
                        ? () => _genererPDF(context)
                        : null,
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(l10n.genererCertificat),
                    style: AppTheme.primaryButtonStyle,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _genererPDF(BuildContext context) async {
    if (_lapinSelectionne == null) return;

    final lapin = _lapinSelectionne!;
    final acheteur = _acheteurController.text;
    final montant = double.tryParse(_montantController.text) ?? 0.0;
    final dateVente = DateTime.now();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête officiel
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CERTIFICAT DE VENTE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfAppTheme.accentPurple900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Document officiel de traçabilité',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfAppTheme.neutral500700,
                      ),
                    ),
                    pw.Divider(
                      thickness: 2,
                      color: PdfAppTheme.accentPurple700,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Informations de vente
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfAppTheme.neutral500400,
                    width: 1.5,
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMATIONS DE VENTE',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Divider(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Date de vente:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(DateFormat('dd/MM/yyyy').format(dateVente)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Acheteur:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(acheteur),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Montant:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${NumberFormat('#,##0.00', 'fr_FR').format(montant)} €',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfAppTheme.success700,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Informations de l'animal
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfAppTheme.info50,
                  border: pw.Border.all(color: PdfAppTheme.info700, width: 1.5),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMATIONS DE L\'ANIMAL',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfAppTheme.info900,
                      ),
                    ),
                    pw.Divider(height: 16, color: PdfAppTheme.info700),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Nom:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(lapin.nom),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Race:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(lapin.race),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Sexe:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(lapin.sexe.label),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Date de naissance:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          DateFormat('dd/MM/yyyy').format(lapin.dateNaissance),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Âge:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${lapin.ageEnMois} mois'),
                      ],
                    ),
                    if (lapin.numeroIdentification != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'N° Puce/Tatouage:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(lapin.numeroIdentification!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              pw.Spacer(),

              // Mentions légales
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfAppTheme.neutral500100,
                  border: pw.Border.all(color: PdfAppTheme.neutral500400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Text(
                  'Ce certificat atteste de la vente de l\'animal mentionné ci-dessus. '
                  'Il garantit la traçabilité et l\'identification de l\'animal conformément à la réglementation en vigueur. '
                  'Document généré par BunnyManager le ${DateFormat('dd/MM/yyyy à HH:mm').format(dateVente)}.',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfAppTheme.neutral500700,
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
              ),

              pw.SizedBox(height: 20),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Signature du vendeur',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfAppTheme.neutral500700,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Signature de l\'acheteur',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfAppTheme.neutral500700,
                      ),
                    ],
                  ),
                ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgRapportGenere)),
      );
    }
  }
}
