part of angular.core.dom;

/**
 * Callback function used to notify of attribute changes.
 */
typedef AttributeChanged(String newValue);

/**
 * Callback function used to notify of text changes.
 */
abstract class TextChangeListener{
  call(String text);
}

/**
 * NodeAttrs is a facade for element attributes. The facade is responsible
 * for normalizing attribute names as well as allowing access to the
 * value of the directive.
 */
class NodeAttrs {
  final dom.Element element;

  Map<String, List<AttributeChanged>> _observers;

  NodeAttrs(this.element);

  operator [](String attributeName) =>
      element.attributes[snakecase(attributeName, '-')];

  operator []=(String attributeName, String value) {
    var snakeName = snakecase(attributeName, '-');
    if (value == null) {
      element.attributes.remove(snakeName);
    } else {
      element.attributes[snakeName] = value;
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
    if (_observers == null) {
      _observers = new Map<String, List<AttributeChanged>>();
    }
    if (!_observers.containsKey(attributeName)) {
      _observers[attributeName] = new List<AttributeChanged>();
    }
    _observers[attributeName].add(notifyFn);
    notifyFn(this[attributeName]);
  }

  void forEach(void f(String k, String v)) {
    element.attributes.forEach((k, v) => f(camelcase(k), v));
  }

  bool containsKey(String attributeName) =>
      element.attributes.containsKey(snakecase(attributeName, '-'));

  Iterable<String> get keys =>
      element.attributes.keys.map((name) => camelcase(name));
}

/**
 * TemplateLoader is an asynchronous access to ShadowRoot which is
 * loaded asynchronously. It allows a Component to be notified when its
 * ShadowRoot is ready.
 */
class TemplateLoader {
  final async.Future<dom.ShadowRoot> _template;

  async.Future<dom.ShadowRoot> get template => _template;

  TemplateLoader(this._template);
}
