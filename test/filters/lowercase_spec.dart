library lowercase_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() => describe('lowercase', () {
  it('should convert string to lowercase', inject((Scope scope) {
    expect(scope.$eval('null | lowercase')).toEqual(null);
    expect(scope.$eval('"FOO" | lowercase')).toEqual('foo');
  }));
});
