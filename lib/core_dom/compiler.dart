part of angular.core.dom;

@NgInjectableService()
class Compiler implements Function {
  final Profiler _perf;
  final Parser _parser;
  final Expando _expando;

  Compiler(this._perf, this._parser, this._expando);

  _compileView(NodeCursor domCursor, NodeCursor templateCursor,
                ElementBinder existingElementBinder,
                DirectiveMap directives) {
    if (domCursor.current == null) return null;

    var directivePositions = null; // don't pre-create to create sparse tree and prevent GC pressure.
    var cursorAlreadyAdvanced;

    do {
      ElementBinder declaredElementSelector = existingElementBinder == null
          ?  directives.selector(domCursor.current)
          : existingElementBinder;

      var childDirectivePositions = null;
      List<DirectiveRef> usableDirectiveRefs = null;

      cursorAlreadyAdvanced = false;

      // TODO: move to ElementBinder
      var compileTransclusionCallback = () {
        DirectiveRef directiveRef = declaredElementSelector.template;
        directiveRef.viewFactory = compileTransclusion(
            domCursor, templateCursor,
            directiveRef, declaredElementSelector, directives);
      };

      var compileChildrenCallback = () {
        if (declaredElementSelector.childMode == NgAnnotation.COMPILE_CHILDREN && domCursor.descend()) {
          templateCursor.descend();

          childDirectivePositions =
          _compileView(domCursor, templateCursor, null, directives);

          domCursor.ascend();
          templateCursor.ascend();
        }
      };

      usableDirectiveRefs = declaredElementSelector.bind(null, null, compileTransclusionCallback, compileChildrenCallback);

      if (childDirectivePositions != null || usableDirectiveRefs != null) {
        if (directivePositions == null) directivePositions = [];
        var directiveOffsetIndex = templateCursor.index;

        directivePositions
            ..add(directiveOffsetIndex)
            ..add(usableDirectiveRefs)
            ..add(childDirectivePositions);
      }
    } while (templateCursor.moveNext() && domCursor.moveNext());

    return directivePositions;
  }

  ViewFactory compileTransclusion(
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
    var directivePositions =
        _compileView(domCursor, transcludeCursor, transcludedElementBinder, directives);
    if (directivePositions == null) directivePositions = [];

    viewFactory = new ViewFactory(transcludeCursor.elements,
        directivePositions, _perf, _expando);
    domCursor.index = domCursorIndex;

    if (domCursor.isInstance) {
      domCursor.insertAnchorBefore(anchorName);
      views = [viewFactory([domCursor.current])];
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

  ViewFactory call(List<dom.Node> elements, DirectiveMap directives) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    final domElements = elements;
    final templateElements = cloneElements(domElements);
    var directivePositions = _compileView(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null, directives);

    var viewFactory = new ViewFactory(templateElements,
        directivePositions == null ? [] : directivePositions, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }



}

