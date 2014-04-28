part of angular.core.dom_internal;

TaggedElementBinder _addBinder(List list, TaggedElementBinder binder) {
  assert(binder.parentBinderOffset != list.length); // Do not point to yourself!
  list.add(binder);
  return binder;
}

@Injectable()
class TaggingCompiler implements Compiler {
  final Profiler _perf;
  final Expando _expando;

  TaggingCompiler(this._perf, this._expando);

  ElementBinder _elementBinderForNode(NodeCursor domCursor,
                                      ElementBinder useExistingElementBinder,
                                      DirectiveMap directives,
                                      List elementBinders) {
    var node = domCursor.current;

    if (node.nodeType == 1) {
      // If nodetype is a element, call selector matchElement.
      // If text, call selector.matchText

      ElementBinder elementBinder = useExistingElementBinder == null ?
          directives.selector.matchElement(node) : useExistingElementBinder;

      if (elementBinder.hasTemplate) {
        var templateBinder = elementBinder as TemplateElementBinder;
        templateBinder.templateViewFactory = _compileTransclusion(
            domCursor, templateBinder.template,
            templateBinder.templateBinder, directives);
      }
      return elementBinder;
    } else if (node.nodeType == dom.Node.TEXT_NODE) {
      return directives.selector.matchText(node);
    }
    return null;
  }

  _compileNode(NodeCursor domCursor,
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
        taggedElementBinder = null;
        taggedElementBinderIndex = parentElementBinderOffset;
      }

      if (elementBinder.shouldCompileChildren) {
        if (domCursor.descend()) {
          var addedDummy = false;
          if (taggedElementBinder == null) {
            addedDummy = true;
            // add a dummy to the list which may be removed later.
            taggedElementBinder = _addBinder(elementBinders,
                new TaggedElementBinder(null, parentElementBinderOffset, isTopLevel));
          }

          _compileView(domCursor, null, directives, taggedElementBinderIndex,
              taggedElementBinder, elementBinders, false);

          if (addedDummy && !_isDummyBinder(taggedElementBinder)) {
            // We are keeping the element binder, so add the class
            // to the DOM node as well.
            //
            // To avoid array chrun, we remove all dummy binders at the
            // end of the compilation process.
            node.classes.add('ng-binding');
          }
          domCursor.ascend();
        }
      }
    } else if (node.nodeType == dom.Node.TEXT_NODE ||
               node.nodeType == dom.Node.COMMENT_NODE) {
      if (elementBinder != null &&
          elementBinder.hasDirectivesOrEvents &&
          directParentElementBinder != null) {
        directParentElementBinder.addText(
            new TaggedTextBinder(elementBinder, domCursor.index));
      } else if (isTopLevel) {
        // Always add an elementBinder for top-level text.
        _addBinder(elementBinders,
            new TaggedElementBinder(elementBinder, parentElementBinderOffset, isTopLevel));
      }
    } else {
      throw "Unsupported node type for $node: [${node.nodeType}]";
    }
  }

  List _compileView(NodeCursor domCursor,
                    ElementBinder useExistingElementBinder,
                    DirectiveMap directives,
                    int parentElementBinderOffset,
                    TaggedElementBinder directParentElementBinder,
                    List<TaggedElementBinder> elementBinders,
                    bool isTopLevel) {
    assert(parentElementBinderOffset != null);
    assert(parentElementBinderOffset < elementBinders.length);
    if (domCursor.current == null) return null;

    do {
      _compileNode(domCursor,
          _elementBinderForNode(domCursor, useExistingElementBinder, directives, elementBinders),
          directives, elementBinders, parentElementBinderOffset,
          isTopLevel, directParentElementBinder);
    } while (domCursor.moveNext());

     return elementBinders;
  }

  TaggingViewFactory _compileTransclusion(
      NodeCursor templateCursor,
      DirectiveRef directiveRef,
      ElementBinder transcludedElementBinder,
      DirectiveMap directives) {
    var anchorName = directiveRef.annotation.selector +
        (directiveRef.value != null ? '=' + directiveRef.value : '');

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var elementBinders = [];
    _compileView(transcludeCursor, transcludedElementBinder,
        directives, -1, null, elementBinders, true);

    var viewFactory = new TaggingViewFactory(transcludeCursor.elements,
        _removeUnusedBinders(elementBinders), _perf);

    return viewFactory;
  }

  TaggingViewFactory call(List<dom.Node> elements, DirectiveMap directives) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    final elementBinders = <TaggedElementBinder>[];
    _compileView(
        new NodeCursor(elements),
        null, directives, -1, null, elementBinders, true);

    var viewFactory = new TaggingViewFactory(
        elements, _removeUnusedBinders(elementBinders), _perf);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }

  _isDummyBinder(TaggedElementBinder binder) =>
    binder.binder == null && binder.textBinders == null && !binder.isTopLevel;

  _removeUnusedBinders(List<TaggedElementBinder> binders) {
    // In order to support text nodes with directiveless parents, we
    // add dummy ElementBinders to the list.  After the entire template
    // has been compiled, we remove the dummies and update the offset indices
    final output = [];
    final List<int> offsetMap = [];
    int outputIndex = 0;

    for (var i = 0, ii = binders.length; i < ii; i++) {
      TaggedElementBinder binder = binders[i];
      if (_isDummyBinder(binder)) {
        offsetMap.add(-2);
      } else {
        if (binder.parentBinderOffset != -1) {
          binder.parentBinderOffset = offsetMap[binder.parentBinderOffset];
        }
        assert(binder.parentBinderOffset != -2);
        output.add(binder);
        offsetMap.add(outputIndex++);
      }
    }
    return output;
  }
}
