part of angular;

class Compiler {
  Directives directives;
  Injector $injector;
  BlockTypeFactory $blockTypeFactory;
  Selector selector;

  Compiler(Directives this.directives,
           Injector this.$injector,
           BlockTypeFactory this.$blockTypeFactory) {
    selector = selectorFactory(directives.enumerate());
  }

  _compileBlock(NodeCursor domCursor, NodeCursor templateCursor,
               List<BlockCache> blockCaches,
               List<DirectiveInfo> useExistingDirectiveInfos) {
    var directivePositions = null; // don't pre-create to create spars tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      var directiveInfos = useExistingDirectiveInfos == null
          ? extractDirectiveInfos(domCursor.nodeList()[0])
          : useExistingDirectiveInfos;
      var compileChildren = true;
      var childDirectivePositions = null;
      var directiveDefs = null;

      cursorAlreadyAdvanced = false;

      for (var j = 0, jj = directiveInfos.length; j < jj; j++) {
        var directiveInfo = directiveInfos[j];
        var directiveFactory = directiveInfo.directiveFactory;
        var blockTypes = null;

        if (directiveFactory.$generate != null) {
          var nodeList = domCursor.nodeList();
          var generatedDirectives = directiveFactory.$generate(directiveInfo.value, nodeList);

          for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
            String generatedSelector = generatedDirectives[k][0];
            String generatedValue = generatedDirectives[k][1];
            Type generatedDirectiveType = $directiveInjector.get(generatedSelector);
            var generatedDirectiveInfo = new DirectiveInfo(
                new DirectiveFactory(generatedDirectiveType),
                generatedValue);

            directiveInfos.add(generatedDirectiveInfo);
          }
        }
        if (directiveFactory.$transclude != null) {
          var remaindingDirectives = directiveInfos.slice(j + 1);
          var transclusion = compileTransclusion(directiveFactory.$transclude,
              domCursor, templateCursor,
              directiveInfo, remaindingDirectives);

          if (transclusion.blockCache) {
            blockCaches.add(transclusion.blockCache);
          }
          blockTypes = transclusion.blockTypes;

          j = jj; // stop processing further directives since they belong to transclusion;
          compileChildren = false;
        }
        if (directiveDefs == null) {
          directiveDefs = [];
        }
        directiveDefs.add(new DirectiveDef(directiveFactory, directiveInfo.value, blockTypes));
      }

      if (compileChildren && domCursor.descend()) {
        templateCursor.descend();

        childDirectivePositions = compileChildren
            ? _compileBlock(domCursor, templateCursor, blockCaches, useExistingDirectiveInfos)
            : null;

        domCursor.ascend();
        templateCursor.ascend();
      }

      if (childDirectivePositions != null || directiveDefs != null) {
        if (directivePositions == null) directivePositions = [];
        var directiveOffsetIndex = templateCursor.index;

        directivePositions
            ..add(directiveOffsetIndex)
            ..add(directiveDefs)
            ..add(childDirectivePositions);
      }
    } while (templateCursor.microNext() && domCursor.microNext());

    return directivePositions;
  }

  compileTransclusion(String selector,
                      NodeCursor domCursor, NodeCursor templateCursor,
                      DirectiveInfo directiveInfo, List<DirectiveInfo>
                      transcludedDirectiveInfos) {
    var anchorName = directiveInfo.name + (directiveInfo.value != null ? '=' + directiveInfo.value : '');
    var blockTypes = {};
    var BlockType;
    var blocks;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var groupName = '';
    var domCursorIndex = domCursor.index;
    var directivePositions = _compileBlock(domCursor, transcludeCursor, [], transcludedDirectiveInfos) || [];

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

    return {'blockTypes': blockTypes,
            'blockCache': blocks ? new BlockCache(blocks) : null};
  }


  List<DirectiveInfo> extractDirectiveInfos(dom.Node node) {
    List<DirectiveInfo> directiveInfos = selector(node);

    // Resolve the Directive Controllers
    for(var j = 0, jj = directiveInfos.length; j < jj; j++) {
      DirectiveInfo directiveInfo = directiveInfos[j];
      DirectiveFactory directiveFactory  = directives[directiveInfo.selector];

      if (directiveFactory.$generate != null) {
        var generatedDirectives = directiveFactory.$generate(directiveInfo.value);

        for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
          var generatedSelector = generatedDirectives[k][0];
          var generatedValue = generatedDirectives[k][1];
          DirectiveFactory generatedDirectiveType = directives[generatedSelector];
          DirectiveInfo generatedDirectiveInfo = new DirectiveInfo(
              new DirectiveFactory(null),
              generatedValue);

          directiveInfos.add(generatedDirectiveInfo);
        }
        jj = directiveInfos.length;
      }

      directiveInfo.directiveFactory = directiveFactory;
    }
    directiveInfos.sort(priorityComparator);
    return directiveInfos;
  }

  priorityComparator(DirectiveInfo a, DirectiveInfo b) {
    int aPriority = a.directiveFactory.$priority || 0,
    bPriority = b.directiveFactory.$priority || 0;

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
