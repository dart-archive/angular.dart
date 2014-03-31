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


export 'package:angular/bootstrap.dart';
export 'package:angular/core/module.dart';
export 'package:angular/directive/module.dart';
export 'package:angular/introspection.dart';
export 'package:angular/filter/module.dart';
export 'package:angular/routing/module.dart';
export 'package:di/di.dart';
export 'package:route_hierarchical/client.dart' hide childRoute;

