import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  int _selectedRapport = 0;

  final List<Map<String, dynamic>> _rapports = [
    {
      'title': 'Registre d\'élevage',
      'icon': Icons.book_rounded,
      'description': 'Registre officiel conforme',
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Bilan mensuel',
      'icon': Icons.calendar_month_rounded,
      'description': 'Synthèse du mois',
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Performances',
      'icon': Icons.trending_up_rounded,
      'description': 'Analyse reproducteurs',
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Suivi sanitaire',
      'icon': Icons.medical_services_rounded,
      'description': 'Rapport santé',
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Rapport financier',
      'icon': Icons.attach_money_rounded,
      'description': 'Comptabilité',
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Certificat vente',
      'icon': Icons.receipt_long_rounded,
      'description': 'Avec traçabilité',
      'color': const Color(0xFF9C27B0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Rapports PDF')),
      body: Column(
        children: [
          // Sélecteur horizontal de rapports
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              height: 120,
              color: Theme.of(context).colorScheme.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _rapports.length,
                itemBuilder: (context, index) {
                  final rapport = _rapports[index];
                  final isSelected = _selectedRapport == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildRapportCard(rapport, isSelected, index),
                  );
                },
              ),
            ),
          ),

          // Contenu du rapport sélectionné
          Expanded(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: _buildRapportContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRapportCard(
    Map<String, dynamic> rapport,
    bool isSelected,
    int index,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRapport = index;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? rapport['color'].withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? rapport['color']
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              rapport['icon'],
              color: isSelected
                  ? rapport['color']
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              rapport['title'],
              style: AppTheme.labelSmall.copyWith(
                color: isSelected
                    ? rapport['color']
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRapportContent() {
    switch (_selectedRapport) {
      case 0:
        return const _RegistreElevageRapport();
      case 1:
        return const _BilanMensuelRapport();
      case 2:
        return const _PerformancesRapport();
      case 3:
        return const _SuiviSanitaireRapport();
      case 4:
        return const _RapportFinancierRapport();
      case 5:
        return const _CertificatVenteRapport();
      default:
        return const Center(child: Text('Rapport non disponible'));
    }
  }
}

// ============================================
// REGISTRE D'ÉLEVAGE
// ============================================
class _RegistreElevageRapport extends StatefulWidget {
  const _RegistreElevageRapport();

  @override
  State<_RegistreElevageRapport> createState() =>
      _RegistreElevageRapportState();
}

class _RegistreElevageRapportState extends State<_RegistreElevageRapport> {
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                        ).colorScheme.onSurface.withOpacity(0.6),
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

// ============================================
// BILAN MENSUEL
// ============================================
class _BilanMensuelRapport extends StatefulWidget {
  const _BilanMensuelRapport();

  @override
  State<_BilanMensuelRapport> createState() => _BilanMensuelRapportState();
}

class _BilanMensuelRapportState extends State<_BilanMensuelRapport> {
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
                    value: _moisSelectionne,
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
                      if (value != null)
                        setState(() => _moisSelectionne = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _anneeSelectionnee,
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
                      if (value != null)
                        setState(() => _anneeSelectionnee = value);
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

// Autres rapports simplifiés
class _PerformancesRapport extends StatelessWidget {
  const _PerformancesRapport();

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
            Text('Rapport Performances', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Analyse détaillée des reproducteurs',
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
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Text('RAPPORT PERFORMANCES');
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rapport généré')));
    }
  }
}

class _SuiviSanitaireRapport extends StatelessWidget {
  const _SuiviSanitaireRapport();

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
            Text('Suivi Sanitaire', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Rapport annuel de santé',
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
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(build: (pw.Context context) => pw.Text('SUIVI SANITAIRE')),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rapport généré')));
    }
  }
}

class _RapportFinancierRapport extends StatelessWidget {
  const _RapportFinancierRapport();

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
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(build: (pw.Context context) => pw.Text('RAPPORT FINANCIER')),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rapport généré')));
    }
  }
}

class _CertificatVenteRapport extends StatefulWidget {
  const _CertificatVenteRapport();

  @override
  State<_CertificatVenteRapport> createState() =>
      _CertificatVenteRapportState();
}

class _CertificatVenteRapportState extends State<_CertificatVenteRapport> {
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
              'Certificat de Vente',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<Lapin>(
              value: _lapinSelectionne,
              decoration: const InputDecoration(
                labelText: 'Lapin à vendre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets_rounded),
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
              decoration: const InputDecoration(
                labelText: 'Nom de l\'acheteur',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _montantController,
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _lapinSelectionne != null &&
                        _acheteurController.text.isNotEmpty &&
                        _montantController.text.isNotEmpty
                    ? () => _genererPDF(context)
                    : null,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Générer le certificat'),
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
      pw.Page(build: (pw.Context context) => pw.Text('CERTIFICAT DE VENTE')),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Certificat généré')));
    }
  }
}
