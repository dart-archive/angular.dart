part of angular.core.dom_internal;

/**
 * ElementBinder is created by the Selector and is responsible for instantiating
 * individual directives and binding element properties.
 */
class ElementBinder {
  // DI Services

  final Profiler _perf;
  final Expando _expando;
  final Map onEvents;

  // Member fields
  final decorators;
  final DirectiveRef template;
  ViewFactory templateViewFactory;

  final DirectiveRef component;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode;

  ElementBinder(this._perf, this._expando, this.template, this.component, this.decorators, this.onEvents, this.childMode);

  ElementBinder.forTransclusion(ElementBinder other)
        : _perf = other._perf,
        _expando = other._expando,
        decorators = other.decorators,
        component = other.component,
        onEvents = other.onEvents,
        childMode = other.childMode;



  bool get hasTemplate => template != null;

  bool get shouldCompileChildren =>
      childMode == NgAnnotation.COMPILE_CHILDREN;

  ElementBinder get templateBinder => new ElementBinder.forTransclusion(this);

  List<DirectiveRef> get _usableDirectiveRefs {
    if (template != null) return [template];
    if (component != null) return new List.from(decorators)..add(component);
    return decorators;
  }

  bool get hasDirectivesOrEvents =>
      _usableDirectiveRefs.isNotEmpty || onEvents.isNotEmpty;

  // DI visibility strategy allowing node-local visibility.
  static final Function _elementOnly = (Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) requesting = requesting.parent;
    return identical(requesting, defining);
  };

  // DI visibility strategy allowing visibility from direct child into parent.
  static final Function _elementDirectChildren =
      (Injector requesting, Injector defining) {
        if (requesting.name == _SHADOW) requesting = requesting.parent;
        return _elementOnly(requesting, defining) ||
               identical(requesting.parent, defining);
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
      if (!hasDirectivesOrEvents) return parentInjector;
      var viewPortFactory = (_) => null;
      var viewFactory = (_) => null;
      var boundViewFactory = (_) => null;
      var nodesAttrsDirectives = null;
      var nodeModule = new Module()
          ..type(NgElement)
          ..value(View, view)
          ..value(dom.Element, node)
          ..value(dom.Node, node)
          ..value(NodeAttrs, nodeAttrs);

      directiveRefs.forEach((DirectiveRef ref) {
        NgAnnotation annotation = ref.annotation;
        var visibility = _elementOnly;
        if (ref.annotation is NgController) {
          scope = scope.createChild(new PrototypeMap(scope.context));
          nodeModule.value(Scope, scope);
        }

        switch (ref.annotation.visibility) {
          case NgDirective.CHILDREN_VISIBILITY:
            visibility = null;
            break;
          case NgDirective.DIRECT_CHILDREN_VISIBILITY:
            visibility = _elementDirectChildren;
            break;
        }

        if (ref.type == NgTextMustacheDirective) {
          nodeModule.factory(NgTextMustacheDirective, (Injector injector) {
            return new NgTextMustacheDirective(
                node, ref.value, injector.get(Interpolate), injector.get(Scope),
                injector.get(FilterMap));
          });
        } else if (ref.type == NgAttrMustacheDirective) {
          if (nodesAttrsDirectives == null) {
            nodesAttrsDirectives = [];
            nodeModule.factory(NgAttrMustacheDirective, (Injector injector) {
              var scope = injector.get(Scope);
              var interpolate = injector.get(Interpolate);
              for (var ref in nodesAttrsDirectives) {
                new NgAttrMustacheDirective(nodeAttrs, ref.value, interpolate,
                    scope, injector.get(FilterMap));
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
            return componentFactory.call(injector, scope, viewCache, http,
                templateCache, directives);
          }, visibility: visibility);
        } else {
          nodeModule.type(ref.type, visibility: visibility);
        }
        for (var publishType in ref.annotation.publishTypes) {
          nodeModule.factory(publishType, (Injector injector) =>
              injector.get(ref.type), visibility: visibility);
        }
        if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
          // Currently, transclude is only supported for NgDirective.
          assert(annotation is NgDirective);
          viewPortFactory = (_) => new ViewPort(node,
              parentInjector.get(NgAnimate));
          viewFactory = (_) => templateViewFactory;
          boundViewFactory = (Injector injector) =>
              templateViewFactory.bind(injector);
        }
      });
      nodeModule..factory(ViewPort, viewPortFactory)
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
        var shadowScope = (fctrs != null && fctrs.containsKey(ref.type)) ?
            fctrs[ref.type].shadowScope :
            null;
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

    onEvents.forEach((event, value) {
      view.registerEvent(EventHandler.attrNameToEventName(event));
    });
    return nodeInjector;
  }

  toString() => "[ElementBinder decorators:$decorators template:$template]";
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
  toString() => "[TaggedTextBinder binder:$binder offset:$offsetIndex]";
}

// Used for the tagging compiler
class TaggedElementBinder {
  final ElementBinder binder;
  int parentBinderOffset;
  var injector;
  bool isTopLevel;

  List<TaggedTextBinder> textBinders;

  TaggedElementBinder(this.binder, this.parentBinderOffset, this.isTopLevel);

  void addText(TaggedTextBinder tagged) {
    if (textBinders == null) textBinders = [];
    textBinders.add(tagged);
  }

  String toString() => "[TaggedElementBinder binder:$binder parentBinderOffset:"
                       "$parentBinderOffset textBinders:$textBinders "
                       "injector:$injector]";
}
