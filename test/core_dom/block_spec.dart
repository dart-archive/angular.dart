library block_spec;

import '../_specs.dart';

class Log {
  List<String> log = <String>[];

  add(String msg) => log.add(msg);
}

@NgDirective(children: NgAnnotation.TRANSCLUDE_CHILDREN, selector: 'foo')
class LoggerBlockDirective {
  LoggerBlockDirective(BlockHole hole, BlockFactory blockFactory,
      BoundBlockFactory boundBlockFactory, Logger logger) {
    assert(hole != null);
    assert(blockFactory != null);
    assert(boundBlockFactory != null);

    logger.add(hole);
    logger.add(boundBlockFactory);
    logger.add(blockFactory);
  }
}

@NgDirective(selector: 'dir-a')
class ADirective {
  ADirective(Log log) {
    log.add('ADirective');
  }
}

@NgDirective(selector: 'dir-b')
class BDirective {
  BDirective(Log log) {
    log.add('BDirective');
  }
}

@NgFilter(name:'filterA')
class AFilter {
  Log log;

  AFilter(this.log) {
    log.add('AFilter');
  }

  call(value) => value;
}

@NgFilter(name:'filterB')
class BFilter {
  Log log;

  BFilter(this.log) {
    log.add('BFilter');
  }

  call(value) => value;
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
      var expando = new Expando();

      beforeEach(inject((Injector injector, Profiler perf) {
        $rootElement.html('<!-- anchor -->');
        anchor = new BlockHole($rootElement.contents().eq(0));
        a = (new BlockFactory($('<span>A</span>a'), [], perf, expando))(injector);
        b = (new BlockFactory($('<span>B</span>b'), [], perf, expando))(injector);
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

          var directiveRef = new DirectiveRef(null,
                                              LoggerBlockDirective,
                                              new NgDirective(children: NgAnnotation.TRANSCLUDE_CHILDREN, selector: 'foo'),
                                              '');
          directiveRef.blockFactory = new BlockFactory($('<b>text</b>'), [], perf, new Expando());
          var outerBlockType = new BlockFactory(
              $('<!--start--><!--end-->'),
              [ 0, [ directiveRef ], null],
              perf,
              new Expando());

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

    describe('deferred', () {

      it('should load directives/filters from the child injector', () {
        Module rootModule = new Module()
          ..type(Probe)
          ..type(Log)
          ..type(AFilter)
          ..type(ADirective);

        Injector rootInjector =
            new DynamicInjector(modules: [new AngularModule(), rootModule]);
        Log log = rootInjector.get(Log);
        Scope rootScope = rootInjector.get(Scope);

        Compiler compiler = rootInjector.get(Compiler);
        DirectiveMap directives = rootInjector.get(DirectiveMap);
        compiler(es('<dir-a>{{\'a\' | filterA}}</dir-a><dir-b></dir-b>'), directives)(rootInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFilter']));


        Module childModule = new Module()
          ..type(BFilter)
          ..type(BDirective);

        var childInjector = forceNewDirectivesAndFilters(rootInjector, [childModule]);

        DirectiveMap newDirectives = childInjector.get(DirectiveMap);
        compiler(es('<dir-a probe="dirA"></dir-a>{{\'a\' | filterA}}'
            '<dir-b probe="dirB"></dir-b>{{\'b\' | filterB}}'), newDirectives)(childInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFilter', 'ADirective', 'BDirective', 'BFilter']));
      });

    });

    //TODO: tests for attach/detach
    //TODO: animation/transitions
    //TODO: tests for re-usability of blocks

  });
}
