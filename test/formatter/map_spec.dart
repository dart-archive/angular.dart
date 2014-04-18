library map_spec;

import '../_specs.dart';
import 'package:angular/formatter/module.dart';

void main() {
  describe('mapitems', () {
    it('should convert a map to list of key value pairs', inject((Parser parse, FormatterMap formatters) {
      List result = parse('{"key1": "value1", "key2": "value2"} | mapitems').eval(null, formatters);
      expect(result.map((kv) => kv.key)).toEqual( ["key1", "key2"]);
      expect(result.map((kv) => kv.value)).toEqual( ["value1", "value2"]);
      expect(parse('null | mapitems').eval(null, formatters)).toEqual(null);
    }));
  });
}
