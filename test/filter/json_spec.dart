library json_spec;

import '../_specs.dart';

main() => describe('json', () {
  it('should convert primitives, array, map to json', inject((Scope scope, Parser parser, FilterMap filters) {
    scope.context['foo'] = [{"string":'foo', "number": 123, "bool": false}];
    expect(parser('foo | json').eval(scope.context, filters)).toEqual('[{"string":"foo","number":123,"bool":false}]');
  }));
});
