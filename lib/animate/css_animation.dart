part of angular.animate;

/**
 * [Animation] implementation for handling the standard angular 'event' and
 * 'event-active' class pattern with css. This will compute transition and
 * animation duration from the css classes and use it to complete futures when
 * the css animations complete.
 */
class CssAnimation extends Animation {
  final String cssClassToAdd;
  final String cssClassToRemove;

  final String cssEventClass;
  final String cssEventActiveClass;

  final Completer<AnimationResult> _completer = new Completer<AnimationResult>();

  AnimationResult _result;
  bool _isActive = false;

  Future<AnimationResult> get onCompleted => _completer.future;

  DateTime startTime;
  Duration duration;

  final Profiler profiler;

  CssAnimation(dom.Element targetElement,
      this.cssEventClass,
      this.cssEventActiveClass,
      { this.profiler,
        this.cssClassToAdd,
        this.cssClassToRemove })
        : super(targetElement);

  attach() {
    // this happens right after creation time but before the first window
    // animation frame is called.
    element.classes.add(cssEventClass);
  }

  start(DateTime time, num offsetMs) {
    // This occurs on the first animation frame.
    // TODO(codelogic): It might be good to find some way of defering this to
    //     the next digest loop instead of the first animation frame.
    this.startTime = time;
    duration = _computeDuration();
  }

  bool update(DateTime time, num offsetMs) {
    // This will always run after the first animationFrame is queued so that
    // inserted elements have the base event class applied before adding the
    // active class to the element. If this is not done, inserted dom nodes
    // will not run their enter animation.
    if(!_isActive && duration != Duration.ZERO) {
      element.classes.add(cssEventActiveClass);
      _isActive = true;
    } else if (time.isAfter(startTime.add(duration))
        || duration == null || duration == Duration.ZERO) {
      // TODO(codelogic): If the initial frame takes a significant amount of
      //   time, the computed duration + startTime might not actually represent
      //   the end of the animation

      // Done with the animation
      return false;
    }

    // Continue updating
    return true;
  }

  detach(DateTime time, num offsetMs) {
    if (!_completer.isCompleted) {
      _onComplete(AnimationResult.COMPLETED);
    }
  }

  interruptAndCancel() {
    if (!_completer.isCompleted) {
      _removeEventAnimationClasses();
      _result = AnimationResult.CANCELED;
      _completer.complete(_result);
    }
  }

  interruptAndComplete() {
    if (!_completer.isCompleted) {
      _onComplete(AnimationResult.COMPLETED_IGNORED);
    }
  }

  // Since there are two different ways to 'complete' an animation:
  void _onComplete(AnimationResult result) {
    _removeEventAnimationClasses();
    _result = result;
    if(cssClassToAdd != null) {
      element.classes.add(cssClassToAdd);
    } else if(cssClassToRemove != null) {
      element.classes.remove(cssClassToRemove);
    }
    _completer.complete(_result);
  }

  /// Cleanup css event classes.
  _removeEventAnimationClasses() {
    element.classes.remove(cssEventClass);
    element.classes.remove(cssEventActiveClass);
  }

  Duration _computeDuration() {
    // TODO(codelogic) this needs to take into account animation, repetition
    //   count and see if delay affects the computed duration.

    // TODO(codelogic): It might be possible to cache durations and avoid the
    //   getComputedStyle() hit for elements and transitions we've already seen.
    var style = element.getComputedStyle();
    var cssDurationString = style.transitionDuration;
    var keyframeDurationString = style.animationDuration;
    var cssDuration = _parseCssDuration(cssDurationString);
    var keyframeDuration = _parseCssDuration(keyframeDurationString);

    return cssDuration > keyframeDuration ? cssDuration : keyframeDuration;
  }

  Duration _parseCssDuration(String duration) {
    // Assume milliseconds
    if (duration.endsWith("ms")) {
      var ms = double.parse(duration.substring(0, duration.length - 2));
      int microseconds = Duration.MICROSECONDS_PER_MILLISECOND * ms;
      return new Duration(microseconds: microseconds.round());
    }

    // Assume seconds
    if (duration.endsWith("s")) {
      var seconds = double.parse(duration.substring(0, duration.length - 1));
      var microseconds = Duration.MICROSECONDS_PER_SECOND * seconds;
      return new Duration(microseconds: microseconds.round());
    }

    _logger.warning("UNABLE TO PARSE DURATION STRING: $duration");
    return Duration.ZERO;
  }
}