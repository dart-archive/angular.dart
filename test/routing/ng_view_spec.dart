library ng_view_spec;

import 'dart:html';
import '../_specs.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/mock/module.dart';

main() {
  describe('Flat ngView', () {
    TestBed _;
    Router router;

    beforeEach(module((Module m) {
      m
        ..install(new AngularMockModule())
        ..type(RouteInitializerFn, implementedBy: FlatRouteInitializer);
    }));

    beforeEach(inject((TestBed tb, Router _router, TemplateCache templates) {
      _ = tb;
      router = _router;

      templates.put('foo.html', new HttpResponse(200,
          '<h1>Foo</h1>'));
      templates.put('bar.html', new HttpResponse(200,
          '<h1>Bar</h1>'));
    }));


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

    beforeEach(module((Module m) {
      m
        ..install(new AngularMockModule())
        ..type(RouteInitializerFn, implementedBy: NestedRouteInitializer);
    }));

    beforeEach(inject((TestBed tb, Router _router, TemplateCache templates) {
      _ = tb;
      router = _router;

      templates.put('library.html', new HttpResponse(200,
          '<div><h1>Library</h1>'
          '<ng-view></ng-view></div>'));
      templates.put('book_list.html', new HttpResponse(200,
          '<h1>Books</h1>'));
      templates.put('book_overview.html', new HttpResponse(200,
          '<h2>Book 1234</h2>'));
      templates.put('book_read.html', new HttpResponse(200,
         '<h2>Read Book 1234</h2>'));
    }));

    // This test is disable on dart2js because it is flaky
    // on dart v1.2. Kasper is looking into it. In the
    // meantime we are disabling it.
    if (!identical(1, 1.0)) {
      it('should switch nested templates', async(() {
        Element root = _.compile('<ng-view></ng-view>');
        expect(root.text).toEqual('');

        router.route('/library/all');
        microLeap();
        expect(root.text).toEqual('LibraryBooks');

        router.route('/library/1234');
        microLeap();
        expect(root.text).toEqual('LibraryBook 1234');

        // nothing should change here
        router.route('/library/1234/overview');
        microLeap();
        expect(root.text).toEqual('LibraryBook 1234');

        // nothing should change here
        router.route('/library/1234/read');
        microLeap();
        expect(root.text).toEqual('LibraryRead Book 1234');
      }));
    }
  });
}

class FlatRouteInitializer implements Function {
  void call(Router router, RouteViewFactory view) {
    router.root
      ..addRoute(
          name: 'foo',
          path: '/foo',
          enter: view('foo.html'))
      ..addRoute(
          name: 'bar',
          path: '/bar',
          enter: view('bar.html'))
      ..addRoute(
          name: 'baz',
          path: '/baz'); // route without a template
  }
}

class NestedRouteInitializer implements Function {
  void call(Router router, RouteViewFactory view) {
    router.root
      ..addRoute(
          name: 'library',
          path: '/library',
          enter: view('library.html'),
          mount: (Route route) => route
            ..addRoute(
                name: 'all',
                path: '/all',
                enter: view('book_list.html'))
            ..addRoute(
                name: 'book',
                path: '/:bookId',
                mount: (Route route) => route
                  ..addRoute(
                      name: 'overview',
                      path: '/overview',
                      defaultRoute: true,
                      enter: view('book_overview.html'))
                  ..addRoute(
                      name: 'read',
                      path: '/read',
                      enter: view('book_read.html'))))
                  ..addRoute(
                      name: 'admin',
                      path: '/admin',
                      enter: view('admin.html'));
  }
}
