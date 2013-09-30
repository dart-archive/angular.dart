library uppercase_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() => describe('uppercase', () {
  it('should convert string to uppercase', inject((Scope scope) {
    expect(scope.$eval('null | uppercase')).toEqual(null);
    expect(scope.$eval('"foo" | uppercase')).toEqual('FOO');
  }));
});
