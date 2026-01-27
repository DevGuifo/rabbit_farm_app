import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏆 GAMIFICATION - Système de progression et récompenses
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Ce fichier implémente un système de gamification léger et non-infantile
/// pour encourager l'utilisation régulière de l'application.
///
/// PRINCIPES :
/// - Non-infantile : Badges professionnels, pas de personnages enfantins
/// - Significatif : Récompenses liées aux vraies compétences d'éleveur
/// - Non-intrusif : L'utilisateur peut ignorer complètement
/// - Progressif : Encourage l'apprentissage et l'amélioration
///
/// COMPOSANTS :
/// 1. Badges (achievements) - Récompenses pour des actions spécifiques
/// 2. Progression - Suivi de l'avancement global
/// 3. Rituels - Encouragement des bonnes pratiques quotidiennes
/// 4. Statistiques - Visualisation des accomplissements
///
/// USAGE :
/// ```dart
/// // Débloquer un badge
/// await GamificationService.unlockBadge(context, BadgeType.firstRabbit);
///
/// // Afficher la progression
/// ProgressionCard()
///
/// // Compléter un rituel quotidien
/// await GamificationService.completeRitual(RitualType.dailyCheck);
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// 🏅 BADGE TYPES - Types de badges disponibles
// ═══════════════════════════════════════════════════════════════════════════

/// Types de badges disponibles dans l'application
enum BadgeType {
  // Badges de démarrage
  firstRabbit(
    'Premier lapin',
    'Ajoutez votre premier lapin',
    Icons.pets,
    BadgeCategory.starter,
  ),
  firstMating(
    'Première saillie',
    'Enregistrez un premier accouplement',
    Icons.favorite,
    BadgeCategory.starter,
  ),
  firstLitter(
    'Première portée',
    'Enregistrez votre première portée',
    Icons.child_care,
    BadgeCategory.starter,
  ),
  firstSale(
    'Première vente',
    'Réalisez votre première vente',
    Icons.attach_money,
    BadgeCategory.starter,
  ),

  // Badges de reproduction
  breeder10(
    'Éleveur confirmé',
    '10 portées enregistrées',
    Icons.workspace_premium,
    BadgeCategory.breeding,
  ),
  breeder50(
    'Éleveur expert',
    '50 portées enregistrées',
    Icons.military_tech,
    BadgeCategory.breeding,
  ),
  highSurvival(
    'Taux de survie élevé',
    '90%+ de survie sur 10 portées',
    Icons.health_and_safety,
    BadgeCategory.breeding,
  ),

  // Badges de santé
  vaccinationComplete(
    'Vaccinations à jour',
    'Tous les lapins vaccinés',
    Icons.vaccines,
    BadgeCategory.health,
  ),
  zeroMortality(
    'Zéro mortalité',
    '30 jours sans perte',
    Icons.verified,
    BadgeCategory.health,
  ),
  healthExpert(
    'Expert santé',
    '50 soins enregistrés',
    Icons.local_hospital,
    BadgeCategory.health,
  ),

  // Badges de gestion
  organizer(
    'Organisateur',
    'Toutes les cages assignées',
    Icons.grid_view,
    BadgeCategory.management,
  ),
  dataKeeper(
    'Archiviste',
    '100 enregistrements',
    Icons.inventory,
    BadgeCategory.management,
  ),
  consistent(
    'Consistant',
    '7 jours d\'utilisation consécutifs',
    Icons.calendar_month,
    BadgeCategory.management,
  ),

  // Badges spéciaux
  yearMilestone(
    'Anniversaire',
    '1 an d\'utilisation',
    Icons.celebration,
    BadgeCategory.special,
  ),
  herd100(
    'Grand élevage',
    '100 lapins dans le cheptel',
    Icons.groups,
    BadgeCategory.special,
  );

  final String title;
  final String description;
  final IconData icon;
  final BadgeCategory category;

  const BadgeType(this.title, this.description, this.icon, this.category);
}

/// Catégories de badges
enum BadgeCategory {
  starter('Démarrage', Icons.flag, Color(0xFF4CAF50)),
  breeding('Reproduction', Icons.favorite, Color(0xFFE91E63)),
  health('Santé', Icons.medical_services, Color(0xFF2196F3)),
  management('Gestion', Icons.settings, Color(0xFF9C27B0)),
  special('Spécial', Icons.star, Color(0xFFFFC107));

