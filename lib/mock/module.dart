library angular.mock;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:mirrors' as mirror;
import 'dart:async' as dartAsync;
import '../angular.dart';
import '../utils.dart' as utils;
import 'package:js/js.dart' as js;
import 'package:di/di.dart';

part 'debug.dart';
part 'exception_handler.dart';
part 'http_backend.dart';
part 'log.dart';
part 'probe.dart';
part 'test_bed.dart';
part 'zone.dart';

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
 *   - [ng.Zone] which displays errors to console;
 */
class AngularMockModule extends Module {
  AngularMockModule() {
    var mockHttpBackend = new MockHttpBackend();

    value(MockHttpBackend, mockHttpBackend);
    value(HttpBackend, mockHttpBackend);

    type(TestBed);
    type(Probe);
    type(Logger);
    type(ExceptionHandler, implementedBy: RethrowExceptionHandler);
    factory(Zone, (_) {
      Zone zone = new Zone();
      zone.onError = (dynamic e, dynamic s, LongStackTrace ls) => dump('EXCEPTION: $e\n$s\n$ls');
      return zone;
    });
  }
}
