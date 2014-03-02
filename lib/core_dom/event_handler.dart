part of angular.core.dom;

typedef void EventFunction(event);

@NgInjectableService()
class EventHandler {
  Map<String, Map<List<dom.Node>, EventFunction>> _eventRegistry = {};
  Map<String, dom.EventListener> _eventToListener = {};
  dom.Element rootElement;

  EventHandler(NgApp ngApp) : rootElement = ngApp.root;

  _RegistrationHandle register(String eventName, EventFunction fn, List<dom.Node> elements) {
    print('Registering ${eventName}');
    var eventHandle = new _RegistrationHandle(eventName, elements);
    var eventListener = (dom.Event event) {
      print(event.type);
      if(elements.any((e) => e == event.target || e.contains(event.target))) {
        _eventRegistry[eventName][elements](event);
      }
    };

    _eventRegistry.putIfAbsent(eventName, () {
      rootElement.addEventListener(eventName, eventListener);
      _eventToListener[eventName] = eventListener;
      return {};
    });
    _eventRegistry[eventName].putIfAbsent(elements, () => fn);
    return eventHandle;
  }

  void unregister(_RegistrationHandle registrationHandle) {
    _eventRegistry[registrationHandle.eventName].remove(registrationHandle.nodes);
    if (_eventRegistry[registrationHandle.eventName].isEmpty) {
      rootElement.removeEventListener(registrationHandle.eventName,
          _eventToListener[registrationHandle.eventName]);
      _eventRegistry.remove(registrationHandle.eventName);
    }
  }
}

class _RegistrationHandle {
  final List<dom.Node> nodes;
  String eventName;

  _RegistrationHandle(this.eventName, this.nodes);
}