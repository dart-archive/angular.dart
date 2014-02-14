part of angular.animate;

/**
 * Instantly complete animations and return a AnimationHandle that will
 * complete on the next digest loop.
 */
class NoAnimate extends Animate {
  final RootScope _scope;
  NoAnimate(this._scope);

  AnimationHandle addClass(Iterable<dom.Node> nodes, String cssClass) {
    _elements(nodes).forEach((el) => el.classes.add(cssClass));
    
    print("${_elements(nodes)}");
    
    return new _CompletedAnimationHandle();
  }
  
  AnimationHandle removeClass(Iterable<dom.Node> nodes, String cssClass) {
    _elements(nodes).forEach((el) => el.classes.remove(cssClass));
    return new _CompletedAnimationHandle();
  }
  
  AnimationHandle insert(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore } ) {
    parent.insertAllBefore(nodes, insertBefore);
    return new _CompletedAnimationHandle();
  }

  AnimationHandle remove(Iterable<dom.Node> nodes) {
    nodes.forEach((n) => n.remove());
    return new _CompletedAnimationHandle();
  }

  AnimationHandle move(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
    nodes.forEach((n) {
      if(n.parentNode == null) n.remove();
      parent.insertBefore(n, insertBefore);
    });
    return new _CompletedAnimationHandle();
  }

  AnimationHandle play(Iterable<Animation> animations) {
    var handle = new _MultiAnimationHandle(
        animations.map((a) => new _CompletedAnimationHandle(future: a.onCompleted)));
    
    animations.forEach((a) => a.interruptAndComplete());
    
    return handle;
  }
}

Iterable<dom.Element> _elements(Iterable<dom.Node> nodes) {
  return nodes.where((el) => el.nodeType == dom.Node.ELEMENT_NODE);
}