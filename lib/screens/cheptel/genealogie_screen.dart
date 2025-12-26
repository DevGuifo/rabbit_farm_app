import 'package:flutter/material.dart';
import '../../models/lapin.dart';
import '../../services/database_helper.dart';

/// Écran pour afficher l'arbre généalogique d'un lapin
class GenealogieScreen extends StatefulWidget {
  final Lapin lapin;

  const GenealogieScreen({super.key, required this.lapin});

  @override
  State<GenealogieScreen> createState() => _GenealogieScreenState();
}

class _GenealogieScreenState extends State<GenealogieScreen> {
  Map<String, dynamic>? _arbreGenealogique;
  double? _tauxConsanguinite;
  bool _isLoading = true;

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

      setState(() {
        _arbreGenealogique = arbre;
        _tauxConsanguinite = taux;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Généalogie de ${widget.lapin.nom}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte du lapin principal
                  _buildLapinCard(widget.lapin, isPrincipal: true),
                  const SizedBox(height: 24),

                  // Taux de consanguinité
                  if (_tauxConsanguinite != null)
                    _buildConsanguiniteCard(_tauxConsanguinite!),
                  const SizedBox(height: 24),

                  // Arbre généalogique
                  Text(
                    'Arbre généalogique (3 générations)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_arbreGenealogique != null)
                    _buildArbreNode(_arbreGenealogique!, level: 0)
                  else
                    const Text('Aucune généalogie disponible'),
                ],
              ),
            ),
    );
  }

  /// Construire un nœud de l'arbre généalogique
  Widget _buildArbreNode(Map<String, dynamic> noeud, {required int level}) {
    if (noeud['lapin'] == null) return const SizedBox.shrink();

    final lapin = noeud['lapin'] as Lapin;
    final hasPere = noeud['pere'] != null;
    final hasMere = noeud['mere'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Le lapin actuel
        if (level > 0)
          Padding(
            padding: EdgeInsets.only(left: level * 24.0),
            child: _buildLapinCard(lapin),
          ),

        // Ses parents
        if (hasPere || hasMere) ...[
          const SizedBox(height: 12),

          // Père
          if (hasPere) ...[
            Padding(
              padding: EdgeInsets.only(left: (level + 1) * 24.0),
              child: Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right, size: 16),
                  const SizedBox(width: 8),
                  const Icon(Icons.male, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('Père', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildArbreNode(noeud['pere'], level: level + 1),
          ],

          // Mère
          if (hasMere) ...[
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: (level + 1) * 24.0),
              child: Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right, size: 16),
                  const SizedBox(width: 8),
                  const Icon(Icons.female, size: 16, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text('Mère', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildArbreNode(noeud['mere'], level: level + 1),
          ],
        ],
      ],
    );
  }

  /// Construire une carte de lapin
  Widget _buildLapinCard(Lapin lapin, {bool isPrincipal = false}) {
    return Card(
      elevation: isPrincipal ? 4 : 1,
      color: isPrincipal
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              lapin.sexe.toLowerCase() == 'mâle' ? Icons.male : Icons.female,
              color: lapin.sexe.toLowerCase() == 'mâle'
                  ? Colors.blue
                  : Colors.pink,
              size: isPrincipal ? 32 : 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lapin.nom,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isPrincipal ? 20 : null,
                    ),
                  ),
                  Text(
                    lapin.race,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    lapin.ageFormate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construire la carte de consanguinité
  Widget _buildConsanguiniteCard(double taux) {
    Color couleur;
    String evaluation;
    IconData icone;

    if (taux < 0.1) {
      couleur = Colors.green;
      evaluation = 'Excellent';
      icone = Icons.check_circle;
    } else if (taux < 0.25) {
      couleur = Colors.orange;
      evaluation = 'Modéré';
      icone = Icons.warning;
    } else {
      couleur = Colors.red;
      evaluation = 'Élevé';
      icone = Icons.error;
    }

    return Card(
      color: couleur.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icone, color: couleur, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taux de consanguinité',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(taux * 100).toStringAsFixed(1)}% - $evaluation',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: couleur,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
