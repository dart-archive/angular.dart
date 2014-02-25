library ng_specs;

import 'dart:html';
import 'package:unittest/unittest.dart' as unit;
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
import 'package:collection/wrappers.dart' show DelegatingList;

import 'jasmine_syntax.dart';

export 'dart:html';
export 'jasmine_syntax.dart' hide main;
export 'package:unittest/unittest.dart';
export 'package:unittest/mock.dart';
export 'package:di/dynamic_injector.dart';
export 'package:angular/angular.dart';
export 'package:angular/mock/module.dart';
export 'package:perf_api/perf_api.dart';

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
  toBeFalsy() => unit.expect(actual, (v) => v == null ? true : v is bool ? v == false : false);
  toBeTruthy() => unit.expect(actual, (v) => v is bool ? v == true : true);
  toBeDefined() => unit.expect(actual, (v) => v != null);
  toBeNull() => unit.expect(actual, unit.isNull);
  toBeNotNull() => unit.expect(actual, unit.isNotNull);

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

$(selector) {
  return new JQuery(selector);
}


class GetterSetter {
  Getter getter(String key) => null;
  Setter setter(String key) => null;
}
var getterSetter = new GetterSetter();

class JQuery extends DelegatingList<Node> {
  JQuery([selector]) : super([]) {
    if (selector == null) {
      // do nothing;
    } else if (selector is String) {
      addAll(es(selector));
    } else if (selector is List) {
      addAll(selector);
    } else if (selector is Node) {
      add(selector);
    } else {
      throw selector;
    }
  }

  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else {
      return outer ? node.outerHtml : node.innerHtml;
    }
  }

  accessor(Function getter, Function setter, [value, single=false]) {
    // TODO(dart): ?value does not work, since value was passed. :-(
    var setterMode = value != null;
    var result = setterMode ? this : '';
    forEach((node) {
      if (setterMode) {
        setter(node, value);
      } else {
        result = single ? getter(node) : '$result${getter(node)}';
      }
    });
    return result;
  }

  html([String html]) => accessor(
          (n) => _toHtml(n),
          (n, v) => n.setInnerHtml(v, treeSanitizer: new NullTreeSanitizer()),
          html);
  val([String text]) => accessor((n) => n.value, (n, v) => n.value = v);
  text([String text]) => accessor((n) => n.text, (n, v) => n.text = v, text);
  contents() => fold(new JQuery(), (jq, node) => jq..addAll(node.nodes));
  toString() => fold('', (html, node) => '$html${_toHtml(node, true)}');
  eq(num childIndex) => $(this[childIndex]);
  remove(_) => forEach((n) => n.remove());
  attr([String name, String value]) => accessor(
          (n) => n.attributes[name],
          (n, v) => n.attributes[name] = v,
          value,
          true);
  prop([String name]) => accessor(
          (n) => getterSetter.getter(name)(n),
          (n, v) => getterSetter.setter(name)(n, v),
          null,
          true);
  textWithShadow() => fold('', (t, n) => '${t}${renderedText(n)}');
  find(selector) => fold(new JQuery(), (jq, n) => jq..addAll(
      (n is Element ? (n as Element).querySelectorAll(selector) : [])));
  hasClass(String name) => fold(false, (hasClass, node) =>
      hasClass || (node is Element && (node as Element).classes.contains(name)));
  addClass(String name) => forEach((node) =>
      (node is Element) ? (node as Element).classes.add(name) : null);
  removeClass(String name) => forEach((node) =>
      (node is Element) ? (node as Element).classes.remove(name) : null);
  css(String name, [String value]) => accessor(
          (Element n) => n.style.getPropertyValue(name),
          (Element n, v) => n.style.setProperty(name, value), value);
  children() => new JQuery(this[0].childNodes);
}


main() {
  beforeEach(setUpInjector);
  beforeEach(() => wrapFn(sync));
  afterEach(tearDownInjector);
}
