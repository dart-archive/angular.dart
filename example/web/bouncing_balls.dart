import 'package:perf_api/perf_api.dart';
import 'package:angular/angular.dart';
import 'package:angular/angular_static.dart';
import 'package:angular/change_detection/change_detection.dart';
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
    value(ScopeStats, new ScopeStats(report: true));
  }
}

main() {
  var getters = {
    'x': (o) => o.x,
    'y': (o) => o.y,
    'bounce': (o) => o.bounce,
    'fps': (o) => o.fps,
    'balls': (o) => o.balls,
    'length': (o) => o.length,
    'digestTime': (o) => o.digestTime,
    'ballClassName': (o) => o.ballClassName,
    'position': (o) => o.position,
    'onClick': (o) => o.onClick,
    'ball': (o) => o.ball,
    'color': (o) => o.color,
    'changeCount': (o) => o.changeCount,
    'playPause': (o) => o.playPause,
    'toggleCSS': (o) => o.toggleCSS,
    'timeDigest': (o) => o.timeDigest,
    'expression': (o) => o.expression,
  };
  var setters = {
    'position': (o, v) => o.position = v,
    'onClick': (o, v) => o.onClick = v,
    'ball': (o, v) => o.ball = v,
    'x': (o, v) => o.x = v,
    'y': (o, v) => o.y = v,
    'balls': (o, v) => o.balls = v,
    'bounce': (o, v) => o.bounce = v,
    'expression': (o, v) => o.expression = v,
    'fps': (o, v) => o.fps = v,
    'length': (o, v) => o.length = v,
    'digestTime': (o, v) => o.digestTime = v,
    'ballClassName': (o, v) => o.ballClassName = v,
  };
  var metadata = {
    BounceController: [new NgController(selector: '[bounce-controller]', publishAs: 'bounce')],
    BallPositionDirective: [new NgDirective(selector: '[ball-position]', map: const { "ball-position": '=>position'})],
    NgEventDirective: [new NgDirective(selector: '[ng-click]', map: const {'ng-click': '&onClick'})],
    NgADirective: [new NgDirective(selector: 'a[href]')],
    NgRepeatDirective: [new NgDirective(children: NgAnnotation.TRANSCLUDE_CHILDREN, selector: '[ng-repeat]', map: const {'.': '@expression'})],
    NgTextMustacheDirective: [new NgDirective(selector: r':contains(/{{.*}}/)')],
    NgAttrMustacheDirective: [new NgDirective(selector: r'[*=/{{.*}}/]')],
  };
  var types = {
    Profiler: (t) => new Profiler(),
    DirectiveSelectorFactory: (t) => new DirectiveSelectorFactory(),
    DirectiveMap: (t) => new DirectiveMap(t(Injector), t(MetadataExtractor), t(DirectiveSelectorFactory)),
    Lexer: (t) => new Lexer(),
    ClosureMap: (t) => new StaticClosureMap(getters, setters), // TODO: types don't match
    DynamicParserBackend: (t) => new DynamicParserBackend(t(ClosureMap)),
    DynamicParser: (t) => new DynamicParser(t(Lexer), t(ParserBackend)),
    Compiler: (t) => new Compiler(t(Profiler), t(Parser), t(Expando)),
    WalkingCompiler: (t) => new WalkingCompiler(t(Profiler), t(Expando)),
    DirectiveSelectorFactory: (t) => new DirectiveSelectorFactory(t(ElementBinderFactory)),
    ElementBinderFactory: (t) => new ElementBinderFactory(t(Parser), t(Profiler), t(Expando)),
    EventHandler: (t) => new EventHandler(t(Node), t(Expando), t(ExceptionHandler)),
    AstParser: (t) => new AstParser(t(Parser)),
    FilterMap: (t) => new FilterMap(t(Injector), t(MetadataExtractor)),
    ExceptionHandler: (t) => new ExceptionHandler(),
    FieldGetterFactory: (t) => new StaticFieldGetterFactory(getters),
    ScopeDigestTTL: (t) => new ScopeDigestTTL(),
    ScopeStats: (t) => new ScopeStats(),
    RootScope: (t) => new RootScope(t(Object), t(AstParser), t(Parser), t(FieldGetterFactory), t(FilterMap), t(ExceptionHandler), t(ScopeDigestTTL), t(NgZone), t(ScopeStats)),
    NgAnimate: (t) => new NgAnimate(),
    Interpolate: (t) => new Interpolate(t(Parser)),

    NgEventDirective: (t) => new NgEventDirective(t(Element), t(Scope)),
    NgADirective: (t) => new NgADirective(t(Element)),
    NgRepeatDirective: (t) => new NgRepeatDirective(t(ViewPort), t(BoundViewFactory), t(Scope), t(Parser), t(AstParser), t(FilterMap)),

    BounceController: (t) => new BounceController(t(Scope)),
    BallPositionDirective: (t) => new BallPositionDirective(t(Element), t(Scope)),
  };
  ngStaticApp(types, metadata, getters, setters)
    .addModule(new MyModule())
    .run();
}
