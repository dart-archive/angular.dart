library angular.service.cache;

import 'dart:collection';

class CacheStats {
  final int capacity;
  final int size;
  final int hits;
  final int misses;
  CacheStats(int this.capacity, int this.size, int this.hits, int this.misses);
  String toString() =>
      "[CacheStats: capacity: $capacity, size: $size, hits: $hits, misses: $misses]";
}


/**
 * The Cache interface.
 */
abstract class Cache<K, V> {
  /**
   * Returns the value for `key` from the cache.  If `key` is not in the cache,
   * returns `null`.
   */
  V get(K key);
  /**
   * Inserts/Updates the `key` in the cache with `value` and returns the value.
   */
  V put(K key, V value);
  /**
   * Removes `key` from the cache.  If `key` isn't present in the cache, does
   * nothing.
   */
  V remove(K key);
  /**
   * Removes all entries from the cache.
   */
  void removeAll();
  int get capacity;
  int get size;
  CacheStats stats();

  // Debugging helpers.
  String _toString(String typeName);
  String toString() => _toString("$runtimeType");
}


/**
 * Mixin that forwards to a backing cache implementation.
 */
class ForwardingCache<K, V> implements Cache<K, V> {
  Cache<K, V> _backingCache;

  V get(K key) => _backingCache.get(key);
  V put(K key, V value) => _backingCache.put(key, value);
  V remove(K key) => _backingCache.remove(key);
  void removeAll() => _backingCache.removeAll();
  int get capacity => _backingCache.capacity;
  int get size => _backingCache.size;
  CacheStats stats() => _backingCache.stats();
  String _toString(String typeName) => _backingCache._toString(typeName);
  String toString() => _backingCache._toString("$runtimeType");
}


/**
 * An unbounded cache.
 */
class UnboundedCache<K, V> implements Cache<K, V> {
  Map<K, V> _entries = <K, V>{};
  int _hits = 0;
  int _misses = 0;

  V get(K key) {
    V value = _entries[key];
    if (value != null || _entries.containsKey(key)) {
      ++_hits;
    } else {
      ++_misses;
    }
    return value;
  }
  V put(K key, V value) => _entries[key] = value;
  V remove(K key) => _entries.remove(key);
  void removeAll() => _entries.clear();
  int get capacity => 0;
  int get size => _entries.length;
  CacheStats stats() => new CacheStats(capacity, size, _hits, _misses);
  String _toString(String typeName) => "[$typeName: size=${_entries.length}, items=$_entries]";
}


/**
 * Simple LRU cache implementation.
 *
 * The constructor takes an optional 
 */
class _LruCache<K, V> implements Cache<K, V> {
  Map<K, V> _entries = new LinkedHashMap<K, V>();
  int _capacity;
  int _hits = 0;
  int _misses = 0;

  _LruCache({int capacity}) {
    this._capacity = (capacity == null) ? 0 : capacity;
  }

  V get(K key) {
    V value = _entries[key];
    if (value != null || _entries.containsKey(key)) {
      ++_hits;
      // refresh
      _entries.remove(key);
      _entries[key] = value;
    } else {
      ++_misses;
    }
    return value;
  }

  V put(K key, V value) {
    // idempotent.  needed to refresh an existing key.
    _entries.remove(key);
    // _capacity always > 0 but might not be true in some future.
    if (_capacity > 0 && _capacity == _entries.length) {
      // drop oldest entry when at capacity
      // _entries.keys.first is fairly cheap - 2 new calls.
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = value;
    return value;
  }

  V remove(K key) => _entries.remove(key);
  void removeAll() => _entries.clear();
  int get capacity => _capacity;
  int get size => _entries.length;
  CacheStats stats() => new CacheStats(capacity, size, _hits, _misses);

  String _toString(String typeName) =>
      "[$typeName: capacity=$capacity, size=$size, items=$_entries]";
}


class LruCache<K, V> extends Cache<K, V> with ForwardingCache<K, V> {
  LruCache({int capacity}) {
    if (capacity != null && capacity > 0) {
      _backingCache = new _LruCache<K, V>(capacity: capacity);
    } else {
      // When unbounded, LRU has no advantage.
      _backingCache = new UnboundedCache<K, V>();
    }
  }
}
