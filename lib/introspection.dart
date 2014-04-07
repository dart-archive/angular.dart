/**
* Introspection of Elements for debugging and tests.
*/
library angular.introspection;

import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:angular/introspection_js.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';

/**
 * Return the closest [ElementProbe] object for a given [Element].
 *
 * **NOTE:** This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The
 * function is not intended to be called from Angular application.
 */
ElementProbe ngProbe(dom.Node node) {
  if (node == null) {
    throw "ngProbe called without node";
  }
  var origNode = node;
  while (node != null) {
    var probe = elementExpando[node];
    if (probe != null) return probe;
    node = node.parent;
  }
  throw "Could not find a probe for [$origNode]";
}


/**
 * Return the [Injector] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
Injector ngInjector(dom.Node node) => ngProbe(node).injector;


/**
 * Return the [Scope] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
Scope ngScope(dom.Node node) => ngProbe(node).scope;


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
 * Return a List of directive controllers associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
List<Object> ngDirectives(dom.Node node) {
  ElementProbe probe = elementExpando[node];
  return probe == null ? [] : probe.directives;
}

