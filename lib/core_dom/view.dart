part of angular.core.dom_internal;

/**
 * Fundamental building block of DOM composed of DOM nodes and placeholders.
 *
 * It is a chunk of DOM which can not be structurally changed. It can have [ViewPort] and [Content]
 * placeholders embedded in its DOM.
 *
 * A [View]s is created through a [ViewFactory].
 */
class View {
  final Scope scope;
  final List<dom.Node> nodes;
  final List insertionPoints = [];

  View(this.nodes, this.scope);

  void addViewPort(ViewPort viewPort) {
    insertionPoints.add(viewPort);
  }

  /// Projected contents for components (ie `<content>` tags)
  void addContent(Content content) {
    insertionPoints.add(content);
  }

  /// Schedules a [fn] to be executed in the next DOM write phase.
  void domWrite(fn()) {
    scope.domWrite(fn);
  }

  /// Schedules a [fn] to be executed in the next DOM read phase.
  void domRead(fn()) {
    scope.domRead(fn);
  }
}

/**
 * Maintains an ordered list of [View]'s.
 *
 * It contains a [placeholder] node that is used as the insertion point for view nodes.
 * Updating the child views of a [ViewPort] is a way to modify the hosting [View].
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

  /// Instantiates a `View` bound to the given [viewScope] or to the `scope` of this `ViewPort`
  /// when none is specified.
  /// The created `View` is scheduled for insertion as the first child or after [insertAfter] when
  /// specified.
  View insertNew(ViewFactory viewFactory, {View insertAfter, Scope viewScope}) {
    if (viewScope == null) viewScope = scope.createProtoChild();
    View view = viewFactory.call(viewScope, directiveInjector);
    return insert(view, insertAfter: insertAfter);
  }

  /// Schedules the insertion of the view in the next DOM write phase.
  /// The [view] gets inserted as the first child or after [insertAfter] when specified.
  View insert(View view, { View insertAfter }) {
    scope.rootScope.domWrite(() {
      dom.Node previousNode = _lastNode(insertAfter);
      _viewsInsertAfter(view, insertAfter);
      _animate.insert(view.nodes, placeholder.parentNode, insertBefore: previousNode.nextNode);
      _notifyLightDom();
    });
    return view;
  }

  /// Schedules the removal of the [view] in the next DOM write phase.
  /// The associated scope is destroyed immediately.
  View remove(View view) {
    view.scope.destroy();
    views.remove(view);
    scope.rootScope.domWrite(() {
      _animate.remove(view.nodes);
      _notifyLightDom();
    });
    return view;
  }

  /// Schedules the move of the [view] in the next DOM write phase.
  View move(View view, { View moveAfter }) {
    dom.Node previousNode = _lastNode(moveAfter);
    views.remove(view);
    _viewsInsertAfter(view, moveAfter);
    scope.rootScope.domWrite(() {
      _animate.move(view.nodes, placeholder.parentNode, insertBefore: previousNode.nextNode);
      _notifyLightDom();
    });
    return view;
  }

  void _viewsInsertAfter(View view, View insertAfter) {
    int index = insertAfter == null ? 0 : views.indexOf(insertAfter) + 1;
    views.insert(index, view);
  }

  /// Concatenates and returns the nodes for all the views.
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
