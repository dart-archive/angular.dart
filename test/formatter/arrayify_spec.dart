library map_spec;

import '../_specs.dart';

void main() {
  describe('arrayify', () {
    it('should convert a map to list of key value pairs', (Parser parse, FormatterMap formatters) {
      List result = parse('{"key1": "value1", "key2": "value2"} | arrayify').eval(null, formatters);
      expect(result.map((kv) => kv.key)).toEqual(["key1", "key2"]);
      expect(result.map((kv) => kv.value)).toEqual(["value1", "value2"]);
    });

    it('should treat null as noop', (Parser parse, FormatterMap formatters) {
      expect(parse('null | arrayify').eval(null, formatters)).toEqual(null);
    });
  });
}
