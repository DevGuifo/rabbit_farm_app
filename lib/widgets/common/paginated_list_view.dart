import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Widget de pagination pour listes volumineuses (500+ éléments)
///
/// Affiche les données par pages avec navigation et statistiques.
/// Optimisé pour la performance avec lazy loading.
class PaginatedListView<T> extends StatefulWidget {
  /// Liste complète des éléments
  final List<T> items;

  /// Nombre d'éléments par page
  final int itemsPerPage;

  /// Constructeur de widget pour chaque élément
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Callback lors du tap sur un élément
  final void Function(T item)? onItemTap;

  /// Widget à afficher si la liste est vide
  final Widget? emptyWidget;

  /// Hauteur fixe des éléments (pour optimisation)
  final double? itemExtent;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemsPerPage = 50,
    this.onItemTap,
    this.emptyWidget,
    this.itemExtent,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  int get _totalPages => (widget.items.length / widget.itemsPerPage).ceil();

  int get _startIndex => _currentPage * widget.itemsPerPage;

  int get _endIndex =>
      (_startIndex + widget.itemsPerPage).clamp(0, widget.items.length);

  List<T> get _currentPageItems {
    if (widget.items.isEmpty) return [];
    return widget.items.sublist(_startIndex, _endIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to first page if items change significantly
    if (widget.items.length != oldWidget.items.length) {
      if (_currentPage >= _totalPages) {
        setState(() => _currentPage = (_totalPages - 1).clamp(0, _totalPages));
      }
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() => _currentPage = page);
      _scrollController.jumpTo(0);
    }
  }

  void _previousPage() => _goToPage(_currentPage - 1);
  void _nextPage() => _goToPage(_currentPage + 1);

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('Aucun element'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header avec pagination
        _buildPaginationHeader(isDark),

        // Liste des éléments
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _currentPageItems.length,
            itemExtent: widget.itemExtent,
            cacheExtent: 300,
            itemBuilder: (context, index) {
              final item = _currentPageItems[index];
              final globalIndex = _startIndex + index;
              return widget.itemBuilder(context, item, globalIndex);
            },
          ),
        ),

        // Footer avec navigation rapide
        if (_totalPages > 1) _buildPaginationFooter(isDark),
      ],
    );
  }

  Widget _buildPaginationHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Compteur
          Text(
            '${_startIndex + 1}-$_endIndex sur ${widget.items.length}',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Navigation rapide
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
                tooltip: 'Premiere page',
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? _previousPage : null,
                tooltip: 'Page precedente',
                iconSize: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                tooltip: 'Page suivante',
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages - 1
                    ? () => _goToPage(_totalPages - 1)
                    : null,
                tooltip: 'Derniere page',
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Boutons de pages (max 5 visibles)
          ..._buildPageButtons(isDark),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons(bool isDark) {
    final buttons = <Widget>[];
    final maxVisible = 5;

    int start = (_currentPage - maxVisible ~/ 2).clamp(
      0,
      _totalPages - maxVisible,
    );
    if (start < 0) start = 0;

    int end = (start + maxVisible).clamp(0, _totalPages);

    for (int i = start; i < end; i++) {
      final isSelected = i == _currentPage;
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _goToPage(i),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}

/// Extension pour ajouter facilement la pagination à une liste
extension PaginationExtension<T> on List<T> {
  /// Vérifie si la liste est assez grande pour justifier la pagination
  bool get needsPagination => length > 50;

  /// Retourne le nombre de pages avec la taille donnée
  int pageCount([int pageSize = 50]) => (length / pageSize).ceil();
}
