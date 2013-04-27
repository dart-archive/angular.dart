part of angular;

class Compiler {
  Injector $directiveInjector;
  BlockTypeFactory $blockTypeFactory;
  Selector selector;

  Compiler($directiveInjector, $blockTypeFactory) {
    selector = selectorFactory($directiveInjector.enumerate());
  }

  compileBlock(NodeCursor domCursor, NodeCursor templateCursor,
               Map<String, BlockCache> blockCaches,
               List<DirectiveInfo> useExistingDirectiveInfos) {
    var directivePositions = null; // don't pre-create to create spars tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      var directiveInfos = useExistingDirectiveInfos || extractDirectiveInfos(domCursor.nodeList()[0]);
      var compileChildren = true;
      var childDirectivePositions = null;
      var directiveDefs = null;

      cursorAlreadyAdvanced = false;

      for (var j = 0, jj = directiveInfos.length; j < jj; j++) {
        var directiveInfo = directiveInfos[j];
        var DirectiveType = directiveInfo.DirectiveType;
        var blockTypes = null;

        if (DirectiveType.$generate) {
          var nodeList = domCursor.nodeList();
          var generatedDirectives = DirectiveType.$generate(directiveInfo.value, nodeList);

          for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
            String generatedSelector = generatedDirectives[k][0];
            String generatedValue = generatedDirectives[k][1];
            Type generatedDirectiveType = $directiveInjector.get(generatedSelector);
            var generatedDirectiveInfo = new DirectiveInfo(
                new DirectiveFactory(generatedDirectiveType),
                generatedValue);

            directiveInfos.push(generatedDirectiveInfo);
          }
        }
        if (DirectiveType.$transclude) {
          var remaindingDirectives = directiveInfos.slice(j + 1);
          var transclusion = compileTransclusion(DirectiveType.$transclude,
              domCursor, templateCursor,
              directiveInfo, remaindingDirectives);

          if (transclusion.blockCache) {
            blockCaches.push(transclusion.blockCache);
          }
          blockTypes = transclusion.blockTypes;

          j = jj; // stop processing further directives since they belong to transclusion;
          compileChildren = false;
        }
        if (!directiveDefs) {
          directiveDefs = [];
        }
        directiveDefs.push(new angular.core.DirectiveDef(DirectiveType, directiveInfo.value, blockTypes));
      }

      if (compileChildren && domCursor.descend()) {
        templateCursor.descend();

        childDirectivePositions = compileChildren
            ? compileBlock(domCursor, templateCursor, blockCaches)
            : null;

        domCursor.ascend();
        templateCursor.ascend();
      }

      if (childDirectivePositions || directiveDefs) {
        if (!directivePositions) directivePositions = [];
        var directiveOffsetIndex = templateCursor.index;

        directivePositions.push(directiveOffsetIndex, directiveDefs, childDirectivePositions);
      }
    } while (templateCursor.microNext() && domCursor.microNext());

    return directivePositions;
  }

  compileTransclusion(String selector,
                      NodeCursor domCursor, NodeCursor templateCursor,
                      DirectiveInfo directiveInfo, List<DirectiveInfo>
                      transcludedDirectiveInfos) {
    var anchorName = directiveInfo.name + (directiveInfo.value ? '=' + directiveInfo.value : '');
    var blockTypes = {};
    var BlockType;
    var blocks;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var groupName = '';
    var domCursorIndex = domCursor.index;
    var directivePositions = compileBlock(domCursor, transcludeCursor, [], transcludedDirectiveInfos) || [];

    BlockType = $blockTypeFactory(transcludeCursor.elements, directivePositions, groupName);
    domCursor.index = domCursorIndex;
    blockTypes[groupName] = BlockType;

    if (domCursor.isInstance()) {
      domCursor.insertAnchorBefore(anchorName);
      blocks = [BlockType(domCursor.nodeList())];
      domCursor.macroNext();
      templateCursor.macroNext();
      while (domCursor.isValid() && domCursor.isInstance()) {
        blocks.push(BlockType(domCursor.nodeList()));
        domCursor.macroNext();
        templateCursor.remove();
      }
    } else {
      domCursor.replaceWithAnchor(anchorName);
    }

    return {blockTypes: blockTypes, blockCache: blocks ? new angular.core.BlockCache(blocks) : null};
  }


  List<DirectiveInfo> extractDirectiveInfos(dom.Node node) {
    List<DirectiveInfo> directiveInfos = selector(node);

    // Resolve the Directive Controllers
    for(var j = 0, jj = directiveInfos.length; j < jj; j++) {
      DirectiveInfo directiveInfo = directiveInfos[j];
      DirectiveType DirectiveType  = $directiveInjector.get(directiveInfo.selector);

      if (DirectiveType.$generate) {
        var generatedDirectives = DirectiveType.$generate(directiveInfo.value);

        for (var k = 0, kk = generatedDirectives.length; k < kk; k++) {
          var generatedSelector = generatedDirectives[k][0];
          var generatedValue = generatedDirectives[k][1];
          /** @type {angular.core.DirectiveType} */
          var generatedDirectiveType = $directiveInjector.get(generatedSelector);
          /** @type {angular.core.DirectiveInfo} */
          var generatedDirectiveInfo = new DirectiveInfo(
              new DirectiveFactory(null),
              generatedValue);

          directiveInfos.push(generatedDirectiveInfo);
        }
        jj = directiveInfos.length;
      }

      directiveInfo.DirectiveType = DirectiveType;
    }
    directiveInfos.sort(priorityComparator);
    return directiveInfos;
  }

  priorityComparator(DirectiveInfo a, DirectiveInfo b) {
    var aPriority = a.DirectiveType.$priority || 0,
    bPriority = b.DirectiveType.$priority || 0;

    return bPriority - aPriority;
  }


  call(List<dom.Node> elements, [List<BlockCache> blockCaches]) {
    var domElements = elements;
    var templateElements = angular.core.dom.clone(domElements);
    var directivePositions = compileBlock(
        new angular.core.dom.NodeCursor(domElements),
        new angular.core.dom.NodeCursor(templateElements),
        blockCaches || []);

    return $blockTypeFactory(templateElements, directivePositions);
  }
}
