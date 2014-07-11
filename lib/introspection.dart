/**
* Introspection of Elements for debugging and tests.
*/
library angular.introspection;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'dart:js' as js;
import 'package:di/di.dart';
import 'package:angular/animate/module.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/core_dom/directive_injector.dart' show DirectiveInjector;
import 'package:angular/core/static_keys.dart';


/**
 * A global write only variable which keeps track of objects attached to the
 * elements. This is useful for debugging AngularDart application from the
 * browser's REPL.
 */
var elementExpando = new Expando('element');


ElementProbe _findProbeWalkingUp(dom.Node node, [dom.Node ascendUntil]) {
  while (node != null && node != ascendUntil) {
    var probe = elementExpando[node];
    if (probe != null) return probe;
    node = node.parent;
  }
  return null;
}


_walkProbesInTree(dom.Node node, Function walker) {
  var probe = elementExpando[node];
  if (probe == null || walker(probe) != true) {
    for (var child in node.childNodes) {
      _walkProbesInTree(child, walker);
    }
  }
}


ElementProbe _findProbeInTree(dom.Node node, [dom.Node ascendUntil]) {
  var probe;
  _walkProbesInTree(node, (_probe) {
    probe = _probe;
    return true;
  });
  return (probe != null) ? probe : _findProbeWalkingUp(node, ascendUntil);
}


List<ElementProbe> _findAllProbesInTree(dom.Node node) {
  List<ElementProbe> probes = [];
  _walkProbesInTree(node, probes.add);
  return probes;
}


/**
 * Return the [ElementProbe] object for the closest [Element] in the hierarchy.
 *
 * The node parameter could be:
 * * a [dom.Node],
 * * a CSS selector for this node.
 *
 * **NOTE:** This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The
 * function is not intended to be called from Angular application.
 */
ElementProbe ngProbe(nodeOrSelector) {
  if (nodeOrSelector == null) throw "ngProbe called without node";
  var node = nodeOrSelector;
  if (nodeOrSelector is String) {
    var nodes = ngQuery(dom.document, nodeOrSelector);
    node = (nodes.isNotEmpty) ? nodes.first : null;
  }
  var probe = _findProbeWalkingUp(node);
  if (probe != null) {
    return probe;
  }
  var forWhat = (nodeOrSelector is String) ? "selector" : "node";
  throw "Could not find a probe for the $forWhat '$nodeOrSelector' nor its parents";
}


