part of angular.core.dom;

TaggedElementBinder _addBinder(List list, TaggedElementBinder binder) {
  assert(binder.parentBinderOffset != list.length); // Do not point to yourself!
  list.add(binder);
  return binder;
}

@NgInjectableService()
class TaggingCompiler implements Compiler {
  final Profiler _perf;
  final Expando _expando;

  TaggingCompiler(this._perf, this._expando);

   List _compileView(
      NodeCursor domCursor, NodeCursor templateCursor,
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
      var node = domCursor.current;

      ElementBinder elementBinder;

      if (node.nodeType == 1) {

        // If nodetype is a element, call selector matchElement.
        // If text, call selector.matchText

        // TODO: selector will return null for non-useful bindings.
        elementBinder = useExistingElementBinder == null
            ?  directives.selector.matchElement(node)
            : useExistingElementBinder;

        if (elementBinder.hasTemplate) {
          elementBinder.templateViewFactory = _compileTransclusion(
              elementBinders, domCursor, templateCursor, elementBinder.template,
              elementBinder.templateBinder, directives);
        }
      }

      node = domCursor.current;

      if (node.nodeType == 1) {
        var templateNode = templateCursor.current as dom.Element;

        var taggedElementBinder = null;
        int taggedElementBinderIndex = parentElementBinderOffset;
        if (elementBinder.hasDirectivesOrEvents || elementBinder.hasTemplate) {
          taggedElementBinder = _addBinder(elementBinders,
              new TaggedElementBinder(elementBinder, parentElementBinderOffset, isTopLevel));
          taggedElementBinderIndex = elementBinders.length - 1;

          // TODO(deboer): Hack, this sucks.
          templateNode.classes.add('ng-binding');
          node.classes.add('ng-binding');
        }

        if (elementBinder.shouldCompileChildren) {
          if (domCursor.descend()) {
            templateCursor.descend();

            var addedDummy = false;
            if (taggedElementBinder == null) {
              addedDummy = true;
              // add a dummy to the list which may be removed later.
              taggedElementBinder = _addBinder(elementBinders,
                new TaggedElementBinder(null, parentElementBinderOffset, isTopLevel));
            }

            _compileView(domCursor, templateCursor, null, directives,
                taggedElementBinderIndex, taggedElementBinder, elementBinders, false);

            if (addedDummy && !_isDummyBinder(taggedElementBinder)) {
              // We are keeping the element binder, so add the class
              // to the DOM node as well.
              //
              // To avoid array chrun, we remove all dummy binders at the
              // end of the compilation process.
              templateNode.classes.add('ng-binding');
              node.classes.add('ng-binding');
            }

            domCursor.ascend();
            templateCursor.ascend();
          }
        }
      } else if (node.nodeType == 3 || node.nodeType == 8) {
        elementBinder = node.nodeType == 3 ?
            directives.selector.matchText(node) :
            elementBinder;

        if (elementBinder != null &&
            elementBinder.hasDirectivesOrEvents &&
            (node.parentNode != null && templateCursor.current.parentNode != null)) {
          directParentElementBinder.addText(
              new TaggedTextBinder(elementBinder, domCursor.index));
        } else if(!(node.parentNode != null &&
                    templateCursor.current.parentNode != null)) {
          // Always add an elementBinder for top-level text.
          _addBinder(elementBinders, new TaggedElementBinder(elementBinder,
              parentElementBinderOffset, isTopLevel));
        }
      } else {
        throw "Unsupported node type for $node: [${node.nodeType}]";
      }
    } while (templateCursor.moveNext() && domCursor.moveNext());

     return elementBinders;
  }

  TaggingViewFactory _compileTransclusion(List<TaggedElementBinder> tElementBinders,
      NodeCursor domCursor, NodeCursor templateCursor,
      DirectiveRef directiveRef,
      ElementBinder transcludedElementBinder,
      DirectiveMap directives) {
    var anchorName = directiveRef.annotation.selector +
        (directiveRef.value != null ? '=' + directiveRef.value : '');
    var viewFactory;
    var views;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var domCursorIndex = domCursor.index;
    var elementBinders = [];
    _compileView(domCursor, transcludeCursor, transcludedElementBinder,
        directives, -1, null, elementBinders, true);

    viewFactory = new TaggingViewFactory(transcludeCursor.elements,
        _removeUnusedBinders(elementBinders), _perf);
    domCursor.index = domCursorIndex;

    if (domCursor.isInstance) {
      domCursor.insertAnchorBefore(anchorName);
      views = [viewFactory([domCursor.current])];
      domCursor.moveNext();
      templateCursor.moveNext();
      while (domCursor.moveNext() && domCursor.isInstance) {
        views.add(viewFactory([domCursor.current]));
        templateCursor.remove();
      }
    } else {
      domCursor.replaceWithAnchor(anchorName);
    }

    return viewFactory;
  }

  TaggingViewFactory call(List<dom.Node> elements, DirectiveMap directives) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    List<dom.Node> domElements = elements;
    List<dom.Node> templateElements = cloneElements(domElements);
    final elementBinders = <TaggedElementBinder>[];
    _compileView(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null, directives, -1, null, elementBinders, true);

    var viewFactory = new TaggingViewFactory(
        templateElements, _removeUnusedBinders(elementBinders), _perf);

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
