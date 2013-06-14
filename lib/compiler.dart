part of angular;

class Compiler {
  DirectiveRegistry directives;
  Injector $injector;
  BlockTypeFactory $blockTypeFactory;
  Selector selector;

  Compiler(DirectiveRegistry this.directives,
           Injector this.$injector,
           BlockTypeFactory this.$blockTypeFactory) {
    selector = selectorFactory(directives.enumerate());
  }

  _compileBlock(NodeCursor domCursor, NodeCursor templateCursor,
               List<BlockCache> blockCaches,
               List<DirectiveRef> useExistingDirectiveRefs) {
    var directivePositions = null; // don't pre-create to create spars tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      var declaredDirectiveRefs = useExistingDirectiveRefs == null
          ? extractDirectiveRefs(domCursor.nodeList()[0])
          : useExistingDirectiveRefs;
      var compileChildren = true;
      var childDirectivePositions = null;
      List<DirectiveRef> usableDirectiveRefs = null;

      cursorAlreadyAdvanced = false;

      for (var j = 0, jj = declaredDirectiveRefs.length; j < jj; j++) {
        var directiveRef = declaredDirectiveRefs[j];
        Directive directive = directiveRef.directive;
        var blockTypes = null;

        if (directive.$generate != null) {
          var nodeList = domCursor.nodeList();
          var generatedDirectives = directive.$generate(directiveRef.value, nodeList);

          for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
            String generatedSelector = generatedDirectives[k][0];
            String generatedValue = generatedDirectives[k][1];
            Type generatedDirectiveType = $directiveInjector.get(generatedSelector);
            var generatedDirectiveRef = new DirectiveRef(
                new Directive(generatedDirectiveType),
                generatedValue);

            declaredDirectiveRefs.add(generatedDirectiveRef);
          }
        }
        if (directive.$transclude != null) {
          var remaindingDirectives = declaredDirectiveRefs.sublist(j + 1);
          var transclusion = compileTransclusion(directive.$transclude,
              domCursor, templateCursor,
              directiveRef, remaindingDirectives);

          if (transclusion['blockCache'] != null) {
            blockCaches.add(transclusion['blockCache']);
          }
          blockTypes = transclusion['blockTypes'];

          j = jj; // stop processing further directives since they belong to transclusion;
          compileChildren = false;
        }
        if (usableDirectiveRefs == null) {
          usableDirectiveRefs = [];
        }
        directiveRef.blockTypes = blockTypes;
        usableDirectiveRefs.add(directiveRef);
        if (directive.$template != null) {
          // TODO(deboer): port this function.
          denormalizeTemplate(x) => x;
          var templateValue = denormalizeTemplate(directive.$template);
          var div = new dom.DivElement();
          div.innerHtml = templateValue;
          var templateBlockType = $injector.get(Compiler)(div.nodes);
          usableDirectiveRefs.add(
              new DirectiveRef(directiveRef.element,
                               directiveRef.selector,
                               directiveRef.name,
                               directiveRef.value,
                               directives['[ng-shadow-dom]'],
                               {'': templateBlockType}));
        }
      }

      if (compileChildren && domCursor.descend()) {
        templateCursor.descend();

        childDirectivePositions = compileChildren
            ? _compileBlock(domCursor, templateCursor, blockCaches, useExistingDirectiveRefs)
            : null;

        domCursor.ascend();
        templateCursor.ascend();
      }

      if (childDirectivePositions != null || usableDirectiveRefs != null) {
        if (directivePositions == null) directivePositions = [];
        var directiveOffsetIndex = templateCursor.index;

        directivePositions
            ..add(directiveOffsetIndex)
            ..add(usableDirectiveRefs)
            ..add(childDirectivePositions);
      }
    } while (templateCursor.microNext() && domCursor.microNext());

    return directivePositions;
  }

  compileTransclusion(String selector,
                      NodeCursor domCursor, NodeCursor templateCursor,
                      DirectiveRef directiveRef,
                      List<DirectiveRef> transcludedDirectiveRefs) {
    var anchorName = directiveRef.name + (directiveRef.value != null ? '=' + directiveRef.value : '');
    var blockTypes = {};
    var BlockType;
    var blocks;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var groupName = '';
    var domCursorIndex = domCursor.index;
    var directivePositions = _compileBlock(domCursor, transcludeCursor, [], transcludedDirectiveRefs);
    if (directivePositions == null) directivePositions = [];

    BlockType = $blockTypeFactory(transcludeCursor.elements, directivePositions, groupName);
    domCursor.index = domCursorIndex;
    blockTypes[groupName] = BlockType;

    if (domCursor.isInstance()) {
      domCursor.insertAnchorBefore(anchorName);
      blocks = [BlockType(domCursor.nodeList())];
      domCursor.macroNext();
      templateCursor.macroNext();
      while (domCursor.isValid() && domCursor.isInstance()) {
        blocks.add(BlockType(domCursor.nodeList()));
        domCursor.macroNext();
        templateCursor.remove();
      }
    } else {
      domCursor.replaceWithAnchor(anchorName);
    }

    return {
      "blockTypes": blockTypes, 
      "blockCache": blocks != null ? new BlockCache(blocks) : null
    };
  }


  List<DirectiveRef> extractDirectiveRefs(dom.Node node) {
    List<DirectiveRef> directiveRefs = selector(node);

    // Resolve the Directive Controllers
    for(var j = 0, jj = directiveRefs.length; j < jj; j++) {
      DirectiveRef directiveRef = directiveRefs[j];
      Directive directive  = directives[directiveRef.selector];

      if (directive.$generate != null) {
        var generatedDirectives = directive.$generate(directiveRef.value);

        for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
          var generatedSelector = generatedDirectives[k][0];
          var generatedValue = generatedDirectives[k][1];
          Directive generatedDirectiveType = directives[generatedSelector];
          DirectiveRef generatedDirectiveRey = new DirectiveRef(
              new Directive(null),
              generatedValue);

          directiveRefs.add(generatedDirectiveRey);
        }
        jj = directiveRefs.length;
      }

      directiveRef.directive = directive;
    }
    directiveRefs.sort(priorityComparator);
    return directiveRefs;
  }

  priorityComparator(DirectiveRef a, DirectiveRef b) {
    int aPriority = a.directive.$priority,
    bPriority = b.directive.$priority;

    return bPriority - aPriority;
  }


  call(List<dom.Node> elements, [List<BlockCache> blockCaches]) {
    List<dom.Node> domElements = elements;
    List<dom.Node> templateElements = cloneElements(domElements);
    var directivePositions = _compileBlock(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        ?blockCaches && blockCaches != null ? blockCaches : [],
        null);

    return $blockTypeFactory(templateElements,
                             directivePositions == null ? [] : directivePositions);
  }
}
