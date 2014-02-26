part of angular.core.dom;

/**
 * Animation handle for controlling and listening to animation completion.
 */
abstract class Animation {
  /**
   * Executed once when the animation is completed with the type of completion
   * result.
   */
  async.Future<AnimationResult> get onCompleted;

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
 * Completed animation handle that is used when an animation is ignored and the
 * final effect of the animation is immediatly completed.
 * 
 * TODO(codelogic): consider making a singleton instance. Depends on how future
 * behaves.
 */
class NoOpAnimation extends Animation {
  async.Future<AnimationResult> _future;
  get onCompleted {
    if (_future == null) {
      _future = new async.Future.value(AnimationResult.COMPLETED_IGNORED);
    }
    return _future;
  }

  NoOpAnimation({async.Future<AnimationResult> future})
      : _future = future;

  complete() { }
  cancel() { }
}

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