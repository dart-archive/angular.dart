part of angular.animate;

/**
 * The optimizer tracks elements and running animations. It's used to control
 * and optionally skip certain animations that are deemed "expensive" such as
 * running animations on child elements while the dom parent is also running an
 * animation.
 */
class AnimationOptimizer {
  final Map<dom.Element, Set<Animation>> _elements = new Map<dom.Element,
      Set<Animation>>();
  final Map<Animation, dom.Element> _animations = new Map<Animation,
      dom.Element>();

  Expando _expando;

  AnimationOptimizer(this._expando);

  /**
   * Track an animation that is running against a dom element. Usually, this
   * should occur when an animation starts.
   */
  void track(Animation animation, dom.Element forElement) {
    if (forElement != null) {
      var animations = _elements.putIfAbsent(forElement, () =>
          new Set<Animation>());
      animations.add(animation);
      _animations[animation] = forElement;
    }
  }

  /**
   * Stop tracking an animation. If it's the last tracked animation on an
   * element forget about that element as well.
   */
  void forget(Animation animation) {
    var element = _animations.remove(animation);
    if (element != null) {
      var animationsOnElement = _elements[element];
      animationsOnElement.remove(animation);
      // It may be more efficient just to keep sets around even after
      // animations complete.
      if (animationsOnElement.length == 0) {
        _elements.remove(element);
      }
    }
  }

  // TODO(codelogic): Allow animations to be forcibly prevented from executing
  // on certain elements, elements and children, and forcibly allowed (ignoring
  // parent animation state);

  /**
   * Returns true if there is tracked animation on the given element.
   */
  bool isAnimating(dom.Element element) {
    return _elements.containsKey(element);
  }

  /**
   * Given all the information this optimizer knows about currently executing
   * animations, return [true] if this element can be animated in an ideal case
   * and [false] if the optimizer thinks that it should not execute.
   */
  bool shouldAnimate(dom.Node node) {
    //var probe = _findElementProbe(node.parentNode);
    var source = node;
    node = node.parentNode;
    while (node != null) {
      if (node.nodeType == dom.Node.ELEMENT_NODE
          && isAnimating(node)) {
        // If there is an already running animation, don't animate.
        return false;
      }
      
      // If we hit a null parent, try to break out of shadow dom.
      if(node.parentNode == null) {
        var probe = _findElementProbe(node);
        if (probe != null && probe.parent != null) {
          // Escape shadow dom.
          node = probe.parent.element;
        } else {
          // If we are at the root of the document, we can animate.
          return true;
        }
      } else {
        node = node.parentNode;
      }
    }

    return true;
  }
  
  // Search and find the element probe for a given node.
  ElementProbe _findElementProbe(dom.Node node) {
    while (node != null) {
      if (_expando[node] != null) {
        return _expando[node];
      }
      node = node.parentNode;
    }
    return null;
  }
}
