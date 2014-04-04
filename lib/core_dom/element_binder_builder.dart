part of angular.core.dom_internal;

@NgInjectableService()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final Expando _expando;

  ElementBinderFactory(this._parser, this._perf, this._expando);

  // TODO: Optimize this to re-use a builder.
  ElementBinderBuilder builder() => new ElementBinderBuilder(this);

  ElementBinder binder(ElementBinderBuilder b) =>
      new ElementBinder(_perf, _expando, _parser,
          b.component, b.decorators, b.onEvents, b.bindAttrs, b.compileChildren);
  TemplateElementBinder templateBinder(ElementBinderBuilder b, ElementBinder transclude) =>
      new TemplateElementBinder(_perf, _expando, _parser,
          b.template, transclude, b.onEvents, b.bindAttrs, b.compileChildren);
}

/**
 * ElementBinderBuilder is an internal class for the Selector which is responsible for
 * building ElementBinders.
 */
class ElementBinderBuilder {
  static RegExp _MAPPING = new RegExp(r'^(@|=>!|=>|<=>|&)\s*(.*)$');

  ElementBinderFactory _factory;

  final onEvents = <String, String>{};
  final bindAttrs = <String, String>{};

  var decorators = <DirectiveRef>[];
  DirectiveRef template;
  ViewFactory templateViewFactory;

  DirectiveRef component;

  bool compileChildren = true;

  ElementBinderBuilder(this._factory);

  void addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;

    compileChildren = annotation.compileChildren;

    if (annotation is NgTemplate) {
      template = ref;
      _addMapping(ref, (annotation as NgTemplate).mapping);
    } else {
      if (annotation is NgComponent) {
        component = ref;
      } else {
        decorators.add(ref);
      }
      annotation = annotation as AbstractNgAttrAnnotation;
      if (annotation.map != null) {
        annotation.map.forEach((attrName, mapping) {
          _addMapping(ref, mapping, attrName);
        });
      }
    }
  }

  ElementBinder get binder {
    if (template != null) {
      var transclude = _factory.binder(this);
      return _factory.templateBinder(this, transclude);
    } else {
      return _factory.binder(this);
    }
  }

  void _addMapping(DirectiveRef ref, String mapping, [String attrName]) {
    if (mapping == null) return;
    Match match = _MAPPING.firstMatch(mapping);
    if (match == null) {
      throw "Unknown mapping '$mapping' for attribute '$attrName'.";
    }
    var mode = match[1];
    var dstPath = match[2];

    if (dstPath.isEmpty && attrName != null) dstPath = attrName;

    ref.mappings.add(new MappingParts(attrName, mode, dstPath, mapping));
  }

  void _addRefs(List<_Directive> directives, dom.Node node, [String attrValue]) {
    directives.forEach((directive) {
      addDirective(new DirectiveRef(node, directive.type, directive.annotation, attrValue));
    });
  }
}
