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
import 'dart:html';
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/core_dom/directive_injector.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/cache/module.dart';
import 'package:angular/mock/static_keys.dart';
import 'package:di/di.dart';
import 'package:mock/mock.dart';

import 'http_backend.dart';

export 'package:angular/mock/test_injection.dart';
export 'http_backend.dart';
export 'zone.dart';

part 'debug.dart';
part 'exception_handler.dart';
part 'log.dart';
part 'probe.dart';
part 'test_bed.dart';
part 'mock_platform_shim.dart';
part 'mock_window.dart';
part 'mock_cache_register.dart';

/**
 * Use in addition to [AngularModule] in your tests.
 *
 * [AngularMockModule] provides:
 *
 *   - [TestBed]
 *   - [Probe]
 *   - [MockHttpBackend] instead of [HttpBackend]
 *   - [MockWebPlatformShim] instead of [WebPlatformShim]
 *   - [Logger]
 *   - [RethrowExceptionHandler] instead of [ExceptionHandler]
 *   - [VmTurnZone] which displays errors to console;
 *   - [MockCacheRegister]
 */
class AngularMockModule extends Module {
  AngularMockModule() {
    bind(ExceptionHandler, toImplementation: RethrowExceptionHandler);
    bind(TestBed);
    bind(Probe);
    bind(Logger);
    bind(MockHttpBackend);
    bind(CacheRegister, toImplementation: MockCacheRegister);
    bind(Element, toValue: document.body);
    bind(Node, toValue: document.body);
    bind(HttpBackend, toInstanceOf: MOCK_HTTP_BACKEND_KEY);
    bind(VmTurnZone, toFactory: () {
      return new VmTurnZone()
        ..onError = (e, s, LongStackTrace ls) => dump('EXCEPTION: $e\n$s\n$ls');
    });
    bind(Window, toImplementation: MockWindow);
    bind(MockWebPlatformShim);
    bind(PlatformJsBasedShim, toInstanceOf: MockWebPlatformShim);
    bind(DefaultPlatformShim, toInstanceOf: MockWebPlatformShim);
  }
}
