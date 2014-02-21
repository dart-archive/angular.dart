part of angular.animate;

/**
 * [Animation] implementation for handling the standard angular 'event' and
 * 'event-active' class pattern with css. This will compute transition and
 * animation duration from the css classes and use it to complete futures when
 * the css animations complete.
 */
class CssAnimation extends Animation {
  final String addAtStart;
  final String addAtEnd;
  final String removeAtStart;
  final String removeAtEnd;

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
        this.addAtStart,
        this.removeAtStart,
        this.addAtEnd,
        this.removeAtEnd })
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
    try {
      duration = _computeTotalDuration();
    } catch (e) {
      print("NOOOOOOO RANGE DURATION FAILED: $e");
    }
  }

  bool update(DateTime time, num offsetMs) {
    
    // This will always run after the first animationFrame is queued so that
    // inserted elements have the base event class applied before adding the
    // active class to the element. If this is not done, inserted dom nodes
    // will not run their enter animation.
    if(!_isActive && duration != Duration.ZERO) {
      element.classes.add(cssEventActiveClass);
      if(addAtStart != null) {
        element.classes.add(addAtStart);
      } else if(removeAtStart != null) {
        element.classes.remove(removeAtStart);
      }
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
      if(addAtStart != null) {
        element.classes.add(addAtStart);
      } else if(removeAtStart != null) {
        element.classes.remove(removeAtStart);
      }
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
    if(addAtEnd != null) {
      element.classes.add(addAtEnd);
    } else if(removeAtEnd != null) {
      element.classes.remove(removeAtEnd);
    }
    _completer.complete(_result);
  }

  // Cleanup css event classes.
  _removeEventAnimationClasses() {
    element.classes.remove(cssEventClass);
    element.classes.remove(cssEventActiveClass);
  }

  Duration _computeTotalDuration() {
    // TODO(codelogic) this needs to take into account animation, repetition
    //   count and see if delay affects the computed duration.

    // TODO(codelogic): It might be possible to cache durations and avoid the
    //   getComputedStyle() hit for elements and transitions we've already seen.
    var style = element.getComputedStyle();
    var transitions = _parseTransitions(style);
    if(transitions.length == 0)
      return Duration.ZERO;
    
    var longestTransition = transitions.reduce((value, transition) 
        => (value == -1 || value.totalDuration < transition.totalDuration)
        ? transition : value);
    return longestTransition.totalDuration;
  }
  
  List<_CssTransition> _parseTransitions(dynamic style) {
    List<_CssTransition> transitions = [];
    
    if(style.transitionDuration.length > 0) {
      // Parse transitions
      List<double> durations = style.transitionDuration
          .split(", ")
          .map((x) => double.parse(x.substring(0,  x.length - 1)))
          .toList();
      List<double> delays = style.transitionDelay
          .split(", ")
          .map((x) => double.parse(x.substring(0,  x.length - 1)))
          .toList();
      List<String> properties = style.transitionProperty
          .split(", ");
      
      assert(durations.length == delays.length);
      assert(delays.length == properties.length);
      
      
      for(int i = 0; i < durations.length; i++) {
        transitions.add(new _CssTransition(properties[i], delays[i], durations[i]));
      }
    }
    
    if(style.animationDuration.length > 0) {
      // Parse and add animation duration properties.
      List<double> animationDurations = style.animationDuration
              .split(", ")
              .map((x) => double.parse(x.substring(0,  x.length - 1)))
              .toList();
      List<double> animationDelays = style.animationDelay
              .split(", ")
              .map((x) => double.parse(x.substring(0,  x.length - 1)))
              .toList();
      
      assert(animationDurations.length == animationDelays.length);
      
      for(int i = 0; i < animationDurations.length; i++) {
        transitions.add(new _CssTransition('animation',
            animationDelays[i], animationDurations[i]));
      }
    }

    return transitions;
  }
}

class _CssTransition {
  final String property;
  final num durationSeconds;
  final num delaySeconds;
  final Duration totalDuration;
  
  _CssTransition(this.property, num delay, num duration)
      : totalDuration = _computeDuration(delay, duration),
        delaySeconds = delay,
        durationSeconds = duration;
  
  static _computeDuration(num delaySeconds, num durationSeconds) {
    var duration = Duration.MICROSECONDS_PER_SECOND * durationSeconds;
    var delay = Duration.MICROSECONDS_PER_SECOND * delaySeconds;
    return new Duration(microseconds: (duration + delay).round());
  }
}