part of angular.core.dom;

@NgInjectableService()
class ElementBinderFactory {
  Parser _parser;

  ElementBinderFactory(Parser this._parser);

  binder([int templateIndex]) {
    return new ElementBinder(_parser);
  }
}

/**
 * ElementBinder is created by the Selector and is responsible for instantiating individual directives
 * and binding element properties.
 */

class ElementBinder {
  Parser _parser;

  ElementBinder(this._parser);

  ElementBinder.forTransclusion(ElementBinder other) {
    _parser = other._parser;
    decorators = other.decorators;
    component = other.component;
    childMode = other.childMode;
    childElementBinders = other.childElementBinders;
  }

  List<DirectiveRef> decorators = [];

  DirectiveRef template;

  DirectiveRef component;

  var childElementBinders;

  var offsetIndex;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = NgAnnotation.COMPILE_CHILDREN;

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

  List<DirectiveRef> walkDOM(compileTransclusionCallback, compileChildrenCallback) {
    if (template != null) {
      template.viewFactory = compileTransclusionCallback(new ElementBinder.forTransclusion(this));
    } else if (childMode == NgAnnotation.COMPILE_CHILDREN) {
        childElementBinders = compileChildrenCallback();
    }
  }

  List<DirectiveRef> get usableDirectiveRefs {
    if (template != null) {
      return [template];
    }
    if (component != null) {
      return new List.from(decorators)..add(component);
    }
    return decorators;
  }


  bool isUseful() {
    return (usableDirectiveRefs != null && usableDirectiveRefs.length != 0) || childElementBinders != null;
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
