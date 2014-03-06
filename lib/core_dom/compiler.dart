part of angular.core.dom;

@NgInjectableService()
class Compiler implements Function {
  final Profiler _perf;
  final Expando _expando;

  Compiler(this._perf, this._expando);

  List<ElementBinder> _compileView(NodeCursor domCursor, NodeCursor templateCursor,
                ElementBinder existingElementBinder,
                DirectiveMap directives) {
    if (domCursor.current == null) return null;

    List<ElementBinder> elementBinders = null; // don't pre-create to create sparse tree and prevent GC pressure.

    do {
      ElementBinder elementBinder = existingElementBinder == null
          ?  directives.selector(domCursor.current)
          : existingElementBinder;

      elementBinder.offsetIndex = templateCursor.index;

      if (elementBinder.hasTemplate) {
        elementBinder.templateViewFactory = compileTransclusion(
            domCursor, templateCursor,
            elementBinder.template, elementBinder.templateBinder, directives);
      }

      if (elementBinder.shouldCompileChildren) {
        if (domCursor.descend()) {
          templateCursor.descend();

          elementBinder.childElementBinders =
              _compileView(domCursor, templateCursor, null, directives);

          domCursor.ascend();
          templateCursor.ascend();
        }
      }

      if (elementBinder.isUseful) {
        if (elementBinders == null) elementBinders = [];
        elementBinders.add(elementBinder);
      }
    } while (templateCursor.moveNext() && domCursor.moveNext());

    return elementBinders;
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
    var elementBinders =
        _compileView(domCursor, transcludeCursor, transcludedElementBinder, directives);
    if (elementBinders == null) elementBinders = [];

    viewFactory = new ViewFactory(transcludeCursor.elements, elementBinders, _perf, _expando);
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
    final List<dom.Node> domElements = elements;
    final List<dom.Node> templateElements = cloneElements(domElements);
    var elementBinders = _compileView(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null, directives);

    var viewFactory = new ViewFactory(templateElements,
        elementBinders == null ? [] : elementBinders, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }
}
