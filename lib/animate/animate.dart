part of angular.animate;

/**
 * The [Animate] service provides dom lifecycle mangement, detection and
 * analysis of css animations, and hooks for custom animations. When any of
 * these animations are run, [AnimationHandle]s are provided so that animations
 * can be controled and so custom dom manipulations can occur when animations
 * complete.
 *
 * TODO: Implement a staggered animation implementation similar to the
 *   AngularJS version.
 */
abstract class Animate {
  /**
   * Add the [cssClass] to the classes on each element in [nodes] after
   * running any defined animations. This is equivalent to running addClass on
   * each element in [nodes] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [nodes] will be
   * canceled.
   */
  AnimationHandle addClass(Iterable<dom.Node> nodes, String cssClass);

  /**
   * Remove the [cssClass] from the classes on each element in [nodes] after
   * running any defined animations. This is equivalent to running removeClass
   * on each element in [nodes] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [nodes] will be
   * canceled.
   */
  AnimationHandle removeClass(Iterable<dom.Node> nodes, String cssClass);

  /**
   * Perform an 'add' animation for each element in [nodes]. The elements
   * must exist in the dom. This is equivalent to running add on each element
   * in [nodes] and returning Future.wait(handles); for the onCompleted
   * property on [AnimationHandle].
   *
   * Any existing animations running on any element in [nodes] will be
   * canceled.
   */
  AnimationHandle insert(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore });

  /**
   * Perform a 'remove' animation for each element in [nodes]. The elements
   * must exist in the dom and should not be detached until the [onCompleted]
   * future on the [AnimationHandle] is executed AND the [AnimationResult] is
   * [AnimationResult.COMPLETED] or [AnimationResult.COMPLETED_IGNORED].
   *
   * This is equivalent to running remove on each element in [nodes] and
   * returning Future.wait(handles); for the onCompleted property on
   * [AnimationHandle].
   *
   * Any existing animations running on any element in [nodes] will be
   * canceled.
   */
  AnimationHandle remove(Iterable<dom.Node> nodes);

  /**
   * Perform a 'move' animation for each element in [nodes]. The elements
   * must exist in the dom. This is equivalent to running move on each element
   * in [nodes] and returning Future.wait(handles); for the onCompleted
   * property on [AnimationHandle].
   *
   * Any existing animations running on any element in [nodes] will be
   * canceled.
   */
  AnimationHandle move(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore });

  /**
   * Play a set of animations. This is equivalent to running play on each
   * animation in [elements] and returning Future.wait(handles); for the
   * onCompleted property on [AnimationHandle].
   *
   * Any existing animations running on any element in [elements] will be
   * canceled.
   */
  AnimationHandle play(Iterable<Animation> animations);
}
