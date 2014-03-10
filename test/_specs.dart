library ng_specs;

import 'dart:html' hide Animation;
import 'package:unittest/unittest.dart' as unit;
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
import 'package:angular/mock/test_injection.dart';
import 'package:collection/wrappers.dart' show DelegatingList;

import 'jasmine_syntax.dart' as jasmine_syntax;

export 'dart:html' hide Animation;
export 'package:unittest/unittest.dart';
export 'package:unittest/mock.dart';
export 'package:di/dynamic_injector.dart';
export 'package:angular/angular.dart';
export 'package:angular/animate/module.dart';
export 'package:angular/mock/module.dart';
export 'package:angular/mock/test_injection.dart';
export 'package:perf_api/perf_api.dart';

es(String html) {
  var div = new DivElement();
  div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return new List.from(div.nodes);
}

e(String html) => es(html).first;

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
  toBeFalsy() => unit.expect(actual, (v) => v == null ? true : v is bool ? v == false : false);
  toBeTruthy() => unit.expect(actual, (v) => v is bool ? v == true : true);
  toBeDefined() => unit.expect(actual, (v) => v != null);
  toBeNull() => unit.expect(actual, unit.isNull);
  toBeNotNull() => unit.expect(actual, unit.isNotNull);

  toHaveHtml(expected) => unit.expect(_toHtml(actual), unit.equals(expected));
  toHaveText(expected) => unit.expect(_elementText(actual), unit.equals(expected));

  toHaveBeenCalled() => unit.expect(actual.called, true, reason: 'method not called');
  toHaveBeenCalledOnce() => unit.expect(actual.count, 1, reason: 'method invoked ${actual.count} expected once');
  toHaveBeenCalledWith([a,b,c,d,e,f]) =>
      unit.expect(actual.firstArgsMatch(a,b,c,d,e,f), true,
      reason: 'method invoked with correct arguments');
  toHaveBeenCalledOnceWith([a,b,c,d,e,f]) =>
      unit.expect(actual.count == 1 && actual.firstArgsMatch(a,b,c,d,e,f),
                 true,
                 reason: 'method invoked once with correct arguments. (Called ${actual.count} times)');

  toHaveClass(cls) => unit.expect(actual.classes.contains(cls), true, reason: ' Expected ${actual} to have css class ${cls}');

  toEqualSelect(options) {
    var actualOptions = [];

    for (var option in actual.querySelectorAll('option')) {
      if (option.selected) {
        actualOptions.add([option.value]);
      } else {
        actualOptions.add(option.value);
      }
    }
    return unit.expect(actualOptions, options);
  }

  toEqualValid() {
    // TODO: implement onece we have forms
  }
  toEqualInvalid() {
    // TODO: implement onece we have forms
  }
  toEqualPristine() {
    // TODO: implement onece we have forms
  }
  toEqualDirty() {
    // TODO: implement onece we have forms
  }


  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else if (node is DocumentFragment) {
      var acc = '';
      node.childNodes.forEach((n) { acc += _toHtml(n, true); });
      return acc;
    } else if (node is List) {
      var acc = '';
      node.forEach((n) { acc += _toHtml(n); });
      return acc;
    } else if (node is Element) {
      // Remove all the "ng-binding" internal classes
      node = node.clone(true) as Element;
      node.classes.remove('ng-binding');
      node.querySelectorAll(".ng-binding").forEach((Element e) {
        e.classes.remove('ng-binding');
      });
      var htmlString = outer ? node.outerHtml : node.innerHtml;
      // Strip out empty class attributes.  This seems like a Dart bug...
      return htmlString.replaceAll(' class=""', '').trim();
    } else {
      throw "JQuery._toHtml not implemented for node type [${node.nodeType}]";
    }
  }

  _elementText(n, [bool notShadow = false]) {
    if (n is List) {
      return n.map((nn) => _elementText(nn)).join("");
    }

    if (n is Comment) return '';

    if (!notShadow && n is Element && n.shadowRoot != null) {
      var shadowText = n.shadowRoot.text;
      var domText = _elementText(n, true);
      return shadowText.replaceFirst("SHADOW-CONTENT", domText);
    }

    if (n.nodes == null || n.nodes.length == 0) return n.text;

    return n.nodes.map((cn) => _elementText(cn)).join("");
  }
}

class NotExpect {
  Expect expect;
  get actual => expect.actual;
  NotExpect(this.expect);

  toHaveBeenCalled() => unit.expect(actual.called, false, reason: 'method called');
  toThrow() => actual();

  toHaveClass(cls) => unit.expect(actual.classes.contains(cls), false, reason: ' Expected ${actual} to not have css class ${cls}');
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => !identical(expected, actual), 'not $expected'));
  toEqual(expected) => unit.expect(actual,
      unit.predicate((actual) => expected != actual, 'not $expected'));
  toContain(expected) => unit.expect(actual,
      unit.predicate((actual) => !actual.contains(expected), 'not $expected'));
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

// TODO: Decide if we want this function to be called 'es' or '$'
$(String selector) =>
  es(selector);

class GetterSetter {
  Getter getter(String key) => null;
  Setter setter(String key) => null;
}
var getterSetter = new GetterSetter();

_injectify(fn) {
  // The function does two things:
  // First: if the it() passed a function, we wrap it in
  //        the "sync" FunctionComposition.
  // Second: when we are calling the FunctionComposition,
  //         we inject "inject" into the middle of the
  //         composition.
  if (fn is! FunctionComposition) {
    fn = sync(fn);
  }
  return fn.outer(inject(fn.inner));
}

// Jasmine syntax
beforeEachModule(fn) => jasmine_syntax.beforeEach(module(fn), priority:1);
beforeEach(fn) => jasmine_syntax.beforeEach(_injectify(fn));
afterEach(fn) => jasmine_syntax.afterEach(_injectify(fn));
it(name, fn) => jasmine_syntax.it(name, _injectify(fn));
iit(name, fn) => jasmine_syntax.iit(name, _injectify(fn));
xit(name, fn) => jasmine_syntax.xit(name, fn);
xdescribe(name, fn) => jasmine_syntax.xdescribe(name, fn);
ddescribe(name, fn) => jasmine_syntax.ddescribe(name, fn);
describe(name, fn) => jasmine_syntax.describe(name, fn);

var jasmine = jasmine_syntax.jasmine;


main() {
  jasmine_syntax.beforeEach(setUpInjector, priority:3);
  jasmine_syntax.afterEach(tearDownInjector);
}
