import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import 'widgets/rapports/registre_elevage_rapport.dart';
import 'widgets/rapports/bilan_mensuel_rapport.dart';
import 'widgets/rapports/performances_rapport.dart';
import 'widgets/rapports/suivi_sanitaire_rapport.dart';
import 'widgets/rapports/rapport_financier_rapport.dart';
import 'widgets/rapports/certificat_vente_rapport.dart';
import 'widgets/rapports/bilan_sanitaire_rapport.dart';
import 'widgets/rapports/analyse_genetique_rapport.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  int _selectedRapport = 0;

  final List<Map<String, dynamic>> _rapports = [
    {
      'title': 'Registre d\'élevage',
      'icon': Icons.book_rounded,
      'description': 'Registre officiel conforme',
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Bilan mensuel',
      'icon': Icons.calendar_month_rounded,
      'description': 'Synthèse du mois',
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Performances',
      'icon': Icons.trending_up_rounded,
      'description': 'Analyse reproducteurs',
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Suivi sanitaire',
      'icon': Icons.medical_services_rounded,
      'description': 'Rapport santé',
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Rapport financier',
      'icon': Icons.attach_money_rounded,
      'description': 'Comptabilité',
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Certificat vente',
      'icon': Icons.receipt_long_rounded,
      'description': 'Avec traçabilité',
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Bilan sanitaire',
      'icon': Icons.health_and_safety_rounded,
      'description': 'État sanitaire complet',
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Analyse génétique',
      'icon': Icons.psychology_rounded,
      'description': 'Consanguinité',
      'color': const Color(0xFF00BCD4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Rapports PDF')),
      body: Column(
        children: [
          // Sélecteur horizontal de rapports
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              height: 120,
              color: Theme.of(context).colorScheme.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _rapports.length,
                itemBuilder: (context, index) {
                  final rapport = _rapports[index];
                  final isSelected = _selectedRapport == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildRapportCard(rapport, isSelected, index),
                  );
                },
              ),
            ),
          ),

          // Contenu du rapport sélectionné
          Expanded(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: _buildRapportContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRapportCard(
    Map<String, dynamic> rapport,
    bool isSelected,
    int index,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRapport = index;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? rapport['color'].withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? rapport['color']
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              rapport['icon'],
              color: isSelected
                  ? rapport['color']
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              rapport['title'],
              style: AppTheme.labelSmall.copyWith(
                color: isSelected
                    ? rapport['color']
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRapportContent() {
    switch (_selectedRapport) {
      case 0:
        return const RegistreElevageRapport();
      case 1:
        return const BilanMensuelRapport();
      case 2:
        return const PerformancesRapport();
      case 3:
        return const SuiviSanitaireRapport();
      case 4:
        return const RapportFinancierRapport();
      case 5:
        return const CertificatVenteRapport();
      case 6:
        return const BilanSanitaireRapport();
      case 7:
        return const AnalyseGenetiqueRapport();
      default:
        return const Center(child: Text('Rapport non disponible'));
    }
  }
}
