library animation_runner_spec;

import 'dart:async';
import '../_specs.dart';

main() {
  describe('AnimationLoop', () {
    TestBed _;
    AnimationLoop runner;
    MockAnimationFrame frame;
    beforeEach(async(inject((TestBed tb, VmTurnZone zone) {
      _ = tb;
      frame = new MockAnimationFrame();
      runner = new AnimationLoop(frame, new Profiler(), zone);
    })));
    
    it('should play animations with window animation frames', async(() {
      var animation = new MockAnimation();
      animation.when(callsTo('read', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything))
        .thenReturn(true, 2)
        .thenReturn(false);
      
      runner.play(animation);

      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.clearLogs();

      frame.frame(0.0);
      microLeap();

      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.clearLogs();

      frame.frame(0.0);
      microLeap();

      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.clearLogs();

      frame.frame(0.0);
      microLeap();
      
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.clearLogs();
      
      frame.frame(0.0);
      microLeap();
      
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
    }));
    
    it('should forget about animations when forget(animation) is called', async(() {
      var animation = new MockAnimation();
      animation.when(callsTo('read', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything))
        .thenReturn(true, 2)
         .thenReturn(false);
            
      runner.play(animation);
      runner.forget(animation);

      frame.frame(0.0);
      microLeap();
      
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
    }));
  });
}

class MockAnimation extends Mock implements LoopedAnimation {
  final Completer<AnimationResult> onCompletedCompleter = new Completer<AnimationResult>();
  Future<AnimationResult> get onCompleted => onCompletedCompleter.future;
  
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAnimationFrame implements AnimationFrame {
  Completer<num> frameCompleter;
  Future<num> get animationFrame {
    if (frameCompleter == null)
      frameCompleter = new Completer<num>();
    return frameCompleter.future;
  }
  
  frame(num time) {
    var completer = frameCompleter;
    frameCompleter = null;
    if (completer != null) {
      completer.complete(time);
    }
  }
}
