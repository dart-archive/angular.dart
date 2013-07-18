import "_specs.dart";
import "dart:async";

main() {
  describe('renderedText', () {
    it('should work on regular DOM nodes', () {
      expect(renderedText($('<span>A<span>C</span></span><span>B</span>'))).toEqual('ACB');
    });

    it('should work with shadow DOM', () {
      var elt = $('<div>DOM content</div>');
      var shadow = elt[0].createShadowRoot();
      shadow.innerHtml = '<div>Shadow content</div><content>SHADOW-CONTENT</content>';
      expect(renderedText(elt)).toEqual('Shadow contentDOM content');
    });

    it('should ignore comments', () {
      expect(renderedText($('<!--e--><span>A<span>C</span></span><span>B</span>'))).toEqual('ACB');
    });
  });


  describe('jquery', () {
    describe('html', () {
      it('get', (){
        var div = $('<div>');
        expect(div.html()).toEqual('');
      });

      it('set', (){
        var div = $('<div>');
        expect(div.html('text')).toBe(div);
        expect(div.html()).toEqual('text');
      });
    });
  });

  describe('async', () {
    it('should run synchronous code', () {
      var ran = false;
      async(() { ran = true; })();
      expect(ran).toBe(true);
    });


    it('should run async code', () {
      var ran = false;
      var thenRan = false;
      async(() {
        new Future.value('s').then((_) { thenRan = true; });
        expect(thenRan).toBe(false);
        nextTurn();
        expect(thenRan).toBe(true);
        ran = true;
      })();
      expect(ran).toBe(true);
    });


    it('should run chained thens', () {
      var log = [];
      async(() {
        new Future.value('s')
            .then((_) { log.add('firstThen'); })
            .then((_) { log.add('2ndThen'); });
        expect(log.join(' ')).toEqual('');
        nextTurn();
        expect(log.join(' ')).toEqual('firstThen 2ndThen');
      })();
    });


    it('shold run futures created in futures', () {
      var log = [];
      async(() {
        new Future.value('s')
        .then((_) {
          log.add('firstThen');
          new Future.value('t').then((_) {
            log.add('2ndThen');
          });
        });
        expect(log.join(' ')).toEqual('');
        nextTurn();
        expect(log.join(' ')).toEqual('firstThen');
        nextTurn();
        expect(log.join(' ')).toEqual('firstThen 2ndThen');
      })();
    });


    it('should complain if you dangle callbacks', () {
      expect(() {
        async(() {
          new Future.value("s").then((_) {});
        })();
      }).toThrow();
    });


    it('should complain if the test throws an exception', () {
      expect(() {
        async(() {
          throw "blah";
        })();
      }).toThrow("blah");
    });
  });
}
