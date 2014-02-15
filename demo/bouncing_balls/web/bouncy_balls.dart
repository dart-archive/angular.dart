import 'package:angular/angular.dart';
import 'dart:html';
import 'dart:math';
import 'dart:core';

var random = new Random();
var width = 400;
var height = 400;
var speed = .05;

class BallModel {
  var x = width * random.nextDouble();
  var y = height * random.nextDouble();
  var velX = 2 * speed * random.nextDouble() - speed;
  var velY = 2 * speed * random.nextDouble() - speed;
  var color = BallModel._color();

  static _color() {
    var color = '#';
    for(var i = 0; i < 6; i++) {
      color += (16 * random.nextDouble()).floor().toRadixString(16);
    }
    return color;
  }

}

@NgController(
  selector: '[bounce-controller]',
  publishAs: 'bounce')
class BounceController {
  var lastTime = window.performance.now();
  var run = true;
  var fps = 0;
  var digestTime = 0;
  var currentDigestTime = 0;
  var balls = [];
  final NgZone zone;
  final Scope scope;
  var ballClassName = 'ball';

  BounceController(this.zone, this.scope) {
    changeCount(100);
    tick();
  }

  void toggleCSS() {
    ballClassName = ballClassName == '' ? 'ball' : '';
  }

  void playPause() {
    run = !run;
    if (run) requestAnimationFrame(tick);
  }

  void requestAnimationFrame(fn) {
    window.requestAnimationFrame((_) => zone.run(fn));
  }

  void changeCount(count) {
    while(count > 0) {
      balls.add(new BallModel());
      count--;
    }
    while(count < 0 && balls.isNotEmpty) {
      balls.removeAt(0);
      count++;
    }
    //tick();
  }

  void timeDigest() {
    var start = window.performance.now();
    digestTime = currentDigestTime;
    scope.rootScope.domRead(() {
      currentDigestTime = window.performance.now() - start;
    });
  }

  void tick() {
    var now = window.performance.now();
    var delay = now - lastTime;

    fps = (1000/delay).round();
    for(var i=0, ii=balls.length; i<ii; i++) {
      var b = balls[i];
      b.x += delay * b.velX;
      b.y += delay * b.velY;
      if (b.x < 0) { b.x *= -1; b.velX *= -1; }
      if (b.y < 0) { b.y *= -1; b.velY *= -1; }
      if (b.x > width) { b.x = 2*width - b.x; b.velX *= -1; }
      if (b.y > height) { b.y = 2*height - b.y; b.velY *= -1; }
    }
    lastTime = now;
    timeDigest();
    if (run) requestAnimationFrame(tick);
  }
}

@NgDirective(
  selector: '[ball-position]',
  map: const {
    "ball-position": '=>position'})
class BallPositionDirective {
  final Element element;
  final Scope scope;
  BallPositionDirective(this.element, this.scope);

  set position(BallModel model) {
    element.style.backgroundColor = model.color;
    scope
        ..watch('x', (x, _) => element.style.left = '${x + 10}px', context: model, readOnly: true)
        ..watch('y', (y, _) => element.style.top = '${y + 10}px', context: model, readOnly: true);
  }
}

class MyModule extends Module {
  MyModule() {
    type(BounceController);
    type(BallPositionDirective);
    value(GetterCache, new GetterCache({
      'x': (o) => o.x,
      'y': (o) => o.y,
      'bounce': (o) => o.bounce,
      'fps': (o) => o.fps,
      'balls': (o) => o.balls,
      'length': (o) => o.length,
      'digestTime': (o) => o.digestTime,
      'ballClassName': (o) => o.ballClassName
    }));
    value(ScopeStats, new ScopeStats(report: true));
  }
}

main() {
  ngBootstrap(module: new MyModule());
}
