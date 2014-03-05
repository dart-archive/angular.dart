part of angular.core.dom;


/**
 * BoundViewFactory is a [ViewFactory] which does not need Injector because
 * it is pre-bound to an injector from the parent. This means that this
 * BoundViewFactory can only be used from within a specific Directive such
 * as [NgRepeat], but it can not be stored in a cache.
 *
 * The BoundViewFactory needs [Scope] to be created.
 */
class BoundViewFactory {
  ViewFactory viewFactory;
  Injector injector;

  BoundViewFactory(this.viewFactory, this.injector);

  View call(Scope scope) =>
    viewFactory(injector.createChild([new Module()..value(Scope, scope)]));
}

/**
 * ViewFactory is used to create new [View]s. ViewFactory is created by the
 * [Compiler] as a result of compiling a template.
 */
class ViewFactory implements Function {
  final List<ElementBinder> elementBinders;
  final List<dom.Node> templateElements;
  final Profiler _perf;
  final Expando _expando;

  ViewFactory(this.templateElements, this.elementBinders, this._perf, this._expando) {
    assert(elementBinders.forEach((ElementBinder eb) { assert(eb is ElementBinder); }) != true);
  }

  BoundViewFactory bind(Injector injector) =>
      new BoundViewFactory(this, injector);

  View call(Injector injector, [List<dom.Node> nodes]) {
    if (nodes == null) nodes = cloneElements(templateElements);
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      var view = new View(nodes);
      _link(view, nodes, elementBinders, injector);
      return view;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  _link(View view, List<dom.Node> nodeList, List elementBinders, Injector parentInjector) {
    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (int i = 0; i < elementBinders.length; i++) {
      var eb = elementBinders[i];
      int index = eb.offsetIndex;

      List childElementBinders = eb.childElementBinders;
      int nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];

      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.view.link', _html(node))) != false);
        // if node isn't attached to the DOM, create a parent for it.
        var parentNode = node.parentNode;
        var fakeParent = false;
        if (parentNode == null) {
          fakeParent = true;
          parentNode = new dom.DivElement();
          parentNode.append(node);
        }

        var childInjector = _instantiateDirectives(view, parentInjector, node,
            eb, parentInjector.get(Parser));

        if (childElementBinders != null) {
          _link(view, node.nodes, childElementBinders, childInjector);
        }

        if (fakeParent) {
          // extract the node from the parentNode.
          nodeList[nodeListIndex] = parentNode.nodes[0];
        }
      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }
    }
  }

  // TODO: This is actually ElementBinder.bind
  Injector _instantiateDirectives(View view, Injector parentInjector,
                                  dom.Node node, ElementBinder elementBinder,
                                  Parser parser) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.view.link.setUp', _html(node))) != false);
    Injector nodeInjector;
    Scope scope = parentInjector.get(Scope);
    FilterMap filters = parentInjector.get(FilterMap);
    Map<Type, _ComponentFactory> fctrs;
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    ElementProbe probe;

    var directiveRefs = elementBinder.usableDirectiveRefs;
    try {
      if (directiveRefs == null || directiveRefs.length == 0) {
        return parentInjector;
      }
      var viewPortFactory = (_) => null;
      var viewFactory = (_) => null;
      var boundViewFactory = (_) => null;
      var nodesAttrsDirectives = null;

      var nodeModule = new Module()
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
            return componentFactory.call(injector, compiler, scope, viewCache,
                http, templateCache, directives);
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
          viewFactory = (_) => ref.viewFactory;
          boundViewFactory = (Injector injector) =>
              ref.viewFactory.bind(injector);
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
        var shadowScope = (fctrs != null && fctrs.containsKey(ref.type))
            ? fctrs[ref.type].shadowScope
            : null;
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

  // DI visibility callback allowing node-local visibility.
  static final Function _elementOnly = (Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) requesting = requesting.parent;
    return identical(requesting, defining);
  };

  // DI visibility callback allowing visibility from direct child into parent.
  static final Function _elementDirectChildren = (Injector requesting,
                                                  Injector defining) {
    if (requesting.name == _SHADOW) requesting = requesting.parent;
    return _elementOnly(requesting, defining) ||
           identical(requesting.parent, defining);
  };
}

/**
 * ViewCache is used to cache the compilation of templates into [View]s.
 * It can be used synchronously if HTML is known or asynchronously if the
 * template HTML needs to be looked up from the URL.
 */
@NgInjectableService()
class ViewCache {
  // _viewFactoryCache is unbounded
  final _viewFactoryCache = new LruCache<String, ViewFactory>(capacity: 0);
  final Http $http;
  final TemplateCache $templateCache;
  final Compiler compiler;
  final dom.NodeTreeSanitizer treeSanitizer;

  ViewCache(this.$http, this.$templateCache, this.compiler, this.treeSanitizer);

  ViewFactory fromHtml(String html, DirectiveMap directives) {
    ViewFactory viewFactory = _viewFactoryCache.get(html);
    if (viewFactory == null) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);
      viewFactory = compiler(div.nodes, directives);
      _viewFactoryCache.put(html, viewFactory);
    }
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives) {
    return $http.getString(url, cache: $templateCache).then(
        (html) => fromHtml(html, directives));
  }
}

