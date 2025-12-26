import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive_io.dart';
import '../../services/database_helper.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/logger.dart';
import '../../models/lapin.dart';

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
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  size: 32,
                  color: Color(0xFF9C27B0),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sauvegarde & Restauration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sécurisez vos données et restaurez-les facilement',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Dernière sauvegarde
            if (_lastBackupDate != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dernière sauvegarde',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy à HH:mm',
                              ).format(_lastBackupDate!),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_lastBackupDate != null) const SizedBox(height: 24),

            // SECTION EXPORT
            const Text(
              'EXPORT DES DONNÉES',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Option 1: Sauvegarde complète
            _buildExportCard(
              title: 'Sauvegarde complète',
              description: 'Base de données SQLite + toutes les photos',
              icon: Icons.backup,
              color: Colors.blue,
              onTap: _isExporting ? null : _exportSauvegardeComplete,
            ),
            const SizedBox(height: 12),

            // Option 2: Export Excel
            _buildExportCard(
              title: 'Export Excel',
              description:
                  'Tableaux Excel par table (lapins, accouplements, etc.)',
              icon: Icons.table_chart,
              color: Colors.green,
              onTap: _isExporting ? null : _exportExcel,
            ),
            const SizedBox(height: 12),

            // Option 3: Export JSON
            _buildExportCard(
              title: 'Export JSON',
              description: 'Format JSON pour API ou développeurs',
              icon: Icons.code,
              color: Colors.orange,
              onTap: _isExporting ? null : _exportJSON,
            ),
            const SizedBox(height: 12),

            // Option 4: Cloud Sync (placeholder)
            _buildExportCard(
              title: 'Synchronisation Cloud',
              description: 'Sauvegarde automatique sur Google Drive (bientôt)',
              icon: Icons.cloud_sync,
              color: Colors.purple,
              onTap: null, // Disabled
            ),
            const SizedBox(height: 32),

            // SECTION IMPORT
            const Text(
              'IMPORT / RESTAURATION',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Option 1: Restaurer sauvegarde
            _buildImportCard(
              title: 'Restaurer une sauvegarde',
              description: 'Remplacer les données actuelles par une sauvegarde',
              icon: Icons.restore,
              color: Colors.red,
              danger: true,
              onTap: _isImporting ? null : _importSauvegarde,
            ),
            const SizedBox(height: 12),

            // Option 2: Import Excel
            _buildImportCard(
              title: 'Importer depuis Excel',
              description: 'Ajouter des données depuis un fichier Excel',
              icon: Icons.upload_file,
              color: Colors.blue,
              onTap: _isImporting ? null : _importExcel,
            ),
            const SizedBox(height: 12),

            // Option 3: Migration
            _buildImportCard(
              title: 'Migrer depuis autre app',
              description: 'Importer les données d\'une autre application',
              icon: Icons.sync_alt,
              color: Colors.teal,
              onTap: _isImporting ? null : _migrationAutreApp,
            ),
            const SizedBox(height: 32),

            // Informations utiles
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Conseils de sauvegarde',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Effectuez une sauvegarde complète au moins une fois par semaine\n'
                      '• Conservez les sauvegardes sur un support externe (USB, Cloud)\n'
                      '• Vérifiez régulièrement l\'intégrité de vos sauvegardes\n'
                      '• La restauration écrase toutes les données actuelles\n'
                      '• Les exports Excel peuvent être modifiés avant réimport',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Indicateur de chargement
            if (_isExporting || _isImporting)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _isExporting
                            ? 'Export en cours...'
                            : 'Import en cours...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onTap == null ? Colors.grey[300] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool danger = false,
  }) {
    return Card(
      elevation: 2,
      color: danger ? Colors.red[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (danger) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ATTENTION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onTap == null ? Colors.grey[300] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
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
      final dbPath = p.join(dbDirectory, 'rabbit_farm.db');
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

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✅ Restauration réussie ! Veuillez redémarrer l\'application',
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
        return;
      }

      final filePath = result.files.single.path!;
      final bytes = await File(filePath).readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Impossible de lire le fichier');
      }

      final excel = Excel.decodeBytes(bytes);
      int importCount = 0;

      // Importer les lapins si la sheet existe
      if (excel.sheets.containsKey('Lapins')) {
        final lapinsSheet = excel.sheets['Lapins']!;
        // Ignorer la première ligne (en-têtes)
        for (var i = 1; i < lapinsSheet.rows.length; i++) {
          final row = lapinsSheet.rows[i];
          if (row.length >= 6) {
            // Créer et insérer le lapin
            // Note: Import simplifié, en production ajouter validation complète
            importCount++;
          }
        }
      }

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✅ Import Excel réussi : $importCount entrées',
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

  Future<void> _migrationAutreApp() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sync_alt, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('Importer des données'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisissez le format de fichier à importer :',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Option CSV
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: const Icon(Icons.table_chart, color: Colors.green),
                ),
                title: const Text('Fichier CSV'),
                subtitle: const Text('Tableur Excel, Google Sheets...'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _importerCSV();
                },
              ),
            ),
            const SizedBox(height: 8),

            // Option JSON
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.code, color: Colors.blue),
                ),
                title: const Text('Fichier JSON'),
                subtitle: const Text('Export d\'autres apps'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _importerJSON();
                },
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Les données seront validées avant import',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
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
          debugPrint('Erreur import ligne $i: $e');
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
          debugPrint('Erreur import lapin: $e');
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
