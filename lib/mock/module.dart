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
import 'dart:mirrors' as mirrors;

import 'package:angular/angular.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/core_dom/directive_injector.dart';
import 'package:angular/core/parser/parser.dart';
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
part 'mock_platform.dart';
part 'mock_window.dart';

/**
 * Use in addition to [AngularModule] in your tests.
 *
 * [AngularMockModule] provides:
 *
 *   - [TestBed]
 *   - [Probe]
 *   - [MockHttpBackend] instead of [HttpBackend]
 *   - [MockWebPlatform] instead of [WebPlatform]
 *   - [Logger]
 *   - [RethrowExceptionHandler] instead of [ExceptionHandler]
 *   - [VmTurnZone] which displays errors to console;
 */
class AngularMockModule extends Module {
  AngularMockModule() {
    bind(ExceptionHandler, toImplementation: RethrowExceptionHandler);
    bind(TestBed);
    bind(Probe);
    bind(Logger);
    bind(MockHttpBackend);
    bind(Element, toValue: document.body);
    bind(Node, toValue: document.body);
    bind(HttpBackend, toInstanceOf: MOCK_HTTP_BACKEND_KEY);
    bind(VmTurnZone, toFactory: () {
      return new VmTurnZone()
          ..onError = (e, s, LongStackTrace ls) => dump('EXCEPTION: $e\n$s\n$ls');
    }, inject: []);
    bind(Window, toImplementation: MockWindow);
    var mockPlatform = new MockWebPlatform();
    bind(MockWebPlatform, toValue: mockPlatform);
    bind(WebPlatform, toValue: mockPlatform);
    bind(Object, toImplementation: TestContext);
  }
}

/**
 * [DynamicObject] helps testing angular.dart.
 *
 * Setting the test context to an instance of [DynamicObject] avoid having to write a specific class
 * for every new test by allowing the dynamic addition of properties through the use of
 * [Object.noSuchMethod]
 *
 */
@proxy
class DynamicObject {
  Map _locals = {};

  void addProperties(Map<String, dynamic> locals) {
    assert(locals != null);
    _locals.addAll(locals);
  }

  noSuchMethod(Invocation invocation) {
    var pArgs = invocation.positionalArguments;
    var field = mirrors.MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return _locals[field];
    }
    if (invocation.isSetter) {
      field = field.substring(0, field.length - 1);
      return _locals[field] = pArgs[0];
    }
    if (invocation.isMethod) {
      return Function.apply(_locals[field], pArgs, invocation.namedArguments);
    }
    throw new UnimplementedError(field);
  }
}

class TestContext extends DynamicObject {
  final $probes = <String, Probe>{};
}
