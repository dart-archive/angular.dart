part of angular.animate;

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
class _MultiAnimationHandle extends AnimationHandle {
  final List<AnimationHandle> _animationHandles;
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
  _MultiAnimationHandle(Iterable<AnimationHandle> animationHandles)
      : _animationHandles = animationHandles.toList(growable: false) {
    _onCompleted = Future.wait(_animationHandles.map((x) => x.onCompleted))
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