part of angular.core.dom_internal;

@NgInjectableService()
class ElementBinderFactory {
  final Parser _parser;
  final Profiler _perf;
  final Expando _expando;

  ElementBinderFactory(this._parser, this._perf, this._expando);

// Optimize this to re-use a builder.
  ElementBinderBuilder builder() => new ElementBinderBuilder(this, _parser);

  ElementBinder binder(template, component, decorators, onEvents, childMode) => new ElementBinder(_perf, _expando, template, component, decorators, onEvents, childMode);
}

/**
 * ElementBinderBuilder is an internal class for the Selector which is responsible for building ElementBinders.
 */
class ElementBinderBuilder {
  ElementBinderFactory _factory;
  final Parser _parser;

  final onEvents = <String, String>{};

// Member fields
  var decorators = <DirectiveRef>[];
  DirectiveRef template;
  ViewFactory templateViewFactory;

  DirectiveRef component;

// Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = NgAnnotation.COMPILE_CHILDREN;


  ElementBinderBuilder(this._factory, this._parser);

  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;
    var children = annotation.children;

    if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
      template = ref;
    } else if (annotation is NgComponent) {
      component = ref;
    } else {
      decorators.add(ref);
    }

    if (annotation.children == NgAnnotation.IGNORE_CHILDREN) {
      childMode = annotation.children;
    }

    createMappings(ref);
  }

  static RegExp _MAPPING = new RegExp(r'^(\@|=\>\!|\=\>|\<\=\>|\&)\s*(.*)$');

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
        throw "Expression '$dstPath' is not assignable in mapping '$mapping' "
        "for attribute '$attrName'.";
      }
      ApplyMapping mappingFn;
      switch (mode) {
        case '@':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller,
                       FilterMap filters, notify()) {
            attrs.observe(attrName, (value) {
              dstPathFn.assign(controller, value);
              notify();
            });
          };
          break;
        case '<=>':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller,
                       FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            String expression = attrs[attrName];
            Expression expressionFn = _parser(expression);
            var viewOutbound = false;
            var viewInbound = false;
            scope.watch(
                expression, (inboundValue, _) {
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
                  dstExpression, (outboundValue, _) {
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
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller,
                       FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            Expression attrExprFn = _parser(attrs[attrName]);
            var shadowValue = null;
            scope.watch(attrs[attrName], (v, _) {
              dstPathFn.assign(controller, shadowValue = v);
              notify();
            },
            filters: filters);
          };
          break;
        case '=>!':
          mappingFn = (NodeAttrs attrs, Scope scope, Object controller,
                       FilterMap filters, notify()) {
            if (attrs[attrName] == null) return notify();
            Expression attrExprFn = _parser(attrs[attrName]);
            var watch;
            watch = scope.watch(attrs[attrName], (value, _) {
              if (dstPathFn.assign(controller, value) != null) {
                watch.remove();
              }
            },
            filters: filters);
            notify();
          };
          break;
        case '&':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst,
                       FilterMap filters, notify()) {
            dstPathFn.assign(dst, _parser(attrs[attrName])
            .bind(scope.context, ScopeLocals.wrapper));
            notify();
          };
          break;
      }
      ref.mappings.add(mappingFn);
    });
  }


  ElementBinder get binder => _factory.binder(template, component, decorators, onEvents, childMode);
}
