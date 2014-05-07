library view_spec;

import '../_specs.dart';
import 'package:angular/application_factory.dart';

class Log {
  List<String> log = <String>[];

  add(String msg) => log.add(msg);
}

@Decorator(children: Directive.TRANSCLUDE_CHILDREN, selector: 'foo')
class LoggerViewDirective {
  LoggerViewDirective(ViewPort port, ViewFactory viewFactory,
      BoundViewFactory boundViewFactory, Logger logger) {
    assert(port != null);
    assert(viewFactory != null);
    assert(boundViewFactory != null);

    logger.add(port);
    logger.add(boundViewFactory);
    logger.add(viewFactory);
  }
}

@Decorator(selector: 'dir-a')
class ADirective {
  ADirective(Log log) {
    log.add('ADirective');
  }
}

@Decorator(selector: 'dir-b')
class BDirective {
  BDirective(Log log) {
    log.add('BDirective');
  }
}

@Formatter(name:'formatterA')
class AFormatter {
  Log log;

  AFormatter(this.log) {
    log.add('AFormatter');
  }

  call(value) => value;
}

@Formatter(name:'formatterB')
class BFormatter {
  Log log;

  BFormatter(this.log) {
    log.add('BFormatter');
  }

  call(value) => value;
}


main() {
  var viewFactoryFactory = (a,b,c,d) => new WalkingViewFactory(a,b,c,d);
  describe('View', () {
    var anchor;
    Element rootElement;
    var viewCache;

    beforeEach(() {
      rootElement = e('<div></div>');
    });

    describe('mutation', () {
      var a, b;
      var expando = new Expando();

      beforeEach((Injector injector, Profiler perf) {
        rootElement.innerHtml = '<!-- anchor -->';
        anchor = new ViewPort(rootElement.childNodes[0],
          injector.get(Animate));
        a = (viewFactoryFactory(es('<span>A</span>a'), [], perf, expando))(injector);
        b = (viewFactoryFactory(es('<span>B</span>b'), [], perf, expando))(injector);
      });


      describe('insertAfter', () {
        it('should insert block after anchor view', () {
          anchor.insert(a);

          expect(rootElement).toHaveHtml('<!-- anchor --><span>A</span>a');
        });


        it('should insert multi element view after another multi element view', () {
          anchor.insert(a);
          anchor.insert(b, insertAfter: a);

          expect(rootElement).toHaveHtml('<!-- anchor --><span>A</span>a<span>B</span>b');
        });


        it('should insert multi element view before another multi element view', () {
          anchor.insert(b);
          anchor.insert(a);

          expect(rootElement).toHaveHtml('<!-- anchor --><span>A</span>a<span>B</span>b');
        });
      });


      describe('remove', () {
        beforeEach(() {
          anchor.insert(a);
          anchor.insert(b, insertAfter: a);

          expect(rootElement.text).toEqual('AaBb');
        });

        it('should remove the last view', () {
          anchor.remove(b);
          expect(rootElement).toHaveHtml('<!-- anchor --><span>A</span>a');
        });

        it('should remove child views from parent pseudo black', () {
          anchor.remove(a);
          expect(rootElement).toHaveHtml('<!-- anchor --><span>B</span>b');
        });

        // TODO(deboer): Make this work again.
        /*
        xit('should remove', (Logger logger, Injector injector, Profiler perf, ElementBinderFactory ebf) {
          anchor.remove(a);
          anchor.remove(b);

          // TODO(dart): I really want to do this:
          // class Directive {
          //   Directive(ViewPort $anchor, Logger logger) {
          //     logger.add($anchor);
          //   }
          // }

          var directiveRef = new DirectiveRef(null,
                                              LoggerViewDirective,
                                              new Decorator(children: Directive.TRANSCLUDE_CHILDREN, selector: 'foo'),
                                              '');
          directiveRef.viewFactory = viewFactoryFactory($('<b>text</b>'), [], perf, new Expando());
          var binder = ebf.binder();
          binder.setTemplateInfo(0, [ directiveRef ]);
          var outerViewType = viewFactoryFactory(
              $('<!--start--><!--end-->'),
              [binder],
              perf,
              new Expando());

          var outerView = outerViewType(injector);
          // The LoggerViewDirective caused a ViewPort for innerViewType to
          // be created at logger[0];
          ViewPort outerAnchor = logger[0];
          BoundViewFactory outterBoundViewFactory = logger[1];

          anchor.insert(outerView);
          // outterAnchor is a ViewPort, but it has "elements" set to the 0th element
          // of outerViewType.  So, calling insertAfter() will insert the new
          // view after the <!--start--> element.
          outerAnchor.insert(outterBoundViewFactory(null));

          expect(rootElement.text).toEqual('text');

          anchor.remove(outerView);

          expect(rootElement.text).toEqual('');
        });
        */
      });


      describe('moveAfter', () {
        beforeEach(() {
          anchor.insert(a);
          anchor.insert(b, insertAfter: a);

          expect(rootElement.text).toEqual('AaBb');
        });


        it('should move last to middle', () {
          anchor.move(a, moveAfter: b);
          expect(rootElement).toHaveHtml('<!-- anchor --><span>B</span>b<span>A</span>a');
        });
      });
    });

    describe('deferred', () {

      it('should load directives/formatters from the child injector', () {
        Module rootModule = new Module()
          ..bind(Probe)
          ..bind(Log)
          ..bind(AFormatter)
          ..bind(ADirective)
          ..bind(Node, toFactory: (injector) => document.body);

        Injector rootInjector = applicationFactory()
            .addModule(rootModule)
            .createInjector();
        Log log = rootInjector.get(Log);
        Scope rootScope = rootInjector.get(Scope);

        Compiler compiler = rootInjector.get(Compiler);
        DirectiveMap directives = rootInjector.get(DirectiveMap);
        compiler(es('<dir-a>{{\'a\' | formatterA}}</dir-a><dir-b></dir-b>'), directives)(rootInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFormatter']));


        Module childModule = new Module()
          ..bind(BFormatter)
          ..bind(BDirective);

        var childInjector = forceNewDirectivesAndFormatters(rootInjector, [childModule]);

        DirectiveMap newDirectives = childInjector.get(DirectiveMap);
        compiler(es('<dir-a probe="dirA"></dir-a>{{\'a\' | formatterA}}'
            '<dir-b probe="dirB"></dir-b>{{\'b\' | formatterB}}'), newDirectives)(childInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFormatter', 'ADirective', 'BDirective', 'BFormatter']));
      });

    });

    //TODO: tests for attach/detach
    //TODO: animation/transitions
    //TODO: tests for re-usability of views

  });
}
