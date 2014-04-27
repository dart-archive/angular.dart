library ng_specs;

import 'dart:html' hide Animation;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:guinness/guinness_html.dart' as gns;

export 'dart:html' hide Animation;

export 'package:unittest/unittest.dart' hide expect;
export 'package:guinness/guinness_html.dart';

export 'package:mock/mock.dart';
export 'package:di/di.dart';
export 'package:di/dynamic_injector.dart';
export 'package:angular/angular.dart';
export 'package:angular/application.dart';
export 'package:angular/introspection.dart';
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
  var div = new DivElement();
  div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return new List.from(div.nodes);
}

e(String html) => es(html).first;


Expect expect(actual, [matcher]) {
  final expect = new Expect(actual);
  if (matcher != null) {
    expect.to(matcher);
  }
  return expect;
}

class Expect extends gns.Expect {
  Expect(actual) : super(actual);

  NotExpect get not => new NotExpect(actual);

  toBeValid() => _expect(actual.valid && !actual.invalid, true,
      reason: 'Form is not valid');

  toBePristine() => _expect(actual.pristine && !actual.dirty, true,
      reason: 'Form is dirty');

  get _expect => gns.guinness.matchers.expect;
}

class NotExpect extends gns.NotExpect {
  NotExpect(actual) : super(actual);

  toBeValid() => _expect(actual.valid && !actual.invalid, false,
      reason: 'Form is valid');

  toBePristine() => _expect(actual.pristine && !actual.dirty, false,
      reason: 'Form is pristine');

  get _expect => gns.guinness.matchers.expect;
}


_injectify(fn) {
  // The function does two things:
  // First: if the it() passed a function, we wrap it in
  //        the "sync" FunctionComposition.
  // Second: when we are calling the FunctionComposition,
  //         we inject "inject" into the middle of the
  //         composition.
  if (fn is! FunctionComposition) fn = sync(fn);
  return fn.outer(inject(fn.inner));
}

// Replace guinness syntax elements to inject dependencies.
beforeEachModule(fn) => gns.beforeEach(module(fn), priority:1);
beforeEach(fn) => gns.beforeEach(_injectify(fn));
afterEach(fn) => gns.afterEach(_injectify(fn));
it(name, fn) => gns.it(name, _injectify(fn));
iit(name, fn) => gns.iit(name, _injectify(fn));

_removeNgBinding(node) {
  if (node is Element) {
    node = node.clone(true) as Element;
    node.classes.remove('ng-binding');
    node.querySelectorAll(".ng-binding").forEach((Element e) {
      e.classes.remove('ng-binding');
    });
    return node;
  }
  return node;
}

main() {
  gns.beforeEach(setUpInjector, priority:3);
  gns.afterEach(tearDownInjector);

  gns.guinnessEnableHtmlMatchers();
  gns.guinness.matchers.config.preprocessHtml = _removeNgBinding;
}
