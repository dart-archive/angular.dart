part of angular.core.dom;

/// Callback function used to notify of attribute changes.
typedef void AttributeChanged(String newValue);

/// Callback function used to notify of observer changes.
typedef void Mustache(bool hasObservers);

/**
 * NodeAttrs is a facade for element attributes. The facade is responsible
 * for normalizing attribute names as well as allowing access to the
 * value of the directive.
 */
class NodeAttrs {
  final dom.Element element;

  Map<String, List<AttributeChanged>> _observers;
  final _mustacheAttrs = <String, _MustacheAttr>{};

  NodeAttrs(this.element);

  operator [](String attrName) => element.attributes[attrName];

  void operator []=(String attrName, String value) {
    if (_mustacheAttrs.containsKey(attrName)) {
      _mustacheAttrs[attrName].isComputed = true;
    }
    if (value == null) {
      element.attributes.remove(attrName);
    } else {
      element.attributes[attrName] = value;
    }
    if (_observers != null && _observers.containsKey(attrName)) {
      _observers[attrName].forEach((notifyFn) => notifyFn(value));
    }
  }

  /**
   * Observe changes to the attribute by invoking the [notifyFn] function. On
   * registration the [notifyFn] function gets invoked synchronize with the
   * current value.
   */
  observe(String attrName, AttributeChanged notifyFn) {
    if (_observers == null) _observers = <String, List<AttributeChanged>>{};
    _observers.putIfAbsent(attrName, () => <AttributeChanged>[])
              .add(notifyFn);

    if (_mustacheAttrs.containsKey(attrName)) {
      if (_mustacheAttrs[attrName].isComputed) notifyFn(this[attrName]);
      _mustacheAttrs[attrName].notifyFn(true);
    } else {
      notifyFn(this[attrName]);
    }
  }

  void forEach(void f(String k, String v)) {
    element.attributes.forEach(f);
  }

  bool containsKey(String attrName) => element.attributes.containsKey(attrName);

  Iterable<String> get keys => element.attributes.keys;

  void listenObserverChanges(String attrName, Mustache notifyFn) {
    _mustacheAttrs[attrName] = new _MustacheAttr(notifyFn);
    notifyFn(false);
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

class _MustacheAttr {
  // Listener trigger when the attribute becomes observed
  final Mustache notifyFn;
  // Whether the value has first been computed
  bool isComputed = false;

  _MustacheAttr(this.notifyFn);
}
