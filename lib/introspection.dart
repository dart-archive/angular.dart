part of angular;

/**
 * A global write only variable which keeps track of objects attached to the elements.
 * This is usefull for debugging AngularDart application from the browser's REPL.
 */
Expando _elementExpando = new Expando('element');

/**
 * Return the closest [ElementProbe] object for a given [Element].
 *
 * NOTE: This global method is here to make it easier to debug Angular application from
 *       the browser's REPL, unit or end-to-end tests. The function is not intended to
 *       be called from Angular application.
 */
ElementProbe ngProbe(dom.Node node) {
  while(node != null) {
    var probe = _elementExpando[node];
    if (probe != null) return probe;
    node = node.parent;
  }
  return null;
}


/**
 * Return the [Injector] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular application from
 * the browser's REPL, unit or end-to-end tests. The function is not intended to be called
 * from Angular application.
 */
Injector ngInjector(dom.Node node) => ngProbe(node).injector;


/**
 * Return the [Scope] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular application from
 * the browser's REPL, unit or end-to-end tests. The function is not intended to be called
 * from Angular application.
 */
Scope ngScope(dom.Node node) => ngProbe(node).scope;


/**
 * Return a List of directive controllers associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular application from
 * the browser's REPL, unit or end-to-end tests. The function is not intended to be called
 * from Angular application.
 */
List<Object> ngDirectives(dom.Node node) {
  ElementProbe probe = _elementExpando[node];
  return probe == null ? [] : probe.directives;
}
