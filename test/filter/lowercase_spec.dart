library lowercase_spec;

import '../_specs.dart';

main() => describe('lowercase', () {
  it('should convert string to lowercase', inject((Parser parse, FilterMap filters) {
    expect(parse('null | lowercase').eval(null, filters)).toEqual(null);
    expect(parse('"FOO" | lowercase').eval(null, filters)).toEqual('foo');
  }));
});
