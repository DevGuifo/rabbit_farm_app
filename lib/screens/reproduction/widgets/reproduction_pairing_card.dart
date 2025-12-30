import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/accouplement.dart';
import '../../../models/lapin.dart';
import '../../../models/portee.dart';
import '../../../providers/reproduction_provider.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../theme/app_theme.dart';
import '../../optimisation/palpation_screen.dart';
import '../../optimisation/preparation_nid_screen.dart';
import '../../optimisation/sevrage_screen.dart';
import '../enregistrer_portee_screen.dart';

/// Card pour afficher un accouplement individuel
/// Design: Cohérent avec Cheptel/Santé
class ReproductionPairingCard extends StatelessWidget {
  final bool isDark;
  final Accouplement pairing;
  final Lapin? femelle;
  final Lapin? male;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const ReproductionPairingCard({
    super.key,
    required this.isDark,
    required this.pairing,
    required this.femelle,
    required this.male,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppTheme.cardLight.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: status + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(),
                Text(
                  DateFormat('dd MMM yyyy').format(pairing.dateAccouplement),
                  style: AppTheme.caption.copyWith(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lapins (Femelle + Mâle)
            Row(
              children: [
                Expanded(
                  child: _buildLapinInfo(
                    icon: Icons.female,
                    name: femelle?.nom ?? 'Doe #${pairing.femelleId}',
                    race: femelle?.race ?? '?',
                    color: AppTheme.accentPink,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.favorite,
                    color: AppTheme.primaryNeonGreen,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: _buildLapinInfo(
                    icon: Icons.male,
                    name: male?.nom ?? 'Buck #${pairing.maleId}',
                    race: male?.race ?? '?',
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expected date
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                    : AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.primaryNeonGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Kidding',
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(pairing.dateMiseBasPrevue),
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDaysUntilColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_getDaysUntil()} days',
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getDaysUntilColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Boutons d'action rapides
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    final joursDepuisAccouplement = DateTime.now().difference(pairing.dateAccouplement).inDays;
    final joursAvantMiseBas = pairing.dateMiseBasPrevue.difference(DateTime.now()).inDays;
    final reproductionProvider = Provider.of<ReproductionProvider>(context, listen: false);
    
    // Vérifier si une portée existe
    Portee? portee;
    try {
      portee = reproductionProvider.portees.firstWhere(
        (p) => p.accouplementId == pairing.id,
      );
    } catch (e) {
      portee = null;
    }
    
    final List<Widget> actions = [];
    
    // Bouton Confirmer (si en attente)
    if (pairing.statut == 'en_attente') {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmerAccouplement(context),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Confirmer', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeonGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        ),
      );
    }
    
    // Bouton Palper (si en attente et entre 10-14 jours)
    if (pairing.statut == 'en_attente' && joursDepuisAccouplement >= 10 && joursDepuisAccouplement <= 14) {
      actions.add(
        const SizedBox(width: 8),
      );
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _palper(context),
            icon: const Icon(Icons.healing, size: 18),
            label: const Text('Palper', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        ),
      );
    }
    
    // Bouton Préparer le nid (si confirmé et proche de la mise bas)
    if (pairing.statut == 'confirme' && joursAvantMiseBas <= 3 && joursAvantMiseBas >= 0) {
      actions.add(
        const SizedBox(width: 8),
      );
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _preparerNid(context),
            icon: const Icon(Icons.home_work, size: 18),
            label: const Text('Nid', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        ),
      );
    }
    
    // Bouton Enregistrer portée (si confirmé et après la date de mise bas)
    if (pairing.statut == 'confirme' && joursAvantMiseBas < 0 && portee == null) {
      actions.add(
        const SizedBox(width: 8),
      );
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _enregistrerPortee(context),
            icon: const Icon(Icons.child_care, size: 18),
            label: const Text('Portée', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        ),
      );
    }
    
    // Bouton Sevrer (si terminé et portée existe)
    if (pairing.statut == 'termine' && portee != null) {
      final ageEnJours = DateTime.now().difference(portee.dateMiseBasReelle).inDays;
      if (ageEnJours >= 28 && ageEnJours <= 56) {
        actions.add(
          const SizedBox(width: 8),
        );
        actions.add(
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sevrer(context),
              icon: const Icon(Icons.pets, size: 18),
              label: const Text('Sevrer', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
            ),
          ),
        );
      }
    }
    
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: actions,
    );
  }
  
  Future<void> _confirmerAccouplement(BuildContext context) async {
    try {
      final provider = Provider.of<ReproductionProvider>(context, listen: false);
      await provider.confirmerAccouplement(pairing.id!);
      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Accouplement confirmé');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Erreur: $e');
      }
    }
  }
  
  void _palper(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PalpationScreen(),
      ),
    );
  }
  
  void _preparerNid(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PreparationNidScreen(),
      ),
    );
  }
  
  void _enregistrerPortee(BuildContext context) {
    final reproductionProvider = Provider.of<ReproductionProvider>(context, listen: false);
    final accouplement = reproductionProvider.accouplements.firstWhere(
      (a) => a.id == pairing.id,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnregistrerPorteeScreen(accouplement: accouplement),
      ),
    );
  }
  
  void _sevrer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SevrageScreen(),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusMap = {
      'en_attente': ('Pending', AppTheme.warning),
      'confirme': ('Confirmed', AppTheme.primaryNeonGreen),
      'en_cours': ('In Progress', AppTheme.info),
      'termine': ('Completed', AppTheme.textSecondary),
    };

    final (label, color) =
        statusMap[pairing.statut] ?? ('Unknown', AppTheme.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLapinInfo({
    required IconData icon,
    required String name,
    required String race,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          race,
          style: AppTheme.caption.copyWith(
            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  int _getDaysUntil() {
    return pairing.dateMiseBasPrevue.difference(DateTime.now()).inDays;
  }

  Color _getDaysUntilColor() {
    final days = _getDaysUntil();
    if (days < 0) return AppTheme.error;
    if (days < 3) return AppTheme.warning;
    return AppTheme.primaryNeonGreen;
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  onEditTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppTheme.error),
                title: const Text('Supprimer', style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteTap();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
