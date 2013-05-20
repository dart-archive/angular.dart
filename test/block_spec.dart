import "_specs.dart";

class LoggerBlockDirective {
  static String $name = 'foo';
  LoggerBlockDirective(BlockList list, Logger logger) {
    if (list == null) {
      throw new ArgumentError('BlockList must be injected.');
    }
    logger.add(list);
  }
}

main() {
  describe('Block', () {
    var anchor;
    var $rootElement;
    var $blockTypeFactory;
    var $blockListFactory;
    var logger;
    var blockCache;

    beforeEach(() {
      $rootElement = $('<div></div>');
      var injector = new Injector();
      $blockTypeFactory = injector.get(BlockTypeFactory);
      $blockListFactory = injector.get(BlockListFactory);
      logger = injector.get(Logger);
    });

    describe('mutation', () {
      var a, b;

      beforeEach(() {
        $rootElement.html('<!-- anchor -->');
        anchor = $blockListFactory($rootElement.contents().eq(0), {});
        a = $blockTypeFactory($('<span>A</span>a'), [])();
        b = $blockTypeFactory($('<span>B</span>b'), [])();
      });


      describe('insertAfter', () {
        it('should insert block after anchor block', () {
          a.insertAfter(anchor);

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(anchor);
        });


        it('should insert multi element block after another multi element block', () {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a<span>B</span>b');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(b);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(a);
        });


        it('should insert multi element block before another multi element block', () {
          b.insertAfter(anchor);
          a.insertAfter(anchor);

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a<span>B</span>b');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(b);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(a);
        });
      });


      describe('remove', () {
        beforeEach(() {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.text()).toEqual('AaBb');
        });

        it('should remove the last block', () {
          b.remove();
          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(null);
        });

        it('should remove child blocks from parent pseudo black', () {
          a.remove();
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(null);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(anchor);
        });

        it('should remove', () {
          a.remove();
          b.remove();

          // TODO(dart): I really want to do this:
          // class Directive {
          //   Directive(BlockList $anchor, Logger logger) {
          //     logger.add($anchor);
          //   }
          // }

          var innerBlockType = $blockTypeFactory($('<b>text</b>'), []);
          var outerBlockType = $blockTypeFactory($('<!--start--><!--end-->'), [
            0, [new DirectiveDef(
                new DirectiveFactory(LoggerBlockDirective),
                '', {'': innerBlockType})], null
          ]);

          var outterBlock = outerBlockType();
          var outterAnchor = logger[0];

          outterBlock.insertAfter(anchor);
          outterAnchor.newBlock().insertAfter(outterAnchor);

          expect($rootElement.text()).toEqual('text');

          outterBlock.remove();

          expect($rootElement.text()).toEqual('');
        });
      });


      describe('moveAfter', () {
        beforeEach(() {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.text()).toEqual('AaBb');
        });


        it('should move last to middle', () {
          b.moveAfter(anchor);
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b<span>A</span>a');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(b);
          expect(b.next).toBe(a);
          expect(b.previous).toBe(anchor);
        });


        it('should move middle to last', () {
          a.moveAfter(b);
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b<span>A</span>a');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(b);
          expect(b.next).toBe(a);
          expect(b.previous).toBe(anchor);
        });
      });
    });

    //TODO: tests for attach/detach
    //TODO: animation/transitions
    //TODO: tests for re-usability of blocks

  });
}
