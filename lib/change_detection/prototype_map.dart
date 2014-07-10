part of angular.watch_group;

class PrototypeMap<K, V> extends MicroMap<K,V> {
  final Map<K, V> prototype;

  PrototypeMap(this.prototype);

  V operator [](name) => containsKey(name) ? super[name] : prototype[name];

  bool get isEmpty => count == 0 && prototype.isEmpty;
  bool get isNotEmpty => count != 0 || prototype.isNotEmpty;
}
