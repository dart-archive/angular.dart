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

  NodeAttrs(dom.Element this.element);

  operator [](String name) => element.attributes[_snakeCase(name, '-')];

  operator []=(String name, String value) {
    name = _snakeCase(name, '-');
    if (value == null) {
      element.attributes.remove(name);
    } else {
      element.attributes[name] = value;
    }
    if (_observers != null && _observers.containsKey(name)) {
      _observers[name].forEach((fn) => fn(value));
    }
  }

  /**
   * Observe changes to the attribute by invoking the [AttributeChanged]
   * function. On registration the [AttributeChanged] function gets invoked
   * synchronise with the current value.
   */
  observe(String attributeName, AttributeChanged notifyFn) {
    attributeName = _snakeCase(attributeName, '-');
    if (_observers == null) {
      _observers = new Map<String, List<AttributeChanged>>();
    }
    if (!_observers.containsKey(attributeName)) {
      _observers[attributeName] = new List<AttributeChanged>();
    }
    _observers[attributeName].add(notifyFn);
    notifyFn(this[attributeName]);
  }
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

var _SNAKE_CASE_REGEXP = new RegExp("[A-Z]");
String _snakeCase(String name, [separator = '_']) {
  _snakeReplace(Match match) {
    return (match.start != 0 ? separator : '') + match.group(0).toLowerCase();
  }
  return name.replaceAllMapped(_SNAKE_CASE_REGEXP, _snakeReplace);
}
