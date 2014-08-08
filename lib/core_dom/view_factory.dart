part of angular.core.dom_internal;


/**
 * BoundViewFactory is a [ViewFactory] which does not need Injector because
 * it is pre-bound to an injector from the parent. This means that this
 * BoundViewFactory can only be used from within a specific Directive such
 * as [NgRepeat], but it can not be stored in a cache.
 *
 * The BoundViewFactory needs [Scope] to be created.
 */
@deprecated
class BoundViewFactory {
  ViewFactory viewFactory;
  DirectiveInjector directiveInjector;

  BoundViewFactory(this.viewFactory, this.directiveInjector);

  View call(Scope scope) => viewFactory(scope, directiveInjector);
}

abstract class ViewFactory implements Function {
  @deprecated
  BoundViewFactory bind(DirectiveInjector directiveInjector);

  View call(Scope scope, DirectiveInjector directiveInjector, [List<dom.Node> elements]);
}

/**
 * ViewCache is used to cache the compilation of templates into [View]s.
 * It can be used synchronously if HTML is known or asynchronously if the
 * template HTML needs to be looked up from the URL.
 */
@Injectable()
class ViewCache {
  // viewFactoryCache is unbounded
  // This cache contains both HTML and URL keys.
  final viewFactoryCache = new LruCache<String, ViewFactory>();
  final Http http;
  final TemplateCache templateCache;
  final Compiler compiler;
  final dom.NodeTreeSanitizer treeSanitizer;

  ViewCache(this.http, this.templateCache, this.compiler, this.treeSanitizer, CacheRegister cacheRegister) {
    cacheRegister.registerCache('ViewCache', viewFactoryCache);
  }

  ViewFactory fromHtml(String html, DirectiveMap directives) {
    ViewFactory viewFactory = viewFactoryCache.get(html);
    if (viewFactory == null) {
      var div = new dom.DivElement();
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);
      viewFactory = compiler(div.nodes, directives);
      viewFactoryCache.put(html, viewFactory);
    }
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives) {
    ViewFactory viewFactory = viewFactoryCache.get(url);
    if (viewFactory == null) {
      return http.get(url, cache: templateCache).then((resp) {
        var viewFactoryFromHttp = fromHtml(resp.responseText, directives);
        viewFactoryCache.put(url, viewFactoryFromHttp);
        return viewFactoryFromHttp;
      });
    }
    return new async.Future.value(viewFactory);
  }
}

class _AnchorAttrs extends NodeAttrs {
  DirectiveRef _directiveRef;

  _AnchorAttrs(DirectiveRef this._directiveRef): super(null);

  String operator [](name) => name == '.' ? _directiveRef.value : null;

  void observe(String attributeName, _AttributeChanged notifyFn) {
    notifyFn(attributeName == '.' ? _directiveRef.value : null);
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
  final DirectiveInjector injector;
  final Scope scope;
  List get directives => injector.directives;
  final bindingExpressions = <String>[];
  final modelExpressions = <String>[];

  ElementProbe(this.parent, this.element, this.injector, this.scope);

  dynamic directive(Type type) => injector.get(type);
}
