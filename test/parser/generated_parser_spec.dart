import '../_specs.dart';
import 'parser_spec.dart' as parser_spec;
import 'generated_functions.dart' as generated_functions;

main() {
  describe('generated parser', () {
    beforeEach(module((AngularModule module) {
      module.type(Parser, implementedBy: StaticParser);
      module.value(StaticParserFunctions, generated_functions.functions());
    }));
    parser_spec.main();
  });
}
