library css_animation_spec;

import '../_specs.dart';

main() {
  describe('CssAnimation', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));
    afterEach(() => _.rootElements.forEach((e) => e.remove()));
    
    it('should correctly respond to an animation lifecycle', async(() {
      _.compile("<style>.event { transition: all 500ms; }</style>"
          +"<div class='always remove-start remove-end'></div>");
      
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];

      expect(element).toHaveClass('always');
      expect(element).toHaveClass('remove-start');
      expect(element).toHaveClass('remove-end');
      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
      expect(element).not.toHaveClass('add-start');
      expect(element).not.toHaveClass('add-end');
      
      var animation = new CssAnimation(element,
          "event",
          "event-active",
          addAtStart: "add-start",
          removeAtStart: "remove-start",
          addAtEnd: "add-end",
          removeAtEnd: "remove-end");
      
      expect(element).toHaveClass('always');
      expect(element).not.toHaveClass('remove-start');
      expect(element).toHaveClass('remove-end');
      expect(element).toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
      expect(element).toHaveClass('add-start');
      expect(element).not.toHaveClass('add-end');
      
      animation.read(0.0);
      animation.update(0.0);
      
      expect(element).toHaveClass('always');
      expect(element).not.toHaveClass('remove-start');
      expect(element).toHaveClass('remove-end');
      expect(element).toHaveClass('event');
      expect(element).toHaveClass('event-active');
      expect(element).toHaveClass('add-start');
      expect(element).not.toHaveClass('add-end');
      
      animation.read(1000.0);
      animation.update(1000.0);

      expect(element).toHaveClass('always');
      expect(element).not.toHaveClass('remove-start');
      expect(element).not.toHaveClass('remove-end');
      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
      expect(element).toHaveClass('add-start');
      expect(element).toHaveClass('add-end');
      
      _.rootElements.forEach((e) => e.remove());
    }));
    
    it('should swap removeAtEnd class if initial style is display none', async(() {
      _.compile("<style>.event { transition: all 500ms; display: none; }</style>"
          "<div class='remove-at-end'></div>");
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];

      var animation = new CssAnimation(element, "event", "event-active",
          removeAtEnd: 'remove-at-end', addAtEnd: 'add-at-end');
      
      expect(element).toHaveClass('remove-at-end');

      animation.read(0.0);
      animation.update(0.0);
      expect(element).not.toHaveClass('remove-at-end');
      expect(element).not.toHaveClass('add-at-end');

      animation.read(1000.0);
      animation.update(1000.0);
      expect(element).toHaveClass('add-at-end');
      expect(element).not.toHaveClass('remove-at-end');
    }));
    
    it('should add classes at end', async(() {
      _.compile("<style>.event { transition: all 500ms; }</style><div></div>");
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];

      var animation = new CssAnimation(element, "event", "event-active",
          addAtEnd: 'add-at-end');

      animation.read(0.0);
      animation.update(0.0);
      expect(element).not.toHaveClass('add-at-end');

      animation.read(1000.0);
      animation.update(1000.0);
      expect(element).toHaveClass('add-at-end');
      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
    }));

    it('should remove the cssClassToRemove', async(() {
      _.compile("<style>.event { transition: all 500ms; }</style>"
          +"<div class=\"remove-end\"></div>");
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];

      var animation = new CssAnimation(element, "event", "event-active",
          removeAtEnd: 'magic');

      animation.complete();
      expect(element).not.toHaveClass('magic');

      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after read', async(() {
      _.compile("<style>.event { transition: all 500ms; }</style><div></div>");
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];
      var animation = new CssAnimation(element, "event", "event-active",
          addAtEnd: 'magic');

      animation.read(0.0);
      animation.cancel();
      expect(element).not.toHaveClass('magic');
      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
    }));
    
    it('should clean up event classes when canceled after update', async(() {
      _.compile("<style>.event { transition: all 500ms; }</style><div></div>");
      _.rootElements.forEach((e) => document.body.append(e));
      var element = _.rootElements[1];

      var animation = new CssAnimation(element, "event", "event-active",
          addAtEnd: 'add-end');

      animation.read(0.0);
      animation.update(0.0);
      animation.cancel();
      expect(element).not.toHaveClass('add-end');
      expect(element).not.toHaveClass('event');
      expect(element).not.toHaveClass('event-active');
    }));
  });
}

