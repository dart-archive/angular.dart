library uppercase_spec;

import '../_specs.dart';

void main() {
  describe('uppercase', () {
    it('should convert string to uppercase', (Parser parse, FilterMap filters) {
      expect(parse('null | uppercase').eval(null, filters)).toEqual(null);
      expect(parse('"foo" | uppercase').eval(null, filters)).toEqual('FOO');
    });
  });
}
