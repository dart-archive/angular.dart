library all_transformer_tests;

import 'expression_generator_spec.dart' as expression_generator_spec;
import 'metadata_generator_spec.dart' as metadata_generator_spec;
import 'static_angular_generator_spec.dart' as static_angular_generator_spec;

main() {
  expression_generator_spec.main();
  metadata_generator_spec.main();
  static_angular_generator_spec.main();
}
