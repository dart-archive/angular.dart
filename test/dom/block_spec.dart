library block_spec;

import '../_specs.dart';

@NgDirective(transclude: true, selector: 'foo')
class LoggerBlockDirective {
  LoggerBlockDirective(BlockHole hole, BlockFactory blockFactory,
      BoundBlockFactory boundBlockFactory, Logger logger) {
    if (hole == null) {
      throw new ArgumentError('BlockHole must be injected.');
    }
    if (boundBlockFactory == null) {
      throw new ArgumentError('BoundBlockFactory must be injected.');
    }
    if (blockFactory == null) {
      throw new ArgumentError('BlockFactory must be injected.');
    }
    logger.add(hole);
    logger.add(boundBlockFactory);
    logger.add(blockFactory);
  }
}

class ReplaceBlockDirective {
  ReplaceBlockDirective(BlockHole hole, BoundBlockFactory boundBlockFactory, Node node, Scope scope) {
    var block = boundBlockFactory(scope);
    block.insertAfter(hole);
    node.remove();
  }
}

class ShadowBlockDirective {
  ShadowBlockDirective(BlockHole hole, BoundBlockFactory boundBlockFactory, Element element, Scope scope) {
    var block = boundBlockFactory(scope);
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

      beforeEach(inject((Injector injector, Profiler perf) {
        $rootElement.html('<!-- anchor -->');
        anchor = new BlockHole($rootElement.contents().eq(0));
        a = (new BlockFactory($('<span>A</span>a'), [], perf))(injector);
        b = (new BlockFactory($('<span>B</span>b'), [], perf))(injector);
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

        it('should remove', inject((Logger logger, Injector injector, Profiler perf) {
          a.remove();
          b.remove();

          // TODO(dart): I really want to do this:
          // class Directive {
          //   Directive(BlockHole $anchor, Logger logger) {
          //     logger.add($anchor);
          //   }
          // }

          var innerBlockType = new BlockFactory($('<b>text</b>'), [], perf);
          var outerBlockType = new BlockFactory($('<!--start--><!--end-->'), [
            0, [new DirectiveRef(null,
                                 new Directive(LoggerBlockDirective),
                                 '',
                                 innerBlockType)], null
          ], perf);

          var outterBlock = outerBlockType(injector);
          // The LoggerBlockDirective caused a BlockHole for innerBlockType to
          // be created at logger[0];
          BlockHole outterAnchor = logger[0];
          BoundBlockFactory outterBoundBlockFactory = logger[1];

          outterBlock.insertAfter(anchor);
          // outterAnchor is a BlockHole, but it has "elements" set to the 0th element
          // of outerBlockType.  So, calling insertAfter() will insert the new
          // block after the <!--start--> element.
          outterBoundBlockFactory(null).insertAfter(outterAnchor);

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