  final String label;
  final IconData icon;
  final Color color;

  const BadgeCategory(this.label, this.icon, this.color);
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 BADGE MODEL - Modèle de données pour un badge
// ═══════════════════════════════════════════════════════════════════════════

/// Représente un badge avec son état de déblocage
class Badge {
  final BadgeType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int? progress; // Pour les badges progressifs (ex: 7/10)
  final int? target;

  const Badge({
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress,
    this.target,
  });

  /// Pourcentage de progression (0.0 à 1.0)
  double get progressPercent {
    if (isUnlocked) return 1.0;
    if (progress == null || target == null) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  /// Convertit en Map pour stockage
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  /// Crée un Badge depuis un Map
  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      type: BadgeType.values.firstWhere((e) => e.name == map['type']),
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      progress: map['progress'],
      target: map['target'],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎮 GAMIFICATION SERVICE - Service centralisé
// ═══════════════════════════════════════════════════════════════════════════

/// Service pour gérer la gamification
class GamificationService {
  static const String _badgesKey = 'gamification_badges';
  static const String _statsKey = 'gamification_stats';
  static const String _ritualsKey = 'gamification_rituals';

  // ─────────────────────────────────────────────────────────────────────────
  // BADGES
  // ─────────────────────────────────────────────────────────────────────────

  /// Récupère tous les badges avec leur état
  static Future<List<Badge>> getAllBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_badgesKey);

    final Map<String, Badge> savedBadges = {};
    if (data != null) {
      final List<dynamic> list = json.decode(data);
      for (final item in list) {
        final badge = Badge.fromMap(item);
        savedBadges[badge.type.name] = badge;
      }
    }

    // Retourner tous les types de badges avec leur état
    return BadgeType.values.map((type) {
      return savedBadges[type.name] ?? Badge(type: type, isUnlocked: false);
    }).toList();
  }

  /// Vérifie si un badge est débloqué
  static Future<bool> isBadgeUnlocked(BadgeType type) async {
    final badges = await getAllBadges();
    return badges.any((b) => b.type == type && b.isUnlocked);
  }

  /// Débloque un badge et affiche une notification
  static Future<void> unlockBadge(
    BuildContext context,
    BadgeType type, {
    bool showNotification = true,
  }) async {
    // Vérifier si déjà débloqué
    if (await isBadgeUnlocked(type)) return;

    // Sauvegarder le badge débloqué
    final badges = await getAllBadges();
    final updatedBadges = badges.map((b) {
      if (b.type == type) {
        return Badge(type: type, isUnlocked: true, unlockedAt: DateTime.now());
      }
      return b;
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _badgesKey,
      json.encode(updatedBadges.map((b) => b.toMap()).toList()),
    );

    // Afficher la notification
    if (showNotification && context.mounted) {
      BadgeUnlockNotification.show(context, type);
    }
  }

  /// Met à jour la progression d'un badge
  static Future<void> updateBadgeProgress(
    BadgeType type, {
    required int progress,
    required int target,
    BuildContext? context,
  }) async {
    final badges = await getAllBadges();
    final currentBadge = badges.firstWhere((b) => b.type == type);

    // Si déjà débloqué, ne rien faire
    if (currentBadge.isUnlocked) return;

    // Vérifier si le badge doit être débloqué
    final shouldUnlock = progress >= target;

    final updatedBadges = badges.map((b) {
      if (b.type == type) {
        return Badge(
          type: type,
          isUnlocked: shouldUnlock,
          unlockedAt: shouldUnlock ? DateTime.now() : null,
          progress: progress,
          target: target,
        );
      }
      return b;
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _badgesKey,
      json.encode(updatedBadges.map((b) => b.toMap()).toList()),
    );

    // Afficher notification si débloqué
    if (shouldUnlock && context != null && context.mounted) {
      BadgeUnlockNotification.show(context, type);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATISTIQUES
  // ─────────────────────────────────────────────────────────────────────────

  /// Récupère les statistiques de gamification
  static Future<GamificationStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_statsKey);

    if (data != null) {
      return GamificationStats.fromMap(json.decode(data));
    }

    return GamificationStats.initial();
  }

  /// Incrémente un compteur de statistique
  static Future<void> incrementStat(String key, {int amount = 1}) async {
    final stats = await getStats();
    final newStats = stats.copyWith(
      counters: {...stats.counters, key: (stats.counters[key] ?? 0) + amount},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(newStats.toMap()));
  }

  /// Enregistre une utilisation quotidienne
  static Future<int> recordDailyUse() async {
    final stats = await getStats();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    // Vérifier si déjà enregistré aujourd'hui
    if (stats.lastUseDate == todayKey) {
      return stats.consecutiveDays;
    }

    // Calculer les jours consécutifs
    int newStreak = 1;
    if (stats.lastUseDate != null) {
      final lastDate = _parseDate(stats.lastUseDate!);
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak = stats.consecutiveDays + 1;
      }
    }

    final newStats = stats.copyWith(
      lastUseDate: todayKey,
      consecutiveDays: newStreak,
      totalDays: stats.totalDays + 1,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(newStats.toMap()));

    return newStreak;
  }

  static DateTime _parseDate(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RITUELS QUOTIDIENS
  // ─────────────────────────────────────────────────────────────────────────

  /// Récupère l'état des rituels du jour
  static Future<Map<RitualType, bool>> getTodayRituals() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    final data = prefs.getString('${_ritualsKey}_$todayKey');
    if (data != null) {
      final Map<String, dynamic> map = json.decode(data);
      return map.map(
        (key, value) => MapEntry(
          RitualType.values.firstWhere((e) => e.name == key),
          value as bool,
        ),
      );
    }

    return {for (final type in RitualType.values) type: false};
  }

  /// Complète un rituel quotidien
  static Future<void> completeRitual(RitualType type) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    final rituals = await getTodayRituals();
    rituals[type] = true;

    await prefs.setString(
      '${_ritualsKey}_$todayKey',
      json.encode(rituals.map((k, v) => MapEntry(k.name, v))),
    );
  }

