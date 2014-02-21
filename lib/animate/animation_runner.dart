part of angular.animate;

/**
 * Window.animationFrame update loop and state machine for animations.
 *
 * TODO(codelogic): Find a way to detect and rate-limit the number of concurrent
 *    animations that are run at the same time.
 * 
 * TODO(codelogic): Shadow dom may prevents parent walks from
 *    detecting parent animations.
 */
class AnimationRunner {
  final dom.Window _wnd;

  bool _animationFrameQueued = false;

  // Active animations are stored so that the classes can later be removed
  // if an additional animation executes on the same element.
  final BiMap<dom.Element, Animation> _activeAnimations = new BiMap();

  final List<Animation> _attached = [];
  final List<Animation> _updating = [];
  final List<Animation> _completed = [];

  final Profiler _profiler;
  final NgZone _zone;

  /**
   * The animation runner which requires the dom [Window] for
   * requestAnimationFrame and a [Clock] instance for providing absolute time
   * for animation. The [profiler] is optional and will report timing
   * information for the animation loop if provided.
   */
  AnimationRunner(this._wnd, this._zone, [Profiler profiler])
      : _profiler = _getProfiler(profiler);

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

      // TODO(codleogic): This should run outside of an angular scope digest.
      _wnd.animationFrame.then((offsetMs)
          => _animationFrame(offsetMs))
          .catchError((error) => print(error));
      //    => _zone.runOutsideAngular(() => _animationFrame(offsetMs)));
    }
  }

  /* On the browsers animation frame event, update animations and progress
   * through the animation state model:
   * 
   *  1. attach() - pre-animation frame.
   *  2. start(...) - frame 1
   *  3. update(...) - frame 1+n
   *  4. read(...) - frame 1+n
   *  5. _repeat until update(...) returns false on frame m_
   *  6. update(...) - frame m
   *  7. detach(...) - frame m
   *  
   *  At any point any animation may be updated by calling interrupt and cancel
   *  with a reference to the [Animation] to cancel. The [AnimationRunner] will
   *  then forget about the [Animation] and will not call any further methods on
   *  the [Animation].
   */
  _animationFrame(num time) {
    _profiler.startTimer("AnimationRunner.AnimationFrame");
    _animationFrameQueued = false;

    _profiler.startTimer("AnimationRunner.AnimationFrame.DomMutates");
    // Dom mutates
    _update(time);
    _detachCompleted(time);

    _profiler.stopTimer("AnimationRunner.AnimationFrame.DomMutates");
    _profiler.startTimer("AnimationRunner.AnimationFrame.DomReads");

    // Dom reads
    _reads(time);
    _startAttached(time);

    _profiler.stopTimer("AnimationRunner.AnimationFrame.DomReads");

    // We don't need to continue queuing animation frames
    // if there are no more animations to process.
    if(_updating.length > 0) {
      _queueAnimationFrame();
    }

    _profiler.stopTimer("AnimationRunner.AnimationFrame");
  }

  _update(num timeMilliseconds) {
    for(int i=0; i<_updating.length; i++) {
      var animation = _updating[i];
      if(!animation.update(timeMilliseconds)) {
        _completed.add(animation);
        _updating.removeAt(i);
        i--;
      }
    }
  }

  _reads(num timeMilliseconds) {
    for(var animation in _updating) {
      animation.read(timeMilliseconds);
    }
  }

  _detachCompleted(num timeMilliseconds) {
    for(var animation in _completed) {
      _activeAnimations.remove(animation.element);
      animation.detach(timeMilliseconds);
    }
    _completed.clear();
  }

  _startAttached(num timeMilliseconds) {
    for(var animation in _attached) {
      animation.start(timeMilliseconds);
      _updating.add(animation);
    }
    _attached.clear();
  }

  _clearElement(element) {
    if(_activeAnimations.containsKey(element)) {
      var animation = _activeAnimations[element];
      _forget(animation);
      animation.interruptAndCancel();
    }
  }
  
  _forget(Animation animation) {
    assert(animation != null);

    _attached.remove(animation);
    _completed.remove(animation);
    _updating.remove(animation);
    _activeAnimations.remove(animation.element);
  }
  
  /**
   * This will return true if this [element] or any of the parent elements have
   * active animations applied to them and false if there is not.
   */
  bool hasRunningParentAnimation(dom.Element element) {
    while(element != null) {
      if(_activeAnimations.containsKey(element))
        return true;
      element = element.parent;
    }
    
    return false;
  }

  /**
   * If the animation runner is currently tracking this animation it will remove
   * the animation from the list of active animations and any currently updating
   * animations, and call interruptAndCancel() on the [Animation] instance.
   */
  interruptAndCancel(Animation animation) {
    if(_activeAnimations.containsValue(animation)) {
      _forget(animation);
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
      _forget(animation);
      animation.interruptAndComplete();
    }
  }
}
