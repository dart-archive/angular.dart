part of angular.watch_group;

class PrototypeMap<K, V> implements Map<K,V> {
  final Map<K, V> prototype;
  final Map<K, V> self = new Map();
  PrototypeMap(this.prototype);

  operator []=(name, value) => self[name] = value;
  operator [](name) => self.containsKey(name) ? self[name] : prototype[name];
}