/**
 * Return the [Injector] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
DirectiveInjector ngInjector(nodeOrSelector) => ngProbe(nodeOrSelector).injector;


/**
 * Return the [Scope] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
Scope ngScope(nodeOrSelector) => ngProbe(nodeOrSelector).scope;


List<dom.Element> ngQuery(dom.Node element, String selector,
                          [String containsText]) {
  var list = [];
  var children = [element];
  if ((element is dom.Element) && element.shadowRoot != null) {
    children.add(element.shadowRoot);
  }
  while (!children.isEmpty) {
    var child = children.removeAt(0);
    child.querySelectorAll(selector).forEach((e) {
      if (containsText == null || e.text.contains(containsText)) list.add(e);
    });
    child.querySelectorAll('*').forEach((e) {
      if (e.shadowRoot != null) children.add(e.shadowRoot);
    });
  }
  return list;
}


/**
 * Return a List of directives associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
List<Object> ngDirectives(nodeOrSelector) => ngProbe(nodeOrSelector).directives;



js.JsObject _jsProbe(ElementProbe probe) {
  return _jsify({
      "element": probe.element,
      "injector": _jsInjector(probe.injector),
      "scope": _jsScopeFromProbe(probe),
      "directives": probe.directives.map((directive) => _jsDirective(directive)),
      "bindings": probe.bindingExpressions,
      "models": probe.modelExpressions
  })..['_dart_'] = probe;
}


js.JsObject _jsInjector(DirectiveInjector injector) =>
    _jsify({"get": injector.get})..['_dart_'] = injector;


js.JsObject _jsScopeFromProbe(ElementProbe probe) =>
    _jsScope(probe.scope, probe.injector.getByKey(SCOPE_STATS_CONFIG_KEY));



// Work around http://dartbug.com/17752
// Proxies a Dart function that accepts up to 10 parameters.
js.JsFunction _jsFunction(Function fn) {
  const Object X = __varargSentinel;
  Function fnCopy = fn;  // workaround a bug.
  return new js.JsFunction.withThis(
      (thisArg, [o1=X, o2=X, o3=X, o4=X, o5=X, o6=X, o7=X, o8=X, o9=X, o10=X]) {
        // Work around a bug in dart 1.4.0 where the closurized variable, fn,
        // gets mysteriously replaced with our own closure function leading to a
        // stack overflow.
        fn = fnCopy;
        if (o10 == null && identical(o9, X)) {
          // Work around another bug in dart 1.4.0.  This bug is not present in
          // dart 1.5.0-dev.2.0.
          // In dart 1.4.0, when running in Dartium (not dart2js), if you invoke
          // a JsFunction from Dart code (either by calling .apply([args]) on it
          // or by calling .callMethod(jsFuncName, [args]) on a JsObject
          // containing the JsFunction, regardless of whether you specified the
          // thisArg keyword parameter, the Dart function is called with the
          // first argument in the thisArg param causing all the arguments to be
          // shifted by one.  We can detect this by the fact that o10 is null
          // but o9 is X (should only happen when o9 got a default value) and
          // work around it by using thisArg as the first parameter.
          return __invokeFn(fn, thisArg, o1, o2, o3, o4, o5, o6, o7, o8, o9);
        } else {
          return __invokeFn(fn, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
        }
      }
      );
}


const Object __varargSentinel = const Object();


__invokeFn(fn, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10) {
  var args = [o1, o2, o3, o4, o5, o6, o7, o8, o9, o10];
  while (args.length > 0 && identical(args.last, __varargSentinel)) {
    args.removeLast();
  }
  return _jsify(Function.apply(fn, args));
}


// Helper function to JSify a Dart object.  While this is *required* to JSify
// the result of a scope.eval(), other uses are not required and are used to
// work around http://dartbug.com/17752 in a convenient way (that bug affects
// dart2js in checked mode.)
_jsify(var obj) {
  if (obj == null || obj is js.JsObject) {
    return obj;
  }
  if (obj is _JsObjectProxyable) {
    return obj._toJsObject();
  }
  if (obj is Function) {
    return _jsFunction(obj);
  }
  if ((obj is Map) || (obj is Iterable)) {
    var mappedObj = (obj is Map) ? 
        new Map.fromIterables(obj.keys, obj.values.map(_jsify)) : obj.map(_jsify);
    if (obj is List) {
      return new js.JsArray.from(mappedObj);
    } else {
      return new js.JsObject.jsify(mappedObj);
    }
  }
  return obj;
}


js.JsObject _jsScope(Scope scope, ScopeStatsConfig config) {
  return _jsify({
      "apply": scope.apply,
      "broadcast": scope.broadcast,
      "context": scope.context,
      "destroy": scope.destroy,
      "digest": scope.rootScope.digest,
      "emit": scope.emit,
      "flush": scope.rootScope.flush,
      "get": (name) => scope.context[name],
      "isAttached": scope.isAttached,
      "isDestroyed": scope.isDestroyed,
      "set": (name, value) => scope.context[name] = value,
      "scopeStatsEnable": () => config.emit = true,
      "scopeStatsDisable": () => config.emit = false,
      r"$eval": (expr) => _jsify(scope.eval(expr)),
  })..['_dart_'] = scope;
}


_jsDirective(directive) => directive;


abstract class _JsObjectProxyable {
  js.JsObject _toJsObject();
}


typedef List<String> _GetExpressionsFromProbe(ElementProbe probe);


/**
 * Returns the "$testability service" object for JS / Protractor use.
 *
 * JS code expects to get a hold of this object in the following way:
 *
 *   // Prereq: There is an "angular" object on window accessible via JS.
 *   var testability = angular.element(document).injector().get('$testability');
 */
