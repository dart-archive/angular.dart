part of angular;

abstract class ElementWrapper {
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
        if (groupCache.hasOwnProperty(group)) {
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

  Block retrieve(String type) {
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

  call(blockNodeList, directivePositions, blockCaches, group) =>
    new Block($exceptionHandler, $blockListFactory, $injector,
              blockNodeList, directivePositions, blockCaches, group);
}

class Block implements ElementWrapper {
  ExceptionHandler $exceptionHandler;
  BlockListFactory $blockListFactory;
  Injector $injector;
  List<dom.Node> elements;
  ElementWrapper previous = null;
  ElementWrapper next = null;
  String group;
  List<Directive> directives = [];
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
    if (elements == null) throw new ArgumentError();
    _link(elements, directivePositions, blockCaches);
  }

  _link(List<dom.Node> nodeList, List directivePositions, List<BlockCache> blockCaches) {
    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (num i = 0, ii = directivePositions.length; i < ii;) {
      num index = directivePositions[i++];
      List<DirectiveDef> directiveDefs = directivePositions[i++];
      List childDirectivePositions = directivePositions[i++];
      dom.Node node = nodeList[index + preRenderedIndexOffset];
      Map<String, BlockListFactory> anchorsByName = {};
      List<String> directiveNames = [];

      if (directiveDefs != null) {
        for (var j = 0, jj = directiveDefs.length; j < jj; j++) {
          var blockCache;

          if (blockCaches != null && blockCaches.length) {
            blockCache = blockCaches.shift();
            preRenderedIndexOffset += blockCache.preRenderedElementCount;
          }

          var directiveDef = directiveDefs[j];
          var name = directiveDef.directiveFactory.$name;

          if (name == null) {
            name = nextUid();
          }

          directiveNames.add(name);
          directiveDefsByName[name] = directiveDef;
          if (directiveDef.isComponent()) {
            anchorsByName[name] = $blockListFactory([node], directiveDef.blockTypes, blockCache);
          }
        }
        _instantiateDirectives(directiveDefsByName, directiveNames, node, anchorsByName);
      }
      if (childDirectivePositions != null) {
        link_(node.childNodes, childDirectivePositions, blockCaches);
      }
    }
  }

  _instantiateDirectives(Map<String, DirectiveDef> directiveDefsByName,
                         List<String> directiveNames,
                         dom.Node node,
                         Map<String, BlockList> anchorsByName) {
    Block block = this;

    LocalFactoryFn localFactoryFn(String name, Injector elementInjector) {
      List<String> match = name.match(angular.core.Block.DYNAMIC_SERVICES_REGEX_);
      DynamicServiceFactoryFn dynamicServiceFactoryFn = match && angular.core.Block.DYNAMIC_SERVICES_[match[1]];

      if (dynamicServiceFactoryFn) {
        return locals[name] = dynamicServiceFactoryFn(match[2], block, node, block.$injector);
      } else if (locals.hasOwnProperty(name)) {
        return locals[name];
      } else if (directiveDefsByName.hasOwnProperty(name)) {
        try {
          var directiveDef = directiveDefsByName[name];

          locals['$anchor'] = anchorsByName.hasOwnProperty(name) ? anchorsByName[name] : undefined;
          locals['$value'] = directiveDef.value;
          return locals[name] = elementInjector.instantiate(/** @type {Function} */(directiveDef.DirectiveType));
        } catch (e) {
          block.$exceptionHandler(e);
        } finally {
          locals['$value'] = undefined;
          locals['$anchor'] = undefined;
        }
      }
    };

    var elementModule = new Module();
    elementModule.value(Block, this);
    elementModule.value(dom.Element, node);
    directiveDefsByName.values.forEach((DirectiveDef def) => elementModule.type(
                def.directiveFactory.directiveType, def.directiveFactory.directiveType));

    for (var i = 0, ii = directiveNames.length; i < ii; i++) {
      var directiveModule = new Module();
      directiveModule.value(BlockList, null);
      directiveModule.value(String, null);

      var injector = new Injector([elementModule, directiveModule], $injector);

      String directiveName = directiveNames[i];
      DirectiveDef directiveDef = directiveDefsByName[directiveName];
      Type directiveType = directiveDef.directiveFactory.directiveType;
      directives.add(injector.get(directiveType));
    }
  }

  attach(Scope scope) {
  // Attach directives
    for(var i = 0, ii = directives.length; i < ii; i++) {
      try {
        for (var j = 0, jj = elements.length; j < jj; j++) {
          elements[j].$scope = scope;
        }
        if (directives[i].attach) directives[i].attach(scope);
      } catch(e) {
        $exceptionHandler(e);
      }
    }
  }

  detach(Scope scope) {
    for(var i = 0, ii = directives.length, directive; i < ii; i++) {
      try {
        directive = directives[i];
        directive.detach && directive.detach(scope);
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
        dom.Node next = jj < j+1 ? elements[j+1] : null;

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
          return removeDomElements;
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
    if (previous.next = next) {
      next.previous = previous;
    }
    // Add block to list
    if (next = previousBlock.next) {
      next.previous = this;
    }
    previous = previousBlock;
    previousBlock.next = this;
    return this;
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

