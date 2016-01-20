library angular.test.tools.transformer.static_angular_generator_spec;

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/static_angular_generator.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import 'package:guinness2/guinness2.dart';

main() {
  describe('StaticAngularGenerator', () {

    it('should modify applicationFactory', () {
      return tests.applyTransformers(
          setupPhases(generateTemplateCache:false),
          inputs: {
            'angular|lib/application_factory.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/application_factory.dart';
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = applicationFactory()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/application_factory_static.dart';
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_type_to_uri_mapper.dart' as generated_static_type_to_uri_mapper;

class MyModule extends Module {}

main() {
  var app = staticApplicationFactory(generated_static_metadata.typeAnnotations, generated_static_expressions.getters, generated_static_expressions.setters, generated_static_expressions.symbols, generated_static_type_to_uri_mapper.typeToUriMapper)
    .addModule(new MyModule())
    .run();
}
'''
          });
    });

    it('should modify applicationFactory with template cache', () {
      return tests.applyTransformers(setupPhases(),
          inputs: {
            'angular|lib/application_factory.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/application_factory.dart';
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = applicationFactory()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/application_factory_static.dart';
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_type_to_uri_mapper.dart' as generated_static_type_to_uri_mapper;
import 'main_generated_template_cache.dart' as generated_template_cache;

class MyModule extends Module {}

main() {
  var app = staticApplicationFactory(generated_static_metadata.typeAnnotations, generated_static_expressions.getters, generated_static_expressions.setters, generated_static_expressions.symbols, generated_static_type_to_uri_mapper.typeToUriMapper).addModule(generated_template_cache.templateCacheModule)
    .addModule(new MyModule())
    .run();
}
'''
          });
    });

    it('handles prefixed app imports', () {
      return tests.applyTransformers(setupPhases(),
          inputs: {
            'angular|lib/application_factory.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/application_factory.dart' as ng;
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = ng.applicationFactory()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/application_factory_static.dart' as ng;
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_type_to_uri_mapper.dart' as generated_static_type_to_uri_mapper;
import 'main_generated_template_cache.dart' as generated_template_cache;

class MyModule extends Module {}

main() {
  var app = ng.staticApplicationFactory(generated_static_metadata.typeAnnotations, generated_static_expressions.getters, generated_static_expressions.setters, generated_static_expressions.symbols, generated_static_type_to_uri_mapper.typeToUriMapper).addModule(generated_template_cache.templateCacheModule)
    .addModule(new MyModule())
    .run();
}
'''
          });
    });
  });
}

const String libAngularDynamic = '''
library angular.app.factory;
class _NgDynamicApp {}

applicationFactory() => new _DynamicApplication();
''';

const String libDI = '''
class Module {}
''';

List<List<Transformer>> setupPhases({bool generateTemplateCache: true}) {
  var options = new TransformOptions(sdkDirectory: dartSdkDirectory,
  generateTemplateCache: generateTemplateCache);

  var resolvers = new Resolvers(dartSdkDirectory);

  return [
      [new StaticAngularGenerator(options, resolvers)]
  ];
}
