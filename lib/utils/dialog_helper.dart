import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Helper pour afficher des dialogs standardisés dans l'application
class DialogHelper {
  /// Dialog de confirmation (Oui/Non)
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDangerous
                    ? AppTheme.error
                    : (confirmColor ?? AppTheme.primaryGreen),
              ),
              const SizedBox(width: AppTheme.spacing12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous
                  ? AppTheme.error
                  : (confirmColor ?? AppTheme.primaryGreen),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Dialog d'information simple
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'OK',
    IconData? icon,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.info),
              const SizedBox(width: AppTheme.spacing12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Dialog d'erreur
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'OK',
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_rounded, color: AppTheme.error),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Dialog d'avertissement
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'Compris',
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppTheme.warning),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Dialog de succès
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'Super !',
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.success),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Dialog de sélection dans une liste
  static Future<T?> showListSelection<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    String? searchHint,
    Widget Function(T)? itemBuilder,
    String cancelLabel = 'Annuler',
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => _ListSelectionDialog<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        searchHint: searchHint,
        itemBuilder: itemBuilder,
        cancelLabel: cancelLabel,
      ),
    );
  }

  /// Bottom sheet standardisé
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pour drag
            if (enableDrag)
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacing8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
              ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: AppTheme.headingMedium)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenu
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: child,
              ),
            ),
            // Actions (optionnel)
            if (actions != null && actions.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Dialog de chargement (non-dismissible)
  static void showLoading({
    required BuildContext context,
    String message = 'Chargement...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Fermer le dialog de chargement
  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }
}

/// Widget interne pour dialog de sélection avec recherche
class _ListSelectionDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? searchHint;
  final Widget Function(T)? itemBuilder;
  final String cancelLabel;

  const _ListSelectionDialog({
    required this.title,
    required this.items,
    required this.itemLabel,
    this.searchHint,
    this.itemBuilder,
    required this.cancelLabel,
  });

  @override
  State<_ListSelectionDialog<T>> createState() =>
      _ListSelectionDialogState<T>();
}

class _ListSelectionDialogState<T> extends State<_ListSelectionDialog<T>> {
  late List<T> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.itemLabel(item).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de recherche (si activée)
            if (widget.searchHint != null) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],
            // Liste
            Flexible(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun résultat',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: widget.itemBuilder != null
                              ? widget.itemBuilder!(item)
                              : Text(widget.itemLabel(item)),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
      ],
    );
  }
}
