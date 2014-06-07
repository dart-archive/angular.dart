part of angular.core.dom_internal;

@Injectable()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final CompilerConfig _config;
  final Expando _expando;
  final ASTParser astParser;
  final ComponentFactory componentFactory;
  final ShadowDomComponentFactory shadowDomComponentFactory;
  final TranscludingComponentFactory transcludingComponentFactory;

  ElementBinderFactory(this._parser, this._perf, this._config, this._expando,
      this.astParser, this.componentFactory, this.shadowDomComponentFactory, this.transcludingComponentFactory);

  // TODO: Optimize this to re-use a builder.
  ElementBinderBuilder builder(FormatterMap formatters, DirectiveMap directives) =>
    new ElementBinderBuilder(this,formatters, directives);

  ElementBinder binder(ElementBinderBuilder b) =>

      new ElementBinder(_perf, _expando, _parser, _config,
          b.componentData, b.decorators, b.onEvents, b.bindAttrs, b.childMode);

  TemplateElementBinder templateBinder(ElementBinderBuilder b, ElementBinder transclude) =>
      new TemplateElementBinder(_perf, _expando, _parser, _config,
          b.template, transclude, b.onEvents, b.bindAttrs, b.childMode);
}

/**
 * ElementBinderBuilder is an internal class for the Selector which is responsible for
 * building ElementBinders.
 */
class ElementBinderBuilder {
  static final RegExp _MAPPING = new RegExp(r'^(@|=>!|=>|<=>|&)\s*(.*)$');

  final ElementBinderFactory _factory;
  final DirectiveMap _directives;
  final FormatterMap _formatters;

  /// "on-*" attribute names and values, added by a [DirectiveSelector]
  final onEvents = <String, String>{};
  /// "bind-*" attribute names and values, added by a [DirectiveSelector]
  final bindAttrs = <String, AST>{};

  final decorators = <DirectiveRef>[];
  DirectiveRef template;
  BoundComponentData componentData;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = Directive.COMPILE_CHILDREN;

  ElementBinderBuilder(this._factory, this._formatters, this._directives);

  /**
   * Adds [DirectiveRef]s to this [ElementBinderBuilder].
   *
   * [addDirective] gets called from [Selector.matchElement] for each directive triggered by the
   * element.
   *
   * When the [Directive] annotation defines a `map`, the attribute mappings are added to the
   * [DirectiveRef].
   */
  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;
    var children = annotation.children;

    if (annotation.children == Directive.TRANSCLUDE_CHILDREN) {
      template = ref;
    } else if (annotation is Component) {
      ComponentFactory factory;
      var annotation = ref.annotation as Component;
      if (annotation.useShadowDom == true) {
        factory = _factory.shadowDomComponentFactory;
      } else if (annotation.useShadowDom == false) {
        factory = _factory.transcludingComponentFactory;
      } else {
        factory = _factory.componentFactory;
      }

      componentData = new BoundComponentData(ref, () => factory.bind(ref, _directives));
    } else {
      decorators.add(ref);
    }

    if (annotation.children == Directive.IGNORE_CHILDREN) {
      childMode = annotation.children;
    }

    if (annotation.map != null) {
      annotation.map.forEach((attrName, mapping) {
        Match match = _MAPPING.firstMatch(mapping);
        if (match == null) {
          throw "Unknown mapping '$mapping' for attribute '$attrName'.";
        }
        var mode = match[1];
        var dstPath = match[2];

        String dstExpression = dstPath.isEmpty ? attrName : dstPath;
        AST dstAST = _factory.astParser(dstExpression); // no formatters

        // Look up the value of attrName and compute an AST
        AST ast;
        if (mode != '@' && mode != '&') {
          var value = attrName == "." ? ref.value : (ref.element as dom.Element).attributes[attrName];
          if (value == null || value.isEmpty) { value = "''"; }
          ast = _factory.astParser(value, formatters: _formatters);
        }

        ref.mappings.add(new MappingParts(attrName, ast, mode, dstAST, mapping));
      });
    }
  }

  /// Creates an returns an [ElementBinder] or a [TemplateElementBinder]
  ElementBinder get binder {
    var elBinder = _factory.binder(this);
    return template == null ? elBinder : _factory.templateBinder(this, elBinder);
  }
}

/**
 * Data used by the ComponentFactory to construct components.
 */
class BoundComponentData {
  final DirectiveRef ref;
  BoundComponentFactory _instance;
  Function _gen;
  BoundComponentFactory get factory {
    if (_instance != null) return _instance;
    _instance = _gen();
    _gen = null; // Clear the gen function for GC.
    return _instance;
  }

  Component get component => ref.annotation as Component;
  @Deprecated('Use typeKey instead')
  Type get type => ref.type;
  Key get typeKey => ref.typeKey;


  /**
   * * [ref]: The components directive ref
   * * [_gen]: A function which returns a [BoundComponentFactory].  Called lazily.
   */
  BoundComponentData(this.ref, this._gen);
}
