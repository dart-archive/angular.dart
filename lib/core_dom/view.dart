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

  View(this.nodes, this.scope);
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
  final _views = <View>[];

  ViewPort(this.directiveInjector, this.scope, this.placeholder, this._animate);

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
    });
    return view;
  }

  View remove(View view) {
    view.scope.destroy();
    _views.remove(view);
    scope.rootScope.domWrite(() {
      _animate.remove(view.nodes);
    });
    return view;
  }

  View move(View view, { View moveAfter }) {
    dom.Node previousNode = _lastNode(moveAfter);
    _views.remove(view);
    _viewsInsertAfter(view, moveAfter);
    scope.rootScope.domWrite(() {
      _animate.move(view.nodes, placeholder.parentNode, insertBefore: previousNode.nextNode);
    });
    return view;
  }

  void _viewsInsertAfter(View view, View insertAfter) {
    int index = insertAfter == null ? 0 : _views.indexOf(insertAfter) + 1;
    _views.insert(index, view);
  }

  dom.Node _lastNode(View insertAfter) =>
    insertAfter == null
      ? placeholder
      : insertAfter.nodes.last;
}
