import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
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

@Controller(
  selector: '[bounce-controller]',
  publishAs: 'bounce')
class BounceController {
  var lastTime = window.performance.now();
  var run = false;
  var fps = 0;
  var digestTime = 0;
  var currentDigestTime = 0;
  var balls = [];
  final Scope scope;
  var ballClassName = 'ball';

  BounceController(this.scope) {
    changeCount(100);
    if (run) tick();
  }

  void toggleCSS() {
    ballClassName = ballClassName == '' ? 'ball' : '';
  }

  void playPause() {
    run = !run;
    if (run) requestAnimationFrame(tick);
  }

  void requestAnimationFrame(fn) {
    window.requestAnimationFrame((_) => fn());
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

List<String> _CACHE = new List.generate(500, (i) => '${i}px');

@Decorator(
  selector: '[ball-position]',
  map: const {
    "ball-position": '=>position'},
  exportExpressions: const ['x', 'y'])
class BallPosition {
  final Element element;
  final Scope scope;
  BallPosition(this.element, this.scope);

  px(x) => _CACHE[max(0, x.round())];

  set position(BallModel model) {
    var style = element.style;
    style.backgroundColor = model.color;
    scope
        ..watch('x', (x, _) => element.style.left = '${x + 10}px',
            context: model, canChangeModel: false)
        ..watch('y', (y, _) => element.style.top = '${y + 10}px',
            context: model, canChangeModel: false);
  }
}

class MyModule extends Module {
  MyModule() {
    bind(BounceController);
    bind(BallPosition);
  }
}

main() {
  applicationFactory().addModule(new MyModule()).run();
}
