library routing_spec;

import 'dart:html';
import '../_specs.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/mock/module.dart';

main() {
  describe('routing', () {
    TestBed _;
    TestRouteInitializer initer;
    Router router;

    beforeEach(module((Module m) {
      router = new Router(useFragment: false, windowImpl: new MockWindow());
      m
        ..install(new AngularMockModule())
        ..type(RouteInitializer, implementedBy: TestRouteInitializer)
        ..value(Router, router);
    }));

    beforeEach(inject((TestBed tb, RouteInitializer _initer) {
      _ = tb;
      initer = _initer;
    }));


    it('should call init of the RouteInitializer once', async(() {
      expect(initer.calledInit).toEqual(0);

      // Force the routing system to initialize.
      _.compile('<ng-view></ng-view>');

      expect(initer.calledInit).toEqual(1);
      expect(initer.router).toBe(router);
    }));

  });
}

class TestRouteInitializer implements RouteInitializer {
  int calledInit = 0;
  Router router;

  void init(Router router, ViewFactory view) {
    calledInit++;
    this.router = router;
  }
}
