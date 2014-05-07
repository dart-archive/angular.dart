part of angular.core.dom_internal;

@Injectable()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final Expando _expando;
  final ComponentFactory _componentFactory;
  final TranscludingComponentFactory _transcludingComponentFactory;
  final ShadowDomComponentFactory _shadowDomComponentFactory;

  ElementBinderFactory(this._parser, this._perf, this._expando, this._componentFactory,
      this._transcludingComponentFactory, this._shadowDomComponentFactory);

  // TODO: Optimize this to re-use a builder.
  ElementBinderBuilder builder() => new ElementBinderBuilder(this);

  ElementBinder binder(ElementBinderBuilder b) =>
      new ElementBinder(_perf, _expando, _parser, _componentFactory,
          _transcludingComponentFactory, _shadowDomComponentFactory,
          b.component, b.decorators, b.onEvents, b.bindAttrs, b.compileChildren);

  TemplateElementBinder templateBinder(ElementBinderBuilder b, ElementBinder transclude) =>
      new TemplateElementBinder(_perf, _expando, _parser, _componentFactory,
          _transcludingComponentFactory, _shadowDomComponentFactory,
          b.template, transclude, b.onEvents, b.bindAttrs, b.compileChildren);
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

  ViewFactory templateViewFactory;
  bool isTemplate = false;
  var decorators = <DirectiveRef>[];

  DirectiveRef component;
  DirectiveRef template;

  bool compileChildren = true;

  ElementBinderBuilder(this._factory);

  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;

    if (annotation is Template) {
      template = ref;
      isTemplate = true;
    } else if (annotation is Component) {
      component = ref;
    } else {
      decorators.add(ref);
    }

    if (annotation.map != null) annotation.map.forEach((attrName, mapping) {
      Match match = _MAPPING.firstMatch(mapping);
      if (match == null) throw "Unknown mapping '$mapping' for attribute '$attrName'.";

      var mode = match[1];
      var dstPath = match[2];

      if (dstPath.isEmpty) dstPath = attrName;

      ref.mappings.add(new MappingParts(attrName, mode, dstPath, mapping));
    });
  }

  ElementBinder get binder {
    if (isTemplate) {
      var transclude = _factory.binder(this);
      return _factory.templateBinder(this, transclude);
    } else {
      return _factory.binder(this);
    }
  }
}
