library angular.introspection_expando;

import 'dart:html' as dom;
import 'dart:js' as js;

import 'package:di/di.dart';
import 'package:angular/introspection.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/directive/module.dart';

/**
 * A global write only variable which keeps track of objects attached to the
 * elements. This is useful for debugging AngularDart application from the
 * browser's REPL.
 */
var elementExpando = new Expando('element');

publishToJavaScript() {
  js.context
    ..['ngProbe'] = new js.JsFunction.withThis((_, dom.Node node) => _jsProbe(ngProbe(node)))
    ..['ngInjector'] = new js.JsFunction.withThis((_, dom.Node node) => _jsInjector(ngInjector(node)))
    ..['ngScope'] = new js.JsFunction.withThis((_, dom.Node node) => _jsScope(ngScope(node)))
    ..['ngQuery'] = new js.JsFunction.withThis((_, dom.Node node, String selector, [String containsText]) =>
  new js.JsArray.from(ngQuery(node, selector, containsText)));
}

js.JsObject _jsProbe(ElementProbe probe) {
  return new js.JsObject.jsify({
      "element": probe.element,
      "injector": _jsInjector(probe.injector),
      "scope": _jsScope(probe.scope),
      "directives": probe.directives.map((directive) => _jsDirective(directive))
  })..['_dart_'] = probe;
}

js.JsObject _jsInjector(Injector injector) =>
new js.JsObject.jsify({"get": injector.get})..['_dart_'] = injector;

js.JsObject _jsScope(Scope scope) {
  return new js.JsObject.jsify({
      "apply": scope.apply,
      "digest": scope.rootScope.digest,
      "flush": scope.rootScope.flush,
      "context": scope.context,
      "get": (name) => scope.context[name],
      "set": (name, value) => scope.context[name] = value
  })..['_dart_'] = scope;
}

_jsDirective(directive) => directive;
