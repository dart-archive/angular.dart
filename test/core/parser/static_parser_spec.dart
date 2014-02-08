library static_parser_spec;

import '../../_specs.dart';

var EVAL = { '1': (scope, filters) => 1 };
var ASSIGN = { };

class AlwaysReturnX implements DynamicParser {
  call(String input) => throw 'x';
}

main() {
  describe('static parser', () {
    beforeEach(module((Module m) {
      m.type(Parser, implementedBy: StaticParser);
      m.type(DynamicParser, implementedBy: AlwaysReturnX);
      m.value(StaticParserFunctions, new StaticParserFunctions(EVAL, ASSIGN));
    }));


    it('should run a static function', inject((Parser parser) {
      expect(parser('1').eval(null)).toEqual(1);
    }));


    it('should call the fallback if there is not function', inject((Parser parser) {
      expect(() => parser('not 1')).toThrow('x');
    }));
  });
}
