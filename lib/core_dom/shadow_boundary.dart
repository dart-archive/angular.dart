part of angular.core.dom_internal;

/**
* The root of the application has a [ShadowBoundary] attached as does every [Component].
*
* [ShadowBoundary] is responsible for inserting style elements.
*/
abstract class ShadowBoundary {
  Set<dom.StyleElement> _insertedStyles;

  void insertStyleElements(List<dom.StyleElement> elements);

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
  void insertStyleElements(List<dom.StyleElement> elements) {
    final newStyles = _newStyles(elements);
    final cloned = newStyles.map((el) => el.clone(true));
    dom.document.head.nodes.addAll(cloned);
    _addInsertedStyles(newStyles);
  }
}

@Injectable()
class ShadowRootBoundary extends ShadowBoundary {
  final dom.ShadowRoot shadowRoot;
  dom.StyleElement _lastStyleElement;

  ShadowRootBoundary(this.shadowRoot);

  void insertStyleElements(List<dom.StyleElement> elements) {
    if (elements.isEmpty) return;

    final newStyles = _newStyles(elements);
    final cloned = newStyles.map((el) => el.clone(true));

    cloned.forEach((style) {
      if (_lastStyleElement != null) {
        _lastStyleElement = shadowRoot.insertBefore(style, _lastStyleElement.nextNode);
      } else if (shadowRoot.hasChildNodes()) {
        _lastStyleElement = shadowRoot.insertBefore(style, shadowRoot.firstChild);
      } else {
        _lastStyleElement = shadowRoot.append(style);
      }
    });

    _addInsertedStyles(newStyles);
  }
}
