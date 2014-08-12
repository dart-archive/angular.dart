part of angular.core.dom_internal;

/**
* The root of the application has a [ShadowBoundary] attached as does every [Component].
*
* [ShadowBoundary] is responsible for inserting style elements.
*/
abstract class ShadowBoundary {
  void insertStyleElements(List<dom.StyleElement> elements);
}

@Injectable()
class DefaultShadowBoundary implements ShadowBoundary {
  void insertStyleElements(List<dom.StyleElement> elements) {
    final cloned = elements.map((el) => el.clone(true));
    dom.document.head.nodes.addAll(cloned);
  }
}

@Injectable()
class ShadowRootBoundary implements ShadowBoundary {
  final dom.ShadowRoot shadowRoot;
  dom.StyleElement _lastStyleElement;

  ShadowRootBoundary(this.shadowRoot);

  void insertStyleElements(List<dom.StyleElement> elements) {
    if (elements.isEmpty) return;
    final cloned = elements.map((el) => el.clone(true));

    cloned.forEach((style) {
      if (_lastStyleElement != null) {
        _lastStyleElement = shadowRoot.insertBefore(style, _lastStyleElement.nextNode);
      } else if (shadowRoot.hasChildNodes()) {
        _lastStyleElement = shadowRoot.insertBefore(style, shadowRoot.firstChild);
      } else {
        _lastStyleElement = shadowRoot.append(style);
      }
    });
  }
}
