part of angular;

abstract class ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;
}

class BlockCache {
  Map<String, List<Block>> groupCache = {};
  num preRenderedElementCount = 0;

  BlockCache([List<Block> blockInstances]) {
    if (?blockInstances) {
      for (var i = 0, ii = blockInstances.length; i < ii; i++) {
        Block block = blockInstances[i];
        String group = block.group;

        preRenderedElementCount += block.elements.length;
        if (groupCache.containsKey(group)) {
          groupCache[group].add(block);
        } else {
          groupCache[group] = [block];
        }
      }
    }
  }

  flush([Function callback]) {
    groupCache.forEach((blocks) {
      while(!blocks.isEmpty) {
        Block block = blocks.removeLast();
        if (?callback) callback(block);
      }
    });
  }

  Block get(String type) {
    if (groupCache.containsKey(type)) {
      var blocks = groupCache[type];
      return blocks.isEmpty ? null : blocks.removeAt(0);
    }
  }
}

class BlockFactory {
  ExceptionHandler $exceptionHandler;
  BlockListFactory $blockListFactory;
  Injector $injector;

  BlockFactory(ExceptionHandler this.$exceptionHandler,
               BlockListFactory this.$blockListFactory,
               Injector this.$injector);

  call(List<dom.Node> blockNodeList, List directivePositions, List<BlockCache> blockCaches, String group) {
    ASSERT(blockNodeList != null);
    ASSERT(directivePositions != null);
    ASSERT(blockCaches != null);
    return new Block($exceptionHandler, $blockListFactory, $injector,
              blockNodeList, directivePositions, blockCaches, group);
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
        List<BlockCache> blockCaches,
        String this.group) {
    ASSERT(elements != null);
    ASSERT(directivePositions != null);
    ASSERT(blockCaches != null);
    _link(elements, directivePositions, blockCaches);
  }

