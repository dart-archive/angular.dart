part of angular.formatter_internal;

/**
 * Given a Map, returns a list of items which have `key` and `value` property.
 *
 * Usage:
 *
 *     <div ng-repeat="item in {'key1': 'value1', 'key2':'value2'} | arrayify">
 *       {{item.key}}: {{item.value}}
 *     </div>
 */
@Formatter(name:'arrayify')
class Arrayify implements Function {
  List<_KeyValue> call(Map inputMap) {
    if (inputMap == null) return null;
    List<_KeyValue> result = [];
    inputMap.forEach((k, v) => result.add(new _KeyValue(k, v)));
    return result;
  }
}

class _KeyValue<K, V> {
  K key;
  V value;

  _KeyValue(this.key, this.value);
}
