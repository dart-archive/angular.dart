part of angular.animate;

/**
 * Final result of an animation after it is no longer attached to the element.
 */
class AnimationResult {
  /// Animation was run (if it exists) and completed successfully.
  static const COMPLETED = const AnimationResult._('COMPLETED');

  /// Animation was skipped, but should be continued.
  static const COMPLETED_IGNORED = const AnimationResult._('COMPLETED_IGNORED');

  /// A [CANCELED] animation should not procced with it's final effects.
  static const CANCELED = const AnimationResult._('CANCELED');
  
  /// Convienence method if you don't care exactly how an animation completed
  /// only that it did.
  bool get isCompleted => this == COMPLETED || this == COMPLETED_IGNORED;

  final String value;
  const AnimationResult._(this.value);
}

/**
 * An [Animation] is a per element state machine that can be implemented and
 * used by the animation system. All methods are optional, but not implementing
 * some methods may result in unintended behavior and you should understand what
 * each method does.
 *
 * The standard lifecycle of dom events is as follows:
 *
 *   1. attach() - Any dom modifications required to 'attach' to the target
 *         element should be executed. Any previously running animations should
 *         have already been completed, canceled, or detached.
 *
 *   2. start() - Read any computed information that may be needed from the
 *         element to setup the animation. Do not change the DOM for performance
 *         reasons.
 *
 *   3. update() - Every animation frame do DOM mutates and / or decide to
 *         continue or not. Return true if you are still animating.
 *
 *   4. read() - Every animation frame you may read computed state here.
 *
 *   5. detatch() - After update returns false, detach will be executed and you
 *         should physically detach from the dom and execute onCompleted futures
 *         so that external code that depends on your animation can do dom
 *         mutates as well.
 *         
 * Additionally, interruptAndCancel() and interruptAndComplete are used to
 * forcibly interupt an animation, and the implementation should immediatly
 * detach from [element].
 */
abstract class Animation {
  /// The element this animation is tied too.
  final dom.Element element;
  Future<AnimationResult> get onCompleted;

  Animation(this.element) {
    assert(element != null);
  }

  /**
   * Perform dom mutations to attach an initialize the animation on [element].
   * The animation should not modify the [element] until this method is called.
   */
  attach() { }

  /**
   * This performs DOM reads to compute information about the animation, and
   * will occur after attach. [time] is a date time representation of the
   * current time, and [offsetMs] is the time since the last animation frame.
   */
  start(DateTime time, num offsetMs) { }

  /**
   * Occurs every animation frame. Return false to stop receiving animation
   * frame updates. Detach will be called after [update] returns false.
   *
   * [time] is a [DateTime] representation of the current time
   * [offsetMs] is the time since the last animation frame.
   */
  bool update(DateTime time, num offsetMs) { return false; }

  /**
   * Occurs every animation frame after [update] is called and should be used
   * to read out DOM state information if needed.
   *
   * [time] is a [DateTime] representation of the current time
   * [offsetMs] is the time since the last animation frame.
   */
  read(DateTime time, num offsetMs) { }

  /**
   * When [update] returns false, this will be called on the same animation
   * frame. Any temporary classes or element modifications should be removed
   * from the element and the onCompleted future should be executed.
   */
  detach(DateTime time, num offsetMs) { }

  /**
   * This occurs when another animation interupts this animation or the cancel()
   * method is called on the AnimationHandel. The animation should remove any
   * temporary classes or element modifications and the onCompleted future
   * should be executed with a result of [CANCELED].
   */
  interruptAndCancel() { }

  /**
   * This occurs when the complete() method is called on the AnimationHandel.
   * The animation should remove any temporary classes or element modifications,
   * finish any final permanent modifications and the onCompleted future
   * should be executed with a result of [COMPLETED].
   */
  interruptAndComplete() { }
}