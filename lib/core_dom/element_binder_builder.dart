part of angular.core.dom_internal;

@Injectable()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final Expando _expando;

  ElementBinderFactory(this._parser, this._perf, this._expando);

  // TODO: Optimize this to re-use a builder.
  ElementBinderBuilder builder() => new ElementBinderBuilder(this);

  ElementBinder binder(ElementBinderBuilder b) =>
      new ElementBinder(_perf, _expando, _parser,
          b.component, b.decorators, b.onEvents, b.bindAttrs, b.childMode);
  TemplateElementBinder templateBinder(ElementBinderBuilder b, ElementBinder transclude) =>
      new TemplateElementBinder(_perf, _expando, _parser,
          b.template, transclude, b.onEvents, b.bindAttrs, b.childMode);
}

/**
 * ElementBinderBuilder is an internal class for the Selector which is responsible for
 * building ElementBinders.
 */
class ElementBinderBuilder {
  static RegExp _MAPPING = new RegExp(r'^(\@|=\>\!|\=\>|\<\=\>|\&)\s*(.*)$');

  ElementBinderFactory _factory;

  final onEvents = <String, String>{};
  final bindAttrs = <String, String>{};

  var decorators = <DirectiveRef>[];
  DirectiveRef template;
  ViewFactory templateViewFactory;

  DirectiveRef component;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = Directive.COMPILE_CHILDREN;

  ElementBinderBuilder(this._factory);

  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;
    var children = annotation.children;

    if (annotation.children == Directive.TRANSCLUDE_CHILDREN) {
      template = ref;
    } else if (annotation is Component) {
      component = ref;
    } else {
      decorators.add(ref);
    }

    if (annotation.children == Directive.IGNORE_CHILDREN) {
      childMode = annotation.children;
    }

    if (annotation.map != null) annotation.map.forEach((attrName, mapping) {
      Match match = _MAPPING.firstMatch(mapping);
      if (match == null) {
        throw "Unknown mapping '$mapping' for attribute '$attrName'.";
      }
      var mode = match[1];
      var dstPath = match[2];

      String dstExpression = dstPath.isEmpty ? attrName : dstPath;

      ref.mappings.add(new MappingParts(attrName, mode, dstExpression, mapping));
    });
  }

  ElementBinder get binder {
    if (template != null) {
      var transclude = _factory.binder(this);
      return _factory.templateBinder(this, transclude);

    } else {
      return _factory.binder(this);
    }

  }
}
