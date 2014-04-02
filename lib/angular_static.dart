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
