import 'package:flutter/material.dart';
import '../../models/lapin.dart';
import '../../models/portee.dart';
import '../../services/database_helper.dart';
import 'genealogie/widgets/rabbit_genealogy_card.dart';
import 'genealogie/widgets/litter_card.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Écran pour afficher l'arbre généalogique d'un lapin avec design Stitch
class GenealogieScreen extends StatefulWidget {
  final Lapin lapin;

  const GenealogieScreen({super.key, required this.lapin});

  @override
  State<GenealogieScreen> createState() => _GenealogieScreenState();
}

class _GenealogieScreenState extends State<GenealogieScreen> {
  double? _tauxConsanguinite;
  List<Portee> _portees = [];
  bool _isLoading = true;

  // Ancêtres extraits
  Lapin? _pere;
  Lapin? _mere;
  Lapin? _grandPerePaternel;
  Lapin? _grandMerePaternel;
  Lapin? _grandPereMaternal;
  Lapin? _grandMereMaternal;

  @override
  void initState() {
    super.initState();
    _chargerGenealogy();
  }

  Future<void> _chargerGenealogy() async {
    setState(() => _isLoading = true);

    try {
      final arbre = await DatabaseHelper.instance.getAncetres(
        widget.lapin.id!,
        generations: 3,
      );
      final taux = await DatabaseHelper.instance.calculerConsanguinite(
        widget.lapin.id!,
      );

      // Charger les portées via les accouplements
      final accouplements = await DatabaseHelper.instance.getAllAccouplements();
      final accouplementsLapin = accouplements.where((a) {
        return a.femelleId == widget.lapin.id || a.maleId == widget.lapin.id;
      }).toList();

      // Charger les portées des accouplements de ce lapin
      final toutesPortees = await DatabaseHelper.instance.getAllPortees();
      final portees = toutesPortees.where((p) {
        return accouplementsLapin.any((a) => a.id == p.accouplementId);
      }).toList();

      // Extraire les ancêtres
      _extraireAncetres(arbre);

      setState(() {
        _tauxConsanguinite = taux;
        _portees = portees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _extraireAncetres(Map<String, dynamic>? arbre) {
    if (arbre == null) return;

    // Parents
    if (arbre['pere'] != null) {
      _pere = arbre['pere']['lapin'] as Lapin?;
      // Grands-parents paternels
      if (arbre['pere']['pere'] != null) {
        _grandPerePaternel = arbre['pere']['pere']['lapin'] as Lapin?;
      }
      if (arbre['pere']['mere'] != null) {
        _grandMerePaternel = arbre['pere']['mere']['lapin'] as Lapin?;
      }
    }

    if (arbre['mere'] != null) {
      _mere = arbre['mere']['lapin'] as Lapin?;
      // Grands-parents maternels
      if (arbre['mere']['pere'] != null) {
        _grandPereMaternal = arbre['mere']['pere']['lapin'] as Lapin?;
      }
      if (arbre['mere']['mere'] != null) {
        _grandMereMaternal = arbre['mere']['mere']['lapin'] as Lapin?;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Genealogy View', style: AppTheme.titleLarge),
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Grands-Parents
                  _buildSectionTitle('GRANDPARENTS', isDark),
                  const SizedBox(height: 12),
                  _buildGrandparentsGrid(),
                  const SizedBox(height: 24),

                  // Section Parents
                  _buildSectionTitle('PARENTS', isDark),
                  const SizedBox(height: 12),
                  _buildParentsRow(),
                  const SizedBox(height: 24),

                  // Carte du lapin sujet
                  _buildSectionTitle('SUBJECT', isDark),
                  const SizedBox(height: 12),
                  RabbitGenealogyCard(lapin: widget.lapin, isSubject: true),
                  const SizedBox(height: 16),

                  // Taux de consanguinité
                  if (_tauxConsanguinite != null)
                    _buildConsanguiniteChip(_tauxConsanguinite!, isDark),
                  const SizedBox(height: 24),

                  // Section Offspring
                  if (_portees.isNotEmpty) ...[
                    _buildSectionTitle('OFFSPRING / LITTERS', isDark),
                    const SizedBox(height: 12),
                    ..._portees.map((portee) => LitterCard(portee: portee)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTheme.caption.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: isDark
            ? AppTheme.textLight.withValues(alpha: 0.7)
            : AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildGrandparentsGrid() {
    return Row(
      children: [
        // Côté paternel
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RabbitGenealogyCard(
                      lapin: _grandPerePaternel,
                      isUnknown: _grandPerePaternel == null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RabbitGenealogyCard(
                      lapin: _grandMerePaternel,
                      isUnknown: _grandMerePaternel == null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Côté maternel
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RabbitGenealogyCard(
                      lapin: _grandPereMaternal,
                      isUnknown: _grandPereMaternal == null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RabbitGenealogyCard(
                      lapin: _grandMereMaternal,
                      isUnknown: _grandMereMaternal == null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentsRow() {
    return Row(
      children: [
        Expanded(
          child: RabbitGenealogyCard(
            lapin: _pere,
            isParent: true,
            isUnknown: _pere == null,
            onTap: _pere != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GenealogieScreen(lapin: _pere!),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RabbitGenealogyCard(
            lapin: _mere,
            isParent: true,
            isUnknown: _mere == null,
            onTap: _mere != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GenealogieScreen(lapin: _mere!),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildConsanguiniteChip(double taux, bool isDark) {
    Color couleur;
    String evaluation;

    if (taux < 0.1) {
      couleur = AppTheme.primaryGreen;
      evaluation = 'Excellent';
    } else if (taux < 0.25) {
      couleur = AppTheme.warning;
      evaluation = 'Modéré';
    } else {
      couleur = AppTheme.error;
      evaluation = 'Élevé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 16, color: couleur),
          const SizedBox(width: 8),
          Text(
            'Taux de consanguinité: ${(taux * 100).toStringAsFixed(1)}% ($evaluation)',
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
