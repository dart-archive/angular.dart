part of angular.animate;

/**
 * The optimizer tracks elements and running animations. It's used to control
 * and optionally skip certain animations that are deemed "expensive" such as
 * running animations on child elements while the dom parent is also running an
 * animation.
 */
class AnimationOptimizer {
  final Map<dom.Element, Set<Animation>> _elements
    = new Map<dom.Element, Set<Animation>>();
  final Map<Animation, dom.Element> _animations
    = new Map<Animation, dom.Element>();
  
  Expando _expando;
  
  AnimationOptimizer(this._expando);
  
  /**
   * Track an animation that is running against a dom element. Usually, this
   * should occur when an animation starts.
   */
  void track(Animation animation, dom.Element forElement) {
    if (forElement != null) {
      var animations = _elements.putIfAbsent(forElement, ()
          => new Set<Animation>());
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
  bool shouldAnimate(dom.Element element) {
    var current = element;
    while(current.parent != null) {
      if (isAnimating(current.parent)) {
        return false;
      }
//      if (element.parent == null) {
//        ElementProbe parentProbe = _expando[element.parent];
//        if(parentProbe.parent != null) {
//          current = parentProbe.parent;
//        } else {
//          return true;
//        }      
//      }
      current = current.parent;
    }
    
    return true;
  }
}
