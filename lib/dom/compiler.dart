library angular.dom.compiler;

import 'dart:html' as dom;
import 'package:perf_api/perf_api.dart';
import 'block.dart';
import 'block_factory.dart';
import 'common.dart';
import 'selector.dart';
import 'node_cursor.dart';
import '../directive.dart';

class Compiler {
  DirectiveRegistry directives;
  DirectiveSelector selector;
  Profiler _perf;

  Compiler(DirectiveRegistry this.directives, Profiler this._perf) {
    selector = directiveSelectorFactory(directives);
  }

  _compileBlock(NodeCursor domCursor, NodeCursor templateCursor,
               List<DirectiveRef> useExistingDirectiveRefs) {
    if (domCursor.nodeList().length == 0) return null;

    var directivePositions = null; // don't pre-create to create spars tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      var declaredDirectiveRefs = useExistingDirectiveRefs == null
          ?  selector(domCursor.nodeList()[0])
          : useExistingDirectiveRefs;
      var compileChildren = true;
      var childDirectivePositions = null;
      List<DirectiveRef> usableDirectiveRefs = null;

      cursorAlreadyAdvanced = false;

      for (var j = 0, jj = declaredDirectiveRefs.length; j < jj; j++) {
        DirectiveRef directiveRef = declaredDirectiveRefs[j];
        NgAnnotationBase annotation = directiveRef.annotation;
        var blockFactory = null;

        if (annotation is NgNonBindable) {
          compileChildren = false;
          break;
        }

        if (annotation is NgDirective && (annotation as NgDirective).transclude) {
          var remainingDirectives = declaredDirectiveRefs.sublist(j + 1);
          blockFactory = compileTransclusion(
              domCursor, templateCursor,
              directiveRef, remainingDirectives);

          j = jj; // stop processing further directives since they belong to transclusion;
          compileChildren = false;
        }
        if (usableDirectiveRefs == null) {
          usableDirectiveRefs = [];
        }
        directiveRef.blockFactory = blockFactory;
        usableDirectiveRefs.add(directiveRef);
      }

      if (compileChildren && domCursor.descend()) {
        templateCursor.descend();

        childDirectivePositions = compileChildren
            ? _compileBlock(domCursor, templateCursor, null)
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

  BlockFactory compileTransclusion(
                      NodeCursor domCursor, NodeCursor templateCursor,
                      DirectiveRef directiveRef,
                      List<DirectiveRef> transcludedDirectiveRefs) {
    var anchorName = directiveRef.annotation.selector + (directiveRef.value != null ? '=' + directiveRef.value : '');
    var blockFactory;
    var blocks;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var domCursorIndex = domCursor.index;
    var directivePositions = _compileBlock(domCursor, transcludeCursor, transcludedDirectiveRefs);
    if (directivePositions == null) directivePositions = [];

    blockFactory = new BlockFactory(transcludeCursor.elements, directivePositions, _perf);
    domCursor.index = domCursorIndex;

    if (domCursor.isInstance()) {
      domCursor.insertAnchorBefore(anchorName);
      blocks = [blockFactory(domCursor.nodeList())];
      domCursor.macroNext();
      templateCursor.macroNext();
      while (domCursor.isValid() && domCursor.isInstance()) {
        blocks.add(blockFactory(domCursor.nodeList()));
        domCursor.macroNext();
        templateCursor.remove();
      }
    } else {
      domCursor.replaceWithAnchor(anchorName);
    }

    return blockFactory;
  }

  BlockFactory call(List<dom.Node> elements) => _perf.time('angular.compiler', () {
    List<dom.Node> domElements = elements;
    List<dom.Node> templateElements = cloneElements(domElements);
    var directivePositions = _compileBlock(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null);

    return new BlockFactory(templateElements,
        directivePositions == null ? [] : directivePositions, _perf);
  });
}
