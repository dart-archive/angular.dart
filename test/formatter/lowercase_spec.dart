library lowercase_spec;

import '../_specs.dart';

void main() {
  describe('lowercase', () {
    it('should convert string to lowercase', inject((Parser parse, FormatterMap formatters) {
      expect(parse('null | lowercase').eval(null, formatters)).toEqual(null);
      expect(parse('"FOO" | lowercase').eval(null, formatters)).toEqual('foo');
    }));
  });
}
