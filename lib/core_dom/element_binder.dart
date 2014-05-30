part of angular.core.dom_internal;

class TemplateElementBinder extends ElementBinder {
  final DirectiveRef template;
  ViewFactory templateViewFactory;

  final bool hasTemplate = true;

  final ElementBinder templateBinder;

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    return _directiveCache = [template];
  }

  TemplateElementBinder(perf, expando, parser, componentFactory,
                        transcludingComponentFactory, shadowDomComponentFactory,
                        this.template, this.templateBinder,
                        onEvents, bindAttrs, childMode)
      : super(perf, expando, parser, componentFactory,
          transcludingComponentFactory, shadowDomComponentFactory,
          null, null, onEvents, bindAttrs, childMode);

  String toString() => "[TemplateElementBinder template:$template]";

  _registerViewFactory(node, parentInjector, nodeModule) {
    assert(templateViewFactory != null);
    nodeModule
      ..bindByKey(VIEW_PORT_KEY, toFactory: (_) =>
          new ViewPort(node, parentInjector.getByKey(ANIMATE_KEY)))
      ..bindByKey(VIEW_FACTORY_KEY, toValue: templateViewFactory)
      ..bindByKey(BOUND_VIEW_FACTORY_KEY, toFactory: (Injector injector) =>
          templateViewFactory.bind(injector));
  }
}


/**
 * ElementBinder is created by the Selector and is responsible for instantiating
 * individual directives and binding element properties.
 */
class ElementBinder {
  // DI Services
  final Profiler _perf;
  final Expando _expando;
  final Parser _parser;

  // The default component factory
  final ComponentFactory _componentFactory;
  final TranscludingComponentFactory _transcludingComponentFactory;
  final ShadowDomComponentFactory _shadowDomComponentFactory;
  final Map onEvents;
  final Map bindAttrs;

  // Member fields
  final decorators;

  final DirectiveRef component;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  final String childMode;

  ElementBinder(this._perf, this._expando, this._parser,
                this._componentFactory,
                this._transcludingComponentFactory,
                this._shadowDomComponentFactory,
                this.component, this.decorators,
                this.onEvents, this.bindAttrs, this.childMode);

  final bool hasTemplate = false;

