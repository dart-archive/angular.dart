part of angular.core.dom_internal;

abstract class ComponentFactory {
  FactoryFn call(dom.Node node, DirectiveRef ref);

  static async.Future<ViewFactory> _viewFuture(
        Component component, ViewCache viewCache, DirectiveMap directives) {
    if (component.template != null) {
      return new async.Future.value(viewCache.fromHtml(component.template, directives));
    }
    if (component.templateUrl != null) {
      return viewCache.fromUrl(component.templateUrl, directives);
    }
    return null;
  }

  static void _setupOnShadowDomAttach(controller, TemplateLoader templateLoader,
                                      Scope shadowScope) {
    if (controller is ShadowRootAware) {
      templateLoader.template.then((shadowDom) {
        if (!shadowScope.isAttached) return;
        (controller as ShadowRootAware).onShadowRoot(shadowDom);
      });
    }
  }
}

@Injectable()
class ShadowDomComponentFactory implements ComponentFactory {
  final Expando _expando;

  ShadowDomComponentFactory(this._expando);

  final Map<String, async.Future<dom.StyleElement>> _styleElementCache = {};

  
  
  FactoryFn call(dom.Node node, DirectiveRef ref) {
    return (Injector injector) {
        var component = ref.annotation as Component;
        Scope scope = injector.getByKey(SCOPE_KEY);
        ViewCache viewCache = injector.getByKey(VIEW_CACHE_KEY);
        Http http = injector.getByKey(HTTP_KEY);
        TemplateCache templateCache = injector.getByKey(TEMPLATE_CACHE_KEY);
        DirectiveMap directives = injector.getByKey(DIRECTIVE_MAP_KEY);
        NgBaseCss baseCss = component.useNgBaseCss ? injector.getByKey(NG_BASE_CSS_KEY) : null;
        // This is a bit of a hack since we are returning different type then we are.
        var componentFactory = new _ComponentFactory(node, ref.typeKey, component,
            injector.getByKey(NODE_TREE_SANITIZER_KEY), _expando, baseCss, _styleElementCache);
        var controller = componentFactory.call(injector, scope, viewCache, http, templateCache,
            directives);

        componentFactory.shadowScope.context[component.publishAs] = controller;
        return controller;
      };
  }
}


/**
 * ComponentFactory is responsible for setting up components. This includes
 * the shadowDom, fetching template, importing styles, setting up attribute
 * mappings, publishing the controller, and compiling and caching the template.
 */
class _ComponentFactory implements Function {

  final dom.Element element;
  final Key typeKey;
  final Component component;
  final dom.NodeTreeSanitizer treeSanitizer;
  final Expando _expando;
  final NgBaseCss _baseCss;
  final Map<String, async.Future<dom.StyleElement>> _styleElementCache;

  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  var controller;

  _ComponentFactory(this.element, this.typeKey, this.component, this.treeSanitizer,
                    this._expando, this._baseCss, this._styleElementCache);

  dynamic call(Injector injector, Scope scope,
               ViewCache viewCache, Http http, TemplateCache templateCache,
               DirectiveMap directives) {
    shadowDom = element.createShadowRoot()
      ..applyAuthorStyles = component.applyAuthorStyles
      ..resetStyleInheritance = component.resetStyleInheritance;

    shadowScope = scope.createChild({}); // Isolate
    // TODO(pavelgj): fetching CSS with Http is mainly an attempt to
    // work around an unfiled Chrome bug when reloading same CSS breaks
    // styles all over the page. We shouldn't be doing browsers work,
    // so change back to using @import once Chrome bug is fixed or a
    // better work around is found.
    Iterable<async.Future<dom.StyleElement>> cssFutures;
    var cssUrls = _baseCss != null ?
       ([]..addAll(_baseCss.urls)..addAll(component.cssUrls)) :
       component.cssUrls;
    if (cssUrls.isNotEmpty) {
      cssFutures = cssUrls.map((cssUrl) => _styleElementCache.putIfAbsent(cssUrl, () =>
        http.get(cssUrl, cache: templateCache)
          .then((resp) => resp.responseText,
            onError: (e) => '/*\n$e\n*/\n')
          .then((styleContent) => new dom.StyleElement()..appendText(styleContent))
      )).toList();
    } else {
      cssFutures = [new async.Future.value(null)];
    }
    var viewFuture = ComponentFactory._viewFuture(component, viewCache, directives);
    TemplateLoader templateLoader = new TemplateLoader(
        async.Future.wait(cssFutures).then((Iterable<dom.StyleElement> cssList) {
          cssList
              .where((styleElement) => styleElement != null)
              .forEach((styleElement) => shadowDom.append(styleElement.clone(true)));
          if (viewFuture != null) {
            return viewFuture.then((ViewFactory viewFactory) {
              return (!shadowScope.isAttached) ?
                shadowDom :
                attachViewToShadowDom(viewFactory);
            });
          }
          return shadowDom;
        }));
    controller = createShadowInjector(injector, templateLoader).getByKey(typeKey);
    ComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
    return controller;
  }

  dom.ShadowRoot attachViewToShadowDom(ViewFactory viewFactory) {
    var view = viewFactory(shadowInjector);
    shadowDom.nodes.addAll(view.nodes);
    return shadowDom;
  }

  Injector createShadowInjector(injector, TemplateLoader templateLoader) {
    var probe;
   var shadowModule = new Module()
      ..bindByKey(typeKey)
      ..bindByKey(NG_ELEMENT_KEY)
      ..bindByKey(EVENT_HANDLER_KEY, toImplementation: ShadowRootEventHandler)
      ..bindByKey(SCOPE_KEY, toValue: shadowScope)
      ..bindByKey(TEMPLATE_LOADER_KEY, toValue: templateLoader)
      ..bindByKey(SHADOW_ROOT_KEY, toValue: shadowDom)
      ..bindByKey(ELEMENT_PROBE_KEY, toFactory: (_) => probe);
      shadowInjector = injector.createChild([shadowModule], name: SHADOW_DOM_INJECTOR_NAME);
    probe = _expando[shadowDom] = new ElementProbe(
        injector.getByKey(ELEMENT_PROBE_KEY), shadowDom, shadowInjector, shadowScope);
    shadowScope.on(ScopeEvent.DESTROY).listen((ScopeEvent) {_expando[shadowDom] = null;});
    return shadowInjector;
  }
}
