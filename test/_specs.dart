library ng_specs;


import 'dart:html';
import 'dart:async' as dartAsync;
import 'package:unittest/unittest.dart' as unit;
import 'package:angular/dom/debug.dart';
import 'dart:mirrors' as mirror;
import 'package:angular/angular.dart';
import 'jasmine_syntax.dart';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import "_log.dart";
import "_http.dart";
import "package:angular/exception_handler.dart";

export 'package:unittest/unittest.dart';
export 'package:angular/dom/debug.dart';
export 'package:angular/angular.dart';
export 'dart:html';
export 'jasmine_syntax.dart' hide main;
export 'package:di/di.dart';
export 'package:unittest/mock.dart';
export 'package:perf_api/perf_api.dart';
export "package:angular/exception_handler.dart";

es(String html) {
  var div = new DivElement();
  div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return div.nodes;
}

e(String html) => es(html).first;

renderedText(n, [bool notShadow = false]) {
  if (n is List) {
    return n.map((nn) => renderedText(nn)).join("");
  }

  if (n is Comment) return '';

  if (!notShadow && n is Element && n.shadowRoot != null) {
    var shadowText = n.shadowRoot.text;
    var domText = renderedText(n, true);
    return shadowText.replaceFirst("SHADOW-CONTENT", domText);
  }

  if (n.nodes == null || n.nodes.length == 0) return n.text;

  return n.nodes.map((cn) => renderedText(cn)).join("");
}

Expect expect(actual, [unit.Matcher matcher = null]) {
  if (matcher != null) {
    unit.expect(actual, matcher);
  }
  return new Expect(actual);
}

class Expect {
  var actual;
  var not;
  Expect(this.actual) {
    not = new NotExpect(this);
  }

  toEqual(expected) => unit.expect(actual, unit.equals(expected));
  toContain(expected) => unit.expect(actual, unit.contains(expected));
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => identical(expected, actual), '$expected'));
  toThrow([exception]) => unit.expect(actual, exception == null ? unit.throws : unit.throwsA(new ExceptionContains(exception)));
  toBeFalsy() => unit.expect(actual, (v) => v == null ? true : v is bool ? v == false : !(v is Object));
  toBeTruthy() => unit.expect(actual, (v) => v is bool ? v == true : v is Object);
  toBeDefined() => unit.expect(actual, (v) => v is Object);
  toBeNull() => unit.expect(actual, unit.isNull);
  toBeNotNull() => unit.expect(actual, unit.isNotNull);

  toHaveBeenCalled() => unit.expect(actual.called, true, reason: 'method not called');
  toHaveBeenCalledOnce() => unit.expect(actual.count, 1, reason: 'method invoked ${actual.count} expected once');

  toHaveClass(cls) => unit.expect(actual.hasClass(cls), true, reason: ' Expected ${actual} to have css class ${cls}');
}

class NotExpect {
  Expect expect;
  get actual => expect.actual;
  NotExpect(this.expect);

  toHaveBeenCalled() => unit.expect(actual.called, false, reason: 'method called');
  toThrow() => actual();

  toHaveClass(cls) => unit.expect(actual.hasClass(cls), false, reason: ' Expected ${actual} to not have css class ${cls}');
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => !identical(expected, actual), '$expected'));
}

class ExceptionContains extends unit.Matcher {

  final _expected;

  const ExceptionContains(this._expected);

  bool matches(item, Map matchState) {
    if (item is String) {
      return item.indexOf(_expected) >= 0;
    }
    return matches('$item', matchState);
  }

  unit.Description describe(unit.Description description) =>
      description.add('exception contains ').addDescriptionOf(_expected);

  unit.Description describeMismatch(item, unit.Description mismatchDescription,
                               Map matchState, bool verbose) {
      return super.describeMismatch('$item', mismatchDescription, matchState,
          verbose);
  }
}

$(selector) {
  return new JQuery(selector);
}

var parserBackend = new ParserBackend(new GetterSetter());

class JQuery implements List<Node> {
  List<Node> _list = [];

