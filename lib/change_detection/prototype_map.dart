part of angular.watch_group;

class PrototypeMap<K, V> implements Map<K,V> {
  final Map<K, V> prototype;
  final Map<K, V> self = new Map();
  PrototypeMap(this.prototype);

  operator []=(name, value) => self[name] = value;
  operator [](name) => self.containsKey(name) ? self[name] : prototype[name];

  get isEmpty => self.isEmpty && prototype.isEmpty;
  get isNotEmpty => self.isNotEmpty || prototype.isNotEmpty;
  get keys => self.keys;
  get values => self.values;
  get length => self.length;

  forEach(fn) => self.forEach(fn);
  remove(key) => self.remove(key);
  clear() => self.clear;
  containsKey(key) => self.containsKey(key);
  containsValue(key) => self.containsValue(key);
  addAll(map) => self.addAll(map);
  putIfAbsent(key, fn) => self.putIfAbsent(key, fn);
}
