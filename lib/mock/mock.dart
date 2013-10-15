library angular.mock;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:mirrors' as mirror;
import 'package:js/js.dart' as js;
import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/utils.dart' as utils;
import 'dart:async' as dartAsync;

part 'debug.dart';
part 'exception_handler.dart';
part 'http_backend.dart';
part 'log.dart';
part 'probe.dart';
part 'test_bed.dart';
part 'zone.dart';

/**
 * Use instead of [AngularModule] in your tests.
 *
 * [AngularMockModule] provides:
 *   - [TestBed]
 *   - [Probe]
 *   - [MockHttpBackend] instead of [HttpBackend]
 *   - [Logger]
 *   - [RethrowExceptionHandler] instead of [ExceptionHandler]
 *   - [Zone] which displays errors to console;
 */
class AngularMockModule extends AngularModule {
  AngularMockModule() {
    type(TestBed);
    type(Probe);
    type(MockHttpBackend);
    factory(HttpBackend, (Injector i) => i.get(MockHttpBackend));
    type(Logger);
    type(ExceptionHandler, implementedBy: RethrowExceptionHandler);
    factory(Zone, (_) {
      Zone zone = new Zone();
      zone.onError = (dynamic e, dynamic s, LongStackTrace ls) => dump('EXCEPTION: $e\n$s\n$ls');
      return zone;
    });
  }
}
