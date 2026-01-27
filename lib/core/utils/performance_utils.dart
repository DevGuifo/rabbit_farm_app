import 'dart:async';
import 'package:flutter/material.dart';

/// Utilitaires pour optimiser les performances de l'application

/// Cache simple pour mémoriser les résultats de calculs coûteux
class MemoizedCache<K, V> {
  final Map<K, V> _cache = {};
  final V Function(K key) _compute;

  MemoizedCache(this._compute);

  V get(K key) {
    if (!_cache.containsKey(key)) {
      _cache[key] = _compute(key);
    }
    return _cache[key]!;
  }

  void clear() => _cache.clear();
  void invalidate(K key) => _cache.remove(key);
}

/// Extension pour optimiser les ListView
extension ListViewPerformance on ListView {
  /// Créer une ListView optimisée avec cacheExtent et itemExtent
  static ListView optimized({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double? itemExtent,
    double cacheExtent = 250.0,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    ScrollController? controller,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent, // Améliore les performances si toutes les items ont la même hauteur
      cacheExtent: cacheExtent, // Cache les widgets hors écran
      padding: padding,
      physics: physics,
      controller: controller,
    );
  }
}

/// Widget wrapper pour éviter les rebuilds inutiles
class OptimizedBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final bool rebuild;

  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.rebuild = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!rebuild) {
      return builder(context);
    }
    return builder(context);
  }
}

/// Debouncer pour limiter la fréquence des appels
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}
