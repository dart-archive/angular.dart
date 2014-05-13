part of angular.core.dom_internal;

abstract class ComponentFactory {
  FactoryFn call(Type type, Component annotation);

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

  static void _setupOnShadowDomAttach(controller, templateLoader, shadowScope) {
    if (controller is ShadowRootAware) {
      templateLoader.template.then((shadowDom) {
        if (!shadowScope.isAttached) return;
        (controller as ShadowRootAware).onShadowRoot(shadowDom);
      });
    }
  }
}

class AutoSelectComponentFactory extends ComponentFactory {
  ShadowDomComponentFactory shadowComponentFactory;
  TranscludingComponentFactory transcludingComponentFactory;
  ComponentFactory defaultComponentFactory;

  AutoSelectComponentFactory(this.defaultComponentFactory,
                             this.shadowComponentFactory,
                             this.transcludingComponentFactory);

  FactoryFn call(Type type, Component annotation) {
    ComponentFactory factory;
    if (annotation.useShadowDom == true) {
      factory = shadowComponentFactory;
    } else if (annotation.useShadowDom == false) {
      factory = transcludingComponentFactory;
    } else {
      factory = defaultComponentFactory;
    }
    return factory(type, annotation);
  }
}

@Injectable()
class ShadowDomComponentFactory implements ComponentFactory {
  final Map<String, async.Future<dom.StyleElement>> _styleElementCache = {};

  FactoryFn call(Type type, Component annotation) {
    // TODO(misko): hoist modules setup outside the closure
    return (Injector injector) {
        Scope scope = injector.get(Scope);
        ViewCache viewCache = injector.get(ViewCache);
        Http http = injector.get(Http);
        TemplateCache templateCache = injector.get(TemplateCache);
        DirectiveMap directives = injector.get(DirectiveMap);
        NgBaseCss baseCss = injector.get(NgBaseCss);
        // This is a bit of a hack since we are returning different type then we are.
        var componentFactory = new _ComponentFactory(injector.get(dom.Element), type, annotation,
            injector.get(dom.NodeTreeSanitizer), injector.get(Expando), baseCss, _styleElementCache);
        var controller = componentFactory.call(injector, scope, viewCache, http, templateCache,
            directives);

        componentFactory.shadowScope.context[annotation.publishAs] = controller;
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
  final Map<String, async.Future<dom.StyleElement>> _styleElementCache;

  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  var controller;

  _ComponentFactory(this.element, this.type, this.component, this.treeSanitizer,
                    this._expando, this._baseCss, this._styleElementCache);

  dynamic call(Injector injector, Scope scope,
               ViewCache viewCache, Http http, TemplateCache templateCache,
               DirectiveMap directives) {
    shadowDom = element.createShadowRoot()
      ..applyAuthorStyles = component.applyAuthorStyles
      ..resetStyleInheritance = component.resetStyleInheritance;

    shadowScope = scope.createChild({'SHADOW':true}); // Isolate
    // TODO(pavelgj): fetching CSS with Http is mainly an attempt to
    // work around an unfiled Chrome bug when reloading same CSS breaks
    // styles all over the page. We shouldn't be doing browsers work,
    // so change back to using @import once Chrome bug is fixed or a
    // better work around is found.
    Iterable<async.Future<dom.StyleElement>> cssFutures;
    var cssUrls = []..addAll(_baseCss.urls)..addAll(component.cssUrls);
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
                attachViewToShadowDom(viewFactory, shadowScope);
            });
          }
          return shadowDom;
        }));
    controller = createShadowInjector(injector, templateLoader).get(type);
    ComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
    return controller;
  }

  dom.ShadowRoot attachViewToShadowDom(ViewFactory viewFactory, Scope scope) {
    var view = viewFactory(shadowInjector, scope);
    shadowDom.nodes.addAll(view.nodes);
    return shadowDom;
  }

  Injector createShadowInjector(injector, TemplateLoader templateLoader) {
    var probe;
    var shadowModule = new Module()
      ..bind(type)
      ..bind(NgElement)
      ..bind(EventHandler, toImplementation: ShadowRootEventHandler)
      ..bind(Scope, toValue: shadowScope)
      ..bind(TemplateLoader, toValue: templateLoader)
      ..bind(dom.ShadowRoot, toValue: shadowDom)
      ..bind(ElementProbe, toFactory: (_) => probe);
    shadowInjector = injector.createChild([shadowModule], name: SHADOW_DOM_INJECTOR_NAME);
    probe = _expando[shadowDom] = new ElementProbe(
        injector.get(ElementProbe), shadowDom, shadowInjector, shadowScope);
    return shadowInjector;
  }
}
