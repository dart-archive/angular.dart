part of angular.core.dom;

typedef void EventFunction(event);

@NgInjectableService()
class EventService {
  Map<String, Map<List<dom.Node>, EventFunction>> _eventRegistry = {};
  Map<String, dom.EventListener> _eventToListener = {};
  dom.Element rootElement;

  EventService(NgApp ngApp) : rootElement = ngApp.root;

  _EventHandle register(String eventName, EventFunction fn, List<dom.Node> elements) {
    var name = eventName.replaceAll("on-", "");
    var eventHandle = new _EventHandle(name, elements);
    var eventListener = (event) {
      _eventRegistry[name][elements](event);
    };

    _eventRegistry.putIfAbsent(name, () {
      rootElement.addEventListener(name, eventListener);
      _eventToListener[name] = eventListener;
      return {};
    });
    _eventRegistry[name].putIfAbsent(elements, () => fn);
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