library css_animation_spec;

import 'dart:async';

import '../_specs.dart';

main() {
  describe('CssAnimate', () {
    TestBed _;
    NgAnimate animate;
    MockAnimationRunner runner;

    beforeEach(inject((TestBed tb) {
      _ = tb;
      runner = new MockAnimationRunner();
      animate = new CssAnimate(runner, new NoAnimate());
    }));

    it('should add a css class to an element node', async(() {
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');
      
      animate.addClass(_.rootElements, 'foo');
      runner.doEverything();
      expect(_.rootElement).toHaveClass('foo');
    }));
    
    it('should remove a css class from an element node', async(() {
      _.compile('<div class="baz foo bar"></div>');
      expect(_.rootElement).toHaveClass('foo');

      animate.removeClass(_.rootElements, 'foo');
      runner.doEverything();
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
      runner.doEverything();
      // This might lead to a flash of unstyled content before
      // removal. It would be nice if this was un-needed.
      microLeap();
      expect(_.rootElement.childNodes.length).toBe(0);
    }));
    
    it('should move nodes', async(() {
      _.compile('<div></div>');
      List<Node> a = $('<span>A</span>a').toList();
      List<Node> b = $('<span>B</span>b').toList();
      a.forEach((n) => _.rootElement.append(n));
      b.forEach((n) => _.rootElement.append(n));
      expect(_.rootElement.text).toEqual("AaBb");

      animate.move(b, _.rootElement, insertBefore: a.first);
      runner.doEverything();
      expect(_.rootElement.text).toEqual("BbAa");
            
      animate.move(a, _.rootElement, insertBefore: b.first);
      runner.doEverything();
      expect(_.rootElement.text).toEqual("AaBb");
            
      animate.move(a, _.rootElement);
      runner.doEverything();
      expect(_.rootElement.text).toEqual("BbAa");
    }));

    
    it('should animate multiple elements', async(() {
      _.compile('<div></div>');
      List<Node> nodes = $('<span>A</span>a<span>B</span>b').toList();

      animate.insert(nodes, _.rootElement);
      runner.doEverything();
      expect(_.rootElement.text).toEqual("AaBb");
    }));
    
    it('should prevent child animations', async(() {
      _.compile('<div></div>');
      animate.addClass(_.rootElements, 'test');
      runner.start();
      expect(_.rootElement).toHaveClass('test-add');
      var spans = $('<span>A</span><span>B</span>');
      animate.insert(spans, _.rootElement);
      runner.start();
      expect(spans.first).not.toHaveClass('ng-add');
    }));
    
    it('should play any Animation', async(() {
      var mockAnimation = new MockAnimation();
      animate.play([mockAnimation, mockAnimation]);
      expect(runner.animation).toBe(mockAnimation);
    }));
  });
}

class MockAnimation extends Mock implements Animation {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAnimationRunner extends Mock implements AnimationRunner {
  bool hasRunningParentAnimationValue = false;
  DateTime now = new DateTime.now();
  Animation animation;
  
  AnimationHandle play(Animation animation) {
    this.animation = animation;
    animation.attach();
    return new MockAnimationHandle();
  }
  
  doEverything() {
    start();
    update();
    detach();
  }
  
  start([num offset = 0]) {
    animation.start(offset);
  }
  
  update([num offset = 0]) {
    animation.update(offset);
  }
  
  read([num offset = 0]) {
    animation.read(offset);
  }
  
  detach([num offset = 0]) {
    animation.detach(offset);
  }
  
  bool hasRunningParentAnimation(Element element) {
    return hasRunningParentAnimationValue;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAnimationHandle extends Mock implements AnimationHandle {
  Future<AnimationResult> get onCompleted {
    var cmp = new Completer<AnimationResult>();
    cmp.complete(AnimationResult.COMPLETED);
    return cmp.future;
  }
  
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}