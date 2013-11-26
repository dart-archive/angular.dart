library generated_parser_spec;

import '../../_specs.dart';
import 'parser_spec.dart' as parser_spec;
import 'generated_functions.dart' as generated_functions;

class AlwaysThrowError implements DynamicParser {
  call(String x) { throw "Fall-thru to DynamicParser disabled [$x]"; }
  primaryFromToken(Token token, parserError) => null;
}


main() {
  describe('generated parser', () {
    beforeEach(module((Module module) {
      module.type(Parser, implementedBy: StaticParser);
      module.type(DynamicParser, implementedBy: AlwaysThrowError);

      module.factory(StaticParserFunctions, (Injector injector) {
        return generated_functions.functions(injector.get(FilterMap));
      });
    }));
    parser_spec.main();
  });
}
