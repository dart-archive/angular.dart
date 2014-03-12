part of angular.core.dom;

typedef void EventFunction(event);

@NgInjectableService()
class EventHandler {
  dom.Node rootNode;
  final Expando expando;
  final ExceptionHandler exceptionHandler;
  final Map<String, Function> listeners = <String, Function>{};

  EventHandler(this.rootNode, this.expando, this.exceptionHandler);

  void register(String eventName) {
    listeners.putIfAbsent(eventName, () {
      print('register $rootNode -> $eventName');
      print('register ${rootNode.firstChild} -> $eventName');
      dom.EventListener eventListener = this.eventListener;
      rootNode.on[eventName].listen(eventListener);
      return eventListener;
    });
  }

  eventListener(dom.Event event) {
    print('event $event $rootNode $target');
    dom.Node element = event.target;
    while (element != null && element != rootNode) {
      var expression;
      if (element is dom.Element)
        expression = (element as dom.Element).attributes[eventNameToAttrName(event.type)];
      print(expression);
      if (expression != null) {
        try {
          var scope = getScope(element);
          if (scope != null) scope.eval(expression);
        } catch (e, s) {
          exceptionHandler(e, s);
        }
      }
      element = element.parentNode;
    }
  }

  Scope getScope(dom.Node element) {
    while (element != null && element != rootNode) {
      ElementProbe probe = expando[element];
      if (probe != null) {
        return probe.scope;
      }
      element = element.parentNode;
    }
    return null;
  }

  /**
  * Converts event name into attribute. Event named 'someCustomEvent' needs to
  * be transformed into on-some-custom-event.
  */
  static String eventNameToAttrName(String eventName) {
    var part = eventName.replaceAllMapped(new RegExp("([A-Z])"), (Match match) {
      return '-${match.group(0).toLowerCase()}';
    });
    return 'on-${part}';
  }

  /**
  * Converts attribute into event name. Attribute 'on-some-custom-event'
  * corresponds to event named 'someCustomEvent'.
  */
  static String attrNameToEventName(String attrName) {
    var part = attrName.replaceAll("on-", "");
    part = part.replaceAllMapped(new RegExp(r'\-(\w)'), (Match match) {
      return match.group(0).toUpperCase();
    });
    return part.replaceAll("-", "");
  }
}
