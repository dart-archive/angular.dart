library json_spec;

import '../_specs.dart';

void main() {
  describe('json', () {
    it('should convert primitives, array, map to json', inject((Scope scope, Parser parser, FormatterMap formatters) {
      scope.context['foo'] = [{"string":'foo', "number": 123, "bool": false}];
      expect(parser('foo | json').eval(scope.context, formatters)).toEqual('[{"string":"foo","number":123,"bool":false}]');
    }));
  });
}
