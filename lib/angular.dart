/**
 * Core functionality for angular.dart, a web framework for Dart.
 *
 *
 * You must import the angular library to use it with Dart, like so:
 *
 *      import 'package:angular/angular.dart';
 *
 * The angular.dart library includes Angular's Directive and Filter classes:
 *
 *  - [angular.directive](#angular/angular-directive) lists all the basic directives
 *  - [angular.filter] (#angular/angular-filter) lists all the basic filters
 *
 * You might also want to optionally import the following Angular libraries:
 *
 *   - [angular.animate](#angular/angular-animate) supports CSS animations that modify the
 *   lifecycle of a DOM
 *   element
 *   - [angular.mock](#angular/angular-mock) provides classes and utilities for testing and
 *   prototyping
 *   - [angular.perf](#angular/angular-perf) provides classes to help evaluate performance in your
 *   app
 *
 *
 * Further reading:
 *
 *   - AngularDart [Overview](http://www.angulardart.org)
 *   - [Tutorial](https://angulardart.org/tutorial/)
 *   - [Mailing List](http://groups.google.com/d/forum/angular-dart?hl=en)
 *
 */
library angular;

import 'dart:html' as dom;
import 'dart:js' as js;
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    'angular.animate',
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

import 'package:angular/core/module.dart';
import 'package:angular/core_dom/module.dart';
import 'package:angular/directive/module.dart';
import 'package:angular/filter/module.dart';
import 'package:angular/perf/module.dart';
import 'package:angular/routing/module.dart';

export 'package:di/di.dart';
export 'package:angular/core/module.dart';
export 'package:angular/core_dom/module.dart';
export 'package:angular/core/parser/parser.dart';
export 'package:angular/core/parser/lexer.dart';
export 'package:angular/directive/module.dart';
export 'package:angular/filter/module.dart';
export 'package:angular/routing/module.dart';
export 'package:angular/change_detection/dirty_checking_change_detector.dart'
    show FieldGetter, GetterCache;

part 'bootstrap.dart';
part 'introspection.dart';
