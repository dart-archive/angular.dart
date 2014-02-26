part of angular.core.dom;

/**
 * The [NgAnimate] service provides dom lifecycle mangement, detection and
 * analysis of css animations, and hooks for custom animations. When any of
 * these animations are run, [Animation]s are returned so the animation can be
 * controled and so that custom dom manipulations can occur when animations
 * complete.
 */
abstract class NgAnimate {
  /**
   * Add the [cssClass] to the classes on [element] after running any
   * defined animations.
   */
  Animation addClass(dom.Element element, String cssClass);

  /**
    * Remove the [cssClass] from the classes on [element] after running any
    * defined animations.
    */
  Animation removeClass(dom.Element element, String cssClass);

  /**
   * Remove the [cssClass] from the classes on [element] after running any
   * defined animations. This is conceptually different remove class and should
   * handle high-priority css styles (eg, display: none !important).
    */
  Animation show(dom.Element element, String cssClass);

  /**
   * Add the [cssClass] to the classes on [element] after running any
   * defined animations. This is conceptually different add class and should
   * handle high-priority css styles (eg, display: none !important).
   */
  Animation hide(dom.Element element, String cssClass);

  /**
   * Perform an 'enter' animation for each element in [nodes]. The elements
   * must exist in the dom. This is equivalent to running enter on each element
   * in [nodes] and returning Future.wait(handles); for the onCompleted
   * property on [Animation].
   */
  Animation insert(Iterable<dom.Node> nodes, dom.Node parent,
                         { dom.Node insertBefore });

  /**
   * Perform a 'remove' animation for each element in [nodes]. The elements
   * must exist in the dom and should not be detached until the [onCompleted]
   * future on the [Animation] is executed AND the [AnimationResult] is
   * [AnimationResult.COMPLETED] or [AnimationResult.COMPLETED_IGNORED].
   *
   * This is equivalent to running remove on each element in [nodes] and
   * returning Future.wait(handles); for the onCompleted property on
   * [Animation].
   */
  Animation remove(Iterable<dom.Node> nodes);

  /**
   * Perform a 'move' animation for each element in [nodes]. The elements
   * must exist in the dom. This is equivalent to running move on each element
   * in [nodes] and returning Future.wait(handles); for the onCompleted
   * property on [Animation].
   */
  Animation move(Iterable<dom.Node> nodes, dom.Node parent,
                       { dom.Node insertBefore });
}
