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

class ViewFactory implements Function {
  final List<TaggedElementBinder> elementBinders;
  final List<dom.Node> templateNodes;
  final List<NodeLinkingInfo> nodeLinkingInfos;
  final Profiler _perf;
  String _debugHtml;

  ViewFactory(templateNodes, this.elementBinders, this._perf) :
      nodeLinkingInfos = computeNodeLinkingInfos(templateNodes),
      templateNodes = templateNodes
  {
    if (traceEnabled) {
      _debugHtml = templateNodes.map((dom.Node e) {
        if (e is dom.Element) {
          return (e as dom.Element).outerHtml;
        } else if (e is dom.Comment) {
          return '<!--${(e as dom.Comment).text}-->';
        } else {
          return e.text;
        }
      }).toList().join('');
    }
  }

  @deprecated
  BoundViewFactory bind(DirectiveInjector directiveInjector) =>
      new BoundViewFactory(this, directiveInjector);

  View call(Scope scope, DirectiveInjector directiveInjector,
            [List<dom.Node> nodes /* TODO: document fragment */]) {
    var s = traceEnter1(View_create, _debugHtml);
    assert(scope != null);
    if (nodes == null) {
      nodes = cloneElements(templateNodes);
    }
    var view = new View(nodes, scope);
    _link(view, scope, nodes, directiveInjector);
    traceLeave(s);

    return view;
  }

  void _bindTagged(TaggedElementBinder tagged, int elementBinderIndex,
      DirectiveInjector rootInjector,
      List<DirectiveInjector> elementInjectors, View view, boundNode,
      Scope scope, _Hydrator hydrator) {
    var binder = tagged.binder;
    DirectiveInjector parentInjector =
        tagged.parentBinderOffset == -1 ? rootInjector : elementInjectors[tagged.parentBinderOffset];

    var elementInjector;
    if (binder == null) {
      elementInjector = parentInjector;
    } else {
      // TODO(misko): Remove this after we remove controllers. No controllers -> 1to1 Scope:View.
      if (parentInjector != rootInjector && parentInjector.scope != null) {
        scope = parentInjector.scope;
      }
      elementInjector = binder.setUp(view, scope, parentInjector, boundNode);
      hydrator.addEntry(binder, elementInjector);
    }
    // TODO(misko): Remove this after we remove controllers. No controllers -> 1to1 Scope:View.
    if (elementInjector != rootInjector && elementInjector.scope != null) {
      scope = elementInjector.scope;
    }
    elementInjectors[elementBinderIndex] = elementInjector;

    if (tagged.textBinders != null) {
      for (var k = 0; k < tagged.textBinders.length; k++) {
        TaggedTextBinder taggedText = tagged.textBinders[k];
        var childNode = boundNode.childNodes[taggedText.offsetIndex];
        final injector = taggedText.binder.setUp(view, scope, elementInjector, childNode);
        hydrator.addEntry(taggedText.binder, injector);
      }
    }
  }

  View _link(View view, Scope scope, List<dom.Node> nodeList, DirectiveInjector rootInjector) {
    final hydrator = new _Hydrator();
    var elementInjectors = new List<DirectiveInjector>(elementBinders.length);
    var directiveDefsByName = {};

    var elementBinderIndex = 0;
    for (int i = 0; i < nodeList.length; i++) {
      dom.Node node = nodeList[i];
      NodeLinkingInfo linkingInfo = nodeLinkingInfos[i];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      if (linkingInfo.isElement) {
        if (linkingInfo.containsNgBinding) {
          var tagged = elementBinders[elementBinderIndex];
          _bindTagged(tagged, elementBinderIndex, rootInjector,
              elementInjectors, view, node, scope, hydrator);
          elementBinderIndex++;
        }

        if (linkingInfo.ngBindingChildren) {
          var elts = (node as dom.Element).querySelectorAll('.ng-binding');
          for (int j = 0; j < elts.length; j++, elementBinderIndex++) {
            TaggedElementBinder tagged = elementBinders[elementBinderIndex];
            _bindTagged(tagged, elementBinderIndex, rootInjector, elementInjectors,
                        view, elts[j], scope, hydrator);
          }
        }
      } else {
        TaggedElementBinder tagged = elementBinders[elementBinderIndex];
        assert(tagged.binder != null || tagged.isTopLevel);
        if (tagged.binder != null) {
          _bindTagged(tagged, elementBinderIndex, rootInjector,
              elementInjectors, view, node, scope, hydrator);
        }
        elementBinderIndex++;
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[i] = parentNode.nodes[0];
      }
    }
    hydrator.hydrate();
    return view;
  }
}


