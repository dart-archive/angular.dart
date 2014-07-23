library ng_specs;

import 'dart:html' hide Animation;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:unittest/unittest.dart' as unit;
import 'package:guinness/guinness_html.dart' as gns;

export 'dart:html' hide Animation;

export 'package:unittest/unittest.dart' hide expect;
export 'package:guinness/guinness_html.dart';

export 'package:mock/mock.dart';
export 'package:di/di.dart';
export 'package:angular/angular.dart';
export 'package:angular/application.dart';
export 'package:angular/introspection.dart';
export 'package:angular/cache/module.dart';
export 'package:angular/cache/js_cache_register.dart';
export 'package:angular/core/annotation.dart';
export 'package:angular/core/registry.dart';
export 'package:angular/core/module_internal.dart';
export 'package:angular/core_dom/module_internal.dart';
export 'package:angular/core/parser/parser.dart';
export 'package:angular/core/parser/lexer.dart';
export 'package:angular/directive/module.dart';
export 'package:angular/formatter/module.dart';
export 'package:angular/routing/module.dart';
export 'package:angular/animate/module.dart';
export 'package:angular/mock/module.dart';
export 'package:perf_api/perf_api.dart';

es(String html) {
  var div = new DivElement()..setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return new List.from(div.nodes);
}

e(String html) => es(html).first;

Expect expect(actual, [matcher]) {
  final expect = new Expect(actual);
  if (matcher != null) expect.to(matcher);
  return expect;
}

class Expect extends gns.Expect {
  Expect(actual) : super(actual);

  NotExpect get not => new NotExpect(actual);

  void toBeValid() => _expect(actual.valid && !actual.invalid, true, reason: 'Form is not valid');

  void toBePristine() => _expect(actual.pristine && !actual.dirty, true, reason: 'Form is dirty');

  void toHaveText(String text) => _expect(actual, new _TextMatcher(text));

  Function get _expect => gns.guinness.matchers.expect;
}

class NotExpect extends gns.NotExpect {
  NotExpect(actual) : super(actual);

  void toBeValid() => _expect(actual.valid && !actual.invalid, false, reason: 'Form is valid');

  void toBePristine() => _expect(actual.pristine && !actual.dirty, false, reason: 'Form is pristine');

  Function get _expect => gns.guinness.matchers.expect;
}


class _TextMatcher extends unit.Matcher {
  final String expected;

  _TextMatcher(this.expected);

  unit.Description describe(unit.Description description) =>
      description..replace("element matching: ${expected}");

  unit.Description describeMismatch(actual, unit.Description mismatchDescription,
      Map matchState, bool verbose) =>
      mismatchDescription..add(_elementText(actual));

  bool matches(actual, Map matchState) =>
      _elementText(actual) == expected;
}

String _elementText(n) {
  hasShadowRoot(n) => n is Element && n.shadowRoot != null;
  if (n is Iterable) return n.map((nn) => _elementText(nn)).join("");
  if (n is Comment) return '';
  if (n is ContentElement) return _elementText(n.getDistributedNodes());
  if (hasShadowRoot(n)) return _elementText(n.shadowRoot.nodes);
  if (n.nodes == null || n.nodes.isEmpty) return n.text;
  return _elementText(n.nodes);
}


Function _injectify(Function fn) {
  // The function does two things:
  // First: if the it() passed a function, we wrap it in
  //        the "sync" FunctionComposition.
  // Second: when we are calling the FunctionComposition,
  //         we inject "inject" into the middle of the
  //         composition.
  if (fn is! FunctionComposition) fn = sync(fn);
  var fc = fn as FunctionComposition;
  return fc.outer(inject(fc.inner));
}

// Replace guinness syntax elements to inject dependencies.
void beforeEachModule(Function fn) {
  gns.beforeEach(module(fn), priority:1);
}

void beforeEach(Function fn) {
  gns.beforeEach(_injectify(fn));
}

void afterEach(Function fn) {
   gns.afterEach(_injectify(fn));
}

void it(String name, Function fn) {
  gns.it(name, _injectify(fn));
}

void iit(String name, Function fn) {
  gns.iit(name, _injectify(fn));
}

_removeNgBinding(node) {
  if (node is Element) {
    var el = node.clone(true) as Element;
    el.classes.remove('ng-binding');
    el.querySelectorAll(".ng-binding").forEach((Element e) {
      e.classes.remove('ng-binding');
    });
    return el;
  }
  return node;
}

main() {
  gns.beforeEach(setUpInjector, priority:3);
  gns.afterEach(tearDownInjector);

  gns.guinnessEnableHtmlMatchers();
  gns.guinness.matchers.config.preprocessHtml = _removeNgBinding;
}