  _link(List<dom.Node> nodeList, List directivePositions, List<BlockCache> blockCaches) {
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

      Map<String, BlockListFactory> anchorsByName = {};
      List<String> directiveNames = [];

      if (directiveRefs != null) {
        for (var j = 0, jj = directiveRefs.length; j < jj; j++) {
          var blockCache;

          if (blockCaches != null && blockCaches.length > 0) {
            blockCache = blockCaches.removeAt(0);
            preRenderedIndexOffset += blockCache.preRenderedElementCount;
          }

          DirectiveRef directiveRef = directiveRefs[j];
          var name = directiveRef.directive.$name;

          if (name == null) {
            name = nextUid();
          }

          directiveNames.add(name);
          directiveDefsByName[name] = directiveRef;
          if (directiveRef.directive.isStructural) {
            anchorsByName[name] = $blockListFactory([node], directiveRef.blockTypes, blockCache);
          }
        }
        _instantiateDirectives(directiveDefsByName, directiveNames, node, anchorsByName);
      }
      if (childDirectivePositions != null) {
        _link(node.nodes, childDirectivePositions, blockCaches);
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[nodeListIndex] = parentNode.nodes[0];
      }
    }
  }

  _instantiateDirectives(Map<String, DirectiveRef> directiveDefsByName,
                         List<String> directiveNames,
                         dom.Node node,
                         Map<String, BlockList> anchorsByName) {
    var elementModule = new Module();
    elementModule.value(Block, this);
    elementModule.value(dom.Element, node);
    elementModule.value(dom.Node, node);
    directiveDefsByName.values.forEach((DirectiveRef def) => elementModule.type(
                def.directive.type, def.directive.type));

    for (var i = 0, ii = directiveNames.length; i < ii; i++) {
      var directiveName = directiveNames[i];
      DirectiveRef directiveRef = directiveDefsByName[directiveName];

      var directiveModule = new Module();

      directiveModule.value(DirectiveValue,
          new DirectiveValue.fromString(directiveRef.value));

      directiveModule.value(BlockList, anchorsByName[directiveName]);

      Type directiveType = directiveRef.directive.type;

      var injector = $injector.createChild(
          [elementModule, directiveModule],
          [directiveType]);

      try {
        var directiveInstance = injector.get(directiveType);
        if (directiveRef.directive.isComponent) {
          directiveInstance = new ComponentWrapper(directiveRef, directiveInstance, node,
              $injector.get(Parser), $injector.get(Compiler), $injector.get(Http));

        }
        directives.add(directiveInstance);
      } catch (e,s) {
        var msg;
        if (e is MirroredUncaughtExceptionError) {
          //TODO(misko): why is this here? Injector should never throw this exception
          msg = e.exception_string + "\n ORIGINAL Stack trace:\n" + e.stacktrace.toString();
        } else {
          msg = "Creating $directiveName: "  + e.toString() +
                "\n ORIGINAL Stack trace:\n" + s.toString();
        }

        throw msg;
      }
    }
  }

  attach(Scope scope) {
    // Attach directives
    for(var i = 0, ii = directives.length; i < ii; i++) {
      try {
        directives[i].attach(scope);
      } catch(e, s) {
        $exceptionHandler(e, s);
      }
    }
  }

  detach(Scope scope) {
    for(var i = 0, ii = directives.length, directive; i < ii; i++) {
      try {
        directive = directives[i];
        directive.detach != null && directive.detach(scope);
      } catch(e) {
        $exceptionHandler(e);
      }
    }
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

class ComponentWrapper {
  DirectiveRef directiveRef;
  dynamic controller;
  dom.Element elementRoot;
  Scope shadowScope;
  Parser parser;
  Block shadowBlock;

  ComponentWrapper(this.directiveRef, this.controller, this.elementRoot, this.parser, $compiler, $http) {
    var directive = directiveRef.directive;
    var shadowRoot = elementRoot.createShadowRoot();

    var styleData = '';
    if (directive.$cssUrl != null) {
      styleData = '<style>@import "${directive.$cssUrl}"</style>';
    }

    _appendAndCompileTemplate(data) {
      shadowRoot.innerHtml = styleData + data;
      shadowBlock = $compiler(shadowRoot.nodes)(shadowRoot.nodes);
    }
    // There is support here for directives having both $template and
    // $templateUrl.  This could be a clever way to add a 'LOADING'
    // message.
    _appendAndCompileTemplate(directive.$template != null ? directive.$template : '');

    if (directive.$templateUrl != null) {
      $http.getString(directive.$templateUrl).then((data) {
        _appendAndCompileTemplate(data);
        // re-attach the scope.
        if (shadowScope != null) {
          shadowBlock.attach(shadowScope);
          shadowScope.$digest();
        }
      });
    }
  }

  attach(scope) {
    shadowScope = scope.$new(true);
    directiveRef.directive.$map.forEach((attrName, mapping) {
      var attrValue = elementRoot.attributes[attrName];
      if (mapping == '@') {
        shadowScope[attrName] = attrValue;
      } else if (mapping == '=') {
        ParsedFn expr = parser(attrValue);
        var shadowValue;
        shadowScope.$watch(
                () => expr(scope),
                (v) => shadowScope[attrName] = shadowValue = v);
        if (expr.assignable) {
          shadowScope.$watch(
                () => shadowScope[attrName],
                (v) {
                  if (shadowValue != v) {
                    shadowValue = v;
                    expr.assign(scope, v);
                  }
                } );
        }
      } else if (mapping == '&') {
        ParsedFn fn = parser(attrValue);
        shadowScope[attrName] = ([locals]) => fn(scope, locals);
      } else {
        throw "Unknown mapping $mapping for attribute $attrName.";
      }
    });
    controller.attach(shadowScope);
    if (shadowBlock != null) {
      shadowBlock.attach(shadowScope);
    }
  }
}

attrAccessorFactory(dom.Element element, String name) {
  return ([String value]) {
    if (?value) {
      if (value == null) {
        element.removeAttribute(name);
      } else {
        element.setAttribute(name, value);
      }
      return value;
    } else {
      return element.getAttribute(name);
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

