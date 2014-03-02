part of angular.core.dom;

typedef void EventFunction(event);

@NgInjectableService()
class EventService {
  Map<String, Map<List<dom.Node>, EventFunction>> _eventRegistry = {};
  Map<String, dom.EventListener> _eventToListener = {};
  dom.Element rootElement;

  EventService(NgApp ngApp) : rootElement = ngApp.root;

  _EventHandle register(String eventName, EventFunction fn, List<dom.Node> elements) {
    var eventHandle = new _EventHandle(eventName, elements);
    var eventListener = (dom.Event event) {
      if(elements.any((e) => e.contains(event.target))) {
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

  void unregister(_EventHandle eventHandle) {
    _eventRegistry[eventHandle.eventName].remove(eventHandle.nodes);
    if (_eventRegistry[eventHandle.eventName].isEmpty) {
      rootElement.removeEventListener(eventHandle.eventName,
          _eventToListener[eventHandle.eventName]);
      _eventRegistry.remove(eventHandle.eventName);
    }
  }
}

class _EventHandle {
  List<dom.Node> nodes;
  String eventName;

  _EventHandle(this.eventName, this.nodes);
}