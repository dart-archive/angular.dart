part of angular.animate;

/**
 * The [Animate] service provides dom lifecycle mangement, detection and
 * analysis of css animations, and hooks for custom animations. When any of
 * these animations are run, [AnimationHandle]s are provided so that animations
 * can be controled and so custom dom manipulations can occur when animations
 * complete.
 *
 * Note: The goal is that this will eventually be integrated with AngularDart.
 */
abstract class Animate {
  // TODO(codelogic): Should this have a factory constructor that defaults too
  //     The NoAnimate implementation?

  // TODO(codelogic): Look at staggered animation implementation in AngularJS.

  /**
   * Add the [cssClass] to the classes on [element] after running any defined
   * animations. Any existing animation running on [element] will be canceled.
   */
  AnimationHandle addClass(dom.Element element, String cssClass);

  /**
   * Remove the [cssClass] from classes on [element] after running any defined
   * animations. Any existing animation running on [element] will be canceled.
   */
  AnimationHandle removeClass(dom.Element element, String cssClass);

  /**
   * Perform an 'add' animation on [element]. The element must exist and have
   * already been added to the dom. Any existing animation running on [element]
   * will be canceled.
   */
  AnimationHandle add(dom.Element element);

  /**
   * Perform a 'remove' animation on [element]. The element must exist in the
   * dom and should not be detached until the [onCompleted] future on the
   * [AnimationHandle] is executed AND the [AnimationResult] is
   * [AnimationResult.COMPLETED] or [AnimationResult.COMPLETED_IGNORED].
   * Any existing animation running on [element] will be canceled.
   */
  AnimationHandle remove(dom.Element element);

  /**
   * Perform an 'move' animation on [element]. The element must exist in the
   * dom. Any existing animation running on [element] will be canceled.
   */
  AnimationHandle move(dom.Element element);

  /**
   * Play a custom animation on the element defined in [animation].  Any
   * existing animation running on [element] will be canceled.
   */
  AnimationHandle play(Animation animation);

  /**
   * Add the [cssClass] to the classes on each element in [elements] after
   * running any defined animations. This is equivalent to running addClass on
   * each element in [elements] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle addClassToAll(List<dom.Element> elements, String cssClass) {
    return new MultiAnimationHandle(
        elements.map((e) => addClass(e, cssClass)).toList());
  }

  /**
   * Remove the [cssClass] from the classes on each element in [elements] after
   * running any defined animations. This is equivalent to running removeClass
   * on each element in [elements] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle removeClassFromAll(List<dom.Element> elements, String cssClass) {
    return new MultiAnimationHandle(
        elements.map((e) => removeClass(e, cssClass)).toList());
  }

  /**
   * Perform an 'add' animation for each element in [elements]. The elements
   * must exist in the dom. This is equivalent to running add on each element
   * in [elements] and returning Future.wait(handles); for the onCompleted
   * property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle addAll(List<dom.Element> elements) {
    return new MultiAnimationHandle(elements.map((e) => add(e)).toList());
  }

  /**
   * Perform a 'remove' animation for each element in [elements]. The elements
   * must exist in the dom and should not be detached until the [onCompleted]
   * future on the [AnimationHandle] is executed AND the [AnimationResult] is
   * [AnimationResult.COMPLETED] or [AnimationResult.COMPLETED_IGNORED].
   *
   * This is equivalent to running remove on each element in [elements] and
   * returning Future.wait(handles); for the onCompleted property on
   * [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle removeAll(List<dom.Element> elements) {
    return new MultiAnimationHandle(elements.map((e) => remove(e)).toList());
  }

  /**
   * Perform a 'move' animation for each element in [elements]. The elements
   * must exist in the dom. This is equivalent to running move on each element
   * in [elements] and returning Future.wait(handles); for the onCompleted
   * property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle moveAll(List<dom.Element> elements) {
    return new MultiAnimationHandle(elements.map((e) => move(e)).toList());
  }

  /**
   * Play a set of animations. This is equivalent to running play on each
   * animation in [elements] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle playAll(List<Animation> animations) {
    return new MultiAnimationHandle(animations.map((a) => play(a)).toList());
  }
}

/**
 * Animation handle for controlling and listening to animation completion.
 */
abstract class AnimationHandle {
  /**
   * Executed once when the animation is completed with the type of completion
   * result.
   */
  Future<AnimationResult> get onCompleted;

  /**
   * Stop and complete the animation immediatly. This has no effect if the
   * animation has already completed.
   *
   * The onCompleted future will be executed if the animation has not been
   * completed.
   */
  void complete();

  /**
   * Stop and cancel the animation immediatly. This has no effect if the
   * animation has already completed.
   *
   * The onCompleted future will be executed if the animation has not been
   * completed.
   */
  void cancel();
}

/**
 * This is a proxy class for dealing with a set of elements where the 'same'
 * or similar animations are being run on them and it's more convenient to have
 * a merged animation handle to control and listen to the entire set of
 * elements.
 */
class MultiAnimationHandle extends AnimationHandle {
  List<AnimationHandle> _animationHandles;
  Future<AnimationResult> _onCompleted;

  /**
   * On completed executes once EVERY other future is completed via
   * Future.wait(). The animation result will be the 'lowest' common result
   * that is returned across all results.
   *
   * if every animation returns [AnimationResult.COMPLETED],
   *   [AnimationResult.COMPLETED] will be returned.
   * if any animation was [AnimationResult.COMPLETED_IGNORED] instead, even if
   *   some animations were completed, [AnimationResult.COMPLETED_IGNORED] will
   *   be returned.
   * if any animation was [AnimationResult.CANCELED], the result will be
   *   [AnimationResult.CANCELED].
   */
  Future<AnimationResult> get onCompleted => _onCompleted;

  /// Create a new [AnimationHandle] with a set of existing [AnimationHandle]s.
  MultiAnimationHandle(List<AnimationHandle> animationHandles) {
    _onCompleted = Future.wait(animationHandles.map((x) => x.onCompleted))
        .then((results) {
          // This ensures that the 'lowest' common result is returned.
          // if every animation COMPLETED, COMPLETED will be returned.
          // if any animation was COMPLETED_IGNORED instead, even if
          //     animations were completed, COMPLETED_IGNORED will be returned.
          // if any animation was canceled, the result will be CANCELED
          var rtrn = AnimationResult.COMPLETED;
          for(var result in results) {
            if(result == AnimationResult.CANCELED)
              return AnimationResult.CANCELED;
            if(result == AnimationResult.COMPLETED_IGNORED)
              rtrn = result;
          }
          return rtrn;
        });
  }

  /// For each of the tracked [AnimationHandle]s, call complete().
  complete() {
    for(var handle in _animationHandles) {
      handle.complete();
    }
  }

  /// For each of the tracked [AnimationHandle]s, call cancel().
  cancel() {
    for(var handle in _animationHandles) {
      handle.cancel();
    }
  }
}