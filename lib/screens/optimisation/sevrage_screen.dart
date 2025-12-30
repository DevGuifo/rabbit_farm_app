import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../models/accouplement.dart';
import '../../services/database_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'sevrage_detail_screen.dart';

/// Ecran de gestion des sevrages - Liste les portees pretes a etre sevrees
class SevrageScreen extends StatefulWidget {
  const SevrageScreen({super.key});

  @override
  State<SevrageScreen> createState() => _SevrageScreenState();
}

class _SevrageScreenState extends State<SevrageScreen> {
  final _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _porteesASevrer =
      []; // portee + accouplement + mere
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerPortees();
  }

  /// Charger toutes les portees pretes a etre sevrees
  Future<void> _chargerPortees() async {
    setState(() => _loading = true);

    try {
      final db = await _dbHelper.database;

      // Recuperer toutes les portees
      final porteesMap = await db.query(
        'portees',
        orderBy: 'date_mise_bas_reelle DESC',
      );
      final portees = porteesMap.map((map) => Portee.fromMap(map)).toList();

      // Pour chaque portee, recuperer les infos de l'accouplement et de la mere
      _porteesASevrer = [];
      for (var portee in portees) {
        // Recuperer l'accouplement
        final accouplementsMap = await db.query(
          'accouplements',
          where: 'id = ?',
          whereArgs: [portee.accouplementId],
        );
        if (accouplementsMap.isEmpty) continue;

        final accouplement = Accouplement.fromMap(accouplementsMap.first);

        // Recuperer la mere
        final mere = await _dbHelper.getLapinById(accouplement.femelleId);
        if (mere == null) continue;

        _porteesASevrer.add({
          'portee': portee,
          'accouplement': accouplement,
          'mere': mere,
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur lors du chargement: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildStats(isDark),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_porteesASevrer.isEmpty)
            Expanded(child: _buildEmptyState(isDark))
          else
            Expanded(child: _buildListePortees(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return StandardHeader(title: 'Sevrages', isDark: isDark);
  }

  Widget _buildStats(bool isDark) {
    if (_loading) return const SizedBox.shrink();

    final porteesPretes = _porteesASevrer.where((data) {
      final portee = data['portee'] as Portee;
      return portee.doitEtreSevres;
    }).length;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              isDark: isDark,
              label: 'Portées totales',
              value: '${_porteesASevrer.length}',
              icon: Icons.pets,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: StatsCard(
              isDark: isDark,
              label: 'Prêtes (35+ jours)',
              value: '$porteesPretes',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return FadeIn(
      child: EmptyState(
        isDark: isDark,
        icon: Icons.grass_outlined,
        title: 'Aucune portée enregistrée',
        subtitle: 'Les portées apparaîtront ici après la mise bas',
      ),
    );
  }

  Widget _buildListePortees(bool isDark) {
    return RefreshIndicator(
      onRefresh: _chargerPortees,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _porteesASevrer.length,
        itemBuilder: (context, index) {
          final data = _porteesASevrer[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildPorteeCard(
              data['portee'] as Portee,
              data['mere'] as Lapin,
              isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPorteeCard(Portee portee, Lapin mere, bool isDark) {
    final estPrete = portee.doitEtreSevres;
    final joursRestants = 35 - portee.ageEnJours;
    final couleurStatut = estPrete ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: estPrete ? AppTheme.primaryGreen : AppTheme.textSecondary,
          width: estPrete ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          // En-tete avec statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: couleurStatut.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: couleurStatut.withValues(alpha: 0.1),
                  child: Icon(
                    estPrete ? Icons.check_circle : Icons.schedule,
                    color: couleurStatut,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portee #${portee.id}',
                        style: AppTheme.titleMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Mere: ${mere.nom}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: couleurStatut,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Text(
                    estPrete ? 'Prete' : '$joursRestants j',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Informations de la portÃ©e
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Naissance',
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(portee.dateMiseBasReelle),
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Age',
                        '${portee.ageEnJours} jours',
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.pets,
                        'Vivants',
                        '${portee.nombreVivants}',
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.show_chart,
                        'Survie',
                        '${portee.tauxSurvie.toStringAsFixed(0)}%',
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton d'action
          if (estPrete)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing16,
                0,
                AppTheme.spacing16,
                AppTheme.spacing16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _demarrerSevrage(portee, mere),
                  icon: const Icon(Icons.grass),
                  label: const Text('Demarrer le sevrage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing16,
                0,
                AppTheme.spacing16,
                AppTheme.spacing16,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      estPrete
                          ? 'Prete a etre sevree'
                          : 'Sevrage recommande dans $joursRestants jour${joursRestants > 1 ? 's' : ''}',
                      style: AppTheme.caption.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: isDark
                ? AppTheme.textLight.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Demarrer le sevrage d'une portee
  void _demarrerSevrage(Portee portee, Lapin mere) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevrageDetailScreen(portee: portee, mere: mere),
      ),
    ).then((success) {
      if (success == true) {
        _chargerPortees(); // Recharger la liste
      }
    });
  }

}