  JQuery([selector]) {
    if (selector == null) {
      // do nothing;
    } else if (selector is String) {
      _list.addAll(es(selector));
    } else if (selector is List) {
      _list.addAll(selector);
    } else if (selector is Node) {
      add(selector);
    } else {
      throw selector;
    }
  }

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);

  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else {
      return outer ? node.outerHtml : node.innerHtml;
    }
  }

  accessor(Function getter, Function setter, [value]) {
    // TODO(dart): ?value does not work, since value was passed. :-(
    var setterMode = value != null;
    var result = setterMode ? this : '';
    _list.forEach((node) {
      if (setterMode) {
        setter(node, value);
      } else {
        result = '$result${getter(node)}';
      }
    });
    return result;
  }

  html([String html]) => accessor(
          (n) => _toHtml(n),
          (n, v) => n.setInnerHtml(v, treeSanitizer: new NullTreeSanitizer()),
          html);
  text([String text]) => accessor((n) => n.text, (n, v) => n.text = v, text);
  contents() => fold(new JQuery(), (jq, node) => jq..addAll(node.nodes));
  toString() => fold('', (html, node) => '$html${_toHtml(node, true)}');
  eq(num childIndex) => $(this[childIndex]);
  remove() => forEach((n) => n.remove());
  attr([String name]) => accessor((n) => n.attributes[name], (n, v) => n.attributes[name] = v);
  prop([String name]) => accessor((n) => parserBackend.getter(name)(n, null), (n, v) => parserBackend.setter(name)(n, v));
  textWithShadow() => fold('', (t, n) => '${t}${renderedText(n)}');
  find(selector) => fold(new JQuery(), (jq, n) => jq..addAll(n.queryAll(selector)));
  hasClass(String name) => fold(false, (hasClass, node) => hasClass ? true : node.classes.contains(name));
}

class Logger implements List {
  List<Node> _list = [];

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);
}

List<Function> _asyncQueue = [];
List _asyncErrors = [];

nextTurn([bool runUntilEmpty = false]) {
  // copy the queue as it may change.
  var toRun = new List.from(_asyncQueue);
  _asyncQueue = [];
  toRun.forEach((fn) => fn());

  if (runUntilEmpty && !_asyncQueue.isEmpty) {
    nextTurn(runUntilEmpty);
  }
}

async(Function fn) =>
  () {
    _asyncErrors = [];
    dartAsync.runZonedExperimental(fn,
        onRunAsync: (asyncFn) => _asyncQueue.add(asyncFn),
        onError: (e) => _asyncErrors.add(e));

    _asyncErrors.forEach((e) {
      throw "During runZoned: $e.  Stack:\n${dartAsync.getAttachedStackTrace(e)}";
    });

    expect(_asyncQueue.isEmpty).toBe(true);
  };

class SpecInjector {
  DynamicInjector moduleInjector;
  DynamicInjector injector;
  List<Module> modules = [];
  DirectiveRegistry directives = new DirectiveRegistry();
  List<Function> initFns = [];

  SpecInjector() {
    var moduleModule = new Module()
      ..factory(AngularModule, (Injector injector) => addModule(new AngularModule()))
      ..factory(Module, (Injector injector) => addModule(new Module()));
    moduleInjector = new DynamicInjector(modules: [moduleModule]);
  }

  addModule(module) {
    modules.add(module);
    return module;
  }

  module(Function fn, [declarationStack]) {
    try {
      var initFn = moduleInjector.invoke(fn);
      if (initFn is Function) {
        initFns.add(initFn);
      }
    } catch (e, s) {
      throw "$e\n$s\nDECLARED AT:$declarationStack";
    }
  }

  inject(Function fn, [declarationStack]) {
    try {
      if (injector == null) {
        injector = new DynamicInjector(modules: modules); // Implicit injection is disabled.
        initFns.forEach((fn) => injector.invoke(fn));
      }
      injector.invoke(fn);
    } catch (e, s) {
      throw "$e\n$s\nDECLARED AT:$declarationStack";
    }
  }

  reset() { injector = null; }
}

SpecInjector currentSpecInjector = null;
inject(Function fn) {
  try { throw ''; } catch (e, stack) {
    if (currentSpecInjector == null ) {
      return () {
        return currentSpecInjector.inject(fn, stack);
      };
    } else {
      return currentSpecInjector.inject(fn, stack);
    }
  }
}
module(Function fn) {
  try { throw ''; } catch(e, stack) {
    if (currentSpecInjector == null ) {
      return () {
        return currentSpecInjector.module(fn, stack);
      };
    } else {
      return currentSpecInjector.module(fn, stack);
    }
  }
}

main() {
  beforeEach(() => currentSpecInjector = new SpecInjector());
  beforeEach(module((AngularModule module) {
    module
      ..type(Logger)
      ..type(MockHttp)
      ..type(Logger)
      ..type(MockHttp)
      ..factory(Zone, (_) {
        Zone zone = new Zone();
        zone.onError = (e) => dump('EXCEPTION: $e\n${dartAsync.getAttachedStackTrace(e)}');
        return zone;
      })
      ..type(Log);
  }));
  afterEach(() => currentSpecInjector = null);
}