/**
 * ComponentFactory is responsible for setting up components. This includes
 * the shadowDom, fetching template, importing styles, setting up attribute
 * mappings, publishing the controller, and compiling and caching the template.
 */
class _ComponentFactory implements Function {

  final dom.Element element;
  final Type type;
  final NgComponent component;
  final dom.NodeTreeSanitizer treeSanitizer;
  final Expando _expando;

  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  Compiler compiler;
  var controller;

  _ComponentFactory(this.element, this.type, this.component, this.treeSanitizer,
                    this._expando);

  dynamic call(Injector injector, Compiler compiler, Scope scope,
               ViewCache $viewCache, Http $http, TemplateCache $templateCache,
               DirectiveMap directives) {
    this.compiler = compiler;
    shadowDom = element.createShadowRoot();
    shadowDom.applyAuthorStyles = component.applyAuthorStyles;
    shadowDom.resetStyleInheritance = component.resetStyleInheritance;

    shadowScope = scope.createChild({}); // Isolate
    // TODO(pavelgj): fetching CSS with Http is mainly an attempt to
    // work around an unfiled Chrome bug when reloading same CSS breaks
    // styles all over the page. We shouldn't be doing browsers work,
    // so change back to using @import once Chrome bug is fixed or a
    // better work around is found.
    List<async.Future<String>> cssFutures = new List();
    var cssUrls = component.cssUrls;
    if (cssUrls.isNotEmpty) {
      cssUrls.forEach((css) => cssFutures.add(
          $http.getString(css, cache: $templateCache).catchError((e) =>
              '/*\n$e\n*/\n')
      ));
    } else {
      cssFutures.add( new async.Future.value(null) );
    }
    var viewFuture;
    if (component.template != null) {
      viewFuture = new async.Future.value($viewCache.fromHtml(
          component.template, directives));
    } else if (component.templateUrl != null) {
      viewFuture = $viewCache.fromUrl(component.templateUrl, directives);
    }
    TemplateLoader templateLoader = new TemplateLoader(
        async.Future.wait(cssFutures).then((Iterable<String> cssList) {
          if (cssList != null) {
            var filteredCssList = cssList.where((css) => css != null );
            shadowDom.setInnerHtml('<style>${filteredCssList.join('')}</style>',
            treeSanitizer: treeSanitizer);
          }
          if (viewFuture != null) {
            return viewFuture.then((ViewFactory viewFactory) {
              if (!shadowScope.isAttached) return shadowDom;
              return attachViewToShadowDom(viewFactory);
            });
          }
          return shadowDom;
        }));
    controller = createShadowInjector(injector, templateLoader).get(type);
    if (controller is NgShadowRootAware) {
      templateLoader.template.then((_) {
        if (!shadowScope.isAttached) return;
        (controller as NgShadowRootAware).onShadowRoot(shadowDom);
      });
    }
    return controller;
  }

  attachViewToShadowDom(ViewFactory viewFactory) {
    var view = viewFactory(shadowInjector);
    shadowDom.nodes.addAll(view.nodes);
    return shadowDom;
  }

  createShadowInjector(injector, TemplateLoader templateLoader) {
    var probe;
    var shadowModule = new Module()
        ..type(type)
        ..value(Scope, shadowScope)
        ..value(TemplateLoader, templateLoader)
        ..value(dom.ShadowRoot, shadowDom)
        ..factory(ElementProbe, (_) => probe);
    shadowInjector = injector.createChild([shadowModule], name: _SHADOW);
    probe = _expando[shadowDom] = new ElementProbe(
        injector.get(ElementProbe), shadowDom, shadowInjector, shadowScope);
    return shadowInjector;
  }
}

class _AnchorAttrs extends NodeAttrs {
  DirectiveRef _directiveRef;

  _AnchorAttrs(DirectiveRef this._directiveRef):super(null);

  operator [](name) => name == '.' ? _directiveRef.value : null;

  observe(String attributeName, AttributeChanged notifyFn) {
    if (attributeName == '.') {
      notifyFn(_directiveRef.value);
    } else {
      notifyFn(null);
    }
  }
}

String _SHADOW = 'SHADOW_INJECTOR';

String _html(obj) {
  if (obj is String) {
    return obj;
  } else if (obj is List) {
    return (obj as List).map((e) => _html(e)).join();
  } else if (obj is dom.Element) {
    var text = (obj as dom.Element).outerHtml;
    return text.substring(0, text.indexOf('>') + 1);
  }
  return obj.nodeName;
}

/**
 * [ElementProbe] is attached to each [Element] in the DOM. Its sole purpose is
 * to allow access to the [Injector], [Scope], and Directives for debugging and
 * automated test purposes. The information here is not used by Angular in any
 * way.
 *
 * see: [ngInjector], [ngScope], [ngDirectives]
 */
class ElementProbe {
  final ElementProbe parent;
  final dom.Node element;
  final Injector injector;
  final Scope scope;
  final directives = [];

  ElementProbe(this.parent, this.element, this.injector, this.scope);
}