class _Testability implements _JsObjectProxyable {
  final dom.Node node;
  final ElementProbe probe;

  _Testability(this.node, this.probe);

  whenStable(callback) {
    probe.injector.get(VmTurnZone).run(
        () => new async.Timer(Duration.ZERO, callback));
  }

  /**
   * Returns a list of all nodes in the selected tree that have an `ng-model`
   * binding specified by the [modelString].  If the optional [exactMatch]
   * parameter is provided and true, it restricts the searches to bindings that
   * are exact matches for [modelString].
   */
  List<dom.Node> findModels(String modelString, [bool exactMatch]) => _findByExpression(
      modelString, exactMatch, (ElementProbe probe) => probe.modelExpressions);

  /**
   * Returns a list of all nodes in the selected tree that have `ng-bind` or
   * mustache bindings specified by the [bindingString].  If the optional
   * [exactMatch] parameter is provided and true, it restricts the searches to
   * bindings that are exact matches for [bindingString].
   */
  List<dom.Node> findBindings(String bindingString, [bool exactMatch]) => _findByExpression(
      bindingString, exactMatch, (ElementProbe probe) => probe.bindingExpressions);

  List<dom.Node> _findByExpression(String query, bool exactMatch, _GetExpressionsFromProbe getExpressions) {
    List<ElementProbe> probes = _findAllProbesInTree(node);
    if (probes.length == 0) {
      probes.add(_findProbeWalkingUp(node));
    }
    List<dom.Node> results = [];
    for (ElementProbe probe in probes) {
      for (String expression in getExpressions(probe)) {
        if(exactMatch == true ? expression == query : expression.indexOf(query) >= 0) {
          results.add(probe.element);
        }
      }
    }
    return results;
  }

  allowAnimations(bool allowed) {
    Animate animate = probe.injector.get(Animate);
    bool previous = animate.animationsAllowed;
    animate.animationsAllowed = (allowed == true);
    return previous;
  }

  js.JsObject _toJsObject() {
    return _jsify({
        'allowAnimations': allowAnimations,
        'findBindings': (bindingString, [exactMatch]) =>
            findBindings(bindingString, exactMatch),
        'findModels': (modelExpressions, [exactMatch]) =>
            findModels(modelExpressions, exactMatch),
        'whenStable': (callback) =>
            whenStable(() => callback.apply([])),
        'notifyWhenNoOutstandingRequests': (callback) {
           print("DEPRECATED: notifyWhenNoOutstandingRequests has been renamed to whenStable");
           whenStable(() => callback.apply([]));
        },
        'probe': () => _jsProbe(probe),
        'scope': () => _jsScopeFromProbe(probe),
        'eval': (expr) => probe.scope.eval(expr),
        'query': (String selector, [String containsText]) =>
            ngQuery(node, selector, containsText),
    })..['_dart_'] = this;
  }
}


_Testability getTestability(dom.Node node) {
  ElementProbe probe = _findProbeInTree(node);
  if (probe == null) {
    throw ("Could not find an ElementProbe for $node.  This might happen "
           "either because there is no Angular directive for that node OR "
           "because your application is running with ElementProbes disabled "
           "(CompilerConfig.elementProbeEnabled = false).");
  }
  return new _Testability(node, probe);
}


void publishToJavaScript() {
  var D = {};
  D['ngProbe'] = (nodeOrSelector) => _jsProbe(ngProbe(nodeOrSelector));
  D['ngInjector'] = (nodeOrSelector) => _jsInjector(ngInjector(nodeOrSelector));
  D['ngScope'] = (nodeOrSelector) => _jsScopeFromProbe(ngProbe(nodeOrSelector));
  D['ngQuery'] = (dom.Node node, String selector, [String containsText]) =>
      ngQuery(node, selector, containsText);
  D['angular'] = {
        'resumeBootstrap': ([arg]) {},
        'getTestability': getTestability,
  };
  js.JsObject J = _jsify(D);
  for (String key in D.keys) {
    js.context[key] = J[key];
  }
}
