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
 * [WalkingViewFactory] is used to create new [View]s. WalkingViewFactory is
 * created by the [Compiler] as a result of compiling a template.
 */
class WalkingViewFactory implements ViewFactory {
  final List<ElementBinderTreeRef> elementBinders;
  final List<dom.Node> templateElements;
  final Profiler _perf;
  final Expando _expando;

  WalkingViewFactory(this.templateElements, this.elementBinders, this._perf,
                     this._expando) {
    assert(elementBinders.every((ElementBinderTreeRef eb) =>
        eb is ElementBinderTreeRef));
  }

  BoundViewFactory bind(DirectiveInjector directiveInjector) =>
      new BoundViewFactory(this, directiveInjector);

  View call(Scope scope, DirectiveInjector directiveInjector, [List<dom.Node> nodes]) {
    assert(directiveInjector != null);
    if (nodes == null) nodes = cloneElements(templateElements);
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      EventHandler eventHandler =  directiveInjector.getByKey(EVENT_HANDLER_KEY);
      Animate animate = directiveInjector.getByKey(ANIMATE_KEY);
      var view = new View(nodes, scope, eventHandler);
      _link(view, scope, nodes, elementBinders, eventHandler, animate, directiveInjector);
      return view;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  View _link(View view, Scope scope, List<dom.Node> nodeList, List elementBinders,
             EventHandler eventHandler, Animate animate,
             DirectiveInjector directiveInjector) {

    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (int i = 0; i < elementBinders.length; i++) {
      // querySelectorAll('.ng-binding') should return a list of nodes in the
      // same order as the elementBinders list.

      // keep a injector array --

      var eb = elementBinders[i];
      int index = eb.offsetIndex;

      ElementBinderTree tree = eb.subtree;

      //List childElementBinders = eb.childElementBinders;
      int nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];
      var binder = tree.binder;

      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.view.link', _html(node))) != false);
        // if node isn't attached to the DOM, create a parent for it.
        var parentNode = node.parentNode;
        var fakeParent = false;
        if (parentNode == null) {
          fakeParent = true;
          parentNode = new dom.DivElement()..append(node);
        }

        DirectiveInjector childInjector;
        if (binder == null) {
          childInjector = directiveInjector;
        } else {
          childInjector = binder.bind(view, scope, directiveInjector, node, eventHandler, animate);

          // TODO(misko): Remove this after we remove controllers. No controllers -> 1to1 Scope:View.
          if (childInjector != directiveInjector) scope = childInjector.scope;
        }
        if (fakeParent) {
          // extract the node from the parentNode.
          nodeList[nodeListIndex] = parentNode.nodes[0];
        }

        if (tree.subtrees != null) {
          _link(view, scope, node.nodes, tree.subtrees, eventHandler, animate, childInjector);
        }
      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }
    }
    return view;
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
  // This cache contains both HTML and URL keys.
  final viewFactoryCache = new LruCache<String, ViewFactory>();
  final Http http;
  final TemplateCache templateCache;
  final Compiler compiler;
  final dom.NodeTreeSanitizer treeSanitizer;

  ViewCache(this.http, this.templateCache, this.compiler, this.treeSanitizer, CacheRegister cacheRegister) {
    cacheRegister.registerCache('viewCache', viewFactoryCache);
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
}
