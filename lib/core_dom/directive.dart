part of angular.core.dom_internal;

/// Callback function used to notify of attribute changes.
typedef void _AttributeChanged(String newValue);

/// Callback function used to notify of observer changes.
typedef void Mustache(bool hasObservers);


/**
 * [TemplateLoader] is an asynchronous access to ShadowRoot which is
 * loaded asynchronously. It allows a Component to be notified when its
 * ShadowRoot is ready.
 */
class TemplateLoader {
  final async.Future<dom.Node> template;

  TemplateLoader(this.template);
}

class _MustacheAttr {
  // Listener trigger when the attribute becomes observed
  final Mustache notifyFn;
  // Whether the value has first been computed
  bool isComputed = false;

  _MustacheAttr(this.notifyFn);
}
