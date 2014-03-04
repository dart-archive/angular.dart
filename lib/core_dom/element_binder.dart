part of angular.core.dom;

class ElementBinder {
  final dom.Node element;
  final _Directive directive;
  final events = <String, String>{};
  final String value;
  final List<ApplyMapping> mappings = new List<ApplyMapping>();
  final childElementBinders = <ElementBinder>[];

  ElementBinder(this.element, this.directive, events, [ this.value ]) {
      this.events.putAll(events);
  }
}