library angular.test.tools.transformer.static_angular_generator_spec;

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/static_angular_generator.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import '../../jasmine_syntax.dart';

main() {
  describe('StaticAngularGenerator', () {
    var options = new TransformOptions(
        sdkDirectory: dartSdkDirectory);

    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new StaticAngularGenerator(options, resolvers)]
    ];

    it('should modify ngDynamicApp', () {
      return tests.applyTransformers(phases,
          inputs: {
            'angular|lib/angular_dynamic.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/angular_dynamic.dart';
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = ngDynamicApp()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/angular_static.dart';
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_injector.dart' as generated_static_injector;

class MyModule extends Module {}

main() {
  var app = ngStaticApp(generated_static_injector.factories, generated_static_metadata.typeAnnotations, generated_static_expressions.getters, generated_static_expressions.setters, generated_static_expressions.symbols)
    .addModule(new MyModule())
    .run();
}
'''
          });
    });

    it('handles prefixed app imports', () {
      return tests.applyTransformers(phases,
          inputs: {
            'angular|lib/angular_dynamic.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/angular_dynamic.dart' as ng;
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = ng.ngDynamicApp()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/angular_static.dart' as ng;
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_injector.dart' as generated_static_injector;

class MyModule extends Module {}

main() {
  var app = ng.ngStaticApp(generated_static_injector.factories, generated_static_metadata.typeAnnotations, generated_static_expressions.getters, generated_static_expressions.setters, generated_static_expressions.symbols)
    .addModule(new MyModule())
    .run();
}
'''
          });
    });
  });
}



const String libAngularDynamic = '''
library angular.dynamic;
class _NgDynamicApp {}

ngDynamicApp() => new _NgDynamicApp();
''';

const String libDI = '''
class Module {}
''';
