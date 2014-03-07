library generated_getter_setter_spec;

import '../../_specs.dart';
import 'parser_spec.dart' as parser_spec;
import 'generated_getter_setter.dart' as gen;

main() {
  describe('hybrid getter-setter', () {
    beforeEachModule((Module module) {
      module..type(Parser, implementedBy: DynamicParser)
            ..value(ClosureMap, gen.closureMap);
    });
    parser_spec.main();
  });
}
