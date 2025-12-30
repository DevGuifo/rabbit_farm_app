import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../constants/stitch_theme_constants.dart';

/// Card "Notes" pour l'onglet Identity (Stitch Design)
class NotesCard extends StatelessWidget {
  final String? notes;
  final String? lastUpdateInfo; // MOCK DATA - "Updated 2 days ago by Admin"

  const NotesCard({super.key, this.notes, this.lastUpdateInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = StitchTheme.getSurfaceColor(context);
    final outlineColor = StitchTheme.getOutlineColor(context);

    // MOCK DATA si aucune note
    final displayNotes = notes?.isNotEmpty == true
        ? notes!
        : 'Good temperament. Shows high resistance to common infections. Slightly aggressive during feeding time.';
    final displayUpdateInfo = lastUpdateInfo ?? 'Updated 2 days ago by Admin';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: outlineColor),
        boxShadow: StitchTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.textLight.withValues(alpha: 0.05)
                  : StitchTheme.neutral50.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(bottom: BorderSide(color: outlineColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: AppTheme.titleMedium.copyWith(
                    color: isDark
                        ? AppTheme.textLight
                        : AppTheme.stitchTextMainLight,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: const Icon(
                    Icons.sticky_note_2,
                    color: StitchTheme.primaryYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayNotes,
                        style: AppTheme.bodyMedium.copyWith(
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? StitchTheme.neutral300
                              : StitchTheme.neutral700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayUpdateInfo,
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? StitchTheme.neutral500
                              : StitchTheme.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
