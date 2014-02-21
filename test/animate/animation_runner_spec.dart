library animation_runner_spec;

import 'dart:async';
import '../_specs.dart';

main() {
  describe('AnimationRunner', () {
    TestBed _;
    MockWindow wnd;
    AnimationRunner runner;
    beforeEach(inject((TestBed tb, NgZone zone) {
      _ = tb;
      wnd = new MockWindow();
      runner = new AnimationRunner(wnd, zone);
    }));
    
    it('should play animations with window animation frames', async(() {
      _.compile('<div></div>');
      var animation = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      animation.when(callsTo('start', anything)).alwaysReturn(null);
      animation.when(callsTo('read', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything))
        .thenReturn(true, 2)
        .thenReturn(false);
      animation.when(callsTo('detach', anything)).alwaysReturn(null);
      
      runner.play(animation);

      animation.getLogs(callsTo('attach')).verify(happenedExactly(1));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.clearLogs();

      wnd.executeAnimationFrame();
      microLeap();

      animation.getLogs(callsTo('attach')).verify(happenedExactly(0));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.clearLogs();
      
      wnd.executeAnimationFrame();
      microLeap();
      
      animation.getLogs(callsTo('attach')).verify(happenedExactly(0));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.clearLogs();
      
      wnd.executeAnimationFrame();
      microLeap();      

      animation.getLogs(callsTo('attach')).verify(happenedExactly(0));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.clearLogs();

      wnd.executeAnimationFrame();
      microLeap();

      animation.getLogs(callsTo('attach')).verify(happenedExactly(0));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(1));
      animation.clearLogs();
      
      wnd.executeAnimationFrame();
      microLeap();

      animation.getLogs(callsTo('attach')).verify(happenedExactly(0));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.clearLogs();
      
      expect(true).toBe(true);
    }));
    
    it('should interrupt existing animations', async(() {
      _.compile('<div></div>');
      var animation = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      
      runner.play(animation);

      var a2 = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      
      runner.play(a2);
      
      animation.getLogs(callsTo('interruptAndCancel')).verify(happenedExactly(1));
      a2.getLogs(callsTo('attach')).verify(happenedExactly(1));
    }));
    
    it('should interrupt existing animations after attach', async(() {
      _.compile('<div></div>');
      var animation = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      animation.when(callsTo('start', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(animation);

      var a2 = new MockAnimation(_.rootElement);
      a2.when(callsTo('attach')).alwaysReturn(null);
      a2.when(callsTo('start', anything)).alwaysReturn(null);
      a2.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(a2);

      wnd.executeAnimationFrame();
      microLeap();

      wnd.executeAnimationFrame();
      microLeap();
      
      animation.getLogs(callsTo('attach')).verify(happenedExactly(1));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('interruptAndCancel')).verify(happenedExactly(1));
      animation.getLogs(callsTo('interruptAndComplete')).verify(happenedExactly(0));
      animation.clearLogs();
    }));
    
    it('should interrupt existing animations after start', async(() {
      _.compile('<div></div>');
      var animation = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      animation.when(callsTo('start', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(animation);

      wnd.executeAnimationFrame();
      microLeap();

      var a2 = new MockAnimation(_.rootElement);
      a2.when(callsTo('attach')).alwaysReturn(null);
      a2.when(callsTo('start', anything)).alwaysReturn(null);
      a2.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(a2);

      wnd.executeAnimationFrame();
      microLeap();

      wnd.executeAnimationFrame();
      microLeap();
      
      animation.getLogs(callsTo('attach')).verify(happenedExactly(1));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('interruptAndCancel')).verify(happenedExactly(1));
      animation.getLogs(callsTo('interruptAndComplete')).verify(happenedExactly(0));
      animation.clearLogs();
    }));
    
    
    it('should interrupt existing animations after updating', async(() {
      _.compile('<div></div>');
      var animation = new MockAnimation(_.rootElement);
      animation.when(callsTo('attach')).alwaysReturn(null);
      animation.when(callsTo('start', anything)).alwaysReturn(null);
      animation.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(animation);

      wnd.executeAnimationFrame();
      microLeap();
      
      wnd.executeAnimationFrame();
      microLeap();

      var a2 = new MockAnimation(_.rootElement);
      a2.when(callsTo('attach')).alwaysReturn(null);
      a2.when(callsTo('start', anything)).alwaysReturn(null);
      a2.when(callsTo('update', anything)).alwaysReturn(true);
      
      runner.play(a2);

      wnd.executeAnimationFrame();
      microLeap();

      wnd.executeAnimationFrame();
      microLeap();

      animation.getLogs(callsTo('attach')).verify(happenedExactly(1));
      animation.getLogs(callsTo('start', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('read', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('update', anything)).verify(happenedExactly(1));
      animation.getLogs(callsTo('detach', anything)).verify(happenedExactly(0));
      animation.getLogs(callsTo('interruptAndCancel')).verify(happenedExactly(1));
      animation.getLogs(callsTo('interruptAndComplete')).verify(happenedExactly(0));
      animation.clearLogs();
    }));
  });
}

class MockAnimation extends Mock implements Animation {
  final Element element;
  final Completer<AnimationResult> onCompletedCompleter = new Completer<AnimationResult>();
  Future<AnimationResult> get onCompleted => onCompletedCompleter.future;
  
  MockAnimation(this.element);
  
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}