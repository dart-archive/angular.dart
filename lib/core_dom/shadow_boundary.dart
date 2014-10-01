part of angular.core.dom_internal;

/**
* The root of the application has a [ShadowBoundary] attached as does every [Component].
*
* [ShadowBoundary] is responsible for inserting style elements.
*/
abstract class ShadowBoundary {
  Set<dom.StyleElement> _insertedStyles;
  final dom.Node root;
  dom.StyleElement _lastStyleElement;

  ShadowBoundary(this.root);

  void insertStyleElements(List<dom.StyleElement> elements, {bool prepend: false}) {
    if (elements.isEmpty) return;

    final newStyles = _newStyles(elements);
    if (newStyles.isEmpty) return;

    final cloned = newStyles.map((el) => el.clone(true)).toList();
    if (_lastStyleElement == null) {
      _insertFirstStyles(cloned);
    } else {
      _insertStyles(cloned, prepend);
    }

    _addInsertedStyles(newStyles);
  }

  _insertFirstStyles(List<dom.StyleElement> elements) {
    elements.reversed.forEach(_insertFrontNode);
    _lastStyleElement = elements.last;
  }

  _insertStyles(List<dom.StyleElement> elements, bool prepend) {
    if (prepend) {
      elements.reversed.forEach(_insertFrontNode);
    } else {
      final next = _lastStyleElement.nextNode;
      root.insertAllBefore(elements, next);
      _lastStyleElement = elements.last;
    }
  }

  _insertFrontNode(dom.StyleElement style) {
    if (root.hasChildNodes()) {
      return root.insertBefore(style, root.firstChild);
    } else {
      return root.append(style);
    }
  }

  Iterable<dom.StyleElement> _newStyles(Iterable<dom.StyleElement> elements) {
    if (_insertedStyles == null) return elements;
    return elements.where((el) => !_insertedStyles.contains(el));
  }

  void _addInsertedStyles(Iterable<dom.StyleElement> elements) {
    if (_insertedStyles == null) _insertedStyles = new Set();
    _insertedStyles.addAll(elements);
  }
}

@Injectable()
class DefaultShadowBoundary extends ShadowBoundary {
  DefaultShadowBoundary()
      : super(dom.document.head);

  DefaultShadowBoundary.custom(dom.Node node)
      : super(node);
}

@Injectable()
class ShadowRootBoundary extends ShadowBoundary {
  ShadowRootBoundary(dom.ShadowRoot shadowRoot)
      : super(shadowRoot);
}
