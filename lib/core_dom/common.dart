part of angular.core.dom;

List<dom.Node> cloneElements(elements) {
  return elements.map((el) => el.clone(true)).toList();
}

void normalizeNgAttributes(dom.Element element) {
  Map<String, String> normalizedAttrs = {};
  element.attributes.forEach((attrName, value) {
    if (attrName.startsWith('data-ng-')) {
      normalizedAttrs[attrName.replaceFirst('data-', '')] = value;
      element.attributes.remove(attrName);
    }
  });
  element.attributes.addAll(normalizedAttrs);
}

typedef ApplyMapping(NodeAttrs attrs, Scope scope, Object dst);

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final NgAnnotation annotation;
  final String value;
  final List<ApplyMapping> mappings = new List<ApplyMapping>();

  BlockFactory blockFactory;

  DirectiveRef(this.element, this.type, this.annotation, [ this.value ]);

  String toString() {
    var html = element is dom.Element ? (element as dom.Element).outerHtml : element.nodeValue;
    return '{ element: $html, selector: ${annotation.selector}, value: $value, type: $type }';
  }
}

/**
 * Creates a child injector that allows loading new directives, filters and
 * services from the provided modules.
 */
Injector forceNewDirectivesAndFilters(Injector injector, List<Module> modules) {
  modules.add(new Module()
      ..factory(Scope,
          (i) => i.parent.get(Scope).$new(filters: i.get(FilterMap))));
  return injector.createChild(modules,
      forceNewInstances: [DirectiveMap, FilterMap]);
}
