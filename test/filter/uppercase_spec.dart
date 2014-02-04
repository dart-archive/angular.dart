library uppercase_spec;

import '../_specs.dart';

main() => describe('uppercase', () {
  it('should convert string to uppercase', inject((Parser parse, FilterMap filters) {
    expect(parse('null | uppercase').eval(null, filters)).toEqual(null);
    expect(parse('"foo" | uppercase').eval(null, filters)).toEqual('FOO');
  }));
});
