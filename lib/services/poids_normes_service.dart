/// Service pour gérer les normes de poids par race et âge
class PoidsNormesService {
  /// Normes de poids par race (en kg)
  /// Structure: {race: {min: poids_min, max: poids_max, adulte: poids_adulte}}
  static const Map<String, Map<String, double>> _normesParRace = {
    'Géant des Flandres': {
      'min': 5.0,
      'max': 7.5,
      'adulte': 6.5,
      'lapereau_max': 1.5, // 0-2 mois
      'jeune_max': 4.0, // 2-5 mois
    },
    'Fauve de Bourgogne': {
      'min': 3.5,
      'max': 5.0,
      'adulte': 4.2,
      'lapereau_max': 1.0,
      'jeune_max': 3.0,
    },
    'Bélier Nain': {
      'min': 1.5,
      'max': 2.5,
      'adulte': 2.0,
      'lapereau_max': 0.5,
      'jeune_max': 1.5,
    },
    'Blanc de Hotot': {
      'min': 3.0,
      'max': 5.0,
      'adulte': 4.0,
      'lapereau_max': 0.8,
      'jeune_max': 2.5,
    },
    'Néo-Zélandais': {
      'min': 3.0,
      'max': 5.5,
      'adulte': 4.5,
      'lapereau_max': 1.0,
      'jeune_max': 3.0,
    },
    'Californien': {
      'min': 3.5,
      'max': 5.0,
      'adulte': 4.2,
      'lapereau_max': 0.9,
      'jeune_max': 2.8,
    },
    'Rex': {
      'min': 3.0,
      'max': 4.5,
      'adulte': 3.8,
      'lapereau_max': 0.8,
      'jeune_max': 2.5,
    },
    'Angora': {
      'min': 2.5,
      'max': 4.0,
      'adulte': 3.5,
      'lapereau_max': 0.7,
      'jeune_max': 2.2,
    },
    'Papillon': {
      'min': 2.0,
      'max': 3.5,
      'adulte': 2.8,
      'lapereau_max': 0.6,
      'jeune_max': 1.8,
    },
    'Argenté de Champagne': {
      'min': 4.0,
      'max': 5.5,
      'adulte': 4.8,
      'lapereau_max': 1.2,
      'jeune_max': 3.5,
    },
  };

  /// Obtenir les normes de poids selon la race et l'âge
  static Map<String, double> getPoidsNormal({
    required String race,
    required int ageJours,
    required String sexe,
  }) {
    // Récupérer les normes de base pour la race
    final normesBase = _normesParRace[race] ?? _normesParRace['Néo-Zélandais']!;

    // Ajuster selon l'âge
    double min, max;

    if (ageJours < 60) {
      // Lapereau (0-2 mois) : croissance rapide
      min = 0.1; // Poids minimum à la naissance
      max = normesBase['lapereau_max'] ?? normesBase['min']! * 0.3;
    } else if (ageJours < 150) {
      // Jeune (2-5 mois) : croissance continue
      min = (normesBase['lapereau_max'] ?? normesBase['min']! * 0.3) * 0.8;
      max = normesBase['jeune_max'] ?? normesBase['min']! * 0.8;
    } else {
      // Adulte (5+ mois) : poids stable
      min = normesBase['min']!;
      max = normesBase['max']!;
      
      // Ajustement selon le sexe (les mâles sont généralement plus lourds)
      if (sexe.toLowerCase().contains('mâle') || 
          sexe.toLowerCase().contains('male')) {
        min = min * 0.95; // Mâles légèrement plus lourds
        max = max * 1.05;
      } else {
        min = min * 0.90; // Femelles légèrement plus légères
        max = max * 0.95;
      }
    }

    return {
      'min': min,
      'max': max,
      'adulte': normesBase['adulte']!,
    };
  }

  /// Vérifier si le poids est anormal (hors normes)
  static bool estPoidsAnormal({
    required double poids,
    required String race,
    required int ageJours,
    required String sexe,
  }) {
    final normes = getPoidsNormal(
      race: race,
      ageJours: ageJours,
      sexe: sexe,
    );

    return poids < normes['min']! || poids > normes['max']!;
  }

  /// Obtenir un message descriptif sur le poids
  static String getMessagePoids({
    required double poids,
    required String race,
    required int ageJours,
    required String sexe,
  }) {
    final normes = getPoidsNormal(
      race: race,
      ageJours: ageJours,
      sexe: sexe,
    );

    if (poids < normes['min']!) {
      final ecart = normes['min']! - poids;
      return 'Poids insuffisant (${ecart.toStringAsFixed(2)}kg sous la norme minimale)';
    } else if (poids > normes['max']!) {
      final ecart = poids - normes['max']!;
      return 'Poids excessif (${ecart.toStringAsFixed(2)}kg au-dessus de la norme maximale)';
    } else {
      return 'Poids normal pour cette race et cet âge';
    }
  }

  /// Calculer le pourcentage d'écart par rapport à la norme
  static double calculerEcartPourcentage({
    required double poids,
    required String race,
    required int ageJours,
    required String sexe,
  }) {
    final normes = getPoidsNormal(
      race: race,
      ageJours: ageJours,
      sexe: sexe,
    );

    final poidsIdeal = normes['adulte']!;
    final ecart = poids - poidsIdeal;
    return (ecart / poidsIdeal) * 100;
  }
}