  /// Vérifie si tous les rituels sont complétés
  static Future<bool> areAllRitualsCompleted() async {
    final rituals = await getTodayRituals();
    return rituals.values.every((completed) => completed);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📈 GAMIFICATION STATS - Statistiques de gamification
// ═══════════════════════════════════════════════════════════════════════════

/// Statistiques de gamification de l'utilisateur
class GamificationStats {
  final int consecutiveDays;
  final int totalDays;
  final String? lastUseDate;
  final Map<String, int> counters;

  const GamificationStats({
    required this.consecutiveDays,
    required this.totalDays,
    this.lastUseDate,
    required this.counters,
  });

  factory GamificationStats.initial() {
    return const GamificationStats(
      consecutiveDays: 0,
      totalDays: 0,
      counters: {},
    );
  }

  GamificationStats copyWith({
    int? consecutiveDays,
    int? totalDays,
    String? lastUseDate,
    Map<String, int>? counters,
  }) {
    return GamificationStats(
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalDays: totalDays ?? this.totalDays,
      lastUseDate: lastUseDate ?? this.lastUseDate,
      counters: counters ?? this.counters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'consecutiveDays': consecutiveDays,
      'totalDays': totalDays,
      'lastUseDate': lastUseDate,
      'counters': counters,
    };
  }

  factory GamificationStats.fromMap(Map<String, dynamic> map) {
    return GamificationStats(
      consecutiveDays: map['consecutiveDays'] ?? 0,
      totalDays: map['totalDays'] ?? 0,
      lastUseDate: map['lastUseDate'],
      counters: Map<String, int>.from(map['counters'] ?? {}),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 RITUALS - Types de rituels quotidiens
// ═══════════════════════════════════════════════════════════════════════════

/// Types de rituels quotidiens
enum RitualType {
  dailyCheck(
    'Vérification quotidienne',
    'Consultez votre cheptel',
    Icons.checklist,
  ),
  healthCheck(
    'Contrôle santé',
    'Vérifiez l\'état de santé',
    Icons.health_and_safety,
  ),
  feedingLog('Alimentation', 'Notez l\'alimentation du jour', Icons.restaurant);

  final String title;
  final String description;
  final IconData icon;

  const RitualType(this.title, this.description, this.icon);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎉 BADGE UNLOCK NOTIFICATION - Notification de badge débloqué
// ═══════════════════════════════════════════════════════════════════════════

/// Affiche une notification élégante quand un badge est débloqué
class BadgeUnlockNotification {
  static void show(BuildContext context, BadgeType badge) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) =>
          _BadgeUnlockOverlay(badge: badge, onDismiss: () => entry.remove()),
    );

    overlay.insert(entry);
  }
}

class _BadgeUnlockOverlay extends StatefulWidget {
  final BadgeType badge;
  final VoidCallback onDismiss;

  const _BadgeUnlockOverlay({required this.badge, required this.onDismiss});

  @override
  State<_BadgeUnlockOverlay> createState() => _BadgeUnlockOverlayState();
}

class _BadgeUnlockOverlayState extends State<_BadgeUnlockOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _badgeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOutBack),
    );

