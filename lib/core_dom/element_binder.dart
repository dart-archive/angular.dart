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

  TemplateElementBinder(perf, expando, parser, config, appInjector,
                        this.template, this.templateBinder,
                        onEvents, bindAttrs, childMode)
      : super(perf, expando, parser, config, appInjector,
          null, null, onEvents, bindAttrs, childMode);

  String toString() => "[TemplateElementBinder template:$template]";
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
  final CompilerConfig _config;
  final Injector _appInjector;
  Animate _animate;

  final Map onEvents;
  final Map bindAttrs;

  // Member fields
  final decorators;

  final BoundComponentData componentData;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  final String childMode;

  ElementBinder(this._perf, this._expando, this._parser, this._config,
                this._appInjector, this.componentData, this.decorators,
                this.onEvents, this.bindAttrs, this.childMode) {
    _animate = _appInjector.getByKey(ANIMATE_KEY);
  }

  final bool hasTemplate = false;

  bool get shouldCompileChildren =>
      childMode == Directive.COMPILE_CHILDREN;

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    if (componentData != null) return _directiveCache = new List.from(decorators)..add(componentData.ref);
    return _directiveCache = decorators;
  }

  bool get hasDirectivesOrEvents =>
      _usableDirectiveRefs.isNotEmpty || onEvents.isNotEmpty || bindAttrs.isNotEmpty;

  void _bindTwoWay(tasks, AST ast, scope, directiveScope,
                   controller, AST dstAST) {
    var taskId = (tasks != null) ? tasks.registerTask() : 0;

    var viewOutbound = false;
    var viewInbound = false;
    scope.watchAST(ast, (inboundValue, _) {
      if (!viewInbound) {
        viewOutbound = true;
        scope.rootScope.runAsync(() => viewOutbound = false);
        var value = dstAST.parsedExp.assign(controller, inboundValue);
        if (tasks != null) tasks.completeTask(taskId);
        return value;
      }
    });
    if (ast.parsedExp.isAssignable) {
      directiveScope.watchAST(dstAST, (outboundValue, _) {
        if (!viewOutbound) {
          viewInbound = true;
          scope.rootScope.runAsync(() => viewInbound = false);
          ast.parsedExp.assign(scope.context, outboundValue);
          if (tasks != null) tasks.completeTask(taskId);
        }
      });
    }
  }

  void _bindOneWay(tasks, ast, scope, AST dstAST, controller) {
    var taskId = (tasks != null) ? tasks.registerTask() : 0;

    scope.watchAST(ast, (v, _) {
      dstAST.parsedExp.assign(controller, v);
      if (tasks != null) tasks.completeTask(taskId);
    });
  }

  void _bindCallback(dstPathFn, controller, expression, scope) {
    dstPathFn.assign(controller, _parser(expression).bind(scope.context, ScopeLocals.wrapper));
  }


  void _createAttrMappings(directive, scope, List<MappingParts> mappings, nodeAttrs, tasks) {
    Scope directiveScope; // Only created if there is a two-way binding in the element.
    for(var i = 0; i < mappings.length; i++) {
      MappingParts p = mappings[i];
      var attrName = p.attrName;
      var attrValueAST = p.attrValueAST;
      AST dstAST = p.dstAST;

      if (!dstAST.parsedExp.isAssignable) {
        throw "Expression '${dstAST.expression}' is not assignable in mapping '${p.originalValue}' "
              "for attribute '$attrName'.";
      }

      // Check if there is a bind attribute for this mapping.
      var bindAttr = bindAttrs[p.attrName];
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
        continue;
      }

      switch (p.mode) {
        case '@': // string
          var taskId = (tasks != null) ? tasks.registerTask() : 0;
          nodeAttrs.observe(attrName, (value) {
            dstAST.parsedExp.assign(directive, value);
            if (tasks != null) tasks.completeTask(taskId);
          });
          break;

        case '<=>': // two-way
          if (nodeAttrs[attrName] == null) continue;
          if (directiveScope == null) {
            directiveScope = scope.createChild(directive);
          }
          _bindTwoWay(tasks, attrValueAST, scope, directiveScope,
              directive, dstAST);
          break;

        case '=>': // one-way
          if (nodeAttrs[attrName] == null) continue;
          _bindOneWay(tasks, attrValueAST, scope, dstAST, directive);
          break;

        case '=>!': //  one-way, one-time
          if (nodeAttrs[attrName] == null) continue;

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
    }
  }

  void hydrate(DirectiveInjector directiveInjector, Scope scope) {
    var s;
    var nodeAttrs = directiveInjector.get(NodeAttrs);
    for(var i = 0; i < _usableDirectiveRefs.length; i++) {
      DirectiveRef ref = _usableDirectiveRefs[i];
      var key = ref.typeKey;
      var directiveName = traceEnabled ? ref.typeKey.toString() : null;
      if (identical(key, TEXT_MUSTACHE_KEY) || identical(key, ATTR_MUSTACHE_KEY)) continue;

      s = traceEnter1(Directive_create, directiveName);
      var directive;
      try {
        directive = directiveInjector.getByKey(ref.typeKey);
        if (ref.annotation is Controller) {
          scope.parentScope.context[(ref.annotation as Controller).publishAs] = directive;
        }

        var tasks = directive is AttachAware ? new _TaskList(() {
          if (scope.isAttached) directive.attach();
        }) : null;

        if (ref.mappings.isNotEmpty) {
          if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
          _createAttrMappings(directive, scope, ref.mappings, nodeAttrs, tasks);
        }

        if (directive is AttachAware) {
          var taskId = (tasks != null) ? tasks.registerTask() : 0;
          Watch watch;
          watch = scope.watch('"attach()"', // Cheat a bit.
              (_, __) {
            watch.remove();
            if (tasks != null) tasks.completeTask(taskId);
          });
        }

        if (tasks != null) tasks.doneRegistering();

        if (directive is DetachAware) {
          scope.on(ScopeEvent.DESTROY).listen((_) => directive.detach());
        }
      } finally {
        traceLeave(s);
      }
    }
  }

  void _createDirectiveFactories(DirectiveRef ref, DirectiveInjector nodeInjector, node,
                                 nodeAttrs) {
    if (ref.typeKey == TEXT_MUSTACHE_KEY) {
      new TextMustache(node, ref.valueAST, nodeInjector.scope);
    } else if (ref.typeKey == ATTR_MUSTACHE_KEY) {
      new AttrMustache(nodeAttrs, ref.value, ref.valueAST, nodeInjector.scope);
    } else if (ref.annotation is Component) {
      assert(ref == componentData.ref);

      BoundComponentFactory boundComponentFactory = componentData.factory;
      Function componentFactory = boundComponentFactory.call(node);
      nodeInjector.bindByKey(ref.typeKey, componentFactory,
          boundComponentFactory.callArgs, ref.annotation.visibility);
    } else {
      nodeInjector.bindByKey(ref.typeKey, ref.factory, ref.paramKeys, ref.annotation.visibility);
    }
  }

  DirectiveInjector setUp(View view, Scope scope,
                         DirectiveInjector parentInjector,
                         dom.Node node) {
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    var directiveRefs = _usableDirectiveRefs;

    DirectiveInjector nodeInjector;
    var parentEventHandler = parentInjector == null ?
        _appInjector.getByKey(EVENT_HANDLER_KEY) :
        eventHandler(parentInjector);
    if (this is TemplateElementBinder) {
      nodeInjector = new TemplateDirectiveInjector(parentInjector, _appInjector,
          node, nodeAttrs, parentEventHandler, scope, _animate, (this as TemplateElementBinder).templateViewFactory, view);
    } else {
      nodeInjector = new DirectiveInjector(parentInjector, _appInjector, node, nodeAttrs, parentEventHandler, scope, _animate, view);
    }

    for(var i = 0; i < directiveRefs.length; i++) {
      DirectiveRef ref = directiveRefs[i];
      Directive annotation = ref.annotation;
      if (ref.annotation is Controller) {
        scope = nodeInjector.scope = scope.createChild(new PrototypeMap(scope.context));
      }
      _createDirectiveFactories(ref, nodeInjector, node, nodeAttrs);
      if (ref.annotation.module != null) {
        DirectiveBinderFn config = ref.annotation.module;
        if (config != null) config(nodeInjector);
      }
      if (_config.elementProbeEnabled && ref.valueAST != null) {
        nodeInjector.elementProbe.bindingExpressions.add(ref.valueAST.expression);
      }
    }

    if (_config.elementProbeEnabled) {
      _expando[node] = nodeInjector.elementProbe;
      // TODO(misko): pretty sure that clearing Expando is not necessary. Remove?
      scope.on(ScopeEvent.DESTROY).listen((_) => _expando[node] = null);
    }

    var jsNode;
    List bindAssignableProps = [];
    bindAttrs.forEach((String prop, AST ast) {
      if (jsNode == null) jsNode = new js.JsObject.fromBrowserObject(node);
      scope.watchAST(ast, (v, _) {
        jsNode[prop] = v;
      });

      if (ast.parsedExp.isAssignable) {
        bindAssignableProps.add([prop, ast.parsedExp]);
      }
    });

    if (bindAssignableProps.isNotEmpty) {
      node.addEventListener('change', (_) {
        bindAssignableProps.forEach((propAndExp) {
          propAndExp[1].assign(scope.context, jsNode[propAndExp[0]]);
        });
      });
    }

    if (onEvents.isNotEmpty) {
      onEvents.forEach((event, value) {
        parentEventHandler.register(EventHandler.attrNameToEventName(event));
      });
    }
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
