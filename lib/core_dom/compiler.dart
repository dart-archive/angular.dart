part of angular.core.dom_internal;


@Injectable()
class Compiler implements Function {
  final Profiler _perf;
  final Expando _expando;

  Compiler(this._perf, this._expando);

  ViewFactory call(List<dom.Node> elements, DirectiveMap directives) {
    var s = traceEnter(Compiler_compile);
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    final elementBinders = <TaggedElementBinder>[];
    _compileView(new NodeCursor(elements),
                 null,              // binderForElement
                 directives,
                 -1,                // parentElementBinderOffset
                 null,              // directParentElementBinder
                 elementBinders,
                 true);             // isTopLevel

    var viewFactory = new ViewFactory(elements, _removeUnusedBinders(elementBinders), _perf);

    assert(_perf.stopTimer(timerId) != false);
    traceLeave(s);
    return viewFactory;
  }

  /// Returns the  ElementBinder for the current node.
  /// Also compiles the template for `TemplateElementBinder`s
  ElementBinder _elementBinderForNode(NodeCursor domCursor,
                                      ElementBinder elementBinder,
                                      DirectiveMap directives) {
    var node = domCursor.current;

    switch(node.nodeType) {
      case dom.Node.ELEMENT_NODE:
        if (elementBinder == null) elementBinder = directives.selector.matchElement(node);
        if (elementBinder.hasTemplate) _compileTransclusion(domCursor, elementBinder, directives);
        return elementBinder;

      case dom.Node.TEXT_NODE:
        return directives.selector.matchText(node);

      default:
        return null;
    }
  }

  /// Compiles the current nodes and add `TaggedElementBinder`(s) to `elementBinders`
  /// Also compiles child nodes when they need to
  void _compileNode(NodeCursor domCursor,
                    ElementBinder elementBinder,
                    DirectiveMap directives,
                    List elementBinders,
                    int parentElementBinderOffset,
                    bool isTopLevel,
                    TaggedElementBinder directParentElementBinder) {
    var node = domCursor.current;

    if (node.nodeType == dom.Node.ELEMENT_NODE) {
      TaggedElementBinder taggedElementBinder;
      int taggedElementBinderIndex;
      if (elementBinder.hasDirectivesOrEvents || elementBinder.hasTemplate) {
        taggedElementBinder = _addBinder(elementBinders,
            new TaggedElementBinder(elementBinder, parentElementBinderOffset, isTopLevel));
        taggedElementBinderIndex = elementBinders.length - 1;
        node.classes.add('ng-binding');
      } else {
        taggedElementBinderIndex = parentElementBinderOffset;
      }

      if (elementBinder.shouldCompileChildren && domCursor.descend()) {
        var addedDummy = false;
        if (taggedElementBinder == null) {
          addedDummy = true;
          // add a dummy `TaggedElementBinder` to the list which may be removed later.
          taggedElementBinder = _addBinder(elementBinders,
              new TaggedElementBinder(null, parentElementBinderOffset, isTopLevel));
        }

        _compileView(domCursor,
                     null,                       // binderForElement
                     directives,
                     taggedElementBinderIndex,   // parentElementBinderOffset
                     taggedElementBinder,        // directParentElementBinder
                     elementBinders,
                     false);                     // isTopLevel

        if (addedDummy && !taggedElementBinder.isDummy) {
          // We need to keep this element binder, so add the class to the DOM node as well.
          // To avoid array churn, we remove all dummy binders at the end of the compilation.
          node.classes.add('ng-binding');
        }
        domCursor.ascend();
      }
    } else if (node.nodeType == dom.Node.TEXT_NODE ||
               node.nodeType == dom.Node.COMMENT_NODE) {
      if (elementBinder != null &&
          elementBinder.hasDirectivesOrEvents &&
          directParentElementBinder != null) {
        directParentElementBinder.addText(new TaggedTextBinder(elementBinder, domCursor.index));
      } else if (isTopLevel) {
        // Always add an elementBinder for top-level text.
        assert(parentElementBinderOffset == -1);
        _addBinder(elementBinders, new TaggedElementBinder(elementBinder, -1, isTopLevel));
      }
    } else {
      throw "Unsupported node type for $node: [${node.nodeType}]";
    }
  }

  /// Compiles all the nodes in the `domCursor` and updates the `elementBinders` list
  void _compileView(NodeCursor domCursor,
                    ElementBinder binderForElement,
                    DirectiveMap directives,
                    int parentElementBinderOffset,
                    TaggedElementBinder directParentElementBinder,
                    List<TaggedElementBinder> elementBinders,
                    bool isTopLevel) {
    assert(parentElementBinderOffset != null && parentElementBinderOffset < elementBinders.length);

    while (domCursor.moveNext()) {
      _compileNode(domCursor,
                   _elementBinderForNode(domCursor, binderForElement, directives),
                   directives,
                   elementBinders,
                   parentElementBinderOffset,
                   isTopLevel,
                   directParentElementBinder);
    }
  }

  /// Compiles a transclusion:
  /// - replaces the element with an anchor (a DOM comment)
  /// - compiles the template
  void _compileTransclusion(NodeCursor templateCursor,
                            TemplateElementBinder templateBinder,
                            DirectiveMap directives) {
    var s = traceEnter(Compiler_template);
    DirectiveRef directiveRef = templateBinder.template;
    ElementBinder transcludedElementBinder = templateBinder.templateBinder;
    var anchorName = directiveRef.annotation.selector +
        (directiveRef.value != null ? '=' + directiveRef.value : '');

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var elementBinders = <TaggedElementBinder>[];
    _compileView(transcludeCursor,
                 transcludedElementBinder,
                 directives,
                 -1,               // parentElementBinderOffset
                 null,             // directParentElementBinder
                 elementBinders,
                 true);            // isTopLevel

    templateBinder.templateViewFactory =
        new ViewFactory(transcludeCursor.elements, _removeUnusedBinders(elementBinders), _perf);
    traceLeave(s);
  }

  /**
   * In order to support text nodes with directiveless parents, we add dummy `ElementBinder`s to the
   * list. After the entire template has been compiled, we remove the dummies and update the offset
   * indices
   */
  List<TaggedElementBinder> _removeUnusedBinders(List<TaggedElementBinder> binders) {
    // Index        Parent index   isDummy
    // 0: -- Root      -1            false
    // 1:  +-- A        0            true
    // 2:    +-- B      1            false
    //
    // Only B needs to stay (A is dummy)
    // srcToDst = [0, null, 1] - removed binders have their dst index set to `null`
    // output = [Root, B]
    final output = <TaggedElementBinder>[];
    final List<int> srcToDst = new List<int>(binders.length);
    int dstIndex = 0;

    for (var srcIndex = 0; srcIndex < binders.length; srcIndex++) {
      TaggedElementBinder binder = binders[srcIndex];
      if (!binder.isDummy) {
        if (binder.parentBinderOffset != -1) {
          // Update the offset to be the index in the `output` list
          binder.parentBinderOffset = srcToDst[binder.parentBinderOffset];
        }
        assert(binder.parentBinderOffset != null);
        output.add(binder);
        srcToDst[srcIndex] = dstIndex++;
      }
    }
    return output;
  }
}

TaggedElementBinder _addBinder(List<TaggedElementBinder> list, TaggedElementBinder binder) {
  assert(binder.parentBinderOffset != list.length); // Do not point to yourself!
  list.add(binder);
  return binder;
}
