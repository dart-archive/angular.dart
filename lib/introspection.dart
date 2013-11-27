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


List<dom.Element> ngQuery(dom.Node element, String selector, [String containsText]) {
  var list = [];
  var children = [element];
  while (!children.isEmpty) {
    var child = children.removeAt(0);
    child.queryAll(selector).forEach((e) {
      if (containsText == null || e.text.contains(containsText)) list.add(e);
    });
    child.queryAll('*').forEach((e) {
      if (e.shadowRoot != null) children.add(e.shadowRoot);
    });
  }
  return list;
}

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

_publishToJavaScript() {
  js.context.ngProbe = (dom.Node node) => _jsProbe(ngProbe(node));
  js.context.ngInjector = (dom.Node node) => _jsInjector(ngInjector(node));
  js.context.ngScope = (dom.Node node) => _jsScope(ngScope(node));
  js.context.ngQuery = (dom.Node node, String selector, [String containsText]) =>
    new JsArray.from(ngQuery(node, selector, containsText));
}

JsObject _jsProbe(ElementProbe probe) {
  return new JsObject.jsify({
    "element": probe.element,
    "injector": _jsInjector(probe.injector),
    "scope": _jsScope(probe.scope),
    "directives": probe.directives.map((directive) => _jsDirective(directive))
  })..['_dart_'] = probe;
}

JsObject _jsInjector(Injector injector) {
  return new JsObject.jsify({
    "get": injector.get
  })..['_dart_'] = injector;
}

JsObject _jsScope(Scope scope) {
  return new JsObject.jsify({
    "\$apply": scope.$apply,
    "\$digest": scope.$digest,
    "get": (name) => scope[name],
    "set": (name, value) => scope[name] = value
  })..['_dart_'] = scope;
}

_jsDirective(directive) => directive;
