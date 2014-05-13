part of angular.core.dom_internal;


/**
 * BoundViewFactory is a [ViewFactory] which does not need Injector because
 * it is pre-bound to an injector from the parent. This means that this
 * BoundViewFactory can only be used from within a specific Directive such
 * as [NgRepeat], but it can not be stored in a cache.
 *
 * The BoundViewFactory needs [Scope] to be created.
 */
class BoundViewFactory {
  static Function factory = (Injector injector) => injector.get(ViewFactory).bind(injector);
  ViewFactory viewFactory;
  Injector injector;

  BoundViewFactory(this.viewFactory, this.injector);

  View call(Scope scope) => viewFactory(injector, scope);
}

abstract class ViewFactory implements Function {
  BoundViewFactory bind(Injector injector);

  View call(Injector injector, Scope scope);

  static FactoryFn componentFactory(Type type, Component annotation) {
    var shadowModule = new Module();
    shadowModule.bind(Scope, toFactory: (Injector i) {
      Scope elementScope = i.parent.get(Scope);
      return elementScope.createChild({});
    });
    shadowModule.bind(type);
    shadowModule.bind(OnEvent, toFactory: (Injector i) => i.parent.get(NgElement));
    var modules = [shadowModule];
    return (Injector elementInjector) {
      Injector shadowInjector = elementInjector.createChild(modules);
      return shadowInjector.get(type);
    };
  }
}

/**
 * ViewCache is used to cache the compilation of templates into [View]s.
 * It can be used synchronously if HTML is known or asynchronously if the
 * template HTML needs to be looked up from the URL.
 */
@Injectable()
class ViewCache {
  // _viewFactoryCache is unbounded
  final _viewFactoryCache = new LruCache<String, ViewFactory>();
  final Http http;
  final TemplateCache templateCache;
  final Compiler compiler;
  final dom.NodeTreeSanitizer treeSanitizer;

  ViewCache(this.http, this.templateCache, this.compiler, this.treeSanitizer);

  ViewFactory fromHtml(String html, DirectiveMap directives) {
    ViewFactory viewFactory = _viewFactoryCache.get(html);
    if (viewFactory == null) {
      var div = new dom.DivElement(); // Todo(misko): use Template
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);
      viewFactory = compiler(div.nodes.toList(), directives);
      _viewFactoryCache.put(html, viewFactory);
    }
    assert(viewFactory.compileInPlace == false);
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives) {
    return http.get(url, cache: templateCache).then(
        (resp) => fromHtml(resp.responseText, directives));
  }
}

String _html(obj) {
  if (obj is String) {
    return obj;
  }
  if (obj is List) {
    return (obj as List).map((e) => _html(e)).join();
  }
  if (obj is dom.Element) {
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
  final List<Object> directives = <Object>[];

  ElementProbe(this.parent, this.element, this.injector, this.scope);
}
