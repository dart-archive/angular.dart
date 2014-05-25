library ng_bind_route_spec;

import 'dart:html';
import '../_specs.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/mock/module.dart';

main() {
  describe('ngBindRoute', () {
    TestBed _;

    beforeEachModule((Module m) => m
      ..install(new AngularMockModule())
      ..bind(RouteInitializerFn, toImplementation: NestedRouteInitializer));

    beforeEach((TestBed tb) {
      _ = tb;
    });


    it('should inject null RouteProvider when no ng-bind-route', async(() {
      Element root = _.compile('<div probe="routeProbe"></div>');
      expect(_.rootScope.context['routeProbe'].injector.get(RouteProvider)).toBeNull();
    }));


    it('should inject RouteProvider with correct flat route', async(() {
      Element root = _.compile(
          '<div ng-bind-route="library"><div probe="routeProbe"></div></div>');
      expect(_.rootScope.context['routeProbe'].injector.get(RouteProvider).routeName)
          .toEqual('library');
    }));


    it('should inject RouteProvider with correct nested route', async(() {
      Element root = _.compile(
          '<div ng-bind-route="library">'
          '  <div ng-bind-route=".all">'
          '    <div probe="routeProbe"></div>'
          '  </div>'
          '</div>');
      expect(_.rootScope.context['routeProbe'].injector.get(RouteProvider).route.name)
          .toEqual('all');
    }));

    it('should expose NgBindRoute as RouteProvider', async(() {
      Element root = _.compile(
          '<div ng-bind-route="library"><div probe="routeProbe"></div></div>');
      expect(_.rootScope.context['routeProbe'].injector.get(RouteProvider) is NgBindRoute).toBeTruthy();
    }));

  });
}

class NestedRouteInitializer implements Function {
  void call(Router router, RouteViewFactory views) {
    views.configure({
        'library': ngRoute(
            path: '/library',
            view: 'library.html',
            mount: {
                'all': ngRoute(path: '/all', view: 'book_list.html'),
                'book': ngRoute(path: '/bookId', mount: {
                    'overview': ngRoute(path: '/overview', defaultRoute: true,
                                        view: 'book_overview.html'),
                    'read': ngRoute(path: '/read', view: 'book_read.html'),
                    'admin': ngRoute(path: '/admin', view: 'admin.html'),
              })
            })
    });
  }
}
