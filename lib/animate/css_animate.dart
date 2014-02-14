part of angular.animate;

/**
 * This defines the standard set of CSS animation classes, transitions, and
 * nomeanclature that will eventually be the foundation of the AngularDart
 * animation framework. This implementation uses the [AnimationRunner] class to
 * queue and run CSS based transition and keyframe animations, and provides a
 * [play(animation)] hook for running arbetrary animations.
 *
 * TODO(codelogic): There needs to be a way to turn animations on / off for
 *   sections of DOM so that they don't ever get animation classes added
 *   in these cases.
 */
class CssAnimate extends Animate {
  static const String ngAnimateCssClass = "ng-animate";
  static const String ngMoveCssClass = "ng-move";
  static const String ngInsertCssClass = "ng-enter";
  static const String ngRemoveCssClass = "ng-leave";

  static const String ngAddPostfix = "add";
  static const String ngRemovePostfix = "remove";
  static const String ngActivePostfix = "active";

  AnimationRunner _animationRunner;
  NoAnimate _noAnimate;
  Profiler profiler;
  RootScope _scope;

  CssAnimate(AnimationRunner this._animationRunner, this._noAnimate, this._scope,
      [ this.profiler ]);

  AnimationHandle addClass(Iterable<dom.Node> nodes, String cssClass) {
    var elements = _partition(_elements(nodes));
    
    var animateHandles = elements.animate.map((el) {
      return _cssAnimation(el, "$cssClass-$ngAddPostfix",
              cssClassToAdd: cssClass);
    });
    
    if(elements.noAnimate.length > 0)
      return _pickAnimationHandle(animateHandles,
          _noAnimate.addClass(elements.noAnimate, cssClass));
    return _pickAnimationHandle(animateHandles);
  }

  AnimationHandle removeClass(Iterable<dom.Node> nodes, String cssClass) {
    var elements = _partition(_elements(nodes));
    
    var animateHandles = elements.animate.map((el) {
      return _cssAnimation(el, "$cssClass-$ngRemovePostfix",
          cssClassToRemove: cssClass);
    });
    
    if(elements.noAnimate.length > 0)
      return _pickAnimationHandle(animateHandles,
          _noAnimate.removeClass(elements.noAnimate, cssClass));
    return _pickAnimationHandle(animateHandles);
  }

  AnimationHandle insert(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
    domInsert(nodes, parent, insertBefore: insertBefore);
    
    var animateHandles = _elements(nodes).where((el) {
      return !_animationRunner.hasRunningParentAnimation(el.parent);
    }).map((el) {
      return _cssAnimation(el, ngInsertCssClass);
    });

    return _pickAnimationHandle(animateHandles);
  }

  AnimationHandle remove(Iterable<dom.Node> nodes) {
    var elements = _partition(_elements(nodes));
    var animateHandles = elements.animate.map((el) {
      return _cssAnimation(el, ngRemoveCssClass)..onCompleted.then((result) {
        if(result.isCompleted) {
          el.remove();
        }
      });
    });
    elements.noAnimate.forEach((el) => el.remove());
    return _pickAnimationHandle(animateHandles);
  }

  AnimationHandle move(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
    domMove(nodes, parent, insertBefore: insertBefore);
    
    var animateHandles = _elements(nodes).where((el) {
      return !_animationRunner.hasRunningParentAnimation(el.parent);
    }).map((el) {
      return _cssAnimation(el, ngMoveCssClass);
    });

    return _pickAnimationHandle(animateHandles);
  }

  AnimationHandle play(Iterable<Animation> animations) {
    // TODO(codelogic): Should we skip the running parent animation check for custom animations?
    return _pickAnimationHandle(animations.map((a) => _animationRunner.play(a)));
  }

  AnimationHandle _cssAnimation(dom.Element element,
      String cssEventClass,
        { String cssClassToAdd,
          String cssClassToRemove}) {

    var animation = new CssAnimation(
        element,
        cssEventClass,
        "$cssEventClass-$ngActivePostfix",
        cssClassToAdd: cssClassToAdd,
        cssClassToRemove: cssClassToRemove,
        profiler: profiler);

    return _animationRunner.play(animation);
  }
  
  
  static AnimationHandle _pickAnimationHandle(Iterable<AnimationHandle> animated, [AnimationHandle noAnimate]) {
    List<AnimationHandle> handles;
 
    if(animated != null)
      handles = animated.toList();
    else if (noAnimate == null)
      return new _CompletedAnimationHandle();
    else
      return noAnimate;
    
    if(noAnimate != null)
      handles.add(noAnimate);

    if(handles.length == 1)
      return handles.first;

    return new _MultiAnimationHandle(handles);
  }
  
  _RunnableAnimations _partition(Iterable nodes) {
    var runnable = new _RunnableAnimations();
    nodes.forEach((el) {
      if(_animationRunner.hasRunningParentAnimation(el.parentNode)) {
        runnable.noAnimate.add(el);
      } else {
        runnable.animate.add(el);
      }
    });
    return runnable;
  }
}

class _RunnableAnimations {
  final animate = [];
  final noAnimate = [];
}

void domRemove(List<dom.Node> nodes) {
  // Not every element is sequential if the list of nodes only
  // includes the elements. Removing a block also includes
  // removing non-element nodes inbetween.
  for(var j = 0, jj = nodes.length; j < jj; j++) {
    dom.Node current = nodes[j];
    dom.Node next = j+1 < jj ? nodes[j+1] : null;

    while(next != null && current.nextNode != next) {
      current.nextNode.remove();
    }
    nodes[j].remove();
  }
}

void domInsert(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
  parent.insertAllBefore(nodes, insertBefore);
}

void domMove(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
  nodes.forEach((n) {
    if(n.parentNode == null) n.remove();
      parent.insertBefore(n, insertBefore);
  });
}

