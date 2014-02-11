part of angular.animate;

/**
 * Window.animationFrame update loop and state machine for animations.
 *
 * TODO(codelogic): Find a way to stop child animations from running.
 * TODO(codelogic): Find a way to detect and rate-limit the number of concurrent
 *    animations that are run at the same time.
 * TODO(codelogic): Figure out if shadow dom prevents parent walks from
 *    detecting parent animations.
 */
class AnimationRunner {
  final Clock _clock;
  final dom.Window _wnd;

  bool _animationFrameQueued = false;

  // Active animations are stored so that the classes can later be removed
  // if an additional animation executes on the same element.
  final BiMap<dom.Element, Animation> _activeAnimations = new BiMap();

  final List<Animation> _attached = [];
  final List<Animation> _updating = [];
  final List<Animation> _completed = [];

  final Profiler _profiler;

  /**
   * The animation runner which requires the dom [Window] for
   * requestAnimationFrame and a [Clock] instance for providing absolute time
   * for animation. The [profiler] is optional and will report timing
   * information for the animation loop.
   */
  AnimationRunner(this._wnd, this._clock, [Profiler _profiler])
      : this._profiler = _getProfiler(_profiler);

  // For some reason the turnary operator doesn't want to work with profiler.
  static Profiler _getProfiler(Profiler value) {
    if (value == null) return new Profiler();
    return value;
  }

  /**
   * Start and play an animation through the state transitions defined in
   * [Animation].
   */
  AnimationHandle play(Animation animation) {
    _clearElement(animation.element);
    _activeAnimations[animation.element] = animation;

    animation.attach();
    _attached.add(animation);

    _queueAnimationFrame();

    var animationHandle = new _AnimationRunnerHandle(this, animation);
    return animationHandle;
  }

  _queueAnimationFrame() {
    if(!_animationFrameQueued) {
      _animationFrameQueued = true;

      _wnd.animationFrame.then((offsetMs)
          => _animationFrame(offsetMs));
    }
  }

  /**
   * On the browsers animation frame event, update animations.
   *
   * TODO(codelogic) It might be good to move this into a seperate class that
   *   ONLY handles animation frames so other systems can hook into it an use it
   *   without the full "Animation" interface and state model.
   */
  _animationFrame(num offsetMs) {
    _profiler.startTimer("AnimationRunner.AnimationFrame");
    _animationFrameQueued = false;

    // It's easier and more consistent to reason about time if we freeze it for
    // the duration of this function.
    var now = _clock.now(); //

    _profiler.startTimer("AnimationRunner.AnimationFrame.DomMutates");
    // Dom mutates
    _update(now, offsetMs);
    _detachCompleted(now, offsetMs);

    _profiler.stopTimer("AnimationRunner.AnimationFrame.DomMutates");
    _profiler.startTimer("AnimationRunner.AnimationFrame.DomReads");

    // Dom reads
    _reads(now, offsetMs);
    _startAttached(now, offsetMs);

    _profiler.stopTimer("AnimationRunner.AnimationFrame.DomReads");

    // We don't need to continue queuing animation frames
    // if there are no more animations to process.
    if(_updating.length > 0) {
      _queueAnimationFrame();
    }

    _profiler.stopTimer("AnimationRunner.AnimationFrame");
  }

  _update(DateTime now, num offset) {
    // FUTURE OPTIMIZATION: If there is some way for an animation to specify
    // how long, or when it completes, we could avoid processing it and queue
    // a timer instead of an animation frame callback. That being said,
    // animation frames are reasonably efficient, so it may not be a problem.
    for(int i=0; i<_updating.length; i++) {
      var animation = _updating[i];
      if(!animation.update(now, offset)) {
        _completed.add(animation);
        _updating.removeAt(i);
        i--;
      }
    }
  }

  _reads(DateTime now, num offsetMs) {
    for(var animation in _updating) {
      animation.read(now, offsetMs);
    }
  }

  _detachCompleted(DateTime now, num offsetMs) {
    for(var animation in _completed) {
      _activeAnimations.remove(animation.element);
      animation.detach(now, offsetMs);
    }
    _completed.clear();
  }

  _startAttached(DateTime now, num offsetMs) {
    for(var animation in _attached) {
      animation.start(now, offsetMs);
      _updating.add(animation);
    }
    _attached.clear();
  }

  _clearElement(element) {
    if(_activeAnimations.containsKey(element)) {
      var animation = _activeAnimations[element];
      _activeAnimations.remove(element);
      _updating.remove(animation);
      animation.interruptAndCancel();
    }
  }

  /**
   * If the animation runner is currently tracking this animation it will remove
   * the animation from the list of active animations and any currently updating
   * animations, and call interruptAndCancel() on the [Animation] instance.
   */
  interruptAndCancel(Animation animation) {
    if(_activeAnimations.containsValue(animation)) {
      _activeAnimations.remove(animation.element);
      _updating.remove(animation);
      animation.interruptAndCancel();
    }
  }

  /**
   * If the animation runner is currently tracking this animation it will remove
   * the animation from the list of active animations and any currently updating
   * animations, and call interruptAndComplete() on the [Animation] instance.
   */
  interruptAndComplete(Animation animation) {
    if(_activeAnimations.containsValue(animation)) {
      _activeAnimations.remove(animation.element);
      _updating.remove(animation);
      animation.interruptAndComplete();
    }
  }
}

/**
 * Animation handle that works with the [AnimationRunner] so that calling code
 * can manage and listen to the lifecycle of an animation.
 */
class _AnimationRunnerHandle extends AnimationHandle {
  final AnimationRunner _runner;
  final Animation _animation;

  get onCompleted => _animation.onCompleted;

  _AnimationRunnerHandle(this._runner, this._animation) {
    assert(_runner != null);
    assert(_animation != null);
  }

  complete() {
    _runner.interruptAndComplete(_animation);
  }

  cancel() {
    _runner.interruptAndComplete(_animation);
  }
}