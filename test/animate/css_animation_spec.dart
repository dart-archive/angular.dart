library css_animation_spec;

import '../_specs.dart';

main() {
  ddescribe('CssAnimation', () {
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
      
      animation.start(new DateTime.now(), 0.0);
      expect(_.rootElement).toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.update(new DateTime.now(), 0.0);
      expect(_.rootElement).toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.detach(new DateTime.now(), 0.0);
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should add the cssClassToAdd', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToAdd: 'magic');
      animation.attach();
      expect(_.rootElement).not.toHaveClass('magic');

      animation.start(new DateTime.now(), 0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      animation.update(new DateTime.now(), 0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      animation.detach(new DateTime.now(), 0.0);
      expect(_.rootElement).toHaveClass('magic');

      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    
    it('should remove the cssClassToRemove', async(() {
      _.compile("<div class=\"magic\"></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToRemove: 'magic');

      expect(_.rootElement).toHaveClass('magic');

      animation.attach();
      expect(_.rootElement).toHaveClass('magic');

      animation.start(new DateTime.now(), 0.0);
      expect(_.rootElement).toHaveClass('magic');

      animation.update(new DateTime.now(), 0.0);
      expect(_.rootElement).toHaveClass('magic');

      animation.detach(new DateTime.now(), 0.0);
      expect(_.rootElement).not.toHaveClass('magic');

      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after attach', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToAdd: 'magic');
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
          cssClassToAdd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(new DateTime.now(), 0.0);

      animation.interruptAndCancel();
      expect(_.rootElement).not.toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after update', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToAdd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(new DateTime.now(), 0.0);
      animation.update(new DateTime.now(), 0.0);

      animation.interruptAndCancel();
      expect(_.rootElement).not.toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    
    it('should clean up event classes when forcibly completed after attach', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToAdd: 'magic');
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
          cssClassToAdd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(new DateTime.now(), 0.0);

      animation.interruptAndComplete();
      expect(_.rootElement).toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when forcibly completed after update', async(() {
      _.compile("<div></div>");

      var animation = new CssAnimation(_.rootElement, "event", "event-active",
          cssClassToAdd: 'magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
      
      animation.attach();
      animation.start(new DateTime.now(), 0.0);
      animation.update(new DateTime.now(), 0.0);

      animation.interruptAndComplete();
      expect(_.rootElement).toHaveClass('magic');
      expect(_.rootElement).not.toHaveClass('event');
      expect(_.rootElement).not.toHaveClass('event-active');
    }));
  });
}