class _Hydrator extends LinkedList<_HydratorEntry> {
  void hydrate() {
    forEach((entry) => entry.hydrate());
  }

  void addEntry(ElementBinder binder, DirectiveInjector injector) {
    add(new _HydratorEntry(binder, injector));
  }
}

class _HydratorEntry extends LinkedListEntry<_HydratorEntry> {
  final ElementBinder binder;
  final DirectiveInjector directiveInjector;
  _HydratorEntry(this.binder, this.directiveInjector);

  void hydrate() {
    binder.hydrate(directiveInjector, directiveInjector.scope);
  }
}

class NodeLinkingInfo {
  /**
   * True if the Node has a 'ng-binding' class.
   */
  final bool containsNgBinding;

  /**
   * True if the Node is a [dom.Element], otherwise it is a Text or Comment node.
   * No other nodeTypes are allowed.
   */
  final bool isElement;

  /**
   * If true, some child has a 'ng-binding' class and the ViewFactory must search
   * for these children.
   */
  final bool ngBindingChildren;

  NodeLinkingInfo(this.containsNgBinding, this.isElement, this.ngBindingChildren);
}

computeNodeLinkingInfos(List<dom.Node> nodeList) {
  List<NodeLinkingInfo> list = new List<NodeLinkingInfo>(nodeList.length);

  for (int i = 0; i < nodeList.length; i++) {
    dom.Node node = nodeList[i];

    assert(node.nodeType == dom.Node.ELEMENT_NODE ||
    node.nodeType == dom.Node.TEXT_NODE ||
    node.nodeType == dom.Node.COMMENT_NODE);

    bool isElement = node.nodeType == dom.Node.ELEMENT_NODE;

    list[i] = new NodeLinkingInfo(
        isElement && (node as dom.Element).classes.contains('ng-binding'),
        isElement,
        isElement && (node as dom.Element).querySelectorAll('.ng-binding').length > 0);
  }
  return list;
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
  final dom.HtmlDocument parseDocument =
      dom.document.implementation.createHtmlDocument('');
  final ResourceUrlResolver resourceResolver;

  ViewCache(this.http, this.templateCache, this.compiler, this.treeSanitizer, this.resourceResolver, CacheRegister cacheRegister) {
    cacheRegister.registerCache('viewCache', viewFactoryCache);
  }

  ViewFactory fromHtml(String html, DirectiveMap directives, [Uri baseUri]) {
    ViewFactory viewFactory = viewFactoryCache.get(html);
    html = resourceResolver.resolveHtml(html, baseUri);

    var div = parseDocument.createElement('div');
    div.setInnerHtml(html, treeSanitizer: treeSanitizer);

    if (viewFactory == null) {
      viewFactory = compiler(div.nodes, directives);
      viewFactoryCache.put(html, viewFactory);
    }
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives, [Uri baseUri]) {
    ViewFactory viewFactory = viewFactoryCache.get(url);
    if (viewFactory == null) {
      return http.get(url, cache: templateCache).then((resp) {
        var viewFactoryFromHttp = fromHtml(resourceResolver.resolveHtml(
                                           resp.responseText, baseUri), directives);
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
