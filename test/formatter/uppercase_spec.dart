library uppercase_spec;

import '../_specs.dart';

void main() {
  describe('uppercase', () {
    it('should convert string to uppercase', (Parser parse, FormatterMap formatters) {
      expect(parse('null | uppercase').eval(null, formatters)).toEqual(null);
      expect(parse('"foo" | uppercase').eval(null, formatters)).toEqual('FOO');
    });
  });
}
