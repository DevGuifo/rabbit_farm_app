import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔍 SELECTOR DIALOG - Dialog générique pour sélection d'éléments
/// ═══════════════════════════════════════════════════════════════════════════
///
/// RÈGLES D'UTILISATION :
/// - Utilisé pour sélectionner un élément parmi une liste
/// - Support recherche intégrée
/// - Retourne l'élément sélectionné ou null
///
/// USAGE SIMPLE :
/// ```dart
/// final lapin = await SelectorDialog.show<Lapin>(
///   context: context,
///   title: 'Sélectionner un lapin',
///   items: lapins,
///   itemBuilder: (lapin) => ListTile(
///     title: Text(lapin.nom),
///     subtitle: Text(lapin.race),
///   ),
/// );
/// ```
///
/// USAGE AVEC RECHERCHE :
/// ```dart
/// final lapin = await SelectorDialog.show<Lapin>(
///   context: context,
///   title: 'Sélectionner un mâle',
///   items: males,
///   searchEnabled: true,
///   searchFilter: (lapin, query) =>
///     lapin.nom.toLowerCase().contains(query.toLowerCase()),
///   itemBuilder: (lapin) => LapinListTile(lapin: lapin),
/// );
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class SelectorDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final bool searchEnabled;
  final bool Function(T item, String query)? searchFilter;
  final String? emptyMessage;
  final IconData? emptyIcon;

  const SelectorDialog({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.searchEnabled = false,
    this.searchFilter,
    this.emptyMessage,
    this.emptyIcon,
  });

  /// Affiche le dialog et retourne l'élément sélectionné
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Widget Function(T item) itemBuilder,
    bool searchEnabled = false,
    bool Function(T item, String query)? searchFilter,
    String? emptyMessage,
    IconData? emptyIcon,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SelectorDialog<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        searchEnabled: searchEnabled,
        searchFilter: searchFilter,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
      ),
    );
  }

  @override
  State<SelectorDialog<T>> createState() => _SelectorDialogState<T>();
}

class _SelectorDialogState<T> extends State<SelectorDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else if (widget.searchFilter != null) {
        _filteredItems = widget.items
            .where((item) => widget.searchFilter!(item, query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de recherche (optionnelle)
            if (widget.searchEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.commonRechercher,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            if (widget.searchEnabled) const SizedBox(height: 16),

            // Liste des éléments
            Flexible(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState(l10n, isDark)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: widget.itemBuilder(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionAnnuler),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.emptyIcon ?? Icons.search_off,
            size: 48,
            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? l10n.aucunResultat,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🐰 LAPIN SELECTOR - Sélecteur spécialisé pour les lapins
/// ═══════════════════════════════════════════════════════════════════════════

class LapinSelectorDialog {
  /// Affiche un sélecteur de lapin mâle
  static Future<T?> showMaleSelector<T>({
    required BuildContext context,
    required List<T> males,
    required String Function(T) getName,
    required String Function(T) getSubtitle,
  }) {
    final l10n = AppLocalizations.of(context);
    return SelectorDialog.show<T>(
      context: context,
      title: l10n.reproSelectionnerMale,
      items: males,
      searchEnabled: males.length > 5,
      searchFilter: (item, query) =>
          getName(item).toLowerCase().contains(query.toLowerCase()),
      emptyMessage: l10n.erreurAucunMaleDisponible,
      emptyIcon: Icons.male,
      itemBuilder: (item) => ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.2),
          child: const Icon(Icons.male, color: AppTheme.accentCyan),
        ),
        title: Text(getName(item)),
        subtitle: Text(getSubtitle(item)),
      ),
    );
  }

  /// Affiche un sélecteur de lapin femelle
  static Future<T?> showFemelleSelector<T>({
    required BuildContext context,
    required List<T> femelles,
    required String Function(T) getName,
    required String Function(T) getSubtitle,
  }) {
    final l10n = AppLocalizations.of(context);
    return SelectorDialog.show<T>(
      context: context,
      title: l10n.reproSelectionnerFemelle,
      items: femelles,
      searchEnabled: femelles.length > 5,
      searchFilter: (item, query) =>
          getName(item).toLowerCase().contains(query.toLowerCase()),
      emptyMessage: l10n.erreurAucuneFemelleDisponible,
      emptyIcon: Icons.female,
      itemBuilder: (item) => ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentPink.withValues(alpha: 0.2),
          child: const Icon(Icons.female, color: AppTheme.accentPink),
        ),
        title: Text(getName(item)),
        subtitle: Text(getSubtitle(item)),
      ),
    );
  }
}
