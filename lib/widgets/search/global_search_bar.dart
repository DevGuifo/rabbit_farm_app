import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';

/// Barre de recherche globale avec suggestions en temps réel
///
/// Peut être utilisée dans le dashboard ou comme écran modal.
/// Pour la navigation vers les détails, utilisez le callback onResultTap
class GlobalSearchBar extends StatefulWidget {
  /// Mode compact (pour le dashboard) ou plein écran
  final bool compact;

  /// Callback appelé lors d'un tap sur un résultat
  final void Function(SearchResult result)? onResultTap;

  const GlobalSearchBar({super.key, this.compact = false, this.onResultTap});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final SearchService _searchService = SearchService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      setState(() {
        _showResults = _focusNode.hasFocus && _results.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _controller.text;

    if (query.length < 2) {
      setState(() {
        _results = [];
        _showResults = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final results = await _searchService.searchGlobal(query);

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
        _showResults = _focusNode.hasFocus && results.isNotEmpty;
      });
    }
  }

  void _onResultTap(SearchResult result) {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _results = [];
      _showResults = false;
    });

    widget.onResultTap?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de recherche
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _showResults
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Rechercher lapins, cages, médicaments...',
              hintStyle: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _showResults = false;
                        });
                      },
                    )
                  : _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ),

        // Résultats de recherche
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(maxHeight: widget.compact ? 250 : 400),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _results.length,
                separatorBuilder: (_, index) => Divider(
                  height: 1,
                  color: isDark
                      ? AppTheme.textSecondary.withValues(alpha: 0.2)
                      : AppTheme.textSecondary.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return _buildResultItem(result, isDark);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultItem(SearchResult result, bool isDark) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getTypeColor(result.type).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            result.iconEmoji ?? result.type.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(
        result.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        result.subtitle,
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getTypeColor(result.type).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          result.type.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _getTypeColor(result.type),
          ),
        ),
      ),
      onTap: () => _onResultTap(result),
    );
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.lapin:
        return AppTheme.primaryGreen;
      case SearchResultType.lot:
        return AppTheme.info;
      case SearchResultType.cage:
        return AppTheme.warning;
      case SearchResultType.medicament:
        return AppTheme.error;
      case SearchResultType.aliment:
        return Colors.orange;
      case SearchResultType.tache:
        return Colors.purple;
    }
  }
}
