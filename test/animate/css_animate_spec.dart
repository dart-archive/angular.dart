library css_animate_spec;

import 'dart:async';
import 'dart:js' as js;

import '../_specs.dart';

_run({bool animationsAllowed}) {
  describe('animationsAllowed=$animationsAllowed', () {
    TestBed _;
    Animate animate;
    MockAnimationLoop runner;

    beforeEach((TestBed tb, Expando expand) {
      _ = tb;
      runner = new MockAnimationLoop(animationsAllowed);
      animate = new CssAnimate(
          runner, new CssAnimationMap(), new AnimationOptimizer(expand));
      animate.animationsAllowed = animationsAllowed;
    });

    it('should add a css class to an element node', async(() {
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');

      animate.addClass(_.rootElement, 'foo');
      runner.frame();

      expect(_.rootElement).toHaveClass('foo');
    }));

    it('should remove a css class from an element node', async(() {
      _.compile('<div class="baz foo bar"></div>');
      expect(_.rootElement).toHaveClass('foo');

      animate.removeClass(_.rootElement, 'foo');
      runner.frame();
      expect(_.rootElement).not.toHaveClass('foo');
    }));

    it('should insert nodes', async(() {
      _.compile('<div></div>');
      expect(_.rootElement.children.length).toBe(0);

      animate.insert([new Element.div()], _.rootElement);
      expect(_.rootElement.children.length).toBe(1);
    }));

    it('should remove nodes', async(() {
      _.compile('<div><p>Hello World</p><!--comment--></div>');
      expect(_.rootElement.childNodes.length).toBe(2);

      animate.remove(_.rootElement.childNodes);
      runner.frame();
      // This might lead to a flash of unstyled content before
      // removal. It would be nice if this was un-needed.
      microLeap();
      expect(_.rootElement.childNodes.length).toBe(0);
    }));

    it('should move nodes', async(() {
      _.compile('<div></div>');
      List<Node> a = es('<span>A</span>a');
      List<Node> b = es('<span>B</span>b');
      a.forEach((n) => _.rootElement.append(n));
      b.forEach((n) => _.rootElement.append(n));
      expect(_.rootElement.text).toEqual("AaBb");

      animate.move(b, _.rootElement, insertBefore: a.first);
      runner.frame();
      expect(_.rootElement.text).toEqual("BbAa");

      animate.move(a, _.rootElement, insertBefore: b.first);
      runner.frame();
      expect(_.rootElement.text).toEqual("AaBb");

      animate.move(a, _.rootElement);
      runner.frame();
      expect(_.rootElement.text).toEqual("BbAa");
    }));

    it('should animate multiple elements', async(() {
      _.compile('<div></div>');
      List<Node> nodes = es('<span>A</span>a<span>B</span>b');

      animate.insert(nodes, _.rootElement);
      runner.frame();
      expect(_.rootElement.text).toEqual("AaBb");
    }));

    it('should prevent child animations', async(() {
      _.compile('<div></div>');
      animate.addClass(_.rootElement, 'test');
      if (animationsAllowed) {
        expect(_.rootElement).toHaveClass('test-add');
      }
      var spans = es('<span>A</span><span>B</span>');
      animate.insert(spans, _.rootElement);
      expect(spans.first).not.toHaveClass('ng-add');
    }));
  });
}

class MockAnimationLoop implements AnimationLoop {
  bool animationsAllowed;
  num time = 0.0;

  MockAnimationLoop(this.animationsAllowed);

  Future<AnimationResult> get onCompleted {
    var cmp = new Completer<AnimationResult>();
    cmp.complete(AnimationResult.COMPLETED);
    return cmp.future;
  }

  List<LoopedAnimation> animations = [];

  void play(LoopedAnimation animation) {
    animations.add(animation);
  }

  void frame() {
    for (var animation in animations) {
      animation.read(time);
    }

    for (var animation in animations) {
      animation.update(time);
    }

    time += 16.0;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

main() {
  describe('CssAnimate', () {
    _run(animationsAllowed: true);
    if (!identical(1, 1.0) &&
        js.context['DART_VERSION'].toString().contains("version: 1.5.")) {
      // Remove this block when issue #1219 is fixed.
      // In Dart 1.5's Dartium, running both describes in any order causes
      // ng_model_spec to fails.  This is not the case in Dart 1.4 or Dart 1.6.
      return;
    }
    _run(animationsAllowed: false);
  });
}
