import 'package:flutter/material.dart';
import '../../../../models/lapin.dart';
import 'basic_information_card.dart';
import 'lineage_card.dart';
import 'notes_card.dart';

/// Onglet Identity (Stitch Design)
/// Compose: Quick Glance + Basic Information + Lineage + Notes
class IdentityTab extends StatelessWidget {
  final Lapin lapin;
  final Map<String, Lapin?> parents;
  final Function(Lapin) onParentTap;

  const IdentityTab({
    super.key,
    required this.lapin,
    required this.parents,
    required this.onParentTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Basic Information Card
          BasicInformationCard(lapin: lapin),
          const SizedBox(height: 16),
          // Lineage Card
          LineageCard(parents: parents, onParentTap: onParentTap),
          const SizedBox(height: 16),
          // Notes Card
          NotesCard(
            notes: lapin.notes,
            lastUpdateInfo: null, // MOCK DATA - À implémenter avec historique
          ),
          const SizedBox(height: 120), // Espace pour FAB
        ],
      ),
    );
  }
}
