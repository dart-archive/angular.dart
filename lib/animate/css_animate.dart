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
  static const String ngAddCssClass = "ng-enter";
  static const String ngRemoveCssClass = "ng-leave";

  static const String ngAddPostfix = "add";
  static const String ngRemovePostfix = "remove";
  static const String ngActivePostfix = "active";

  AnimationRunner _animationRunner;
  Profiler profiler;

  CssAnimate(AnimationRunner this._animationRunner,
      [ this.profiler ]);

  AnimationHandle addClass(dom.Element element, String cssClass) {
    return _cssAnimation(element, "$cssClass-$ngAddPostfix",
        cssClassToAdd: cssClass);
  }

  AnimationHandle removeClass(dom.Element element, String cssClass) {
    return _cssAnimation(element, "$cssClass-$ngRemovePostfix",
        cssClassToRemove: cssClass);
  }

  AnimationHandle add(dom.Element element) {
    return _cssAnimation(element, ngAddCssClass);
  }

  AnimationHandle remove(dom.Element element) {
    return _cssAnimation(element, ngRemoveCssClass);
  }

  AnimationHandle move(dom.Element element) {
    return _cssAnimation(element, ngMoveCssClass);
  }

  AnimationHandle play(Animation animation) {
    return _animationRunner.play(animation);
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
}