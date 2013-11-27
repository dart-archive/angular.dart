/**
 * Angular is a framework for building single page web applications.
 *
 * Further reading:
 *
 *   - AngularJS [Overview](http://www.angularjs.org)
 *   - [Tutorial](https://github.com/angular/angular.dart.tutorial/wiki)
 *   - [Mailing List](http://groups.google.com/d/forum/angular-dart?hl=en)
 *
 */
library angular;

import 'dart:html' as dom;
import 'dart:js';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

import 'package:angular/core/module.dart';
import 'package:angular/core_dom/module.dart';
import 'package:angular/directive/module.dart';
import 'package:angular/filter/module.dart';
import 'package:angular/perf/module.dart';
import 'package:angular/routing/module.dart';
import 'package:js/js.dart' as js;

export 'package:di/di.dart';
export 'package:angular/core/module.dart';
export 'package:angular/core_dom/module.dart';
export 'package:angular/core/parser/parser_library.dart';
export 'package:angular/directive/module.dart';
export 'package:angular/filter/module.dart';
export 'package:angular/routing/module.dart';

part 'bootstrap.dart';
part 'introspection.dart';
