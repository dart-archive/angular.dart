library ng_specs;

import 'dart:html' hide Animation;
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

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

  Function get _expect => gns.guinness.matchers.expect;
}

class NotExpect extends gns.NotExpect {
  NotExpect(actual) : super(actual);

  void toBeValid() => _expect(actual.valid && !actual.invalid, false, reason: 'Form is valid');

  void toBePristine() => _expect(actual.pristine && !actual.dirty, false, reason: 'Form is pristine');

  Function get _expect => gns.guinness.matchers.expect;
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

// For sharding across multiple instances of karma.
var _numShards = 1;
var _shardId = 0;
var _itCount = 0;

_initSharding() {
  var window = js.context['window'];
  print("ckck:1: $window");
  var karma = js.context['__karma__'];
  print("ckck:2: $karma");
  if (karma == null) return;
  print("ckck:3");
  var config = karma['config'];
  print("ckck:4");
  if (config == null) return;
  print("ckck:5");
  var args = config['args'];
  print("ckck:6");
  if (args == null) return;
  print("ckck:7");
  // args = _toDartArray(args);
  print("ckck:8: $args");
  if (args.length != 2) return;
  print("ckck:9");
  _numShards = int.parse(args[0]);
  print("ckck:10");
  _shardId = int.parse(args[1]);
  print("ckck:11");
  print("\n\nCKCK: Initted sharding: $_numShards and $_shardId");
  print("ckck:12");
}

void _itFirstTime(String name, Function fn) {
  print("CKCK: _itFirstTime");
  it = _it;
  _initSharding();
  _it(name, fn);
}

void _it(String name, Function fn) {
  _itCount += 1;
  if (_itCount % _numShards == _shardId) {
    gns.it(name, _injectify(fn));
  }
}

var it = _itFirstTime;

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
