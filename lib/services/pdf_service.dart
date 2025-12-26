import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing_lib;
import 'package:intl/intl.dart';
import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/portee.dart';
import '../models/recette.dart';
import '../models/depense.dart';
import '../services/database_helper.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');
  final NumberFormat _formatMontant = NumberFormat.currency(
    symbol: '€',
    decimalDigits: 2,
    locale: 'fr_FR',
  );

  /// Générer la fiche complète d'un lapin
  Future<void> genererFicheLapin(Lapin lapin) async {
    final pdf = pw.Document();

    // Récupérer toutes les données du lapin
    final parents = await _getParents(lapin);
    final pesees = await _db.getPeseesByLapin(lapin.id!);
    final soins = await _db.getSoinsByLapin(lapin.id!);
    final recettes = await _db.getRecettesByLapin(lapin.id!);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            _buildHeader('Fiche individuelle', lapin.nom),
            pw.SizedBox(height: 20),

            // Informations générales
            _buildSection('Informations générales', [
              _buildInfoRow('Nom', lapin.nom),
              _buildInfoRow('Race', lapin.race),
              _buildInfoRow('Sexe', lapin.sexe == 'male' ? 'Mâle' : 'Femelle'),
              _buildInfoRow(
                'Date de naissance',
                _formatDate.format(lapin.dateNaissance),
              ),
              _buildInfoRow('Âge', _calculerAge(lapin.dateNaissance)),
              _buildInfoRow(
                'Poids actuel',
                lapin.poids != null
                    ? '${lapin.poids!.toStringAsFixed(2)} kg'
                    : 'Non pesé',
              ),
              _buildInfoRow('Statut', lapin.statut ?? 'Inconnu'),
              _buildInfoRow(
                'Localisation',
                lapin.localisation ?? 'Non spécifiée',
              ),
            ]),
            pw.SizedBox(height: 20),

            // Généalogie
            if (parents.isNotEmpty) ...[
              _buildSection('Généalogie', [
                if (parents['pere'] != null)
                  _buildInfoRow(
                    'Père',
                    '${parents['pere']!.nom} (${parents['pere']!.race})',
                  ),
                if (parents['mere'] != null)
                  _buildInfoRow(
                    'Mère',
                    '${parents['mere']!.nom} (${parents['mere']!.race})',
                  ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Historique des pesées
            if (pesees.isNotEmpty) ...[
              _buildSection('Historique des pesées', [
                _buildTable(
                  ['Date', 'Poids (kg)', 'Notes'],
                  pesees
                      .map(
                        (p) => [
                          _formatDate.format(p.date),
                          p.poids.toStringAsFixed(2),
                          p.notes ?? '-',
                        ],
                      )
                      .toList(),
                ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Historique des soins
            if (soins.isNotEmpty) ...[
              _buildSection('Historique des soins', [
                _buildTable(
                  ['Date', 'Type', 'Description'],
                  soins
                      .map(
                        (s) => [
                          _formatDate.format(s.date),
                          s.type,
                          s.description,
                        ],
                      )
                      .toList(),
                ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Recettes associées
            if (recettes.isNotEmpty) ...[
              _buildSection('Ventes', [
                _buildTable(
                  ['Date', 'Description', 'Montant'],
                  recettes
                      .map(
                        (r) => [
                          _formatDate.format(r.date),
                          r.description,
                          _formatMontant.format(r.montant),
                        ],
                      )
                      .toList(),
                ),
              ]),
            ],

            // Pied de page
            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name: 'fiche_${lapin.nom}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Générer un rapport financier
  Future<void> genererRapportFinancier({
    required DateTime debut,
    required DateTime fin,
    required List<Recette> recettes,
    required List<Depense> depenses,
  }) async {
    final pdf = pw.Document();

    final totalRecettes = recettes.fold(0.0, (sum, r) => sum + r.montant);
    final totalDepenses = depenses.fold(0.0, (sum, d) => sum + d.montant);
    final benefice = totalRecettes - totalDepenses;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            _buildHeader(
              'Rapport financier',
              'Du ${_formatDate.format(debut)} au ${_formatDate.format(fin)}',
            ),
            pw.SizedBox(height: 20),

            // Résumé
            _buildSection('Résumé', [
              _buildInfoRow(
                'Total recettes',
                _formatMontant.format(totalRecettes),
              ),
              _buildInfoRow(
                'Total dépenses',
                _formatMontant.format(totalDepenses),
              ),
              pw.Divider(thickness: 2),
              _buildInfoRow(
                'Bénéfice',
                _formatMontant.format(benefice),
                isBold: true,
              ),
            ]),
            pw.SizedBox(height: 20),

            // Détail des recettes
            if (recettes.isNotEmpty) ...[
              _buildSection('Détail des recettes', [
                _buildTable(
                  ['Date', 'Catégorie', 'Description', 'Montant'],
                  recettes
                      .map(
                        (r) => [
                          _formatDate.format(r.date),
                          _getNomCategorieRecette(r.categorie),
                          r.description,
                          _formatMontant.format(r.montant),
                        ],
                      )
                      .toList(),
                ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Détail des dépenses
            if (depenses.isNotEmpty) ...[
              _buildSection('Détail des dépenses', [
                _buildTable(
                  ['Date', 'Catégorie', 'Description', 'Montant'],
                  depenses
                      .map(
                        (d) => [
                          _formatDate.format(d.date),
                          _getNomCategorieDepense(d.categorie),
                          d.description,
                          _formatMontant.format(d.montant),
                        ],
                      )
                      .toList(),
                ),
              ]),
            ],

            // Pied de page
            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name: 'rapport_financier_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Générer un pedigree
  Future<void> genererPedigree(Lapin lapin) async {
    final pdf = pw.Document();

    // Récupérer l'arbre généalogique
    final arbre = await _construireArbreGenealogique(lapin, 4);

    pdf.addPage(
      pw.Page(
        pageFormat: pdf_lib.PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Pedigree', lapin.nom),
              pw.SizedBox(height: 20),
              pw.Expanded(child: _buildArbreGenealogique(arbre)),
              pw.SizedBox(height: 10),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name:
          'pedigree_${lapin.nom}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Générer un rapport de reproduction
  Future<void> genererRapportReproduction(
    List<Accouplement> accouplements,
    List<Portee> portees,
  ) async {
    final pdf = pw.Document();

    final nbAccouplements = accouplements.length;
    final nbPortees = portees.length;
    final nbTotalNes = portees.fold(0, (sum, p) => sum + p.nombreNes);
    final nbTotalVivants = portees.fold(0, (sum, p) => sum + p.nombreVivants);
    final tauxReussite = nbAccouplements > 0
        ? (nbPortees / nbAccouplements * 100)
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader('Rapport de reproduction', 'Statistiques globales'),
            pw.SizedBox(height: 20),

            // Statistiques
            _buildSection('Statistiques', [
              _buildInfoRow(
                'Nombre d\'accouplements',
                nbAccouplements.toString(),
              ),
              _buildInfoRow('Nombre de portées', nbPortees.toString()),
              _buildInfoRow(
                'Taux de réussite',
                '${tauxReussite.toStringAsFixed(1)}%',
              ),
              _buildInfoRow('Lapereaux nés (total)', nbTotalNes.toString()),
              _buildInfoRow('Lapereaux vivants', nbTotalVivants.toString()),
              if (nbPortees > 0)
                _buildInfoRow(
                  'Moyenne par portée',
                  (nbTotalVivants / nbPortees).toStringAsFixed(1),
                ),
            ]),
            pw.SizedBox(height: 20),

            // Liste des portées
            if (portees.isNotEmpty) ...[
              _buildSection('Détail des portées', [
                _buildTable(
                  ['Date mise bas', 'Nés', 'Vivants', 'Morts'],
                  portees
                      .map(
                        (p) => [
                          _formatDate.format(p.dateMiseBasReelle),
                          p.nombreNes.toString(),
                          p.nombreVivants.toString(),
                          p.nombreMorts.toString(),
                        ],
                      )
                      .toList(),
                ),
              ]),
            ],

            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name: 'rapport_reproduction_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ============= MÉTHODES UTILITAIRES =============

  pw.Widget _buildHeader(String titre, String sousTitre) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titre,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          sousTitre,
          style: const pw.TextStyle(
            fontSize: 14,
            color: pdf_lib.PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildSection(String titre, List<pw.Widget> contenu) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titre,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: pdf_lib.PdfColors.brown,
          ),
        ),
        pw.SizedBox(height: 10),
        ...contenu,
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String valeur, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              valeur,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTable(List<String> headers, List<List<String>> rows) {
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(
        color: pdf_lib.PdfColors.grey300,
      ),
      cellAlignment: pw.Alignment.centerLeft,
      headers: headers,
      data: rows,
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.Text(
          'Mon Élevage Lapins - Généré le ${_formatDate.format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 10,
            color: pdf_lib.PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildArbreGenealogique(Map<String, dynamic> arbre) {
    return pw.Center(child: pw.Text('Arbre généalogique - À implémenter'));
  }

  Future<Map<String, Lapin?>> _getParents(Lapin lapin) async {
    final parents = <String, Lapin?>{};

    final relations = await _db.getRelationByLapinId(lapin.id!);
    if (relations != null) {
      if (relations['pereId'] != null) {
        parents['pere'] = await _db.getLapinById(relations['pereId']!);
      }
      if (relations['mereId'] != null) {
        parents['mere'] = await _db.getLapinById(relations['mereId']!);
      }
    }

    return parents;
  }

  Future<Map<String, dynamic>> _construireArbreGenealogique(
    Lapin lapin,
    int profondeur,
  ) async {
    if (profondeur == 0) return {'lapin': lapin};

    final parents = await _getParents(lapin);
    final arbre = <String, dynamic>{'lapin': lapin};

    if (parents['pere'] != null) {
      arbre['pere'] = await _construireArbreGenealogique(
        parents['pere']!,
        profondeur - 1,
      );
    }
    if (parents['mere'] != null) {
      arbre['mere'] = await _construireArbreGenealogique(
        parents['mere']!,
        profondeur - 1,
      );
    }

    return arbre;
  }

  String _calculerAge(DateTime dateNaissance) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateNaissance);

    final annees = difference.inDays ~/ 365;
    final mois = (difference.inDays % 365) ~/ 30;

    if (annees > 0) {
      return '$annees an${annees > 1 ? 's' : ''} et $mois mois';
    }
    return '$mois mois';
  }

  String _getNomCategorieRecette(String categorie) {
    switch (categorie) {
      case 'vente_lapin':
        return 'Vente lapin';
      case 'vente_portee':
        return 'Vente portée';
      case 'autre':
        return 'Autre';
      default:
        return categorie;
    }
  }

  String _getNomCategorieDepense(String categorie) {
    switch (categorie) {
      case 'alimentation':
        return 'Alimentation';
      case 'veterinaire':
        return 'Vétérinaire';
      case 'equipement':
        return 'Équipement';
      case 'autre':
        return 'Autre';
      default:
        return categorie;
    }
  }
}
