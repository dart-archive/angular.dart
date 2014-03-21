/**
*
* Classes and utilities for testing and prototyping in AngularDart.
*
* This is an optional library. You must import it in addition to the [angular.dart]
* (#angular/angular) library,
* like so:
*
*      import 'package:angular/angular.dart';
*      import 'package:angular/mock/module.dart';
*
*
*/
library angular.mock;

import 'dart:async' as dart_async;
import 'dart:collection' show ListBase;
import 'dart:convert' show JSON;
import 'dart:html';
import 'dart:js' as js;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart' as utils;
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:unittest/mock.dart';

export 'zone.dart';

part 'debug.dart';
part 'exception_handler.dart';
part 'http_backend.dart';
part 'log.dart';
part 'probe.dart';
part 'test_bed.dart';
part 'mock_window.dart';
part 'test_injection.dart';

/**
 * Use in addition to [AngularModule] in your tests.
 *
 * [AngularMockModule] provides:
 *
 *   - [TestBed]
 *   - [Probe]
 *   - [MockHttpBackend] instead of [HttpBackend]
 *   - [Logger]
 *   - [RethrowExceptionHandler] instead of [ExceptionHandler]
 *   - [NgZone] which displays errors to console;
 */
class AngularMockModule extends Module {
  AngularMockModule() {
    type(ExceptionHandler, implementedBy: RethrowExceptionHandler);
    type(TestBed);
    type(Probe);
    type(Logger);
    type(MockHttpBackend);
    value(Element, document.body);
    value(Node, document.body);
    factory(HttpBackend, (Injector i) => i.get(MockHttpBackend));
    factory(NgZone, (_) {
      return new NgZone()
        ..onError = (e, s, LongStackTrace ls) => dump('EXCEPTION: $e\n$s\n$ls');
    });
    type(Window, implementedBy: MockWindow);
  }
}
