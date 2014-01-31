/**
 * An import that specifies the minimal set of mirrors used needed
 * for Angular applications.
 *
 * This is only needed if the application is relying on mirrors at runtime and
 * not using generated expressions and a static injector (experimental at this
 * time).
 *
 * To use this, just include this file anywhere in your project (no further
 * steps).
 */
library angular.dart2js_mirrors;

import 'dart:html' as dom;
import 'package:angular/angular.dart';
import 'package:angular/core/service.dart';

/**
 * If you are writing code accessed from Angular expressions, you must include
 * your own @MirrorsUsed annotation or ensure that everything is tagged with
 * the Ng annotations.
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
],
override: const [
    'angular.core',
    'angular.core.parser.eval_access',
    'angular.core.parser.eval_calls',
    'angular.directive',
    'unittest.mock',
    'di.src.reflected_type',
    'mirrors', // di.mirrors
])
import 'dart:mirrors' show MirrorsUsed, MirrorSystem;