  bool get shouldCompileChildren =>
      childMode == Directive.COMPILE_CHILDREN;

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    if (component != null) return _directiveCache = new List.from(decorators)..add(component);
    return _directiveCache = decorators;
  }

  bool get hasDirectivesOrEvents =>
      _usableDirectiveRefs.isNotEmpty || onEvents.isNotEmpty;

  void _bindTwoWay(tasks, AST ast, scope, directiveScope,
                   controller, AST dstAST) {
    var taskId = tasks.registerTask();

    var viewOutbound = false;
    var viewInbound = false;
    scope.watchAST(ast, (inboundValue, _) {
      if (!viewInbound) {
        viewOutbound = true;
        scope.rootScope.runAsync(() => viewOutbound = false);
        var value = dstAST.parsedExp.assign(controller, inboundValue);
        tasks.completeTask(taskId);
        return value;
      }
    });
    if (ast.parsedExp.isAssignable) {
      directiveScope.watchAST(dstAST, (outboundValue, _) {
        if (!viewOutbound) {
          viewInbound = true;
          scope.rootScope.runAsync(() => viewInbound = false);
          ast.parsedExp.assign(scope.context, outboundValue);
          tasks.completeTask(taskId);
        }
      });
    }
  }

  _bindOneWay(tasks, ast, scope, AST dstAST, controller) {
    var taskId = tasks.registerTask();

    scope.watchAST(ast, (v, _) {
      dstAST.parsedExp.assign(controller, v);
      tasks.completeTask(taskId);
    });
  }

  void _bindCallback(dstPathFn, controller, expression, scope) {
    dstPathFn.assign(controller, _parser(expression).bind(scope.context, ScopeLocals.wrapper));
  }


  void _createAttrMappings(directive, scope, List<MappingParts> mappings, nodeAttrs, tasks) {
    Scope directiveScope; // Only created if there is a two-way binding in the element.
    mappings.forEach((MappingParts p) {
      var attrName = p.attrName;
      var attrValueAST = p.attrValueAST;
      AST dstAST = p.dstAST;

      if (!dstAST.parsedExp.isAssignable) {
        throw "Expression '${dstAST.expression}' is not assignable in mapping '${p.originalValue}' "
              "for attribute '$attrName'.";
      }

      // Check if there is a bind attribute for this mapping.
      var bindAttr = bindAttrs["bind-${p.attrName}"];
      if (bindAttr != null) {
        if (p.mode == '<=>') {
          if (directiveScope == null) {
            directiveScope = scope.createChild(directive);
          }
          _bindTwoWay(tasks, bindAttr, scope, directiveScope,
              directive, dstAST);
        } else if (p.mode == '&') {
          throw "Callbacks do not support bind- syntax";
        } else {
          _bindOneWay(tasks, bindAttr, scope, dstAST, directive);
        }
        return;
      }

      switch (p.mode) {
        case '@': // string
          var taskId = tasks.registerTask();
          nodeAttrs.observe(attrName, (value) {
            dstAST.parsedExp.assign(directive, value);
            tasks.completeTask(taskId);
          });
          break;

        case '<=>': // two-way
          if (nodeAttrs[attrName] == null) return;
          if (directiveScope == null) {
            directiveScope = scope.createChild(directive);
          }
          _bindTwoWay(tasks, attrValueAST, scope, directiveScope,
              directive, dstAST);
          break;

        case '=>': // one-way
          if (nodeAttrs[attrName] == null) return;
          _bindOneWay(tasks, attrValueAST, scope,
              dstAST, directive);
          break;

        case '=>!': //  one-way, one-time
          if (nodeAttrs[attrName] == null) return;

          var watch;
          var lastOneTimeValue;
          watch = scope.watchAST(attrValueAST, (value, _) {
            if ((lastOneTimeValue = dstAST.parsedExp.assign(directive, value)) != null && watch != null) {
                var watchToRemove = watch;
                watch = null;
                scope.rootScope.domWrite(() {
                  if (lastOneTimeValue != null) {
                    watchToRemove.remove();
                  } else {  // It was set to non-null, but stablized to null, wait.
                    watch = watchToRemove;
                  }
                });
            }
          });
          break;

        case '&': // callback
          _bindCallback(dstAST.parsedExp, directive, nodeAttrs[attrName], scope);
          break;
      }
    });
  }

  void _link(nodeInjector, probe, scope, nodeAttrs) {
    _usableDirectiveRefs.forEach((DirectiveRef ref) {
      var directive = nodeInjector.getByKey(ref.typeKey);
      probe.directives.add(directive);

      if (ref.annotation is Controller) {
        scope.context[(ref.annotation as Controller).publishAs] = directive;
      }

      var tasks = new _TaskList(directive is AttachAware ? () {
        if (scope.isAttached) directive.attach();
      } : null);

      if (ref.mappings.isNotEmpty) {
        if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
        _createAttrMappings(directive, scope, ref.mappings, nodeAttrs, tasks);
      }

      if (directive is AttachAware) {
        var taskId = tasks.registerTask();
        Watch watch;
        watch = scope.watch('1', // Cheat a bit.
            (_, __) {
          watch.remove();
          tasks.completeTask(taskId);
        });
      }

      tasks.doneRegistering();

      if (directive is DetachAware) {
        scope.on(ScopeEvent.DESTROY).listen((_) => directive.detach());
      }
    });
  }

  void _createDirectiveFactories(DirectiveRef ref, nodeModule, node, nodesAttrsDirectives, nodeAttrs,
                                 visibility) {
    if (ref.type == TextMustache) {
      nodeModule.bind(TextMustache, toFactory: (Injector injector) {
        return new TextMustache(node, ref.valueAST, injector.getByKey(SCOPE_KEY));
      });
    } else if (ref.type == AttrMustache) {
      if (nodesAttrsDirectives.isEmpty) {
        nodeModule.bind(AttrMustache, toFactory: (Injector injector) {
          var scope = injector.getByKey(SCOPE_KEY);
          for (var ref in nodesAttrsDirectives) {
            new AttrMustache(nodeAttrs, ref.value, ref.valueAST, scope);
          }
        });
      }
      nodesAttrsDirectives.add(ref);
    } else if (ref.annotation is Component) {
      var factory;
      var annotation = ref.annotation as Component;
      if (annotation.useShadowDom == true) {
        factory = _shadowDomComponentFactory;
      } else if (annotation.useShadowDom == false) {
        factory = _transcludingComponentFactory;
      } else {
        factory = _componentFactory;
      }
      nodeModule.bindByKey(ref.typeKey, toFactory: factory.call(node, ref), visibility: visibility);
    } else {
      nodeModule.bindByKey(ref.typeKey, visibility: visibility);
    }
  }

  // Overridden in TemplateElementBinder
  void _registerViewFactory(node, parentInjector, nodeModule) {
    nodeModule..bindByKey(VIEW_PORT_KEY, toValue: null)
              ..bindByKey(VIEW_FACTORY_KEY, toValue: null)
              ..bindByKey(BOUND_VIEW_FACTORY_KEY, toValue: null);
  }


  Injector bind(View view, Injector parentInjector, dom.Node node) {
    Injector nodeInjector;
    Scope scope = parentInjector.getByKey(SCOPE_KEY);
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    ElementProbe probe;

    var directiveRefs = _usableDirectiveRefs;
    if (!hasDirectivesOrEvents) return parentInjector;

    var nodesAttrsDirectives = [];
    var nodeModule = new Module()
        ..bindByKey(NG_ELEMENT_KEY)
        ..bindByKey(VIEW_KEY, toValue: view)
        ..bindByKey(ELEMENT_KEY, toValue: node)
        ..bindByKey(NODE_KEY, toValue: node)
        ..bindByKey(NODE_ATTRS_KEY, toValue: nodeAttrs)
        ..bindByKey(ELEMENT_PROBE_KEY, toFactory: (_) => probe);

    directiveRefs.forEach((DirectiveRef ref) {
      Directive annotation = ref.annotation;
      var visibility = ref.annotation.visibility;
      if (ref.annotation is Controller) {
        scope = scope.createChild(new PrototypeMap(scope.context));
        nodeModule.bind(Scope, toValue: scope);
      }

      _createDirectiveFactories(ref, nodeModule, node, nodesAttrsDirectives, nodeAttrs,
          visibility);
      if (ref.annotation.module != null) {
         nodeModule.install(ref.annotation.module());
      }
    });

    _registerViewFactory(node, parentInjector, nodeModule);

    nodeInjector = parentInjector.createChild([nodeModule]);
    probe = _expando[node] = new ElementProbe(
        parentInjector.getByKey(ELEMENT_PROBE_KEY), node, nodeInjector, scope);
    scope.on(ScopeEvent.DESTROY).listen((_) {_expando[node] = null;});

    _link(nodeInjector, probe, scope, nodeAttrs);

    onEvents.forEach((event, value) {
      view.registerEvent(EventHandler.attrNameToEventName(event));
    });
    return nodeInjector;
  }

  String toString() => "[ElementBinder decorators:$decorators]";
}

