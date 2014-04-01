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

  TemplateElementBinder(_perf, _expando, this.template, this.templateBinder, onEvents, childMode)
    : super(_perf, _expando, null, null, onEvents, childMode);

  toString() => "[TemplateElementBinder template:$template]";

  _registerViewFactory(node, parentInjector, nodeModule) {
    nodeModule
      ..factory(ViewPort, (_) => new ViewPort(node, parentInjector.get(NgAnimate)))
      ..factory(ViewFactory, (_) => templateViewFactory)
      ..factory(BoundViewFactory, (Injector injector) => templateViewFactory.bind(injector));
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
  final Map onEvents;

  // Member fields
  final decorators;


  final DirectiveRef component;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  final String childMode;

  ElementBinder(this._perf, this._expando, this.component, this.decorators, this.onEvents, this.childMode);

  final bool hasTemplate = false;

  bool get shouldCompileChildren =>
      childMode == NgAnnotation.COMPILE_CHILDREN;

  ElementBinder get templateBinder => new ElementBinder.forTransclusion(this);

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    if (component != null) return _directiveCache = new List.from(decorators)..add(component);
    return _directiveCache = decorators;
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

  _link(nodeInjector, probe, scope, nodeAttrs, filters) {
    _usableDirectiveRefs.forEach((DirectiveRef ref) {
      var linkTimer;
      try {
        var linkMapTimer;
        assert((linkTimer = _perf.startTimer('ng.view.link', ref.type)) != false);
        var controller = nodeInjector.get(ref.type);
        probe.directives.add(controller);
        assert((linkMapTimer = _perf.startTimer('ng.view.link.map', ref.type)) != false);

        if (ref.annotation is NgController) {
          scope.context[(ref.annotation as NgController).publishAs] = controller;
        }

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
          if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
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
  }

  _createDirectiveFactories(DirectiveRef ref, nodeModule, node, nodesAttrsDirectives, nodeAttrs, visibility) {
    if (ref.type == NgTextMustacheDirective) {
      nodeModule.factory(NgTextMustacheDirective, (Injector injector) {
        return new NgTextMustacheDirective(node, ref.value, injector.get(Interpolate), injector.get(Scope), injector.get(FilterMap));
      });
    } else if (ref.type == NgAttrMustacheDirective) {
      if (nodesAttrsDirectives.isEmpty) {
        nodeModule.factory(NgAttrMustacheDirective, (Injector injector) {
          var scope = injector.get(Scope);
          var interpolate = injector.get(Interpolate);
          for (var ref in nodesAttrsDirectives) {
            new NgAttrMustacheDirective(nodeAttrs, ref.value, interpolate, scope, injector.get(FilterMap));
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
        var componentFactory = new _ComponentFactory(node, ref.type, ref.annotation as NgComponent, injector.get(dom.NodeTreeSanitizer), _expando);
        var controller = componentFactory.call(injector, scope, viewCache, http, templateCache, directives);

        componentFactory.shadowScope.context[(ref.annotation as NgComponent).publishAs] = controller;
        return controller;
      }, visibility: visibility);
    } else {
      nodeModule.type(ref.type, visibility: visibility);
    }
  }

  // Overridden in TemplateElementBinder
  _registerViewFactory(node, parentInjector, nodeModule) {
    nodeModule
      ..factory(ViewPort, null)
      ..factory(ViewFactory, null)
      ..factory(BoundViewFactory, null);
  }

  Injector bind(View view, Injector parentInjector, dom.Node node) {
    Injector nodeInjector;
    Scope scope = parentInjector.get(Scope);
    FilterMap filters = parentInjector.get(FilterMap);
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    ElementProbe probe;

    var timerId;
    assert((timerId = _perf.startTimer('ng.view.link.setUp', _html(node))) != false);
    var directiveRefs = _usableDirectiveRefs;
    try {
      if (!hasDirectivesOrEvents) return parentInjector;

      var nodesAttrsDirectives = [];
      var nodeModule = new Module()
          ..type(NgElement)
          ..value(View, view)
          ..value(dom.Element, node)
          ..value(dom.Node, node)
          ..value(NodeAttrs, nodeAttrs)
          ..factory(ElementProbe, (_) => probe);

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

        _createDirectiveFactories(ref, nodeModule, node, nodesAttrsDirectives, nodeAttrs, visibility);
        for (var publishType in ref.annotation.publishTypes) {
          nodeModule.factory(publishType, (Injector injector) =>
              injector.get(ref.type), visibility: visibility);
        }
      });

      _registerViewFactory(node, parentInjector, nodeModule);

      nodeInjector = parentInjector.createChild([nodeModule]);
      probe = _expando[node] = new ElementProbe(
          parentInjector.get(ElementProbe), node, nodeInjector, scope);
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }

    _link(nodeInjector, probe, scope, nodeAttrs, filters);

    onEvents.forEach((event, value) {
      view.registerEvent(EventHandler.attrNameToEventName(event));
    });
    return nodeInjector;
  }

  toString() => "[ElementBinder decorators:$decorators]";
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