    _entryController.forward().then((_) {
      _badgeController.forward();
    });

    // Auto-dismiss après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _entryController.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = widget.badge.category.color;

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _badgeController]),
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16 + _slideAnimation.value,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _entryController.reverse().then((_) => widget.onDismiss());
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Badge icon avec animation
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.badge.icon,
                              size: 28,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Texte
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Badge débloqué !',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.badge.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.badge.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 WIDGETS DE GAMIFICATION
// ═══════════════════════════════════════════════════════════════════════════

/// Widget affichant un badge
class BadgeWidget extends StatelessWidget {
  final Badge badge;
  final double size;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = badge.type.category.color;
    final isUnlocked = badge.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: '${badge.type.title}\n${badge.type.description}',
        child: Stack(
          children: [
            // Badge principal
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? color : theme.colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: Icon(
                badge.type.icon,
                size: size * 0.45,
                color: isUnlocked
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),

            // Indicateur de verrouillage
            if (!isUnlocked)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.35,
                  height: size * 0.35,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: size * 0.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // Indicateur de progression
            if (!isUnlocked && badge.progress != null)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: badge.progressPercent,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    color.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Carte de progression globale
class ProgressionCard extends StatefulWidget {
  const ProgressionCard({super.key});

  @override
  State<ProgressionCard> createState() => _ProgressionCardState();
}

class _ProgressionCardState extends State<ProgressionCard> {
  List<Badge> _badges = [];
  GamificationStats _stats = GamificationStats.initial();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final badges = await GamificationService.getAllBadges();
    final stats = await GamificationService.getStats();

    if (mounted) {
      setState(() {
        _badges = badges;
        _stats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedCount = _badges.where((b) => b.isUnlocked).length;
    final totalCount = _badges.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text(
                  'Votre progression',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Badges',
                  value: '$unlockedCount/$totalCount',
                  icon: Icons.military_tech,
                ),
                _StatItem(
                  label: 'Jours consécutifs',
                  value: '${_stats.consecutiveDays}',
                  icon: Icons.local_fire_department,
                  color: _stats.consecutiveDays >= 7 ? Colors.orange : null,
                ),
                _StatItem(
                  label: 'Total jours',
                  value: '${_stats.totalDays}',
                  icon: Icons.calendar_today,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% complété',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Widget pour afficher les rituels quotidiens
class DailyRitualsCard extends StatefulWidget {
  final VoidCallback? onRitualCompleted;

  const DailyRitualsCard({super.key, this.onRitualCompleted});

  @override
  State<DailyRitualsCard> createState() => _DailyRitualsCardState();
}

class _DailyRitualsCardState extends State<DailyRitualsCard> {
  Map<RitualType, bool> _rituals = {};

  @override
  void initState() {
    super.initState();
    _loadRituals();
  }

  Future<void> _loadRituals() async {
    final rituals = await GamificationService.getTodayRituals();
    if (mounted) {
      setState(() => _rituals = rituals);
    }
  }

  Future<void> _completeRitual(RitualType type) async {
    await GamificationService.completeRitual(type);
    await _loadRituals();
    widget.onRitualCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = _rituals.values.where((v) => v).length;
    final allCompleted = completedCount == RitualType.values.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  allCompleted ? Icons.check_circle : Icons.wb_sunny,
                  color: allCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rituels du jour',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: allCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/${RitualType.values.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: allCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste des rituels
            ...RitualType.values.map((type) {
              final isCompleted = _rituals[type] ?? false;
              return ListTile(
                leading: Icon(
                  isCompleted ? Icons.check_circle : type.icon,
                  color: isCompleted
                      ? Colors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  type.title,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                subtitle: Text(type.description),
                trailing: isCompleted
                    ? null
                    : TextButton(
                        onPressed: () => _completeRitual(type),
                        child: const Text('Fait'),
                      ),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }
}