/**
 * Private class used for managing controller.attach() calls
 */
class _TaskList {
  Function onDone;
  final List _tasks = [];
  bool isDone = false;
  int firstTask;

  _TaskList(this.onDone) {
    if (onDone == null) isDone = true;
    firstTask = registerTask();
  }

  int registerTask() {
    if (isDone) return null; // Do nothing if there is nothing to do.
    _tasks.add(false);
    return _tasks.length - 1;
  }

  void completeTask(id) {
    if (isDone) return;
    _tasks[id] = true;
    if (_tasks.every((a) => a)) {
      onDone();
      isDone = true;
    }
  }

  void doneRegistering() {
    completeTask(firstTask);
  }
}

// Used for walking the DOM
class ElementBinderTreeRef {
  final int offsetIndex;
  final ElementBinderTree subtree;

  ElementBinderTreeRef(this.offsetIndex, this.subtree);
}

class ElementBinderTree {
  final ElementBinder binder;
  final List<ElementBinderTreeRef> subtrees;

  ElementBinderTree(this.binder, this.subtrees);
}

class TaggedTextBinder {
  final ElementBinder binder;
  final int offsetIndex;

  TaggedTextBinder(this.binder, this.offsetIndex);
  String toString() => "[TaggedTextBinder binder:$binder offset:$offsetIndex]";
}

// Used for the tagging compiler
class TaggedElementBinder {
  final ElementBinder binder;
  int parentBinderOffset;
  bool isTopLevel;

  List<TaggedTextBinder> textBinders;

  TaggedElementBinder(this.binder, this.parentBinderOffset, this.isTopLevel);

  void addText(TaggedTextBinder tagged) {
    if (textBinders == null) textBinders = [];
    textBinders.add(tagged);
  }

  bool get isDummy => binder == null && textBinders == null && !isTopLevel;

  String toString() => "[TaggedElementBinder binder:$binder parentBinderOffset:"
                       "$parentBinderOffset textBinders:$textBinders]";
}
