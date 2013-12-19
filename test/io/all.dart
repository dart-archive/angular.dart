library all_io_tests;

import 'source_metadata_extractor_spec.dart' as source_metadata_extractor_spec;
import 'expression_extractor_spec.dart' as expression_extractor_spec;
import 'template_cache_generator_spec.dart' as template_cache_generator_spec;

main() {
  source_metadata_extractor_spec.main();
  expression_extractor_spec.main();
  template_cache_generator_spec.main();
}