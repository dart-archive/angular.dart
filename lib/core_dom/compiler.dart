part of angular.core.dom;

@NgInjectableService()
class Compiler {
  final DirectiveMap directives;
  final Profiler _perf;
  final Parser _parser;
  final Expando _expando;

  DirectiveSelector selector;

  Compiler(this.directives, this._perf, this._parser, this._expando) {
    selector = directiveSelectorFactory(directives);
  }

  _compileBlock(NodeCursor domCursor, NodeCursor templateCursor,
                List<DirectiveRef> useExistingDirectiveRefs) {
    if (domCursor.nodeList().length == 0) return null;

    var directivePositions = null; // don't pre-create to create sparse tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      var declaredDirectiveRefs = useExistingDirectiveRefs == null
          ?  selector(domCursor.nodeList()[0])
          : useExistingDirectiveRefs;
      var children = NgAnnotation.COMPILE_CHILDREN;
      var childDirectivePositions = null;
      List<DirectiveRef> usableDirectiveRefs = null;

      cursorAlreadyAdvanced = false;

      for (var j = 0, jj = declaredDirectiveRefs.length; j < jj; j++) {
        DirectiveRef directiveRef = declaredDirectiveRefs[j];
        NgAnnotation annotation = directiveRef.annotation;
        var blockFactory = null;

        if (annotation.children != children &&
            children == NgAnnotation.COMPILE_CHILDREN) {
          children = annotation.children;
        }

        if (children == NgAnnotation.TRANSCLUDE_CHILDREN) {
          var remainingDirectives = declaredDirectiveRefs.sublist(j + 1);
          blockFactory = compileTransclusion(
              domCursor, templateCursor,
              directiveRef, remainingDirectives);

          j = jj; // stop processing further directives since they belong to transclusion;
        }
        if (usableDirectiveRefs == null) {
          usableDirectiveRefs = [];
        }
        directiveRef.blockFactory = blockFactory;
        createMappings(directiveRef);
        usableDirectiveRefs.add(directiveRef);
      }

      if (children == NgAnnotation.COMPILE_CHILDREN && domCursor.descend()) {
        templateCursor.descend();

        childDirectivePositions = _compileBlock(domCursor, templateCursor, null);

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

    blockFactory = new BlockFactory(transcludeCursor.elements, directivePositions, _perf, _expando);
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

  BlockFactory call(List<dom.Node> elements) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    List<dom.Node> domElements = elements;
    List<dom.Node> templateElements = cloneElements(domElements);
    var directivePositions = _compileBlock(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null);

    var blockFactory = new BlockFactory(templateElements,
        directivePositions == null ? [] : directivePositions, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return blockFactory;
  }

  static RegExp _MAPPING = new RegExp(r'^(\@|=\>\!|\=\>|\<\=\>|\&)\s*(.*)$');

  createMappings(DirectiveRef ref) {
    NgAnnotation annotation = ref.annotation;
    if (annotation.map != null) annotation.map.forEach((attrName, mapping) {
      Match match = _MAPPING.firstMatch(mapping);
      if (match == null) {
        throw "Unknown mapping '$mapping' for attribute '$attrName'.";
      }
      var mode = match[1];
      var dstPath = match[2];

      Expression dstPathFn = _parser(dstPath.isEmpty ? attrName : dstPath);
      if (!dstPathFn.isAssignable) {
        throw "Expression '$dstPath' is not assignable in mapping '$mapping' for attribute '$attrName'.";
      }
      ApplyMapping mappingFn;
      switch (mode) {
        case '@':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst) {
            attrs.observe(attrName, (value) => dstPathFn.assign(dst, value));
          };
          break;
        case '<=>':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst) {
            if (attrs[attrName] == null) return;
            Expression attrExprFn = _parser(attrs[attrName]);
            var shadowValue = null;
            scope.$watch(
                    () => attrExprFn.eval(scope),
                    (v) => dstPathFn.assign(dst, shadowValue = v),
                attrs[attrName]);
            if (attrExprFn.isAssignable) {
              scope.$watch(
                      () => dstPathFn.eval(dst),
                      (v) {
                    if (shadowValue != v) {
                      shadowValue = v;
                      attrExprFn.assign(scope, v);
                    }
                  },
                  dstPath);
            }
          };
          break;
        case '=>':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst) {
            if (attrs[attrName] == null) return;
            Expression attrExprFn = _parser(attrs[attrName]);
            var shadowValue = null;
            scope.$watch(
                    () => attrExprFn.eval(scope),
                    (v) => dstPathFn.assign(dst, shadowValue = v),
                    attrs[attrName]);
          };
          break;
        case '=>!':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst) {
            if (attrs[attrName] == null) return;
            Expression attrExprFn = _parser(attrs[attrName]);
            var stopWatching;
            stopWatching = scope.$watch(
                () => attrExprFn.eval(scope),
                (value) {
                  if (dstPathFn.assign(dst, value) != null) {
                    stopWatching();
                  }
                },
                attrs[attrName]);
          };
          break;
        case '&':
          mappingFn = (NodeAttrs attrs, Scope scope, Object dst) {
            dstPathFn.assign(dst, _parser(attrs[attrName]).bind(scope, ScopeLocals.wrapper));
          };
          break;
      }
      ref.mappings.add(mappingFn);
    });
  }
}

