part of angular;

Symbol _SHADOW = new Symbol('SHADOW_INJECTOR');

abstract class ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;
}

class BlockFactory {
  ExceptionHandler $exceptionHandler;
  BlockListFactory $blockListFactory;
  Injector $injector;

  BlockFactory(ExceptionHandler this.$exceptionHandler,
               BlockListFactory this.$blockListFactory,
               Injector this.$injector);

  call(List<dom.Node> blockNodeList, List directivePositions, String group, Injector injector) {
    ASSERT(blockNodeList != null);
    ASSERT(directivePositions != null);
    ASSERT(injector != null);
    return new Block($exceptionHandler, $blockListFactory, injector,
              blockNodeList, directivePositions, group);
  }
}

class Block implements ElementWrapper {
  ExceptionHandler $exceptionHandler;
  BlockListFactory $blockListFactory;
  Injector $injector;
  List<dom.Node> elements;
  ElementWrapper previous = null;
  ElementWrapper next = null;
  String group;
  List<dynamic> directives = [];
  Function onInsert;
  Function onRemove;
  Function onMove;

  Block(ExceptionHandler this.$exceptionHandler,
        BlockListFactory this.$blockListFactory,
        Injector this.$injector,
        List<dom.Node> this.elements,
        List directivePositions,
        String this.group) {
    ASSERT(elements != null);
    ASSERT(directivePositions != null);
    ASSERT($injector != null);
    _link(elements, directivePositions, $injector);
  }

  _link(List<dom.Node> nodeList, List directivePositions, Injector parentInjector) {
    var stack;
    try {throw '';} catch(e,s) {stack = s;}
    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (num i = 0, ii = directivePositions.length; i < ii;) {
      num index = directivePositions[i++];

      List<DirectiveRef> directiveRefs = directivePositions[i++];
      List childDirectivePositions = directivePositions[i++];
      var nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      var childInjector = _instantiateDirectives(parentInjector, node, directiveRefs);

      if (childDirectivePositions != null) {
        _link(node.nodes, childDirectivePositions, childInjector);
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[nodeListIndex] = parentNode.nodes[0];
      }
    }
  }

  Injector _instantiateDirectives(Injector parentInjector, dom.Node node, List<DirectiveRef> directiveRefs) {
    if (directiveRefs == null || directiveRefs.length == 0) return parentInjector;
    var nodeModule = new Module();
    var blockListFactory = () => null;
    var nodeAttrs = new NodeAttrs(node);

    nodeModule.value(Block, this);
    nodeModule.value(dom.Element, node);
    nodeModule.value(dom.Node, node);
    nodeModule.value(NodeAttrs, nodeAttrs);
    directiveRefs.forEach((DirectiveRef ref) {
      Type type = ref.directive.type;
      var visibility = elementOnly;
      if (ref.directive.$visibility == DirectiveVisibility.CHILDREN) {
        visibility = null;
      } else if (ref.directive.$visibility == DirectiveVisibility.DIRECT_CHILDREN) {
        visibility = elementDirectChildren;
      }
      if (ref.directive.isComponent) {
        //nodeModule.factory(type, new ComponentFactory(node, ref.directive), visibility: visibility);
        // TODO(misko): there should be no need to wrap function like this.
        nodeModule.factory(type, (Injector injector, Compiler compiler, Scope scope, Parser parser, BlockCache $blockCache, UrlRewriter urlRewriter) =>
          (new ComponentFactory(node, ref.directive))(injector, compiler, scope, parser, $blockCache, urlRewriter),
          visibility: visibility);
      } else {
        nodeModule.type(type, type, visibility: visibility);
      }
      nodeAttrs[ref.directive.$name] = ref.value;
      if (ref.directive.isStructural) {
        blockListFactory = (Injector injector) => $blockListFactory([node], ref.blockTypes, injector);
      }
    });
    nodeModule.factory(BlockList, blockListFactory);
    var nodeInjector = parentInjector.createChild([nodeModule]);
    directiveRefs.forEach((ref) => nodeInjector.get(ref.directive.type));
    return nodeInjector;
  }

