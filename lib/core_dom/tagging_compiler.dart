part of angular.core.dom;

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
                                          TaggedElementBinder directParentElementBinder) {
    List<TaggedElementBinder> elementBinders = [];
    if (domCursor.current == null) return null;


    do {
      var node = domCursor.current;

      ElementBinder elementBinder;

      if (node.nodeType == 1) {

        // If nodetype is a element, call selector matchElement.  If text, call selector.matchText

        // TODO: selector will return null for non-useful bindings.
        elementBinder = useExistingElementBinder == null
        ?  directives.selector.matchElement(node)
        : useExistingElementBinder;

        if (elementBinder.hasTemplate) {
          elementBinder.templateViewFactory = _compileTransclusion(elementBinders,
          domCursor, templateCursor,
          elementBinder.template, elementBinder.templateBinder, directives, parentElementBinderOffset);
        }
      }

      node = domCursor.current;
      if (node.nodeType == 1) {

        var taggedElementBinder = null;
        if (elementBinder.hasDirectives || elementBinder.hasTemplate) {
          taggedElementBinder = new TaggedElementBinder(elementBinder, parentElementBinderOffset);
          elementBinders.add(taggedElementBinder);
          parentElementBinderOffset = elementBinders.length - 1;

          // TODO(deboer): Hack, this sucks.
          (templateCursor.current as dom.Element).classes.add('ng-binding');
          node.classes.add('ng-binding');
        }

        if (elementBinder.shouldCompileChildren) {
          if (domCursor.descend()) {
            templateCursor.descend();

            elementBinders.addAll(
              _compileView(domCursor, templateCursor, null, directives, parentElementBinderOffset,
                  taggedElementBinder));

            domCursor.ascend();
            templateCursor.ascend();
          }
        }
      } else if (node.nodeType == 3 || node.nodeType == 8) {
        elementBinder = node.nodeType == 3 ? directives.selector.matchText(node) : elementBinder;

        if (elementBinder.hasDirectives && (node.parentNode != null && templateCursor.current.parentNode != null)) {
          if (directParentElementBinder == null) {

            directParentElementBinder = new TaggedElementBinder(null, parentElementBinderOffset);
            elementBinders.add(directParentElementBinder);

            assert(templateCursor.current.parentNode is dom.Element);
            assert(node.parentNode is dom.Element);

            (node.parentNode as dom.Element).classes.add('ng-binding');
            (templateCursor.current.parentNode as dom.Element).classes.add('ng-binding');
          }
          directParentElementBinder.addText(new TaggedTextBinder(elementBinder, 0 /* TODO */));
        } else if(!(node.parentNode != null && templateCursor.current.parentNode != null)) {  // Always add an elementBinder for top-level text.
          elementBinders.add(new TaggedElementBinder(elementBinder, parentElementBinderOffset));
        }
    //  } else if (node.nodeType == 8) { // comment

      } else {
        throw "wtf";
      }
    } while (templateCursor.moveNext() && domCursor.moveNext());

     return elementBinders;
  }

  TaggingViewFactory _compileTransclusion(List<TaggedElementBinder> tElementBinders,
      NodeCursor domCursor, NodeCursor templateCursor,
      DirectiveRef directiveRef,
      ElementBinder transcludedElementBinder,
      DirectiveMap directives,
      int parentElementBinderOffset) {
    var anchorName = directiveRef.annotation.selector + (directiveRef.value != null ? '=' + directiveRef.value : '');
    var viewFactory;
    var views;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var domCursorIndex = domCursor.index;
    var elementBinders =
        _compileView(domCursor, transcludeCursor, transcludedElementBinder, directives, parentElementBinderOffset, null);
    if (elementBinders == null) elementBinders = [];

    viewFactory = new TaggingViewFactory(transcludeCursor.elements, elementBinders, _perf, _expando);
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
    List<TaggedElementBinder> elementBinders = _compileView(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null, directives, -1, null);

    var viewFactory = new TaggingViewFactory(templateElements,
    elementBinders == null ? [] : elementBinders, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }
}
