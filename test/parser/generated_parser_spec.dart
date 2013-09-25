library generated_parser_spec;

import '../_specs.dart';
import 'parser_spec.dart' as parser_spec;
import 'generated_functions.dart' as generated_functions;

main() {
  describe('generated parser', () {
    beforeEach(module((AngularModule module) {
      module.type(Parser, implementedBy: StaticParser);
      module.factory(StaticParserFunctions, (Injector injector) {
        return generated_functions.functions(injector.get(FilterMap));
      });
    }));
    parser_spec.main();
  });
}
