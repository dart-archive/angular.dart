library angular.service.cache;

/**
 * A simple map-backed cache.
 */
class Cache<T> {
  Map<String, Object> _data = <String, Object>{};

  /**
   * Returns the value for `key` from the cache.  If `key` is not in the cache,
   * returns `null`.
   */
  T get(String key) {
    return _data[key];
  }

  /**
   * Inserts/Updates the `key` in the cache with `value` and returns the value.
   */
  T put(String key, T value) {
    return _data[key] = value;
  }

  /**
   * Removes `key` from the cache.  If `key` isn't present in the cache, does
   * nothing.
   */
  void remove(String key) {
    _data.remove(key);
  }

  /**
   * Removes all entries from the cache.
   */
  void removeAll() {
    _data.clear();
  }
}
