part of angular.core.dom;

@NgInjectableService()
class TaggingCompiler implements Compiler {
  final Profiler _perf;
  final Expando _expando;

  TaggingCompiler(this._perf, this._expando);

   List _compileView(

      NodeCursor domCursor, NodeCursor templateCursor,
                                          ElementBinder useExistingElementBinder,
                                          DirectiveMap directives) {
    List<TaggedElementBinder> elementBinders = [];
    if (domCursor.nodeList().length == 0) return null;


    do {
      var subtrees, binder;

      var node = domCursor.nodeList()[0];

      // If nodetype is a element, call selector matchElement.  If text, call selector.matchText

      // TODO: selector will return null for non-useful bindings.
      ElementBinder elementBinder = useExistingElementBinder == null
      ?  directives.selector.match(node)
      : useExistingElementBinder;

      if (elementBinder.hasTemplate) {
        elementBinder.templateViewFactory = _compileTransclusion(elementBinders,
            domCursor, templateCursor,
            elementBinder.template, elementBinder.templateBinder, directives);
      }

      if (elementBinder.shouldCompileChildren) {
        if (domCursor.descend()) {
          templateCursor.descend();

          elementBinders.addAll(
          _compileView(domCursor, templateCursor, null, directives /*current element list length*/));

          domCursor.ascend();
          templateCursor.ascend();
        }
      }

      // move this up
      if (elementBinder.hasDirectives) {
        elementBinders.add(new TaggedElementBinder(elementBinder, -1));
        node.classes.add('ng-binding');
        binder = elementBinder;
      }
    } while (templateCursor.microNext() && domCursor.microNext());

     return elementBinders;
  }

  TaggingViewFactory _compileTransclusion(List<TaggedElementBinder> tElementBinders,
      NodeCursor domCursor, NodeCursor templateCursor,
      DirectiveRef directiveRef,
      ElementBinder transcludedElementBinder,
      DirectiveMap directives) {
    var anchorName = directiveRef.annotation.selector + (directiveRef.value != null ? '=' + directiveRef.value : '');
    var viewFactory;
    var views;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var domCursorIndex = domCursor.index;
    var elementBinders =
    _compileView(domCursor, transcludeCursor, transcludedElementBinder, directives);
    if (elementBinders == null) elementBinders = [];

    viewFactory = new TaggingViewFactory(transcludeCursor.elements, elementBinders, _perf, _expando);
    domCursor.index = domCursorIndex;

    if (domCursor.isInstance()) {
      domCursor.insertAnchorBefore(anchorName);
      views = [viewFactory(domCursor.nodeList())];
      domCursor.macroNext();
      templateCursor.macroNext();
      while (domCursor.isValid() && domCursor.isInstance()) {
        views.add(viewFactory(domCursor.nodeList()));
        domCursor.macroNext();
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
        null, directives);

    var viewFactory = new TaggingViewFactory(templateElements,
    elementBinders == null ? [] : elementBinders, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }
}
