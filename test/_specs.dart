library ng_specs;

import 'dart:html' hide Animation;
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:unittest/unittest.dart' as unit;
import 'package:guinness/guinness_html.dart' as gns;
import 'package:angular/core_dom/resource_url_resolver.dart';

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
export 'package:angular/core_dom/type_to_uri_mapper.dart';
export 'package:angular/core/parser/parser.dart';
export 'package:angular/core/parser/lexer.dart';
export 'package:angular/directive/module.dart';
export 'package:angular/formatter/module.dart';
export 'package:angular/routing/module.dart';
export 'package:angular/animate/module.dart';
export 'package:angular/touch/module.dart';
export 'package:angular/mock/module.dart';
export 'package:perf_api/perf_api.dart';

es(String html) {
  var div = new DivElement()..setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return new List.from(div.nodes);
}

e(String html) => es(html).first;

// All our tests files are served under this prefix when run under Karma.  (i.e.
// this file, _specs.dart, is at path /base/test/_specs.dart.  However, if
// you're using a different test server or reconfigured the base prefix, then
// you can set this to something different.
String TEST_SERVER_BASE_PREFIX = "/base/";

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

// For sharding across multiple instances of karma.
// _numKarmaShards values:
//   1:   (default) Use one shard. (i.e. there's no sharding.)
//   0:   No shards!  So no tests are run.  However, the preprocessors are still
//        executed and the browsers are launched.  This can be used to validate
//        the configuration and browsers without running any tests.
//        scripts/travis/build.sh uses this to run the preprocessors once to
//        generate the dart2js output.  It then runs the tests with multiple
//        shards knowing that these shards will all use the dart2js output
//        generated from the dummy run.
//   > 1: Specifies that there are this many number of total karma shards.  If
//        there are N karma shards and T tests, then each shard runs about T/N
//        tests.  In this case, the _shardId - which must be [0, N) - indicates
//        the current karma shard so we can select the appropriate subset of
//        tests to run.
int _numShards = 1;
int _shardId = 0;
int _itCount = 0;
bool _failOnIit = false;

_safeJsGet(dottedName) => dottedName.split(".").fold(
    js.context, (a, b) => (a == null ? a : a[b]));

_initSharding() {
  _failOnIit = (_safeJsGet("__karma__.config.clientArgs.travis") != null);
  _numShards = _safeJsGet("__karma__.config.clientArgs.travis.numKarmaShards");
  _shardId = _safeJsGet("__karma__.config.clientArgs.travis.karmaShardId");
  if (_numShards == null || _shardId == null) {
    _numShards = 1;
    _shardId = 0;
  }
}

void _itFirstTime(String name, Function fn) {
  _initSharding();
  if (_numShards > 0) {
    _it(name, fn);
    it = _it;
  } else {
    // This is a test run who purpose is to prime the dart2js cache.  Do not
    // actually run any tests.
    gns.it('should print the dart2js cache', () {});
    it = (String name, Function fn) {};
  }
}

void _it(String name, Function fn) {
  _itCount += 1;
  if (_itCount % _numShards == _shardId) {
    gns.it(name, _injectify(fn));
  }
}

var it = _itFirstTime;

void iit(String name, Function fn) {
  if (_failOnIit) {
    throw "iit is not allowed when running under a CI server";
  }
  gns.iit(name, _injectify(fn));
}

void ddescribe(String name, Function fn) {
  if (_failOnIit) {
    throw "ddescribe is not allowed when running under a CI server";
  }
  gns.ddescribe(name, fn);
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

  beforeEachModule((Module m) {
    m.bind(ResourceResolverConfig);
  });
}
