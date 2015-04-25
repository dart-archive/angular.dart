part of angular.watch_group;

class PrototypeMap<K, V> implements Map<K,V> {
  final Map<K, V> prototype;
  final Map<K, V> self = new HashMap();

  PrototypeMap(this.prototype);

  void operator []=(K name, V value) {
    self[name] = value;
  }
  V operator [](Object name) => self.containsKey(name) ? self[name] : prototype[name];

  bool get isEmpty => self.isEmpty && prototype.isEmpty;
  bool get isNotEmpty => self.isNotEmpty || prototype.isNotEmpty;
  // todo(vbe) include prototype keys ?
  Iterable<K> get keys => self.keys;
  // todo(vbe) include prototype values ?
  Iterable<V> get values => self.values;
  int get length => self.length;

  void forEach(void fn(K key, V value)) {
    // todo(vbe) include prototype ?
    self.forEach(fn);
  }
  V remove(Object key) => self.remove(key);
  clear() => self.clear;
  // todo(vbe) include prototype ?
  bool containsKey(Object key) => self.containsKey(key);
  // todo(vbe) include prototype ?
  bool containsValue(Object value) => self.containsValue(value);
  void addAll(Map<K, V> map) {
    self.addAll(map);
  }
  // todo(vbe) include prototype ?
  V putIfAbsent(K key, V fn()) => self.putIfAbsent(key, fn);

  toString() => self.toString();
}
