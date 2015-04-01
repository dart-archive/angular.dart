library angular.test.tools.transformer.type_relative_uri_generator_spec;

import 'dart:async';

import 'package:angular/tools/transformer/type_relative_uri_generator.dart';
import 'package:angular/tools/transformer/options.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import 'package:guinness/guinness.dart';

main() {
  describe('TypeRelativeUriGenerator', () {
    var options = new TransformOptions(sdkDirectory: dartSdkDirectory);
    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [[new TypeRelativeUriGenerator(options, resolvers)]];

    it('should map types in web directory', () {
      return generates(phases, inputs: {
        'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'dir/foo.dart';

                @Component()
                class A {}

                main() {}
                ''',
        'a|web/dir/foo.dart': '''
                import 'package:angular/angular.dart';

                @Component()
                class B {}
            ''',
        'angular|lib/angular.dart': libAngular,
      },
          imports: [
        'import \'main.dart\' as import_0',
        'import \'dir/foo.dart\' as import_1',
      ],
          types: {'import_0.A': 'main.dart', 'import_1.B': 'dir/foo.dart',});
    });

    it('should map package imports', () {
      return generates(phases, inputs: {
        'a|web/main.dart': '''
                import 'package:b/foo.dart';

                main() {}
                ''',
        'b|lib/foo.dart': '''
                import 'package:angular/angular.dart';

                @Component()
                class B {}
            ''',
        'angular|lib/angular.dart': libAngular,
      },
          imports: ['import \'package:b/foo.dart\' as import_0',],
          types: {'import_0.B': 'package:b/foo.dart',});
    });

    it('should handle no mapped types', () {
      return generates(phases, inputs: {
        'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                main() {}
                ''',
        'angular|lib/angular.dart': libAngular,
      });
    });

    it('should warn on no angular imports', () {
      return generates(phases, inputs: {
        'a|web/main.dart': '''
                main() {}
                ''',
        'angular|lib/angular.dart': libAngular,
      }, messages: [
        'warning: Unable to resolve '
            'angular.core.annotation_src.Component.'
      ]);
    });
  });
}

Future generates(List<List<Transformer>> phases, {Map<String, String> inputs,
    List<String> imports: const [], Map<String, String> types: const {},
    Iterable<String> messages: const []}) {
  var buffer = new StringBuffer();
  buffer.write(header);
  for (var i in imports) {
    buffer.write('$i;\n');
  }
  buffer.write(preamble);
  types.forEach((type, uri) {
    buffer.write("""  $type: Uri.parse(r'''$uri'''),\n""");
  });
  buffer.write('};\n');

  return tests.applyTransformers(phases,
      inputs: inputs,
      results: {'a|web/main_static_type_to_uri_mapper.dart': buffer.toString()},
      messages: messages);
}

const String header = '''
library a.web.main.generated_type_uris;

import 'package:angular/core_dom/type_to_uri_mapper.dart';
''';

const String preamble = r'''

/// Used when URIs have been converted to be page-relative at build time.
class _StaticTypeToUriMapper implements TypeToUriMapper {
  Uri uriForType(Type type) {
    var uri = _uriMapping[type];
    if (uri == null) {
      throw new StateError('Unable to find URI mapping for $type');
    }
    return uri;
  }
}

final typeToUriMapper = new _StaticTypeToUriMapper();

final Map<Type, Uri> _uriMapping = <Type, Uri> {
''';

const String libAngular = '''
library angular.core.annotation_src;

class Component {
  const Component({String templateUrl, String selector});
}
''';
