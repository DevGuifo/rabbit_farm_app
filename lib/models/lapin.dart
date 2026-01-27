import 'accouplement.dart';
import 'enums/sexe.dart';
import 'enums/statut_accouplement.dart';

/// Modèle de données représentant un lapin (individu)
///
/// **Architecture Lot/Individu :**
/// - Un lapin appartient toujours à un lot (lotId requis)
/// - Le nom devient optionnel (identifiant principal = lot.identifiant)
/// - Les individus servent pour : reproducteurs, santé spécifique, suivi exceptionnel
///
/// **Champs de synchronisation (futurs - pour migration Supabase) :**
/// - `userId` : ID de l'utilisateur propriétaire (UUID Supabase)
/// - `createdAt` : Date de création de l'enregistrement
/// - `updatedAt` : Date de dernière modification
/// - `syncedAt` : Date de dernière synchronisation avec Supabase
/// - `isDirty` : Flag indiquant si l'enregistrement a des modifications non synchronisées
/// - `isDeleted` : Soft delete - marqué comme supprimé mais conservé pour sync
/// - `syncConflict` : JSON contenant les informations de conflit de synchronisation
///
/// Ces champs seront ajoutés lors de la migration vers Supabase (voir MIGRATION_SUPABASE.md)
class Lapin {
  final int? id;

  /// Nom optionnel (l'identifiant principal est maintenant numeroIdentification)
  /// Vide par défaut pour les lapins créés en lot sans surnom individuel
  final String nom;
  final String race;
  final Sexe sexe;
  final DateTime dateNaissance;
  final double? poids;
  final String? statut;
  final String? localisation;
  final String? photoPath;
  final String? numeroIdentification;
  final String? couleur;
  final double? prixAchat;
  final String? origine;
  final String? notes;
  final String? caracteristiques;

  // Champ FK pour localisation (Phase 2 Refactoring)
  final int? cageId; // FK vers cages.id

  /// FK vers lots.id - Appartenance au lot (obligatoire pour nouveaux lapins)
  /// NULL pour lapins créés avant migration (seront migrés vers lot par défaut)
  final int? lotId;

  // Champs de synchronisation (réservés pour migration future Supabase)
  // À décommenter lors de la migration vers Supabase
  // final String? userId;
  // final DateTime? createdAt;
  // final DateTime? updatedAt;
  // final DateTime? syncedAt;
  // final bool isDirty;
  // final bool isDeleted;
  // final Map<String, dynamic>? syncConflict;

  Lapin({
    this.id,
    this.nom = '',
    required this.race,
    required this.sexe,
    required this.dateNaissance,
    this.poids,
    this.statut,
    this.localisation,
    this.photoPath,
    this.numeroIdentification,
    this.couleur,
    this.prixAchat,
    this.origine,
    this.notes,
    this.caracteristiques,
    this.cageId,
    this.lotId,
  });

  /// Générer un identifiant unique au format LP-YYYY-MM-NNN
  ///
  /// [date] : Date de création (année/mois pour le préfixe)
  /// [sequence] : Numéro séquentiel (1-999)
  ///
  /// Exemple: LP-2026-01-001 = Premier lapin créé en janvier 2026
  static String genererIdentifiant(DateTime date, int sequence) {
    final annee = date.year.toString();
    final mois = date.month.toString().padLeft(2, '0');
    final seq = sequence.toString().padLeft(3, '0');
    return 'LP-$annee-$mois-$seq';
  }

  /// Parser un identifiant pour extraire les composants
  static Map<String, dynamic>? parseIdentifiant(String identifiant) {
    final regex = RegExp(r'^LP-(\d{4})-(\d{2})-(\d{3})$');
    final match = regex.firstMatch(identifiant);
    if (match == null) return null;

    return {
      'annee': int.parse(match.group(1)!),
      'mois': int.parse(match.group(2)!),
      'sequence': int.parse(match.group(3)!),
    };
  }

  /// Calculer l'âge du lapin en jours
  int get ageEnJours {
    return DateTime.now().difference(dateNaissance).inDays;
  }

  /// Calculer l'âge du lapin en mois
  int get ageEnMois {
    return (ageEnJours / 30).floor();
  }

