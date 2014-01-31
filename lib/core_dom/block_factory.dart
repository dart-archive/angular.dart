part of angular.core.dom;


/**
 * BoundBlockFactory is a [BlockFactory] which does not need Injector because
 * it is pre-bound to an injector from the parent. This means that this
 * BoundBlockFactory can only be used from within a specific Directive such
 * as [NgRepeat], but it can not be stored in a cache.
 *
 * The BoundBlockFactory needs [Scope] to be created.
 */
class BoundBlockFactory {
  BlockFactory blockFactory;

  Injector injector;

  BoundBlockFactory(this.blockFactory, this.injector);

  Block call(Scope scope) {
    return blockFactory(injector.createChild([new Module()..value(Scope, scope)]));
  }
}

/**
 * BlockFactory is used to create new [Block]s. BlockFactory is created by the
 * [Compiler] as a result of compiling a template.
 */
class BlockFactory {
  final List directivePositions;
  final List<dom.Node> templateElements;
  final Profiler _perf;
  final Expando _expando;

  BlockFactory(this.templateElements, this.directivePositions, this._perf, this._expando);

  BoundBlockFactory bind(Injector injector) =>
    new BoundBlockFactory(this, injector);

  Block call(Injector injector, [List<dom.Node> elements]) {
    if (elements == null) {
      elements = cloneElements(templateElements);
    }
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.block')) != false);
      var block = new Block(elements);
      _link(block, elements, directivePositions, injector);
      return block;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  _link(Block block, List<dom.Node> nodeList, List directivePositions, Injector parentInjector) {
    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (int i = 0, ii = directivePositions.length; i < ii;) {
      int index = directivePositions[i++];

      List<DirectiveRef> directiveRefs = directivePositions[i++];
      List childDirectivePositions = directivePositions[i++];
      int nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];

      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.block.link', _html(node))) != false);
        // if node isn't attached to the DOM, create a parent for it.
        var parentNode = node.parentNode;
        var fakeParent = false;
        if (parentNode == null) {
          fakeParent = true;
          parentNode = new dom.DivElement();
          parentNode.append(node);
        }

        var childInjector = _instantiateDirectives(block, parentInjector, node,
            directiveRefs, parentInjector.get(Parser));

        if (childDirectivePositions != null) {
          _link(block, node.nodes, childDirectivePositions, childInjector);
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

  Injector _instantiateDirectives(Block block, Injector parentInjector,
                                  dom.Node node, List<DirectiveRef> directiveRefs,
                                  Parser parser) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.block.link.setUp', _html(node))) != false);
    Injector nodeInjector;
    Scope scope = parentInjector.get(Scope);
    Map<Type, _ComponentFactory> fctrs;
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    ElementProbe probe;

    try {
      if (directiveRefs == null || directiveRefs.length == 0) return parentInjector;
      var nodeModule = new Module();
      var blockHoleFactory = (_) => null;
      var blockFactory = (_) => null;
      var boundBlockFactory = (_) => null;
      var nodesAttrsDirectives = null;

      nodeModule.value(Block, block);
      nodeModule.value(dom.Element, node);
      nodeModule.value(dom.Node, node);
      nodeModule.value(NodeAttrs, nodeAttrs);
      directiveRefs.forEach((DirectiveRef ref) {
        NgAnnotation annotation = ref.annotation;
        var visibility = _elementOnly;
        if (ref.annotation is NgController) {
          scope = scope.$new();
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
                injector.get(TextChangeListener));
          });
        } else if (ref.type == NgAttrMustacheDirective) {
          if (nodesAttrsDirectives == null) {
            nodesAttrsDirectives = [];
            nodeModule.factory(NgAttrMustacheDirective, (Injector injector) {
              var scope = injector.get(Scope);
              var interpolate = injector.get(Interpolate);
              for(var ref in nodesAttrsDirectives) {
                new NgAttrMustacheDirective(nodeAttrs, ref.value, interpolate, scope);
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
            BlockCache blockCache = injector.get(BlockCache);
            Http http = injector.get(Http);
            TemplateCache templateCache = injector.get(TemplateCache);
            // This is a bit of a hack since we are returning different type then we are.
            var componentFactory = new _ComponentFactory(node, ref.type, ref.annotation as NgComponent, injector.get(dom.NodeTreeSanitizer));
            if (fctrs == null) fctrs = new Map<Type, _ComponentFactory>();
            fctrs[ref.type] = componentFactory;
            return componentFactory.call(injector, compiler, scope, blockCache, http, templateCache);
          }, visibility: visibility);
        } else {
          nodeModule.type(ref.type, visibility: visibility);
        }
        for (var publishType in ref.annotation.publishTypes) {
          nodeModule.factory(publishType, (Injector injector) => injector.get(ref.type), visibility: visibility);
        }
        if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
          // Currently, transclude is only supported for NgDirective.
          assert(annotation is NgDirective);
          blockHoleFactory = (_) => new BlockHole([node]);
          blockFactory = (_) => ref.blockFactory;
          boundBlockFactory = (Injector injector) => ref.blockFactory.bind(injector);
        }
      });
      nodeModule.factory(BlockHole, blockHoleFactory);
      nodeModule.factory(BlockFactory, blockFactory);
      nodeModule.factory(BoundBlockFactory, boundBlockFactory);
      nodeInjector = parentInjector.createChild([nodeModule]);
      probe = _expando[node] = new ElementProbe(node, nodeInjector, scope);
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
    directiveRefs.forEach((DirectiveRef ref) {
      var linkTimer;
      try {
        var linkMapTimer;
        assert((linkTimer = _perf.startTimer('ng.block.link', ref.type)) != false);
        var controller = nodeInjector.get(ref.type);
        probe.directives.add(controller);
        assert((linkMapTimer = _perf.startTimer('ng.block.link.map', ref.type)) != false);
        var shadowScope = (fctrs != null && fctrs.containsKey(ref.type)) ? fctrs[ref.type].shadowScope : null;
        if (ref.annotation is NgController) {
          scope[(ref.annotation as NgController).publishAs] = controller;
        } else if (ref.annotation is NgComponent) {
          shadowScope[(ref.annotation as NgComponent).publishAs] = controller;
        }
        if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
        for(var map in ref.mappings) {
          map(nodeAttrs, scope, controller);
        }
        if (controller is NgAttachAware) {
          var removeWatcher;
          removeWatcher = scope.$watch(() {
            removeWatcher();
            controller.attach();
          });
        }
        if (controller is NgDetachAware) {
          scope.$on(r'$destroy', controller.detach);
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
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return identical(requesting, defining);
  };

  // DI visibility callback allowing visibility from direct child into parent.

  static final Function _elementDirectChildren = (Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return _elementOnly(requesting, defining) || identical(requesting.parent, defining);
  };
}

/**
 * BlockCache is used to cache the compilation of templates into [Block]s.
 * It can be used synchronously if HTML is known or asynchronously if the
 * template HTML needs to be looked up from the URL.
 */
@NgInjectableService()
class BlockCache {
  // _blockFactoryCache is unbounded
  Cache<String, BlockFactory> _blockFactoryCache =
      new LruCache<String, BlockFactory>(capacity: 0);

  Http $http;

  TemplateCache $templateCache;

  Compiler compiler;

  dom.NodeTreeSanitizer treeSanitizer;

  BlockCache(this.$http, this.$templateCache, this.compiler, this.treeSanitizer);

  BlockFactory fromHtml(String html) {
    BlockFactory blockFactory = _blockFactoryCache.get(html);
    if (blockFactory == null) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);
      blockFactory = compiler(div.nodes);
      _blockFactoryCache.put(html, blockFactory);
    }
    return blockFactory;
  }

  async.Future<BlockFactory> fromUrl(String url) {
    return $http.getString(url, cache: $templateCache).then(fromHtml);
  }
}

/**
 * ComponentFactory is responsible for setting up components. This includes
 * the shadowDom, fetching template, importing styles, setting up attribute
 * mappings, publishing the controller, and compiling and caching the template.
 */
class _ComponentFactory {

  final dom.Element element;
  final Type type;
  final NgComponent component;
  final dom.NodeTreeSanitizer treeSanitizer;

  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  Compiler compiler;
  var controller;

  _ComponentFactory(this.element, this.type, this.component, this.treeSanitizer);

  dynamic call(Injector injector, Compiler compiler, Scope scope, BlockCache $blockCache, Http $http, TemplateCache $templateCache) {
    this.compiler = compiler;
    shadowDom = element.createShadowRoot();
    shadowDom.applyAuthorStyles = component.applyAuthorStyles;
    shadowDom.resetStyleInheritance = component.resetStyleInheritance;

    shadowScope = scope.$new(isolate: true);
    // TODO(pavelgj): fetching CSS with Http is mainly an attempt to
    // work around an unfiled Chrome bug when reloading same CSS breaks
    // styles all over the page. We shouldn't be doing browsers work,
    // so change back to using @import once Chrome bug is fixed or a
    // better work around is found.
    List<async.Future<String>> cssFutures = new List();
    var cssUrls = component.allCssUrls;
    if (cssUrls != null) {
      cssUrls.forEach((css) => cssFutures.add( $http.getString(css, cache: $templateCache) ) );
    } else {
      cssFutures.add( new async.Future.value(null) );
    }
    var blockFuture;
    if (component.template != null) {
      blockFuture = new async.Future.value($blockCache.fromHtml(component.template));
    } else if (component.templateUrl != null) {
      blockFuture = $blockCache.fromUrl(component.templateUrl);
    }
    TemplateLoader templateLoader = new TemplateLoader( async.Future.wait(cssFutures).then((Iterable<String> cssList) {
      if (cssList != null) {
        var filteredCssList = cssList.where((css) => css != null );
        shadowDom.setInnerHtml('<style>${filteredCssList.join('')}</style>', treeSanitizer: treeSanitizer);
      }
      if (blockFuture != null) {
        return blockFuture.then((BlockFactory blockFactory) => attachBlockToShadowDom(blockFactory));
      }
      return shadowDom;
    }));
    controller = createShadowInjector(injector, templateLoader).get(type);
    if (controller is NgShadowRootAware) {
      templateLoader.template.then((controller as NgShadowRootAware).onShadowRoot);
    }
    return controller;
  }

  attachBlockToShadowDom(BlockFactory blockFactory) {
    var block = blockFactory(shadowInjector);
    shadowDom.nodes.addAll(block.elements);
    return shadowDom;
  }

  createShadowInjector(injector, TemplateLoader templateLoader) {
    var shadowModule = new Module()
        ..type(type)
        ..value(Scope, shadowScope)
        ..value(TemplateLoader, templateLoader)
        ..value(dom.ShadowRoot, shadowDom);
    shadowInjector = injector.createChild([shadowModule], name: _SHADOW);
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
    return (obj as List).fold('', (v, e) => v + _html(e));
  } else if (obj is dom.Element) {
    var text = (obj as dom.Element).outerHtml;
    return text.substring(0, text.indexOf('>') + 1);
  } else {
    return obj.nodeName;
  }
}

/**
 * [ElementProbe] is attached to each [Element] in the DOM. Its sole purpose is to
 * allow access to the [Injector], [Scope], and Directives for debugging and automated
 * test purposes. The information here is not used by Angular in any way.
 *
 * SEE: [ngInjector], [ngScope], [ngDirectives]
 */
class ElementProbe {
  final dom.Node element;
  final Injector injector;
  final Scope scope;
  final directives = [];

  ElementProbe(this.element, this.injector, this.scope);
}
