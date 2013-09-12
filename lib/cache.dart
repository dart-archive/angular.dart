part of angular;

/**
 * A simple map-backed cache.
 * TODO(pavelgj): add LRU support.
 */
class Cache<T> {
  Map<String, Object> _data = <String, Object>{};

  T get(String key) {
    return _data[key];
  }

  T put(String key, T value) {
    return _data[key] = value;
  }

  void remove(String key) {
    _data.remove(key);
  }

  void removeAll() {
    _data.clear();
  }
}
