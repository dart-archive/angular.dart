part of angular.core.dom;

const String COMPILE_CHILDREN = "compile children";
const String IGNORE_CHILDREN = "ignore children";

class NodeBinder {

}

class ElementBinder implements NodeBinder {
  final List<DirectiveRef> decoratorsMap;
  final Map<String, String> onEvents;
  final childMode;
  final List<ElementBinder> childElementBinders;
  final String value;

  final dom.Node element;

  final List<ApplyMapping> mappings = new List<ApplyMapping>();

  ElementBinder(this.element, this.decoratorsMap, this.onEvents, this.childElementBinders,
      [this.value, this.childMode = COMPILE_CHILDREN]);

  Injector bind(Injector injector, dom.Node node) {
    return null;
  }
}

class TextBinder implements NodeBinder {

}