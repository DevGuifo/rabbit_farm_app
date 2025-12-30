import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart' hide Border;
import '../../models/accouplement.dart';
import '../../models/recette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive_io.dart';
import '../../services/database_helper.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/logger.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';
import 'widgets/export_options_section.dart';
import 'widgets/import_options_section.dart';
import 'widgets/backup_info_card.dart';
import 'widgets/backup_tips_card.dart';
import 'widgets/progress_section.dart';
import 'widgets/migration_format_dialog.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastBackupPath;
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _loadLastBackupInfo();
  }

  Future<void> _loadLastBackupInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupPath = prefs.getString('last_backup_path');
      final lastBackupTimestamp = prefs.getInt('last_backup_timestamp');

      if (lastBackupPath != null && lastBackupTimestamp != null) {
        setState(() {
          _lastBackupPath = lastBackupPath;
          _lastBackupDate = DateTime.fromMillisecondsSinceEpoch(
            lastBackupTimestamp,
          );
        });
        logger.debug('Dernière sauvegarde chargée: $_lastBackupPath');
      }
    } catch (e) {
      logger.error('Erreur lors du chargement des infos de sauvegarde', e);
    }
  }

  Future<void> _saveLastBackupInfo(String path, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_path', path);
      await prefs.setInt('last_backup_timestamp', date.millisecondsSinceEpoch);

      setState(() {
        _lastBackupPath = path;
        _lastBackupDate = date;
      });

      logger.info('Informations de sauvegarde enregistrées');
    } catch (e) {
      logger.error('Erreur lors de la sauvegarde des infos de backup', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export / Import'),
        backgroundColor: AppTheme.accentPink,
        foregroundColor: AppTheme.textLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  size: 32,
                  color: AppTheme.accentPink,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sauvegarde & Restauration',
                  style: AppTheme.titleLarge.copyWith(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sécurisez vos données et restaurez-les facilement',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            BackupInfoCard(
              backupPath: _lastBackupPath,
              backupDate: _lastBackupDate,
              onShare: _shareBackup,
            ),
            if (_lastBackupDate != null) const SizedBox(height: 24),
            ExportOptionsSection(
              onExportDatabase: _exportSauvegardeComplete,
              onExportExcel: _exportExcel,
              onExportJson: _exportJSON,
              onExportCsv: _exportCsv,
              isExporting: _isExporting,
            ),
            const SizedBox(height: 32),
            ImportOptionsSection(
              onImportDatabase: _importSauvegarde,
              onImportExcel: _importExcel,
              onImportJson: _migrationAutreApp,
              isImporting: _isImporting,
            ),
            const SizedBox(height: 32),
            const BackupTipsCard(),
            ProgressSection(
              isExporting: _isExporting,
              isImporting: _isImporting,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareBackup() async {
    if (_lastBackupPath != null) {
      await Share.shareXFiles([
        XFile(_lastBackupPath!),
      ], subject: 'Sauvegarde BunnyManager');
    }
  }

  // ============================================
  // MÉTHODES EXPORT
  // ============================================

  Future<void> _exportSauvegardeComplete() async {
    setState(() => _isExporting = true);

    try {
      // 1. Obtenir le chemin de la base de données
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      final dbPath = db.path;

      // 2. Créer un dossier temporaire pour la sauvegarde
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupDir = Directory('${tempDir.path}/backup_$timestamp');
      await backupDir.create(recursive: true);

      // 3. Copier la base de données
      final dbFile = File(dbPath);
      final dbBackupPath = '${backupDir.path}/database.db';
      await dbFile.copy(dbBackupPath);

      // 4. Copier les photos (si elles existent)
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      if (await photosDir.exists()) {
        final photosBackupDir = Directory('${backupDir.path}/photos');
        await photosBackupDir.create();

        await for (final entity in photosDir.list()) {
          if (entity is File) {
            final fileName = p.basename(entity.path);
            await entity.copy('${photosBackupDir.path}/$fileName');
          }
        }
      }

      // 5. Créer un fichier d'information
      final infoFile = File('${backupDir.path}/backup_info.txt');
      await infoFile.writeAsString(
        'BunnyManager Backup\n'
        'Date: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}\n'
        'Version: 1.0\n'
        'Database: ${p.basename(dbPath)}\n',
      );

      // 6. Compresser le tout en ZIP
      logger.info('Création de l\'archive ZIP...');
      final zipPath = '${tempDir.path}/BunnyManager_backup_$timestamp.zip';
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);

      // Ajouter tous les fichiers du dossier de backup
      encoder.addDirectory(backupDir);
      encoder.close();

      logger.info('Archive ZIP créée: $zipPath');

      // 7. Partager l'archive ZIP
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Sauvegarde BunnyManager - $timestamp',
        text: 'Sauvegarde complète de vos données d\'élevage (format ZIP)',
      );

      // 8. Sauvegarder les infos de backup
      await _saveLastBackupInfo(zipPath, DateTime.now());

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✅ Sauvegarde complète créée avec succès (ZIP)',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur lors de la sauvegarde: $e');
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _isExporting = true);

    try {
      final db = DatabaseHelper.instance;
      final excel = Excel.createExcel();

      // Sheet Lapins
      final lapinsSheet = excel['Lapins'];
      lapinsSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Nom'),
        TextCellValue('Race'),
        TextCellValue('Sexe'),
        TextCellValue('Date Naissance'),
        TextCellValue('Statut'),
      ]);

      final lapins = await db.getAllLapins();
      for (var lapin in lapins) {
        lapinsSheet.appendRow([
          IntCellValue(lapin.id ?? 0),
          TextCellValue(lapin.nom),
          TextCellValue(lapin.race),
          TextCellValue(lapin.sexe),
          TextCellValue(DateFormat('dd/MM/yyyy').format(lapin.dateNaissance)),
          TextCellValue(lapin.statut ?? ''),
        ]);
      }

      // Sheet Accouplements
      final accouplSheet = excel['Accouplements'];
      accouplSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Mâle ID'),
        TextCellValue('Femelle ID'),
        TextCellValue('Date'),
        TextCellValue('Statut'),
      ]);

      final accouplements = await db.getAllAccouplements();
      for (var acc in accouplements) {
        accouplSheet.appendRow([
          IntCellValue(acc.id ?? 0),
          IntCellValue(acc.maleId),
          IntCellValue(acc.femelleId),
          TextCellValue(DateFormat('dd/MM/yyyy').format(acc.dateAccouplement)),
          TextCellValue(acc.statut),
        ]);
      }

      // Sheet Recettes
      final recettesSheet = excel['Recettes'];
      recettesSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Montant'),
        TextCellValue('Catégorie'),
        TextCellValue('Date'),
      ]);

      final recettes = await db.getAllRecettes();
      for (var r in recettes) {
        recettesSheet.appendRow([
          IntCellValue(r.id ?? 0),
          DoubleCellValue(r.montant),
          TextCellValue(r.categorie),
          TextCellValue(DateFormat('dd/MM/yyyy').format(r.date)),
        ]);
      }

      // Sheet Dépenses
      final depensesSheet = excel['Depenses'];
      depensesSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Montant'),
        TextCellValue('Catégorie'),
        TextCellValue('Date'),
      ]);

      final depenses = await db.getAllDepenses();
      for (var d in depenses) {
        depensesSheet.appendRow([
          IntCellValue(d.id ?? 0),
          DoubleCellValue(d.montant),
          TextCellValue(d.categorie),
          TextCellValue(DateFormat('dd/MM/yyyy').format(d.date)),
        ]);
      }

      // Supprimer la sheet par défaut
      excel.delete('Sheet1');

      // Sauvegarder
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'elevage_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = p.join(directory.path, fileName);
      final fileBytes = excel.encode();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      // Partager
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Export Excel de l\'\u00e9levage');

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✅ Export Excel réussi : $fileName',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur: $e');
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);

    try {
      final db = DatabaseHelper.instance;

      // Créer un fichier CSV avec toutes les données
      final csvLines = <String>[];

      // En-tête
      csvLines.add('=== EXPORT BUNNYMANAGER ===');
      csvLines.add(
        'Date export: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
      );
      csvLines.add('');

      // 1. LAPINS
      csvLines.add('=== LAPINS ===');
      csvLines.add(
        'ID,Nom,Race,Sexe,Date Naissance,Poids,Statut,Localisation,Numéro Identification,Couleur',
      );
      final lapins = await db.getAllLapins();
      for (final lapin in lapins) {
        csvLines.add(
          [
            lapin.id?.toString() ?? '',
            _escapeCsv(lapin.nom),
            _escapeCsv(lapin.race),
            _escapeCsv(lapin.sexe),
            DateFormat('yyyy-MM-dd').format(lapin.dateNaissance),
            lapin.poids?.toString() ?? '',
            lapin.statut ?? '',
            lapin.localisation ?? '',
            lapin.numeroIdentification ?? '',
            lapin.couleur ?? '',
          ].join(','),
        );
      }
      csvLines.add('');

      // 2. ACCOUPLEMENTS
      csvLines.add('=== ACCOUPLEMENTS ===');
      csvLines.add(
        'ID,Mâle ID,Mâle Nom,Femelle ID,Femelle Nom,Date Accouplement,Date Mise Bas Prévue,Statut',
      );
      final accouplements = await db.getAllAccouplements();
      for (final acc in accouplements) {
        final male = await db.getLapinById(acc.maleId);
        final femelle = await db.getLapinById(acc.femelleId);
        csvLines.add(
          [
            acc.id?.toString() ?? '',
            acc.maleId.toString(),
            _escapeCsv(male?.nom ?? 'Inconnu'),
            acc.femelleId.toString(),
            _escapeCsv(femelle?.nom ?? 'Inconnu'),
            DateFormat('yyyy-MM-dd').format(acc.dateAccouplement),
            DateFormat('yyyy-MM-dd').format(acc.dateMiseBasPrevue),
            _escapeCsv(acc.statut),
          ].join(','),
        );
      }
      csvLines.add('');

      // 3. PORTÉES
      csvLines.add('=== PORTÉES ===');
      csvLines.add('ID,Accouplement ID,Date Mise Bas,Nés,Vivants,Morts');
      final portees = await db.getAllPortees();
      for (final portee in portees) {
        csvLines.add(
          [
            portee.id?.toString() ?? '',
            portee.accouplementId.toString(),
            DateFormat('yyyy-MM-dd').format(portee.dateMiseBasReelle),
            portee.nombreNes.toString(),
            portee.nombreVivants.toString(),
            portee.nombreMorts.toString(),
          ].join(','),
        );
      }
      csvLines.add('');

      // 4. PESÉES
      csvLines.add('=== PESÉES ===');
      csvLines.add('ID,Lapin ID,Lapin Nom,Date,Poids,Notes');
      final pesees = await db.getAllPesees();
      for (final pesee in pesees) {
        final lapin = await db.getLapinById(pesee.lapinId);
        csvLines.add(
          [
            pesee.id?.toString() ?? '',
            pesee.lapinId.toString(),
            _escapeCsv(lapin?.nom ?? 'Inconnu'),
            DateFormat('yyyy-MM-dd').format(pesee.date),
            pesee.poids.toString(),
            _escapeCsv(pesee.notes ?? ''),
          ].join(','),
        );
      }
      csvLines.add('');

      // 5. SOINS
      csvLines.add('=== SOINS ===');
      csvLines.add(
        'ID,Lapin ID,Lapin Nom,Date,Type,Description,Médicament,Dosage',
      );
      final soins = await db.getAllSoins();
      for (final soin in soins) {
        final lapin = await db.getLapinById(soin.lapinId);
        csvLines.add(
          [
            soin.id?.toString() ?? '',
            soin.lapinId.toString(),
            _escapeCsv(lapin?.nom ?? 'Inconnu'),
            DateFormat('yyyy-MM-dd').format(soin.date),
            _escapeCsv(soin.type),
            _escapeCsv(soin.description),
            _escapeCsv(soin.medicament ?? ''),
            _escapeCsv(soin.dosage ?? ''),
          ].join(','),
        );
      }
      csvLines.add('');

      // 6. RECETTES
      csvLines.add('=== RECETTES ===');
      csvLines.add('ID,Date,Catégorie,Montant,Description,Lapin ID');
      final recettes = await db.getAllRecettes();
      for (final recette in recettes) {
        csvLines.add(
          [
            recette.id?.toString() ?? '',
            DateFormat('yyyy-MM-dd').format(recette.date),
            _escapeCsv(recette.categorie),
            recette.montant.toString(),
            _escapeCsv(recette.description),
            recette.lapinId?.toString() ?? '',
          ].join(','),
        );
      }
      csvLines.add('');

      // 7. DÉPENSES
      csvLines.add('=== DÉPENSES ===');
      csvLines.add('ID,Date,Catégorie,Montant,Description');
      final depenses = await db.getAllDepenses();
      for (final depense in depenses) {
        csvLines.add(
          [
            depense.id?.toString() ?? '',
            DateFormat('yyyy-MM-dd').format(depense.date),
            _escapeCsv(depense.categorie),
            depense.montant.toString(),
            _escapeCsv(depense.description),
          ].join(','),
        );
      }

      // Sauvegarder le fichier
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'elevage_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsString(csvLines.join('\n'), encoding: utf8);

      // Partager
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Export CSV complet de l\'élevage');

      if (mounted) {
        SnackbarHelper.showSuccess(context, '✅ Export CSV réussi : $fileName');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur: $e');
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  /// Échapper les caractères spéciaux pour CSV
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> _exportJSON() async {
    setState(() => _isExporting = true);

    try {
      final db = DatabaseHelper.instance;
      final data = <String, dynamic>{
        'version': '1.0',
        'dateExport': DateTime.now().toIso8601String(),
        'lapins': (await db.getAllLapins()).map((l) => l.toMap()).toList(),
        'accouplements': (await db.getAllAccouplements())
            .map((a) => a.toMap())
            .toList(),
        'portees': (await db.getAllPortees()).map((p) => p.toMap()).toList(),
        'pesees': (await db.getAllPesees()).map((p) => p.toMap()).toList(),
        'soins': (await db.getAllSoins()).map((s) => s.toMap()).toList(),
        'recettes': (await db.getAllRecettes()).map((r) => r.toMap()).toList(),
        'depenses': (await db.getAllDepenses()).map((d) => d.toMap()).toList(),
      };

      // Convertir en JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Sauvegarder
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'elevage_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Partager
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Export JSON de l\'\u00e9levage');

      if (mounted) {
        SnackbarHelper.showSuccess(context, '✅ Export JSON réussi : $fileName');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur: $e');
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  // ============================================
  // MÉTHODES IMPORT
  // ============================================

  Future<void> _importSauvegarde() async {
    // Confirmation avant restauration
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Attention !',
      message:
          'La restauration va remplacer TOUTES vos données actuelles '
          'par celles de la sauvegarde.\n\n'
          'Cette action est IRRÉVERSIBLE.\n\n'
          'Voulez-vous continuer ?',
      confirmLabel: 'Restaurer',
      isDangerous: true,
      icon: Icons.warning,
    );

    if (confirm != true) return;

    setState(() => _isImporting = true);

    try {
      // Sélectionner le fichier de sauvegarde
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          SnackbarHelper.showInfo(context, 'Aucun fichier sélectionné');
        }
        return;
      }

      final sourceFile = File(result.files.single.path!);

      // Obtenir le chemin de la DB actuelle
      final dbDirectory = await getDatabasesPath();
      final dbPath = p.join(dbDirectory, 'mon_elevage_lapins.db');
      final dbFile = File(dbPath);

      // Faire une sauvegarde de sécurité avant restauration
      final directory = await getApplicationDocumentsDirectory();
      final backupPath = p.join(
        directory.path,
        'backup_before_restore_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db',
      );
      await dbFile.copy(backupPath);

      // Remplacer la DB
      await sourceFile.copy(dbPath);

      // Recharger tous les providers
      if (mounted) {
        await Future.wait([
          Provider.of<LapinProvider>(context, listen: false).chargerLapins(),
          Provider.of<ReproductionProvider>(
            context,
            listen: false,
          ).chargerTout(),
          Provider.of<SanteProvider>(context, listen: false).chargerTout(),
          Provider.of<FinanceProvider>(context, listen: false).chargerTout(),
        ]);
      }

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✅ Restauration réussie et données rechargées !',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur: $e');
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importExcel() async {
    setState(() => _isImporting = true);

    try {
      // Sélectionner le fichier Excel
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          SnackbarHelper.showInfo(context, 'Aucun fichier sélectionné');
        }
        setState(() => _isImporting = false);
        return;
      }

      final filePath = result.files.single.path!;
      final bytes = await File(filePath).readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Impossible de lire le fichier');
      }

      final excel = Excel.decodeBytes(bytes);
      int importCount = 0;
      int erreurs = 0;
      final List<String> erreursDetails = [];

      final db = DatabaseHelper.instance;

      // Importer les lapins si la sheet existe
      if (excel.sheets.containsKey('Lapins')) {
        final lapinsSheet = excel.sheets['Lapins']!;
        if (lapinsSheet.rows.length < 2) {
          throw Exception('Sheet "Lapins" vide ou invalide');
        }

        // Vérifier les en-têtes
        final headers = lapinsSheet.rows[0];
        if (headers.length < 6) {
          throw Exception(
            'Format invalide : colonnes manquantes dans "Lapins"',
          );
        }

        // Ignorer la première ligne (en-têtes)
        for (var i = 1; i < lapinsSheet.rows.length; i++) {
          final row = lapinsSheet.rows[i];
          if (row.isEmpty || row.length < 6) continue;

          try {
            // Extraire et valider les données
            final nom = _getCellValue(row[1])?.toString().trim() ?? '';
            if (nom.isEmpty) {
              erreurs++;
              erreursDetails.add('Ligne ${i + 1}: Nom manquant');
              continue;
            }

            final race = _getCellValue(row[2])?.toString().trim() ?? '';
            if (race.isEmpty) {
              erreurs++;
              erreursDetails.add('Ligne ${i + 1}: Race manquante');
              continue;
            }

            final sexeStr =
                _getCellValue(row[3])?.toString().trim().toLowerCase() ?? '';
            if (sexeStr != 'male' && sexeStr != 'femelle') {
              erreurs++;
              erreursDetails.add(
                'Ligne ${i + 1}: Sexe invalide (doit être "male" ou "femelle")',
              );
              continue;
            }

            final dateStr = _getCellValue(row[4])?.toString().trim() ?? '';
            DateTime? dateNaissance;
            try {
              // Essayer plusieurs formats de date
              if (dateStr.contains('/')) {
                final parts = dateStr.split('/');
                if (parts.length == 3) {
                  dateNaissance = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              } else {
                dateNaissance = DateTime.tryParse(dateStr);
              }
            } catch (e) {
              erreurs++;
              erreursDetails.add('Ligne ${i + 1}: Date invalide ($dateStr)');
              continue;
            }

            if (dateNaissance == null) {
              erreurs++;
              erreursDetails.add('Ligne ${i + 1}: Date de naissance invalide');
              continue;
            }

            final statut = _getCellValue(row[5])?.toString().trim();

            // Créer le lapin
            final lapin = Lapin(
              nom: nom,
              race: race,
              sexe: sexeStr,
              dateNaissance: dateNaissance,
              statut: statut,
            );

            await db.insertLapin(lapin);
            importCount++;
          } catch (e) {
            erreurs++;
            erreursDetails.add('Ligne ${i + 1}: ${e.toString()}');
            logger.error('Erreur import ligne ${i + 1}: $e');
          }
        }
      }

      // Importer les accouplements si la sheet existe
      if (excel.sheets.containsKey('Accouplements')) {
        final accouplSheet = excel.sheets['Accouplements']!;
        if (accouplSheet.rows.length >= 2) {
          for (var i = 1; i < accouplSheet.rows.length; i++) {
            final row = accouplSheet.rows[i];
            if (row.isEmpty || row.length < 5) continue;

            try {
              final maleId = _getIntValue(row[1]);
              final femelleId = _getIntValue(row[2]);
              final dateStr = _getCellValue(row[3])?.toString().trim() ?? '';

              if (maleId == null || femelleId == null) {
                erreurs++;
                erreursDetails.add(
                  'Accouplement ligne ${i + 1}: IDs invalides',
                );
                continue;
              }

              // Vérifier que les lapins existent
              final male = await db.getLapinById(maleId);
              final femelle = await db.getLapinById(femelleId);
              if (male == null || femelle == null) {
                erreurs++;
                erreursDetails.add(
                  'Accouplement ligne ${i + 1}: Lapin(s) introuvable(s)',
                );
                continue;
              }

              DateTime? dateAccouplement;
              try {
                if (dateStr.contains('/')) {
                  final parts = dateStr.split('/');
                  if (parts.length == 3) {
                    dateAccouplement = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                  }
                } else {
                  dateAccouplement = DateTime.tryParse(dateStr);
                }
              } catch (e) {
                erreurs++;
                erreursDetails.add(
                  'Accouplement ligne ${i + 1}: Date invalide',
                );
                continue;
              }

              if (dateAccouplement == null) {
                erreurs++;
                erreursDetails.add(
                  'Accouplement ligne ${i + 1}: Date manquante',
                );
                continue;
              }

              final statut =
                  _getCellValue(row[4])?.toString().trim() ?? 'en_attente';

              final accouplement = Accouplement(
                maleId: maleId,
                femelleId: femelleId,
                dateAccouplement: dateAccouplement,
                dateMiseBasPrevue: dateAccouplement.add(
                  const Duration(days: 31),
                ),
                statut: statut,
              );

              await db.insertAccouplement(accouplement);
              importCount++;
            } catch (e) {
              erreurs++;
              erreursDetails.add(
                'Accouplement ligne ${i + 1}: ${e.toString()}',
              );
            }
          }
        }
      }

      // Importer les recettes si la sheet existe
      if (excel.sheets.containsKey('Recettes')) {
        final recettesSheet = excel.sheets['Recettes']!;
        if (recettesSheet.rows.length >= 2) {
          for (var i = 1; i < recettesSheet.rows.length; i++) {
            final row = recettesSheet.rows[i];
            if (row.isEmpty || row.length < 4) continue;

            try {
              final montant = _getDoubleValue(row[1]);
              final categorie =
                  _getCellValue(row[2])?.toString().trim() ?? 'autre';
              final dateStr = _getCellValue(row[3])?.toString().trim() ?? '';

              if (montant == null || montant <= 0) {
                erreurs++;
                erreursDetails.add('Recette ligne ${i + 1}: Montant invalide');
                continue;
              }

              DateTime? date;
              try {
                if (dateStr.contains('/')) {
                  final parts = dateStr.split('/');
                  if (parts.length == 3) {
                    date = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                  }
                } else {
                  date = DateTime.tryParse(dateStr);
                }
              } catch (e) {
                erreurs++;
                erreursDetails.add('Recette ligne ${i + 1}: Date invalide');
                continue;
              }

              date ??= DateTime.now();

              final recette = Recette(
                montant: montant,
                categorie: categorie,
                date: date,
                description: 'Import Excel',
              );

              await db.insertRecette(recette);
              importCount++;
            } catch (e) {
              erreurs++;
              erreursDetails.add('Recette ligne ${i + 1}: ${e.toString()}');
            }
          }
        }
      }

      // Afficher le résultat
      String message = '✅ Import Excel réussi : $importCount entrée(s)';
      if (erreurs > 0) {
        message += '\n⚠️ $erreurs erreur(s)';
        if (erreursDetails.length <= 5) {
          message += '\n${erreursDetails.join('\n')}';
        } else {
          message +=
              '\n${erreursDetails.take(5).join('\n')}\n... et ${erreursDetails.length - 5} autres';
        }
      }

      if (mounted) {
        if (erreurs > 0) {
          SnackbarHelper.showWarning(context, message);
        } else {
          SnackbarHelper.showSuccess(context, message);
        }
      }
    } catch (e) {
      logger.error('Erreur import Excel: $e');
      if (mounted) {
        SnackbarHelper.showError(context, '❌ Erreur: $e');
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  /// Helper pour extraire la valeur d'une cellule
  dynamic _getCellValue(Data? cell) {
    if (cell == null) return null;
    return cell.value;
  }

  /// Helper pour extraire une valeur entière
  int? _getIntValue(Data? cell) {
    final value = _getCellValue(cell);
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      return parsed;
    }
    return null;
  }

  /// Helper pour extraire une valeur décimale
  double? _getDoubleValue(Data? cell) {
    final value = _getCellValue(cell);
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
      return parsed;
    }
    return null;
  }

  Future<void> _migrationAutreApp() async {
    showDialog(
      context: context,
      builder: (context) => MigrationFormatDialog(
        onSelectCsv: _importerCSV,
        onSelectJson: _importerJSON,
      ),
    );
  }

  Future<void> _importerCSV() async {
    try {
      setState(() => _isImporting = true);

      // Sélection fichier
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.first.path!);
      final contenu = await file.readAsString();

      // Parser CSV basique (nom, race, sexe, date_naissance)
      final lignes = contenu.split('\n');
      if (lignes.length < 2) {
        throw Exception('Fichier CSV vide ou invalide');
      }

      // Ignorer la ligne d'en-tête
      int importes = 0;
      int erreurs = 0;

      for (int i = 1; i < lignes.length; i++) {
        final ligne = lignes[i].trim();
        if (ligne.isEmpty) continue;

        final colonnes = ligne.split(',');
        if (colonnes.length < 4) {
          erreurs++;
          continue;
        }

        try {
          // Format attendu: nom,race,sexe,date_naissance
          final nom = colonnes[0].trim();
          final race = colonnes[1].trim();
          final sexe = colonnes[2].trim().toLowerCase();
          final dateStr = colonnes[3].trim();

          if (nom.isEmpty || race.isEmpty) {
            erreurs++;
            continue;
          }

          // Parser date (format DD/MM/YYYY ou YYYY-MM-DD)
          DateTime? dateNaissance;
          if (dateStr.contains('/')) {
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              dateNaissance = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          } else if (dateStr.contains('-')) {
            dateNaissance = DateTime.tryParse(dateStr);
          }

          if (dateNaissance == null) {
            erreurs++;
            continue;
          }

          // Créer lapin
          final lapin = Lapin(
            nom: nom,
            race: race,
            sexe: sexe == 'male' || sexe == 'm' ? 'male' : 'femelle',
            dateNaissance: dateNaissance,
          );

          // Sauvegarder en DB
          final db = await DatabaseHelper.instance.database;
          await db.insert('lapins', lapin.toMap());
          importes++;
        } catch (e) {
          logger.error('❌ Erreur import ligne $i', e);
          erreurs++;
        }
      }

      setState(() => _isImporting = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import terminé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '$importes lapin${importes > 1 ? 's' : ''} importé${importes > 1 ? 's' : ''}',
                    ),
                  ],
                ),
                if (erreurs > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '$erreurs ligne${erreurs > 1 ? 's' : ''} ignorée${erreurs > 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur import: $e');
      }
    }
  }

  Future<void> _importerJSON() async {
    try {
      setState(() => _isImporting = true);

      // Sélection fichier
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.first.path!);
      final contenu = await file.readAsString();

      // Parser JSON
      final data = jsonDecode(contenu) as Map<String, dynamic>;

      // Format attendu: { "lapins": [...] }
      if (!data.containsKey('lapins') || data['lapins'] is! List) {
        throw Exception('Format JSON invalide');
      }

      final lapinsData = data['lapins'] as List;
      int importes = 0;
      int erreurs = 0;

      for (final lapinData in lapinsData) {
        try {
          final lapin = Lapin(
            nom: lapinData['nom'] as String,
            race: lapinData['race'] as String,
            sexe: (lapinData['sexe'] as String).toLowerCase() == 'male'
                ? 'male'
                : 'femelle',
            dateNaissance: DateTime.parse(
              lapinData['date_naissance'] as String,
            ),
            statut: lapinData['statut'] as String?,
            localisation: lapinData['localisation'] as String?,
            couleur: lapinData['couleur'] as String?,
            notes: lapinData['notes'] as String?,
          );

          // Sauvegarder en DB
          final db = await DatabaseHelper.instance.database;
          await db.insert('lapins', lapin.toMap());
          importes++;
        } catch (e) {
          logger.error('❌ Erreur import lapin', e);
          erreurs++;
        }
      }

      setState(() => _isImporting = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import terminé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '$importes lapin${importes > 1 ? 's' : ''} importé${importes > 1 ? 's' : ''}',
                    ),
                  ],
                ),
                if (erreurs > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '$erreurs entrée${erreurs > 1 ? 's' : ''} ignorée${erreurs > 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur import: $e');
      }
    }
  }
}
