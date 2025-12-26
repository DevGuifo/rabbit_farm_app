import 'package:flutter/material.dart';
import '../models/protocole_soin.dart';
import '../services/database_helper.dart';

/// Provider pour gérer les protocoles de soin
class ProtocoleSoinProvider with ChangeNotifier {
  List<ProtocoleSoin> _protocoles = [];
  bool _isLoading = false;

  List<ProtocoleSoin> get protocoles => _protocoles;
  bool get isLoading => _isLoading;

  /// Charger tous les protocoles depuis la base de données
  Future<void> chargerProtocoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('protocoles_soin', orderBy: 'nom ASC');
      _protocoles = maps.map((map) => ProtocoleSoin.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des protocoles de soin: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un protocole
  Future<void> ajouterProtocole(ProtocoleSoin protocole) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('protocoles_soin', protocole.toMap());
      final nouveauProtocole = protocole.copyWith(id: id);
      _protocoles.add(nouveauProtocole);
      _protocoles.sort((a, b) => a.nom.compareTo(b.nom));
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout du protocole de soin: $e');
      rethrow;
    }
  }

  /// Modifier un protocole
  Future<void> modifierProtocole(ProtocoleSoin protocole) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'protocoles_soin',
        protocole.toMap(),
        where: 'id = ?',
        whereArgs: [protocole.id],
      );

      final index = _protocoles.indexWhere((p) => p.id == protocole.id);
      if (index != -1) {
        _protocoles[index] = protocole;
        _protocoles.sort((a, b) => a.nom.compareTo(b.nom));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la modification du protocole de soin: $e');
      rethrow;
    }
  }

  /// Supprimer un protocole
  Future<void> supprimerProtocole(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('protocoles_soin', where: 'id = ?', whereArgs: [id]);
      _protocoles.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du protocole de soin: $e');
      rethrow;
    }
  }

  /// Obtenir un protocole par son ID
  ProtocoleSoin? getProtocoleById(int id) {
    try {
      return _protocoles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les protocoles actifs
  List<ProtocoleSoin> getProtocolesActifs() {
    return _protocoles.where((p) => p.actif).toList();
  }

  /// Obtenir les protocoles inactifs
  List<ProtocoleSoin> getProtocolesInactifs() {
    return _protocoles.where((p) => !p.actif).toList();
  }

  /// Filtrer les protocoles par type
  List<ProtocoleSoin> getProtocolesParType(String type) {
    return _protocoles.where((p) => p.type == type).toList();
  }

  /// Statistiques : répartition par type
  Map<String, int> getRepartitionParType() {
    final Map<String, int> stats = {
      'vaccination': 0,
      'traitement': 0,
      'prevention': 0,
      'routine': 0,
    };

    for (final protocole in _protocoles) {
      stats[protocole.type] = (stats[protocole.type] ?? 0) + 1;
    }

    return stats;
  }

  /// Statistiques : nombre de protocoles actifs/inactifs
  Map<String, int> getRepartitionActivite() {
    return {
      'actifs': _protocoles.where((p) => p.actif).length,
      'inactifs': _protocoles.where((p) => !p.actif).length,
    };
  }

  /// Statistiques : coût total estimé des protocoles actifs
  double getCoutTotalProtocolesActifs() {
    final protocolesActifs = getProtocolesActifs();
    return protocolesActifs.fold<double>(
      0,
      (sum, p) => sum + (p.coutEstime ?? 0),
    );
  }

  /// Statistiques : coût moyen par protocole
  double? getCoutMoyenProtocole() {
    final protocolesAvecCout = _protocoles
        .where((p) => p.coutEstime != null)
        .toList();
    if (protocolesAvecCout.isEmpty) return null;

    final total = protocolesAvecCout.fold<double>(
      0,
      (sum, p) => sum + p.coutEstime!,
    );
    return total / protocolesAvecCout.length;
  }

  /// Activer/désactiver un protocole
  Future<void> toggleActif(int id) async {
    final protocole = getProtocoleById(id);
    if (protocole == null) return;

    final protocoleModifie = protocole.copyWith(actif: !protocole.actif);
    await modifierProtocole(protocoleModifie);
  }

  /// Rechercher des protocoles par nom
  List<ProtocoleSoin> rechercherProtocoles(String query) {
    final queryLower = query.toLowerCase();
    return _protocoles
        .where(
          (p) =>
              p.nom.toLowerCase().contains(queryLower) ||
              p.description.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  /// Obtenir les protocoles nécessitant un médicament spécifique
  List<ProtocoleSoin> getProtocolesAvecMedicament(String medicament) {
    return _protocoles
        .where((p) => p.medicamentsNecessaires.contains(medicament))
        .toList();
  }

  /// Obtenir les protocoles pour une catégorie de lapins
  List<ProtocoleSoin> getProtocolesParCategorie(String categorie) {
    return _protocoles
        .where(
          (p) => p.lapinsConcernes == categorie || p.lapinsConcernes == 'tous',
        )
        .toList();
  }

  /// Dupliquer un protocole
  Future<void> dupliquerProtocole(int id) async {
    final protocole = getProtocoleById(id);
    if (protocole == null) return;

    final protocoleDuplique = ProtocoleSoin(
      nom: '${protocole.nom} (Copie)',
      description: protocole.description,
      type: protocole.type,
      frequence: protocole.frequence,
      medicamentsNecessaires: protocole.medicamentsNecessaires,
      lapinsConcernes: protocole.lapinsConcernes,
      coutEstime: protocole.coutEstime,
      instructions: protocole.instructions,
      actif: false, // Les copies sont inactives par défaut
    );

    await ajouterProtocole(protocoleDuplique);
  }

  /// Obtenir les protocoles de vaccination
  List<ProtocoleSoin> getProtocolesVaccination() {
    return getProtocolesParType('vaccination');
  }

  /// Obtenir les protocoles de routine actifs
  List<ProtocoleSoin> getProtocolesRoutineActifs() {
    return _protocoles.where((p) => p.type == 'routine' && p.actif).toList();
  }
}
