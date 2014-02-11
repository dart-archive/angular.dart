part of angular.animate;

/**
 * Instantly complete animations and return a AnimationHandle that will
 * complete on the next digest loop.
 */
class NoAnimate extends Animate {
  AnimationHandle addClass(dom.Element element, String cssClass) {
    element.classes.add(cssClass);
    return _completedAnimationHandle();
  }

  AnimationHandle removeClass(dom.Element element, String cssClass) {
    element.classes.remove(cssClass);
    return _completedAnimationHandle();
  }

  AnimationHandle add(dom.Element element) {
    return _completedAnimationHandle();
  }

  AnimationHandle remove(dom.Element element) {
    return _completedAnimationHandle();
  }

  AnimationHandle move(dom.Element element) {
    return _completedAnimationHandle();
  }

  AnimationHandle play(Animation animation) {
    var handle = new _CompletedAnimationHandle(future: animation.onCompleted);
    animation.interruptAndComplete();
    return handle;
  }

  AnimationHandle _completedAnimationHandle() {
    return new _CompletedAnimationHandle();
  }
}

class _CompletedAnimationHandle extends AnimationHandle {
  Future<AnimationResult> _future;
  get onCompleted => _future;

  _CompletedAnimationHandle({Future<AnimationResult> future})
      : _future = future {
    if(_future == null) {
      var completer = new Completer<AnimationResult>();
      _future = completer.future;
      completer.complete(AnimationResult.COMPLETED_IGNORED);
    }
  }

  complete() { }
  cancel() { }
}