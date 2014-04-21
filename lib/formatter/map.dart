part of angular.formatter_internal;

/**
 * Returns a list of key-value pairs.
 *
 * Usage:
 *
 *     {{ {'key1': 'value1', 'key2':'value2'} | mapitems }}
 */
@Formatter(name:'mapitems')
class MapItems<K, V> implements Function {
  List<_KeyValue<K, V>> call(Map<K, V> inputMap) {
    if (inputMap == null) return null;
    List<_KeyValue<K, V>> result = [];
    inputMap.forEach((K k, V v) => result.add(new _KeyValue(k, v)) );
    return result;
  }
}

class _KeyValue<K, V> {
  K key;
  V value;

  _KeyValue(this.key, this.value);
}
