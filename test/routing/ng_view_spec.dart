library ng_view_spec;

import 'dart:html';
import '../_specs.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/mock/module.dart';

main() => describe('ngView', () {
  describe('Flat ngView', () {
    TestBed _;
    Router router;

    beforeEachModule((Module m) {
      m
        ..install(new AngularMockModule())
        ..bind(RouteInitializerFn, toImplementation: FlatRouteInitializer);
    });

    beforeEach((TestBed tb, Router _router, TemplateCache templates) {
      _ = tb;
      router = _router;

      templates.put('foo.html', new HttpResponse(200,
          '<h1 probe="p">Foo</h1>'));
      templates.put('bar.html', new HttpResponse(200,
          '<h1 probe="p">Bar</h1>'));
    });


    it('should switch template', async(() {
      Element root = _.compile('<ng-view></ng-view>');
      expect(root.text).toEqual('');

      router.route('/foo');
      microLeap();
      expect(root.text).toEqual('Foo');

      router.route('/bar');
      microLeap();
      expect(root.text).toEqual('Bar');

      router.route('/foo');
      microLeap();
      expect(root.text).toEqual('Foo');
    }));

    it('should expose NgView as RouteProvider', async(() {
      _.compile('<ng-view probe="m"></ng-view>');
      router.route('/foo');
      microLeap();
      _.rootScope.apply();
      Probe probe = _.rootScope.context['p'];

      expect(probe.injector.get(RouteProvider) is NgView).toBeTruthy();
    }));


    it('should switch template when route is already active', async(() {
      // Force the routing system to initialize.
      _.compile('<ng-view></ng-view>');

      router.route('/foo');
      microLeap();
      Element root = _.compile('<ng-view></ng-view>');
      expect(root.text).toEqual('');

      _.rootScope.apply();
      microLeap();
      expect(root.text).toEqual('Foo');
    }));


    it('should clear template when route is deactivated', async(() {
      Element root = _.compile('<ng-view></ng-view>');
      expect(root.text).toEqual('');

      router.route('/foo');
      microLeap();
      expect(root.text).toEqual('Foo');

      router.route('/baz'); // route without a template
      microLeap();
      expect(root.text).toEqual('');
    }));

  });


  describe('Nested ngView', () {
    TestBed _;
    Router router;

    beforeEachModule((Module m) {
      m
        ..install(new AngularMockModule())
        ..bind(RouteInitializerFn, toImplementation: NestedRouteInitializer);
    });

    beforeEach((TestBed tb, Router _router, TemplateCache templates) {
      _ = tb;
      router = _router;
      _.rootScope.context['flag'] = true;

      templates.put('library.html', new HttpResponse(200,
          '<div><h1>Library</h1>'
          '<ng-view ng-if="flag"></ng-view></div>'));
      templates.put('book_list.html', new HttpResponse(200,
          '<h1>Books</h1>'));
      templates.put('book_overview.html', new HttpResponse(200,
          '<h2>Book 1234</h2>'));
      templates.put('book_read.html', new HttpResponse(200,
         '<h2>Read Book 1234</h2>'));
      templates.put('alt.html', new HttpResponse(200, 'alt'));
    });

    it('should switch nested templates', async(() {
      Element root = _.compile('<ng-view></ng-view>');
      microLeap(); _.rootScope.apply(); microLeap();
      expect(root.text).toEqual('');

      router.route('/library/all');
      microLeap(); _.rootScope.apply(); microLeap();
      expect(root.text).toEqual('LibraryBooks');

      router.route('/library/1234');
      microLeap(); _.rootScope.apply(); microLeap();
      expect(root.text).toEqual('LibraryBook 1234');

      // nothing should change here
      router.route('/library/1234/overview');
      microLeap(); _.rootScope.apply(); microLeap();
      expect(root.text).toEqual('LibraryBook 1234');

      // nothing should change here
      router.route('/library/1234/read');
      microLeap(); _.rootScope.apply(); microLeap();
      expect(root.text).toEqual('LibraryRead Book 1234');
    }));

    it('should not attempt to destroy and already destroyed childscope', async(() {
      // This can happen with nested ng-views.  Refer
      // https://github.com/angular/angular.dart/issues/1182
      // and repro case
      // https://github.com/chirayuk/sample/tree/issue_1182_leaving_a_nested_ng_view
      Element root = _.compile('<ng-view></ng-view>');
      microLeap(); _.rootScope.apply(); microLeap();

      router.route('/library/1234');
      microLeap(); _.rootScope.apply(); microLeap();

      expect(root.text).toEqual('LibraryBook 1234');

      _.rootScope.context['flag'] = false;
      microLeap(); _.rootScope.apply(); microLeap();
      router.route('/alt');
      microLeap(); _.rootScope.apply(); microLeap();

      expect(root.text).toEqual('alt');
    }));
  });

  describe('Inline template ngView', () {
    TestBed _;
    Router router;

    beforeEachModule((Module m) {
      m
        ..install(new AngularMockModule())
        ..bind(RouteInitializerFn, toValue: (router, views) {
          views.configure({
            'foo': ngRoute(
                path: '/foo',
                viewHtml: '<h1>Hello</h1>')
          });
        });
    });

    beforeEach((TestBed tb, Router _router, TemplateCache templates) {
      _ = tb;
      router = _router;
    });

    it('should switch inline templates', async(() {
      Element root = _.compile('<ng-view></ng-view>');
      expect(root.text).toEqual('');

      router.route('/foo');
      microLeap();
      expect(root.text).toEqual('Hello');
    }));
  });
});

@Injectable()
class FlatRouteInitializer implements Function {
  void call(Router router, RouteViewFactory views) {
    views.configure({
        'foo': ngRoute(path: '/foo', view:'foo.html'),
        'bar': ngRoute(path: '/bar', view: 'bar.html'),
        'baz': ngRoute(path: '/baz'),
    });
  }
}

@Injectable()
class NestedRouteInitializer implements Function {
  void call(Router router, RouteViewFactory views) {
    views.configure({
      'library': ngRoute(
          path: '/library',
          view: 'library.html',
          mount: {
              'all': ngRoute(path: '/all', view: 'book_list.html'),
              'book': ngRoute(
                  path: '/:bookId',
                  mount: {
                      'overview': ngRoute(path: '/overview', view: 'book_overview.html',
                                          defaultRoute: true),
                      'read': ngRoute(path: '/read', view: 'book_read.html'),
                      'admin': ngRoute(path: '/admin', view: 'admin.html'),
                  })
          }),
      'alt': ngRoute(
          path: '/alt',
          view: 'alt.html'),
    });
  }
}