  /// Obtenir une représentation textuelle de l'âge
  String get ageFormate {
    if (ageEnJours < 30) {
      return '$ageEnJours jour${ageEnJours > 1 ? 's' : ''}';
    } else if (ageEnMois < 12) {
      return '$ageEnMois mois';
    } else {
      final annees = (ageEnMois / 12).floor();
      final moisRestants = ageEnMois % 12;
      if (moisRestants == 0) {
        return '$annees an${annees > 1 ? 's' : ''}';
      } else {
        return '$annees an${annees > 1 ? 's' : ''} et $moisRestants mois';
      }
    }
  }

  /// Vérifier si la femelle est gestante
  ///
  /// [accouplements] : Liste des accouplements à vérifier
  ///
  /// Retourne true si la femelle a un accouplement actif (en_attente ou confirme)
  /// et que la date de mise bas n'est pas encore passée
  bool estGestante(List<Accouplement> accouplements) {
    // Seulement pour les femelles
    if (sexe != Sexe.femelle) {
      return false;
    }

    if (id == null) return false;

    final maintenant = DateTime.now();

    // Chercher un accouplement actif pour cette femelle
    for (final acc in accouplements) {
      // Vérifier que c'est bien un accouplement pour cette femelle
      if (acc.femelleId != id) continue;

      // Vérifier le statut (en_attente ou confirme)
      if (acc.statut != StatutAccouplement.enAttente && acc.statut != StatutAccouplement.confirme) continue;

      // Vérifier que la date de mise bas n'est pas passée
      if (maintenant.isBefore(acc.dateMiseBasPrevue)) {
        return true;
      }
    }

    return false;
  }

  /// Créer une copie du lapin avec des modifications
  Lapin copyWith({
    int? id,
    String? nom,
    String? race,
    Sexe? sexe,
    DateTime? dateNaissance,
    double? poids,
    String? statut,
    String? localisation,
    String? photoPath,
    String? numeroIdentification,
    String? couleur,
    double? prixAchat,
    String? origine,
    String? notes,
    String? caracteristiques,
    int? cageId,
    int? lotId,
  }) {
    return Lapin(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      race: race ?? this.race,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      poids: poids ?? this.poids,
      statut: statut ?? this.statut,
      localisation: localisation ?? this.localisation,
      photoPath: photoPath ?? this.photoPath,
      numeroIdentification: numeroIdentification ?? this.numeroIdentification,
      couleur: couleur ?? this.couleur,
      prixAchat: prixAchat ?? this.prixAchat,
      origine: origine ?? this.origine,
      notes: notes ?? this.notes,
      caracteristiques: caracteristiques ?? this.caracteristiques,
      cageId: cageId ?? this.cageId,
      lotId: lotId ?? this.lotId,
    );
  }

  /// Convertir le lapin en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'race': race,
      'sexe': sexe.toDatabase(),
      'date_naissance': dateNaissance.toIso8601String(),
      'poids': poids,
      'statut': statut,
      'localisation': localisation,
      'photo_path': photoPath,
      'numero_identification': numeroIdentification,
      'couleur': couleur,
      'prix_achat': prixAchat,
      'origine': origine,
      'notes': notes,
      'caracteristiques': caracteristiques,
      'cage_id': cageId,
      'lot_id': lotId,
    };
  }

  /// Créer un lapin depuis un Map de la base de données
  factory Lapin.fromMap(Map<String, dynamic> map) {
    return Lapin(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      race: map['race'] as String,
      sexe: Sexe.fromString(map['sexe'] as String),
      dateNaissance: DateTime.parse(map['date_naissance'] as String),
      poids: map['poids'] as double?,
      statut: map['statut'] as String?,
      localisation: map['localisation'] as String?,
      photoPath: map['photo_path'] as String?,
      numeroIdentification: map['numero_identification'] as String?,
      couleur: map['couleur'] as String?,
      prixAchat: map['prix_achat'] as double?,
      origine: map['origine'] as String?,
      notes: map['notes'] as String?,
      caracteristiques: map['caracteristiques'] as String?,
      cageId: map['cage_id'] as int?,
      lotId: map['lot_id'] as int?,
    );
  }

  @override
  String toString() {
    return 'Lapin{id: $id, nom: $nom, race: $race, sexe: $sexe, age: $ageFormate, lotId: $lotId}';
  }
}
