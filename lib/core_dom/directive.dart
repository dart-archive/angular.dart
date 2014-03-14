part of angular.core.dom;

/// Callback function used to notify of attribute changes.
typedef AttributeChanged(String newValue);

/// Callback function used to notify of observer changes.
typedef void ObserverChanged(bool hasListeners);

/**
 * NodeAttrs is a facade for element attributes. The facade is responsible
 * for normalizing attribute names as well as allowing access to the
 * value of the directive.
 */
class NodeAttrs {
  final dom.Element element;

  Map<String, List<AttributeChanged>> _observers;

  Map<String, List<ObserverChanged>> _observerListeners = {};

  NodeAttrs(this.element);

  operator [](String attributeName) => element.attributes[attributeName];

  void operator []=(String attributeName, String value) {
    if (value == null) {
      element.attributes.remove(attributeName);
    } else {
      element.attributes[attributeName] = value;
    }
    if (_observers != null && _observers.containsKey(attributeName)) {
      _observers[attributeName].forEach((fn) => fn(value));
    }
  }

  /**
   * Observe changes to the attribute by invoking the [AttributeChanged]
   * function. On registration the [AttributeChanged] function gets invoked
   * synchronise with the current value.
   */
  observe(String attributeName, AttributeChanged notifyFn) {
    if (_observers == null) _observers = <String, List<AttributeChanged>>{};
    _observers.putIfAbsent(attributeName, () => <AttributeChanged>[])
              .add(notifyFn);

    notifyFn(this[attributeName]);

    if (_observerListeners.containsKey(attributeName)) {
      _observerListeners[attributeName].forEach((cb) => cb(true));
    }
  }

  void forEach(void f(String k, String v)) {
    element.attributes.forEach(f);
  }

  bool containsKey(String attributeName) =>
      element.attributes.containsKey(attributeName);

  Iterable<String> get keys => element.attributes.keys;

  void listenObserverChanges(String attributeName, ObserverChanged fn) {
    if (_observerListeners == null) {
      _observerListeners = <String, List<ObserverChanged>>{};
    }
    _observerListeners.putIfAbsent(attributeName, () => <ObserverChanged>[])
                      .add(fn);
    fn(false);
  }
}

/**
 * TemplateLoader is an asynchronous access to ShadowRoot which is
 * loaded asynchronously. It allows a Component to be notified when its
 * ShadowRoot is ready.
 */
class TemplateLoader {
  final async.Future<dom.ShadowRoot> template;

  TemplateLoader(this.template);
}
