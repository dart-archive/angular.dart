import "_specs.dart";

@NgDirective(transclude: '.', selector: 'foo')
class LoggerBlockDirective {
  LoggerBlockDirective(BlockList list, Logger logger) {
    if (list == null) {
      throw new ArgumentError('BlockList must be injected.');
    }
    logger.add(list);
  }
}

class ReplaceBlockDirective {
  ReplaceBlockDirective(BlockList list, Node node, Scope scope) {
    var block = list.newBlock(scope);
    block.insertAfter(list);
    node.remove();
  }
}

class ShadowBlockDirective {
  ShadowBlockDirective(BlockList list, Element element, Scope scope) {
    var block = list.newBlock(scope);
    var shadowRoot = element.createShadowRoot();
    for (var i = 0, ii = block.elements.length; i < ii; i++) {
      shadowRoot.append(block.elements[i]);
    }
  }
}

main() {
  describe('Block', () {
    var anchor;
    var $rootElement;
    var blockCache;

    beforeEach(() {
      $rootElement = $('<div></div>');
    });

    describe('mutation', () {
      var a, b;

      beforeEach(inject((BlockTypeFactory $blockTypeFactory, Injector injector) {
        $rootElement.html('<!-- anchor -->');
        anchor = new BlockList($rootElement.contents().eq(0), {}, injector);
        a = $blockTypeFactory($('<span>A</span>a'), [])(injector);
        b = $blockTypeFactory($('<span>B</span>b'), [])(injector);
      }));


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


      xdescribe('replace', () {
        it('should allow directives to remove elements', inject((BlockTypeFactory $blockTypeFactory) {
          var innerBlockType = $blockTypeFactory($('<b>text</b>'), []);
          var outerBlockType = $blockTypeFactory($('<div>TO BE REPLACED</div><div>:ok</div>'), [
              0, [new DirectiveRef(null, null, '', '',
                                   new Directive(ReplaceBlockDirective),
                                   {'': innerBlockType})], null
          ]);

          var outerBlock = outerBlockType();
          outerBlock.insertAfter(anchor);
          expect($rootElement.text()).toEqual('text:ok');
        }));

        it('should allow directives to create shadow DOM', inject((BlockTypeFactory $blockTypeFactory) {
          var innerBlockType = $blockTypeFactory($('<b>shadow</b>'), []);
          var outerBlockType = $blockTypeFactory($('<x-shadowy>boo</x-shadowy><div>:ok</div>'), [
              0, [new DirectiveRef(null, null, '', '',
                                   new Directive(ShadowBlockDirective),
                                   {'': innerBlockType})], null
          ]);

          var outerBlock = outerBlockType();
          outerBlock.insertAfter(anchor);
          expect($rootElement.text()).toEqual('boo:ok');
          expect(renderedText($rootElement)).toEqual('shadow:ok');

        }));
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

        it('should remove', inject((BlockTypeFactory $blockTypeFactory, Logger logger, Injector injector) {
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
            0, [new DirectiveRef(null, null, '', '',
                                 new Directive(LoggerBlockDirective),
                                 {'': innerBlockType})], null
          ]);

          var outterBlock = outerBlockType(injector);
          // The LoggerBlockDirective caused a BlockList for innerBlockType to
          // be created at logger[0];
          BlockList outterAnchor = logger[0];

          outterBlock.insertAfter(anchor);
          // outterAnchor is a BlockList, but it has "elements" set to the 0th element
          // of outerBlockType.  So, calling insertAfter() will insert the new
          // block after the <!--start--> element.
          outterAnchor.newBlock(null).insertAfter(outterAnchor);

          expect($rootElement.text()).toEqual('text');

          outterBlock.remove();

          expect($rootElement.text()).toEqual('');
        }));
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