  /// DI visibility callback allowing node-local visibility.
  bool elementOnly(Injector requesting, Injector defining) {
    if (requesting.instances.containsKey(_SHADOW)) {
      requesting = requesting.instances[_SHADOW];
    }
    return identical(requesting, defining);
  }

  /// DI visibility callback allowing visibility from direct child into parent.
  bool elementDirectChildren(Injector requesting, Injector defining) {
    if (requesting.instances.containsKey(_SHADOW)) {
      requesting = requesting.instances[_SHADOW];
    }
    return elementOnly(requesting, defining) || identical(requesting.parent, defining);
  }


  Block insertAfter(ElementWrapper previousBlock) {
    // TODO(misko): this will try to insert regardless if the node is an existing server side pre-rendered instance.
    // This is inefficient since the node should already be at the right location. We should have a check
    // for that. If pre-rendered then do nothing. This will also short circuit animation.

    // Update Link List.
    next = previousBlock.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousBlock;
    previousBlock.next = this;

    // Update DOM
    List<dom.Node> previousElements = previousBlock.elements;
    dom.Node previousElement = previousElements[previousElements.length - 1];
    dom.Node insertBeforeElement = previousElement.nextNode;
    dom.Node parentElement = previousElement.parentNode;
    bool preventDefault = false;

    Function insertDomElements = () {
      for(var i = 0, ii = elements.length; i < ii; i++) {
        parentElement.insertBefore(elements[i], insertBeforeElement);
      }
    };

    if (onInsert != null) {
      onInsert({
        "preventDefault": () {
          preventDefault = true;
          return insertDomElements;
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      insertDomElements();
    }
    return this;
  }

  /**
   * @return {angular.core.Block}
   */
  remove() {
    bool preventDefault = false;

    Function removeDomElements = () {
      for(var j = 0, jj = elements.length; j < jj; j++) {
        dom.Node current = elements[j];
        dom.Node next = j+1 < jj ? elements[j+1] : null;

        while(next != null && current.nextNode != next) {
          current.nextNode.remove();
        }
        elements[j].remove();
      }
    };

    if (onRemove != null) {
      onRemove({
        "preventDefault": () {
          preventDefault = true;
          return removeDomElements();
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      removeDomElements();
    }

    // Remove block from list
    if (previous != null && (previous.next = next) != null) {
      next.previous = previous;
    }
    next = previous = null;
    return this;
  }


  /**
   * @param {angular.core.Block} previousBlock
   * @return {angular.core.Block}
   */
  moveAfter(previousBlock) {
    var previousElements = previousBlock.elements,
        previousElement = previousElements[previousElements.length - 1],
        insertBeforeElement = previousElement.nextNode,
        parentElement = previousElement.parentNode,
        blockElements = elements;

    for(var i = 0, ii = blockElements.length; i < ii; i++) {
      parentElement.insertBefore(blockElements[i], insertBeforeElement);
    }

    // Remove block from list
    previous.next = next;
    if (next != null) {
      next.previous = previous;
    }
    // Add block to list
    next = previousBlock.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousBlock;
    previousBlock.next = this;
    return this;
  }
}

class ComponentFactory {
  dom.Element element;
  Directive directive;
  dom.ShadowRoot shadowDom;
  Scope shadowScope;
  Injector shadowInjector;
  Compiler compiler;

  ComponentFactory(this.element, this.directive);

  dynamic call(Injector injector, Compiler compiler, Scope scope,
      Parser parser, BlockCache $blockCache, UrlRewriter urlRewriter) {
    this.compiler = compiler;
    shadowDom = element.createShadowRoot();
    shadowDom.applyAuthorStyles =
        directive.$shadowRootOptions.$applyAuthorStyles;
    shadowDom.resetStyleInheritance =
        directive.$shadowRootOptions.$resetStyleInheritance;

    shadowScope = scope.$new(true);
    createAttributeMapping(scope, shadowScope, parser);
    if (directive.$cssUrl != null) {
      shadowDom.innerHtml = '<style>@import "${urlRewriter(directive.$cssUrl)}"</style>';
    }
    TemplateLoader templateLoader;
    if (directive.$template != null) {
      var blockFuture = new async.Future.value().then((_) =>
          attachBlockToShadowDom($blockCache.fromHtml(directive.$template)));
      templateLoader = new TemplateLoader(blockFuture);
    } else if (directive.$templateUrl != null) {
      var blockFuture = $blockCache.fromUrl(directive.$templateUrl)
          .then((BlockType blockType) => attachBlockToShadowDom(blockType));
      templateLoader = new TemplateLoader(blockFuture);
    }
    var controller =
        createShadowInjector(injector, templateLoader).get(directive.type);
    if (directive.$publishAs != null) {
      shadowScope[directive.$publishAs] = controller;
    }
    return controller;
  }

  attachBlockToShadowDom(BlockType blockType) {
    var block = blockType(shadowInjector);
    shadowDom.nodes.addAll(block.elements);
    shadowInjector.get(Scope).$digest();
    return shadowDom;
  }

  createShadowInjector(injector, TemplateLoader templateLoader) {
    var shadowModule = new ScopeModule(shadowScope)
      ..type(directive.type, directive.type)
      ..value(TemplateLoader, templateLoader)
      ..value(dom.ShadowRoot, shadowDom);
    shadowInjector = injector.createChild([shadowModule]);
    // TODO(misko): creazy hack to mark injector
    shadowInjector.instances[_SHADOW] = injector;
    return shadowInjector;
  }

  createAttributeMapping(Scope parentScope, Scope shadowScope, Parser parser) {
    directive.$map.forEach((attrName, mapping) {
      var attrValue = element.attributes[snake_case(attrName, '-')];
      if (attrValue == null) attrValue = '';
      if (mapping == '@') {
        shadowScope[attrName] = attrValue;
      } else if (mapping == '=') {
        ParsedFn expr = parser(attrValue);
        var shadowValue;
        shadowScope.$watch(
            () => expr(parentScope),
            (v) => shadowScope[attrName] = shadowValue = v);
        if (expr.assignable) {
          shadowScope.$watch(
            () => shadowScope[attrName],
            (v) {
              if (shadowValue != v) {
                shadowValue = v;
                expr.assign(parentScope, v);
              }
            } );
        }
      } else if (mapping == '&') {
        ParsedFn fn = parser(attrValue);
        shadowScope[attrName] = ([locals]) => fn(parentScope, locals);
      } else {
        throw "Unknown mapping $mapping for attribute $attrName.";
      }
    });
  }
}

class BlockCache {
  Cache _blockCache;
  Http $http;
  TemplateCache $templateCache;
  Compiler compiler;

  BlockCache(CacheFactory $cacheFactory, Http this.$http,
      TemplateCache this.$templateCache, Compiler this.compiler) {
    _blockCache = $cacheFactory('blocks');
  }

  BlockType fromHtml(String html) {
    BlockType blockType = _blockCache.get(html);
    if (blockType == null) {
      var div = new dom.Element.tag('div');
      div.innerHtml = html;
      blockType = compiler(div.nodes);
      _blockCache.put(html, blockType);
    }
    return blockType;
  }

  async.Future<BlockType> fromUrl(String url) {
    return $http.getString(url, cache: $templateCache).then((String tmpl) {
      return fromHtml(tmpl);
    });
  }
}

/**
 * A convinience wrapper for "templates" cache.
 */
class TemplateCache implements Cache<HttpResponse> {
  Cache _cache;

  TemplateCache(CacheFactory $cacheFactory) {
    _cache = $cacheFactory('templates');
  }

  Object get(key) => _cache.get(key);
  put(key, HttpResponse value) => _cache.put(key, value);
  putString(key, String value) => _cache.put(key, new HttpResponse(200, value));
  void remove(key) => _cache.remove(key);
  void removeAll() => _cache.removeAll();
  CacheInfo info() => _cache.info();
  void destroy() => _cache.destroy();
}

class TemplateLoader {
  final async.Future<dom.ShadowRoot> _template;
  async.Future<dom.ShadowRoot> get template => _template;
  TemplateLoader(this._template);
}

attrAccessorFactory(dom.Element element, String name) {
  return ([String value]) {
    if (value != null) {
      if (value == null) {
        element.attributes.remove(name);
      } else {
        element.attributes[name] = value;
      }
      return value;
    } else {
      return element.attributes[name];
    }
  };
}

Function classAccessorFactory(dom.Element element, String name) {
  return ([bool value]) {
    var className = element.className,
        paddedClassName = ' ' + className + ' ',
        hasClass = paddedClassName.indexOf(' ' + name + ' ') != -1;

    if (arguments.length) {
      if (!value && hasClass) {
        paddedClassName = paddedClassName.replace(' ' + name + ' ', ' ');
        element.className =
            paddedClassName.substring(1, paddedClassName.length - 2);
      } else if (value && !hasClass) {
        element.className = className + ' ' + name;
      }
      hasClass = !!value;
    }
    return hasClass;
  };
}

styleAccessorFactory(dom.Element element, String name) {
  return ([String value]) {
    if (arguments.length) {
      if (!value) {
        value = '';
      }
      element.style[name] = value;
    } else {
      value = element.style[name];
    }
    return value;
  };
}

RegExp _DYNAMIC_SERVICES_REGEX = new RegExp(
    r'^(\$text|\$attr_?|\$style_?|\$class_?|\$on_?|\$prop_?|\$service_)(.*)$');

Map<String, Function> _DYNAMIC_SERVICES = {
  r'$text': (String name, Block block, dom.Element element) {
    return element.nodeType == 3 /* text node */
        ? (value) { element.nodeValue = value || ''; }
        : (value) { element.innerText = value || ''; };
  },

  r'$attr_': (String name, Block block, dom.Element element) {
    return attrAccessorFactory(name, element);
  },

  r'$attr': (String name, Block block, dom.Element element) {
    return bind(null, attrAccessorFactory, element);
  },

  r'$style_': (String name, Block block, dom.Element element) {
    return styleAccessorFactory(name, element);
  },

  r'$style': (String name, Block block, dom.Element element) {
    return bind(null, styleAccessorFactory, element);
  },

  r'$class_': (String name, Block block, dom.Element element) {
    return classAccessorFactory(name, element);
  },

  r'$class': (String name, Block block, dom.Element element) {
    return bind(null, classAccessorFactory, element);
  },

  r'$on_': (String name, Block block, dom.Element element) {
    // TODO: there needs to be a way to clean this up on block detach
    return (callback) {
      if (name == 'remove') {
        block.onRemove = callback;
      } else if (name == 'insert') {
        block.onInsert = callback;
      } else {
        element.addEventListener(name, callback);
      }
    };
  },

  r'$prop_': (String name, Block block, dom.Element element) {
    return (value) {
      return element[name];
    };
  },

  r'$service_': (String name, Block block, dom.Element element) {
    return $injector.get(name);
  }
};

class NodeAttrs {
  dom.Node node;
  Map<String, String> attributes;

  NodeAttrs(dom.Node this.node, [Map<String, String> this.attributes]) {
    if (attributes == null) {
      attributes = {};
    }
  }

  operator []=(String name, String value) => attributes[name] = value;
  operator [](name) {
    if (!(name is String)) {
      name = new Directive(name.runtimeType).$name;
    }
    var value = attributes[name];
    return value;
  }

  dom.Element get element => node;
}
