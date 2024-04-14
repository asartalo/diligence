class DiScopeCache {
  final Map<Symbol, Object> _cache = {};

  T getSet<T>(Symbol key, T Function() factory) {
    if (!_cache.containsKey(key)) {
      final object = factory();
      _cache[key] = object as Object;
    }
    return _cache[key] as T;
  }
}
