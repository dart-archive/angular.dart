part of angular.core.dom_internal;

abstract class ComponentFactory {
  FactoryFn call(dom.Node node, DirectiveRef ref);
}

@Injectable()
class ShadowDomComponentFactory implements ComponentFactory {
  final Expando _expando;

  ShadowDomComponentFactory(this._expando);

  FactoryFn call(dom.Node node, DirectiveRef ref) {
    return (Injector injector) {
        var component = ref.annotation as Component;
        Compiler compiler = injector.get(Compiler);
        Scope scope = injector.get(Scope);
        ViewCache viewCache = injector.get(ViewCache);
        Http http = injector.get(Http);
        TemplateCache templateCache = injector.get(TemplateCache);
        DirectiveMap directives = injector.get(DirectiveMap);
        NgBaseCss baseCss = injector.get(NgBaseCss);
        // This is a bit of a hack since we are returning different type then we are.
        var componentFactory = new _ComponentFactory(node, ref.type, component,
            injector.get(dom.NodeTreeSanitizer), _expando, baseCss);
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
  final Type type;
  final Component component;
  final dom.NodeTreeSanitizer treeSanitizer;
  final Expando _expando;
  final NgBaseCss _baseCss;

  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  var controller;

  _ComponentFactory(this.element, this.type, this.component, this.treeSanitizer,
                    this._expando, this._baseCss);

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
        List<async.Future<String>> cssFutures = new List();
    var cssUrls = []..addAll(_baseCss.urls)..addAll(component.cssUrls);
    if (cssUrls.isNotEmpty) {
      cssUrls.forEach((css) => cssFutures.add(http
      .get(css, cache: templateCache).then(
              (resp) => resp.responseText,
              onError: (e) => '/*\n$e\n*/\n')
      ));
    } else {
      cssFutures.add(new async.Future.value(null));
    }
    var viewFuture;
    if (component.template != null) {
      viewFuture = new async.Future.value(viewCache.fromHtml(
          component.template, directives));
    } else if (component.templateUrl != null) {
      viewFuture = viewCache.fromUrl(component.templateUrl, directives);
    }
    TemplateLoader templateLoader = new TemplateLoader(
        async.Future.wait(cssFutures).then((Iterable<String> cssList) {
          if (cssList != null) {
            shadowDom.setInnerHtml(
                cssList
                .where((css) => css != null)
                .map((css) => '<style>$css</style>')
                .join(''),
                treeSanitizer: treeSanitizer);
          }
          if (viewFuture != null) {
            return viewFuture.then((ViewFactory viewFactory) {
              return (!shadowScope.isAttached) ?
              shadowDom :
              attachViewToShadowDom(viewFactory);
            });
          }
          return shadowDom;
        }));
    controller = createShadowInjector(injector, templateLoader).get(type);
    if (controller is ShadowRootAware) {
      templateLoader.template.then((_) {
        if (!shadowScope.isAttached) return;
        (controller as ShadowRootAware).onShadowRoot(shadowDom);
      });
    }
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
      ..type(type)
      ..type(NgElement)
      ..type(EventHandler, implementedBy: ShadowRootEventHandler)
      ..value(Scope, shadowScope)
      ..value(TemplateLoader, templateLoader)
      ..value(dom.ShadowRoot, shadowDom)
      ..factory(ElementProbe, (_) => probe);
    shadowInjector = injector.createChild([shadowModule], name: SHADOW_DOM_INJECTOR_NAME);
    probe = _expando[shadowDom] = new ElementProbe(
        injector.get(ElementProbe), shadowDom, shadowInjector, shadowScope);
    return shadowInjector;
  }
}
