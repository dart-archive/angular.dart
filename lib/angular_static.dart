/**
 * Bootstrapping for Angular applications via code generation, for production.
 *
 * Most angular.dart apps rely on dynamic transformation at compile time to generate the artifacts
 * needed for tree shaking during compilation with `dart2js`. However,
 * if your deployment environment makes it impossible for you to use transformers,
 * you can call [staticApplication](#angular-app-static@id_staticApplication)
 * directly in your `main()` function, and explicitly define the getters, setters, annotations, and
 * factories yourself.
 *
 *     import 'package:angular/angular.dart';
 *     import 'package:angular/angular_static.dart';
 *
 *     class MyModule extends Module {
 *       MyModule() {
 *         type(HelloWorldController);
 *       }
 *     }
 *
 *     main() {
 *       staticApplication()
 *           .addModule(new MyModule())
 *           .run();
 *     }
 *
 *  Note that you must explicitly import both
 * `angular.dart` and `angular_static.dart` at the start of your file. See [staticApplication]
 * (#angular-app-static@id_staticApplication) for more on explicit definitions required with this
 * library.
 *
 */
library angular.app.static;

import 'package:di/static_injector.dart';
import 'package:di/di.dart' show TypeFactory, Injector;
import 'package:angular/bootstrap.dart';
import 'package:angular/core/registry.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/parser_static.dart';
import 'package:angular/core/parser/dynamic_parser.dart';
import 'package:angular/core/registry_static.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_static.dart';

export 'package:angular/core/parser/parser_static.dart' show
    StaticClosureMap;

class _StaticApplication extends Application {
  final Map<Type, TypeFactory> typeFactories;

  _StaticApplication(Map<Type, TypeFactory> this.typeFactories,
               Map<Type, Object> metadata,
               Map<String, FieldGetter> fieldGetters,
               Map<String, FieldSetter> fieldSetters,
               Map<String, Symbol> symbols) {
    ngModule
        ..value(MetadataExtractor, new StaticMetadataExtractor(metadata))
        ..value(FieldGetterFactory, new StaticFieldGetterFactory(fieldGetters))
        ..value(ClosureMap, new StaticClosureMap(fieldGetters, fieldSetters,
            symbols));
  }

  Injector createInjector() =>
      new StaticInjector(modules: modules, typeFactories: typeFactories);
}

Application staticApplication(
    Map<Type, TypeFactory> typeFactories,
    Map<Type, Object> metadata,
    Map<String, FieldGetter> fieldGetters,
    Map<String, FieldSetter> fieldSetters,
    Map<String, Symbol> symbols) {
  return new _StaticApplication(typeFactories, metadata, fieldGetters, fieldSetters,
      symbols);
}
