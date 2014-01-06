library generated_getter_setter_spec;

import '../../_specs.dart';
import 'parser_spec.dart' as parser_spec;
import 'generated_getter_setter.dart' as generated;

main() {
  describe('hybrid getter-setter', () {
    beforeEach(module((Module module) {
      module.type(Parser, implementedBy: DynamicParser);
      module.type(GetterSetter, implementedBy: generated.StaticGetterSetter);
    }));
    parser_spec.main();
  });
}

