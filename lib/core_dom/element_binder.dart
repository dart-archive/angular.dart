part of angular.core.dom;

@NgInjectableService()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final Expando _expando;

  ElementBinderFactory(this._parser, this._perf, this._expando);

  binder() {
    return new ElementBinder(_parser, _perf, _expando);
  }
}

/**
 * ElementBinder is created by the Selector and is responsible for instantiating individual directives
 * and binding element properties.
 */

class ElementBinder {
  // DI Services
  Parser _parser;
  Profiler _perf;
  Expando _expando;

  // Member fields
  List<DirectiveRef> decorators = [];
  DirectiveRef template;
  ViewFactory templateViewFactory;

  DirectiveRef component;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = NgAnnotation.COMPILE_CHILDREN;


  ElementBinder(this._parser, this._perf, this._expando);

  ElementBinder.forTransclusion(ElementBinder other) {
    _parser = other._parser;
    _perf = other._perf;
    _expando = other._expando;

    decorators = other.decorators;
    component = other.component;
    childMode = other.childMode;
  }

  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;
    var children = annotation.children;

    if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
      template = ref;
    } else if(annotation is NgComponent) {
      component = ref;
    } else {
      decorators.add(ref);
    }

    if (annotation.children == NgAnnotation.IGNORE_CHILDREN) {
      childMode = annotation.children;
    }

    createMappings(ref);
  }

  bool get hasTemplate {
    return template != null;
  }

  bool get shouldCompileChildren {
    return childMode == NgAnnotation.COMPILE_CHILDREN;
  }

  ElementBinder get templateBinder {
    return new ElementBinder.forTransclusion(this);
  }

  List<DirectiveRef> get _usableDirectiveRefs {
    if (template != null) {
      return [template];
    }
    if (component != null) {
      return new List.from(decorators)..add(component);
    }
    return decorators;
  }

  bool get hasDirectives {
    return (_usableDirectiveRefs != null && _usableDirectiveRefs.length != 0);
  }

  // DI visibility callback allowing node-local visibility.

  static final Function _elementOnly = (Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return identical(requesting, defining);
  };

  // DI visibility callback allowing visibility from direct child into parent.

  static final Function _elementDirectChildren = (Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return _elementOnly(requesting, defining) || identical(requesting.parent, defining);
  };

  Injector bind(View view, Injector parentInjector, dom.Node node) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.view.link.setUp', _html(node))) != false);
    Injector nodeInjector;
    Scope scope = parentInjector.get(Scope);
    FilterMap filters = parentInjector.get(FilterMap);
    Map<Type, _ComponentFactory> fctrs;
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    ElementProbe probe;

    var directiveRefs = _usableDirectiveRefs;
    try {
      if (directiveRefs == null || directiveRefs.length == 0) return parentInjector;
      var nodeModule = new Module();
      var viewPortFactory = (_) => null;
      var viewFactory = (_) => null;
      var boundViewFactory = (_) => null;
      var nodesAttrsDirectives = null;

      nodeModule.type(NgElement);
      nodeModule.value(View, view);
      nodeModule.value(dom.Element, node);
      nodeModule.value(dom.Node, node);
      nodeModule.value(NodeAttrs, nodeAttrs);
      directiveRefs.forEach((DirectiveRef ref) {
        NgAnnotation annotation = ref.annotation;
        var visibility = _elementOnly;
        if (ref.annotation is NgController) {
          scope = scope.createChild(new PrototypeMap(scope.context));
          nodeModule.value(Scope, scope);
        }
        if (ref.annotation.visibility == NgDirective.CHILDREN_VISIBILITY) {
          visibility = null;
        } else if (ref.annotation.visibility == NgDirective.DIRECT_CHILDREN_VISIBILITY) {
          visibility = _elementDirectChildren;
        }
        if (ref.type == NgTextMustacheDirective) {
          nodeModule.factory(NgTextMustacheDirective, (Injector injector) {
            return new NgTextMustacheDirective(
                node, ref.value, injector.get(Interpolate), injector.get(Scope),
                injector.get(AstParser), injector.get(FilterMap));
          });
        } else if (ref.type == NgAttrMustacheDirective) {
          if (nodesAttrsDirectives == null) {
            nodesAttrsDirectives = [];
            nodeModule.factory(NgAttrMustacheDirective, (Injector injector) {
              var scope = injector.get(Scope);
              var interpolate = injector.get(Interpolate);
              for (var ref in nodesAttrsDirectives) {
                new NgAttrMustacheDirective(nodeAttrs, ref.value, interpolate,
                scope, injector.get(AstParser), injector.get(FilterMap));
              }
            });
          }
          nodesAttrsDirectives.add(ref);
        } else if (ref.annotation is NgComponent) {
          //nodeModule.factory(type, new ComponentFactory(node, ref.directive), visibility: visibility);
          // TODO(misko): there should be no need to wrap function like this.
          nodeModule.factory(ref.type, (Injector injector) {
            Compiler compiler = injector.get(Compiler);
            Scope scope = injector.get(Scope);
            ViewCache viewCache = injector.get(ViewCache);
            Http http = injector.get(Http);
            TemplateCache templateCache = injector.get(TemplateCache);
            DirectiveMap directives = injector.get(DirectiveMap);
            // This is a bit of a hack since we are returning different type then we are.
            var componentFactory = new _ComponentFactory(node, ref.type,
                            ref.annotation as NgComponent,
                            injector.get(dom.NodeTreeSanitizer), _expando);
            if (fctrs == null) fctrs = new Map<Type, _ComponentFactory>();
            fctrs[ref.type] = componentFactory;
            return componentFactory.call(injector, scope, viewCache, http, templateCache, directives);
          }, visibility: visibility);
        } else {
          nodeModule.type(ref.type, visibility: visibility);
        }
        for (var publishType in ref.annotation.publishTypes) {
          nodeModule.factory(publishType, (Injector injector) => injector.get(ref.type), visibility: visibility);
        }
        if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
          // Currently, transclude is only supported for NgDirective.
          assert(annotation is NgDirective);
          viewPortFactory = (_) => new ViewPort(node,
            parentInjector.get(NgAnimate));
          viewFactory = (_) => templateViewFactory;
          boundViewFactory = (Injector injector) => templateViewFactory.bind(injector);
        }
      });
      nodeModule
        ..factory(ViewPort, viewPortFactory)
        ..factory(ViewFactory, viewFactory)
        ..factory(BoundViewFactory, boundViewFactory)
        ..factory(ElementProbe, (_) => probe);
      nodeInjector = parentInjector.createChild([nodeModule]);
      probe = _expando[node] = new ElementProbe(
          parentInjector.get(ElementProbe), node, nodeInjector, scope);
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
    directiveRefs.forEach((DirectiveRef ref) {
      var linkTimer;
      try {
        var linkMapTimer;
        assert((linkTimer = _perf.startTimer('ng.view.link', ref.type)) != false);
        var controller = nodeInjector.get(ref.type);
        probe.directives.add(controller);
        assert((linkMapTimer = _perf.startTimer('ng.view.link.map', ref.type)) != false);
        var shadowScope = (fctrs != null && fctrs.containsKey(ref.type)) ? fctrs[ref.type].shadowScope : null;
        if (ref.annotation is NgController) {
          scope.context[(ref.annotation as NgController).publishAs] = controller;
        } else if (ref.annotation is NgComponent) {
          shadowScope.context[(ref.annotation as NgComponent).publishAs] = controller;
        }
        if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
        var attachDelayStatus = controller is NgAttachAware ? [false] : null;
        checkAttachReady() {
          if (attachDelayStatus.reduce((a, b) => a && b)) {
            attachDelayStatus = null;
            if (scope.isAttached) {
              controller.attach();
            }
          }
        }
        for (var map in ref.mappings) {
          var notify;
          if (attachDelayStatus != null) {
            var index = attachDelayStatus.length;
            attachDelayStatus.add(false);
            notify = () {
              if (attachDelayStatus != null) {
                attachDelayStatus[index] = true;
                checkAttachReady();
              }
            };
          } else {
            notify = () => null;
          }
          map(nodeAttrs, scope, controller, filters, notify);
        }
        if (attachDelayStatus != null) {
          Watch watch;
          watch = scope.watch(
              '1', // Cheat a bit.
                  (_, __) {
                watch.remove();
                attachDelayStatus[0] = true;
                checkAttachReady();
              });
        }
        if (controller is NgDetachAware) {
          scope.on(ScopeEvent.DESTROY).listen((_) => controller.detach());
        }
        assert(_perf.stopTimer(linkMapTimer) != false);
      } finally {
        assert(_perf.stopTimer(linkTimer) != false);
      }
    });
    return nodeInjector;
  }

  static RegExp _MAPPING = new RegExp(r'^(\@|=\>\!|\=\>|\<\=\>|\&)\s*(.*)$');

  // TODO: Move this into the Selector
  createMappings(DirectiveRef ref) {
    NgAnnotation annotation = ref.annotation;
    if (annotation.map != null) annotation.map.forEach((attrName, mapping) {
      Match match = _MAPPING.firstMatch(mapping);
      if (match == null) {
        throw "Unknown mapping '$mapping' for attribute '$attrName'.";
      }
      var mode = match[1];
      var dstPath = match[2];

      String dstExpression = dstPath.isEmpty ? attrName : dstPath;
      Expression dstPathFn = _parser(dstExpression);
      if (!dstPathFn.isAssignable) {
        throw "Expression '$dstPath' is not assignable in mapping '$mapping' for attribute '$attrName'.";
      }
      ApplyMapping mappingFn;
      switch (mode) {
        case '@':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller, FilterMap filters, notify()) {
            attrs.observe(attrName, (value) {
              dstPathFn.assign(controller, value);
              notify();
            });
          };
          break;
        case '<=>':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller, FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            String expression = attrs[attrName];
            Expression expressionFn = _parser(expression);
            var viewOutbound = false;
            var viewInbound = false;
            scope.watch(
                expression,
                    (inboundValue, _) {
                  if (!viewInbound) {
                    viewOutbound = true;
                    scope.rootScope.runAsync(() => viewOutbound = false);
                    var value = dstPathFn.assign(controller, inboundValue);
                    notify();
                    return value;
                  }
                },
                filters: filters
            );
            if (expressionFn.isAssignable) {
              scope.watch(
                  dstExpression,
                      (outboundValue, _) {
                    if (!viewOutbound) {
                      viewInbound = true;
                      scope.rootScope.runAsync(() => viewInbound = false);
                      expressionFn.assign(scope.context, outboundValue);
                      notify();
                    }
                  },
                  context: controller,
                  filters: filters
              );
            }
          };
          break;
        case '=>':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller, FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            Expression attrExprFn = _parser(attrs[attrName]);
            var shadowValue = null;
            scope.watch(attrs[attrName],
                (v, _) {
              dstPathFn.assign(controller, shadowValue = v);
              notify();
            },
            filters: filters);
          };
          break;
        case '=>!':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller, FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            Expression attrExprFn = _parser(attrs[attrName]);
            var watch;
            watch = scope.watch(
                attrs[attrName],
                    (value, _) {
                  if (dstPathFn.assign(controller, value) != null) {
                    watch.remove();
                  }
                },
                filters: filters);
            notify();
          };
          break;
        case '&':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst, FilterMap filters, notify()) {
            dstPathFn.assign(dst, _parser(attrs[attrName]).bind(scope.context, ScopeLocals.wrapper));
            notify();
          };
          break;
      }
      ref.mappings.add(mappingFn);
    });
  }
}


// Used for walking the DOM
class ElementBinderTreeRef {
  final int offsetIndex;
  final ElementBinderTree subtree;

  ElementBinderTreeRef(this.offsetIndex, this.subtree);
}
class ElementBinderTree {
  ElementBinder binder;
  List<ElementBinderTreeRef> subtrees;

  ElementBinderTree(this.binder, this.subtrees);
}


class TaggedTextBinder {
  ElementBinder binder;
  final int offsetIndex;

  TaggedTextBinder(this.binder, this.offsetIndex);
}

// Used for the tagging compiler
class TaggedElementBinder {
  ElementBinder binder;
  int parentBinderOffset;
  var injector;

  List<TaggedTextBinder> textBinders;

  TaggedElementBinder(this.binder, this.parentBinderOffset);

  void addText(TaggedTextBinder tagged) {
    if (textBinders == null) {
      textBinders = [];
    }
    textBinders.add(tagged);
  }

  toString() => "[TaggedElementBinder binder:$binder parentBinderOffset:$parentBinderOffset textBinders:$textBinders injector:$injector]";
}
