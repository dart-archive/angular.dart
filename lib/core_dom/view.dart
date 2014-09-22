part of angular.core.dom_internal;

/**
 * A View is a fundamental building block of DOM. It is a chunk of DOM which
 * can not be structurally changed. A View can have [ViewPort] placeholders
 * embedded in its DOM.  A [ViewPort] can contain other [View]s and it is the
 * only way in which DOM structure can be modified.
 *
 * A [View] is a collection of DOM nodes

 * A [View] can be created from [ViewFactory].
 *
 */
class View {
  final Scope scope;
  final List<dom.Node> nodes;
  final List insertionPoints = [];

  LinkedListEntryGroup<DirectiveInjector> _rootInjectors = new LinkedListEntryGroup();

  View(this.nodes, this.scope);

  void addViewPort(ViewPort viewPort) {
    insertionPoints.add(viewPort);
  }

  void addContent(Content content) {
    insertionPoints.add(content);
  }

  void domWrite(fn()) {
    scope.domWrite(fn);
  }

  void domRead(fn()) {
    scope.domRead(fn);
  }

  void addRootDirectiveInjector(DirectiveInjector inj) {
    _rootInjectors.add(inj);
  }

  void remove() {
    _rootInjectors.unlink();
    _rootInjectors.forEach((di) => di.afterMove());
  }

  void afterMove() {
    _rootInjectors.forEach((di) => di.afterMove());
  }
}

/**
 * A ViewPort maintains an ordered list of [View]'s. It contains a
 * [placeholder] node that is used as the insertion point for view nodes.
 */
class ViewPort {
  final DirectiveInjector directiveInjector;
  final Scope scope;
  final dom.Node placeholder;
  final Animate _animate;
  final DestinationLightDom _lightDom;
  final View _parentView;
  final views = <View>[];

  ViewPort(DirectiveInjector directiveInjector, this.scope, this.placeholder, this._animate, [this._lightDom, View parentView])
      : directiveInjector = directiveInjector,
      _parentView = parentView != null ? parentView : directiveInjector.getByKey(VIEW_KEY) {
    _parentView.addViewPort(this);
  }

  View insertNew(ViewFactory viewFactory, { View insertAfter, Scope viewScope}) {
    if (viewScope == null) viewScope = scope.createChild(new PrototypeMap(scope.context));
    View view = viewFactory.call(viewScope, directiveInjector);
    return insert(view, insertAfter: insertAfter);
  }

  View insert(View view, { View insertAfter }) {
    scope.rootScope.domWrite(() {
      dom.Node previousNode = _lastNode(insertAfter);
      _viewsInsertAfter(view, insertAfter);
      _animate.insert(view.nodes, placeholder.parentNode, insertBefore: previousNode.nextNode);
      _notifyLightDom();
    });
    return view;
  }

  View remove(View view) {
    view.scope.destroy();
    views.remove(view);
    view.remove();
    scope.rootScope.domWrite(() {
      _animate.remove(view.nodes);
      _notifyLightDom();
    });
    return view;
  }

  View move(View view, { View moveAfter }) {
    dom.Node previousNode = _lastNode(moveAfter);
    views.remove(view);
    _viewsInsertAfter(view, moveAfter);
    view.afterMove();
    scope.rootScope.domWrite(() {
      _animate.move(view.nodes, placeholder.parentNode, insertBefore: previousNode.nextNode);
      _notifyLightDom();
    });
    return view;
  }

  void _viewsInsertAfter(View view, View insertAfter) {
    int index = insertAfter == null ? 0 : views.indexOf(insertAfter) + 1;
    views.insert(index, view);
    view._rootInjectors.moveAfter(_findRootInjectorGroupToInsertAfter(index - 1));
  }

  LinkedListEntryGroup _findRootInjectorGroupToInsertAfter(int viewIndex) {
    if (views.isEmpty) return null;

    while (viewIndex >= 0 && views[viewIndex]._rootInjectors.isEmpty) {
      viewIndex --;
    }

    return viewIndex >= 0 ? views[viewIndex]._rootInjectors : null;
  }

  List<dom.Node> get nodes {
    final r = [];
    for(final v in views) {
      r.addAll(v.nodes);
    }
    return r;
  }

  void _notifyLightDom() {
    if (_lightDom != null) _lightDom.redistribute();
  }

  dom.Node _lastNode(View insertAfter) =>
    insertAfter == null
      ? placeholder
      : insertAfter.nodes.last;
}
