library angular.dynamic;

import 'package:di/dynamic_injector.dart';
import "package:angular/angular.dart";
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_dynamic.dart';
import 'package:angular/core/registry_dynamic.dart';
import 'package:angular/core/parser/parser_dynamic.dart';
import 'dart:html' as dom;

/**
 * If you are writing code accessed from Angular expressions, you must include
 * your own @MirrorsUsed annotation or ensure that everything is tagged with
 * the Ng annotations.
 *
 * All programs should also include a @MirrorsUsed(override: '*') which
 * tells the compiler that only the explicitly listed libraries will
 * be reflected over.
 *
 * This is a short-term fix until we implement a transformer-based solution
 * which does not rely on mirrors.
 */
@MirrorsUsed(targets: const [
    'angular',
    'angular.core',
    'angular.core.dom',
    'angular.filter',
    'angular.perf',
    'angular.directive',
    'angular.routing',
    'angular.core.parser.Parser',
    'angular.core.parser.dynamic_parser',
    'angular.core.parser.lexer',
    'perf_api',
    List,
    dom.NodeTreeSanitizer,
],
metaTargets: const [
    NgInjectableService,
    NgDirective,
    NgController,
    NgComponent,
    NgFilter
])
import 'dart:mirrors' show MirrorsUsed;

class _NgDynamicApp extends NgApp {
  _NgDynamicApp() {
    ngModule
        ..type(MetadataExtractor, implementedBy: DynamicMetadataExtractor)
        ..type(FieldGetterFactory, implementedBy: DynamicFieldGetterFactory)
        ..type(ClosureMap, implementedBy: DynamicClosureMap);
  }

  Injector createInjector()
      => new DynamicInjector(modules: modules);
}

NgApp ngDynamicApp() => new _NgDynamicApp();
