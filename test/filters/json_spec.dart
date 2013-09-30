library json_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() => describe('json', () {
  it('should convert primitives, array, map to json', inject((Scope scope) {
    scope.foo = [{"string":'foo', "number": 123, "bool": false}];
    expect(scope.$eval('foo | json')).toEqual('[{"string":"foo","number":123,"bool":false}]');
  }));
});
