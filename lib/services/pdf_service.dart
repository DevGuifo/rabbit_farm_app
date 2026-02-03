import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing_lib;
import 'package:intl/intl.dart';
import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/portee.dart';
import '../models/recette.dart';
import '../models/depense.dart';
import '../models/cage.dart';
import '../models/enums/sexe.dart';
import '../models/enums/type_soin.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');
  
  /// Fallback synchrone pour les contextes non-async (basé sur les préférences utilisateur)
  NumberFormat get _formatMontant => PreferencesService().getMoneyFormatterSync();

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
              _buildInfoRow(
                'Sexe',
                lapin.sexe == Sexe.male ? 'Mâle' : 'Femelle',
              ),
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
                          s.type.label,
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
                          r.categorie.label,
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
                          d.categorie.label,
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
    return pw.TableHelper.fromTextArray(
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
    final lapin = arbre['lapin'] as Lapin;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Lapin principal (génération 0)
        _buildLapinBox(lapin, isMainRabbit: true),
        pw.SizedBox(height: 20),

        // Parents (génération -1)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Expanded(
              child: arbre['pere'] != null
                  ? _buildParentSection(arbre['pere'], 'Père')
                  : _buildEmptyParent('Père inconnu'),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: arbre['mere'] != null
                  ? _buildParentSection(arbre['mere'], 'Mère')
                  : _buildEmptyParent('Mère inconnue'),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLapinBox(Lapin lapin, {bool isMainRabbit = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: isMainRabbit
              ? pdf_lib.PdfColors.brown
              : pdf_lib.PdfColors.grey,
          width: isMainRabbit ? 2 : 1,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: isMainRabbit
            ? pdf_lib.PdfColors.brown50
            : pdf_lib.PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lapin.nom,
            style: pw.TextStyle(
              fontSize: isMainRabbit ? 14 : 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            lapin.race,
            style: pw.TextStyle(
              fontSize: isMainRabbit ? 11 : 9,
              color: pdf_lib.PdfColors.grey700,
            ),
          ),
          pw.Text(
            lapin.sexe == Sexe.male ? 'Mâle' : 'Femelle',
            style: pw.TextStyle(
              fontSize: isMainRabbit ? 10 : 8,
              color: pdf_lib.PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildParentSection(Map<String, dynamic> arbre, String titre) {
    final lapin = arbre['lapin'] as Lapin;

    return pw.Column(
      children: [
        pw.Text(
          titre,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: pdf_lib.PdfColors.brown,
          ),
        ),
        pw.SizedBox(height: 5),
        _buildLapinBox(lapin),

        // Grands-parents
        if (arbre['pere'] != null || arbre['mere'] != null) ...[
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              if (arbre['pere'] != null)
                pw.Expanded(child: _buildGrandParentBox(arbre['pere']))
              else
                pw.Expanded(child: _buildEmptyParent('?')),
              pw.SizedBox(width: 5),
              if (arbre['mere'] != null)
                pw.Expanded(child: _buildGrandParentBox(arbre['mere']))
              else
                pw.Expanded(child: _buildEmptyParent('?')),
            ],
          ),
        ],
      ],
    );
  }

  pw.Widget _buildGrandParentBox(Map<String, dynamic> arbre) {
    final lapin = arbre['lapin'] as Lapin;

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pdf_lib.PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lapin.nom,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
          ),
          pw.Text(
            lapin.race,
            style: const pw.TextStyle(
              fontSize: 7,
              color: pdf_lib.PdfColors.grey600,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmptyParent(String texte) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pdf_lib.PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        color: pdf_lib.PdfColors.grey100,
      ),
      child: pw.Center(
        child: pw.Text(
          texte,
          style: const pw.TextStyle(
            fontSize: 8,
            color: pdf_lib.PdfColors.grey500,
          ),
        ),
      ),
    );
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

  /// Générer un rapport bilan sanitaire
  Future<void> genererRapportBilanSanitaire({
    DateTime? debut,
    DateTime? fin,
  }) async {
    final pdf = pw.Document();
    final periode = debut != null && fin != null
        ? '${_formatDate.format(debut)} - ${_formatDate.format(fin)}'
        : 'Toutes périodes';

    // Récupérer données
    final lapins = await _db.getAllLapins();
    final soins = debut != null && fin != null
        ? await _db.getSoinsByPeriode(debut, fin)
        : await _db.getAllSoins();
    final deces = debut != null && fin != null
        ? await _db.getDecesByPeriode(debut, fin)
        : await _db.getAllDeces();

    // Statistiques
    final nbVaccinations = soins
        .where((s) => s.type == TypeSoin.vaccination)
        .length;
    final nbTraitements = soins
        .where((s) => s.type == TypeSoin.traitement)
        .length;
    final nbConsultations = soins.where((s) => s.type == TypeSoin.autre).length;
    final nbDeces = deces.length;
    final tauxMortalite = lapins.isNotEmpty
        ? (nbDeces / lapins.length) * 100
        : 0.0;

    // Répartition par type de soin
    final repartitionSoins = <String, int>{};
    for (final soin in soins) {
      repartitionSoins[soin.type.label] =
          (repartitionSoins[soin.type.label] ?? 0) + 1;
    }

    // Causes de décès
    final causesDeces = <String, int>{};
    for (final deces in deces) {
      causesDeces[deces.cause] = (causesDeces[deces.cause] ?? 0) + 1;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader('Bilan sanitaire', periode),
            pw.SizedBox(height: 20),

            // Statistiques globales
            _buildSection('Statistiques globales', [
              _buildInfoRow('Nombre de lapins', '${lapins.length}'),
              _buildInfoRow('Vaccinations', '$nbVaccinations'),
              _buildInfoRow('Traitements', '$nbTraitements'),
              _buildInfoRow('Consultations', '$nbConsultations'),
              _buildInfoRow('Décès', '$nbDeces'),
              _buildInfoRow(
                'Taux de mortalité',
                '${tauxMortalite.toStringAsFixed(2)}%',
              ),
            ]),
            pw.SizedBox(height: 20),

            // Répartition des soins
            if (repartitionSoins.isNotEmpty) ...[
              _buildSection('Répartition des soins', [
                ...repartitionSoins.entries.map(
                  (e) => _buildInfoRow(e.key, '${e.value}'),
                ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Causes de décès
            if (causesDeces.isNotEmpty) ...[
              _buildSection('Causes de décès', [
                ...causesDeces.entries.map(
                  (e) => _buildInfoRow(e.key, '${e.value}'),
                ),
              ]),
              pw.SizedBox(height: 20),
            ],

            // Tableau des soins récents
            if (soins.isNotEmpty) ...[
              _buildSection('Soins récents', [
                _buildTable(
                  ['Date', 'Lapin', 'Type', 'Description'],
                  soins.take(20).map((s) {
                    final lapin = lapins.firstWhere(
                      (l) => l.id == s.lapinId,
                      orElse: () => Lapin(
                        nom: 'Inconnu',
                        race: '',
                        sexe: Sexe.inconnu,
                        dateNaissance: DateTime.now(),
                      ),
                    );
                    return [
                      _formatDate.format(s.date),
                      lapin.nom,
                      s.type.label,
                      s.description,
                    ];
                  }).toList(),
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
      name: 'bilan_sanitaire_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Générer un rapport d'analyse génétique
  Future<void> genererRapportAnalyseGenetique() async {
    final pdf = pw.Document();
    final lapins = await _db.getAllLapins();

    // Calculer consanguinité pour tous les lapins
    final analyses = <Map<String, dynamic>>[];

    for (final lapin in lapins) {
      if (lapin.id == null) continue;

      try {
        final consanguinite = await _db.calculerConsanguinite(lapin.id!);
        final parents = await _db.getParents(lapin.id!);

        analyses.add({
          'lapin': lapin,
          'consanguinite': consanguinite,
          'parents': parents,
        });
      } catch (e) {
        // Ignorer les erreurs de calcul
        continue;
      }
    }

    // Trier par consanguinité décroissante
    analyses.sort(
      (a, b) => (b['consanguinite'] as double).compareTo(
        a['consanguinite'] as double,
      ),
    );

    // Statistiques
    final moyenneConsanguinite = analyses.isNotEmpty
        ? analyses
                  .map((a) => a['consanguinite'] as double)
                  .reduce((a, b) => a + b) /
              analyses.length
        : 0.0;
    final maxConsanguinite = analyses.isNotEmpty
        ? analyses.first['consanguinite'] as double
        : 0.0;
    final nbElevage = analyses
        .where((a) => (a['consanguinite'] as double) > 0.25)
        .length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader('Analyse génétique', 'Consanguinité du cheptel'),
            pw.SizedBox(height: 20),

            // Statistiques
            _buildSection('Statistiques', [
              _buildInfoRow('Nombre de lapins analysés', '${analyses.length}'),
              _buildInfoRow(
                'Consanguinité moyenne',
                '${(moyenneConsanguinite * 100).toStringAsFixed(2)}%',
              ),
              _buildInfoRow(
                'Consanguinité maximale',
                '${(maxConsanguinite * 100).toStringAsFixed(2)}%',
              ),
              _buildInfoRow('Lapins avec consanguinité > 25%', '$nbElevage'),
            ]),
            pw.SizedBox(height: 20),

            // Tableau des lapins
            _buildSection('Détail par lapin', [
              _buildTable(
                ['Nom', 'Race', 'Consanguinité', 'Père', 'Mère'],
                analyses.map((a) {
                  final lapin = a['lapin'] as Lapin;
                  final consanguinite = a['consanguinite'] as double;
                  final parents = a['parents'] as Map<String, Lapin?>;

                  return [
                    lapin.nom,
                    lapin.race,
                    '${(consanguinite * 100).toStringAsFixed(1)}%',
                    parents['pere']?.nom ?? '-',
                    parents['mere']?.nom ?? '-',
                  ];
                }).toList(),
              ),
            ]),

            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name: 'analyse_genetique_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
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

  /// Générer une carte de cage avec QR code
  Future<void> genererCarteCage(Cage cage) async {
    final pdf = pw.Document();

    // Récupérer les informations de la cage via l'extension LocalisationExtension
    final clapier = await _db.getClapierById(cage.clapierId);
    final batiment = clapier != null
        ? await _db.getBatimentById(clapier.batimentId)
        : null;
    final occupants = await _db.getOccupantsCage(cage.id!);
    final lapins = await _db.getAllLapins();
    final lapinsDansCage = lapins
        .where((l) => l.localisation == cage.numero)
        .toList();

    // Données pour le QR code (sera scannable via le texte)
    final qrData = 'CAGE:${cage.id}';

    pdf.addPage(
      pw.Page(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CARTE DE CAGE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'BunnyManager',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: pdf_lib.PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  // QR Code - Afficher le texte pour l'instant (sera amélioré avec génération d'image)
                  pw.Container(
                    width: 100,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: pdf_lib.PdfColors.black,
                        width: 2,
                      ),
                      color: pdf_lib.PdfColors.white,
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'QR',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            qrData,
                            style: const pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Informations de la cage
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: pdf_lib.PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informations de la cage',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildInfoRowCage('Numéro', cage.numero),
                    if (batiment != null)
                      _buildInfoRowCage('Bâtiment', batiment.nom),
                    if (clapier != null)
                      _buildInfoRowCage('Clapier', clapier.nom),
                    _buildInfoRowCage('Type', cage.type.label),
                    _buildInfoRowCage('Capacité', '${cage.capacite} lapin(s)'),
                    _buildInfoRowCage(
                      'Occupants',
                      '$occupants / ${cage.capacite}',
                    ),
                    _buildInfoRowCage('Statut', cage.getStatut(occupants)),
                    if (cage.description != null &&
                        cage.description!.isNotEmpty)
                      _buildInfoRowCage('Description', cage.description!),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Liste des lapins dans la cage
              if (lapinsDansCage.isNotEmpty) ...[
                pw.Text(
                  'Lapins dans la cage',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: pdf_lib.PdfColors.grey300),
                  children: [
                    // En-tête
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: pdf_lib.PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell('Nom', isHeader: true),
                        _buildTableCell('Race', isHeader: true),
                        _buildTableCell('Sexe', isHeader: true),
                        _buildTableCell('Âge', isHeader: true),
                      ],
                    ),
                    // Données
                    ...lapinsDansCage.map((lapin) {
                      final age = DateTime.now()
                          .difference(lapin.dateNaissance)
                          .inDays;
                      return pw.TableRow(
                        children: [
                          _buildTableCell(lapin.nom),
                          _buildTableCell(lapin.race),
                          _buildTableCell(lapin.sexe.label),
                          _buildTableCell('${age ~/ 30} mois'),
                        ],
                      );
                    }),
                  ],
                ),
              ],

              pw.Spacer(),

              // Pied de page
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Généré le ${_formatDate.format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: pdf_lib.PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Scannez le QR code pour accéder rapidement à cette cage',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: pdf_lib.PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    await printing_lib.Printing.layoutPdf(
      onLayout: (pdf_lib.PdfPageFormat format) async => pdf.save(),
      name:
          'carte_cage_${cage.numero}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _buildInfoRowCage(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
