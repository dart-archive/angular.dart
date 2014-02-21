library css_animation_spec;

import '../_specs.dart';

main() {
  describe('CssAnimation', () {
    TestBed _;
    beforeEach(inject((TestBed tb) => _ = tb));
    
    it('should correctly respond to an animation lifecycle', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active");
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      expect(_.rootElement).toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.start(0.0);
      expect(_.rootElement).toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.update(1000.0);
      expect(_.rootElement).toHaveClass('event');
      expect(_.rootElement).toHaveClass('event-active');
      
      animation.detach(1000.0);
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should add the cssClassToAdd', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      animation.attach();
      expect(_.rootElement).not.toHaveClass('magic');

      animation.start(0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      animation.update(0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      animation.detach(0.0);
      expect(_.rootElement).toHaveClass('magic');

      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    
    it('should remove the cssClassToRemove', async(() {
      _.compile("<div class=\"magic\"></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          removeAtEnd: 'magic');

      expect(_.rootElement).toHaveClass('magic');

      animation.attach();
      expect(_.rootElement).toHaveClass('magic');

      animation.start(0.0);
      expect(_.rootElement).toHaveClass('magic');

      animation.update(0.0);
      expect(_.rootElement).toHaveClass('magic');

      animation.detach(0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after attach', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.interruptAndCancel();
      expect(_.rootElement).not.toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after start', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(0.0);

      animation.interruptAndCancel();
      expect(_.rootElement).not.toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after update', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(0.0);
      animation.update(0.0);

      animation.interruptAndCancel();
      expect(_.rootElement).not.toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    
    it('should clean up event classes when forcibly completed after attach', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.interruptAndComplete();
      expect(_.rootElement).toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when forcibly completed after start', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(0.0);

      animation.interruptAndComplete();
      expect(_.rootElement).toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when forcibly completed after update', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          addAtEnd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(0.0);
      animation.update(0.0);

      animation.interruptAndComplete();
      expect(_.rootElement).toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
  });
}

