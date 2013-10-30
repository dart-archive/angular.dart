part of angular.routing;

/**
 * A directive that works with the [Router] and loads the template associated
 * with the current route.
 *
 *     <ng-view></ng-view>
 *
 * [NgViewDirective] can work with [NgViewDirective] to define nested views
 * for hierarchical routes. For example:
 *
 *     class MyRouteInitializer implements RouteInitializer {
 *       void init(Router router, ViewFactory view) {
 *         router.root
 *           ..addRoute(
 *               name: 'library',
 *               path: '/library',
 *               enter: view('library.html'),
 *               mount: (Route route) => route
 *                 ..addRoute(
 *                     name: 'all',
 *                     path: '/all',
 *                     enter: view('book_list.html'))
 *                 ..addRoute(
 *                     name: 'book',
 *                     path: '/:bookId',
 *                     mount: (Route route) => route
 *                       ..addRoute(
 *                           name: 'overview',
 *                           path: '/overview',
 *                           defaultRoute: true,
 *                           enter: view('book_overview.html'))
 *                       ..addRoute(
 *                           name: 'read',
 *                           path: '/read',
 *                           enter: view('book_read.html'))));
 *       }
 *     }
 *
 * index.html:
 *
 *     <ng-view></ng-view>
 *
 * library.html:
 *
 *     <div ng-bind-route="library">
 *       <h1>Library!</h1>
 *
 *       <ng-view></ng-view>
 *     </div>
 *
 * book_list.html:
 *
 *     <ul>
 *       <li><a href="/library/12345/overview">Book 12345</a>
 *       <li><a href="/library/23456/overview">Book 23456</a>
 *     </ul>
 */
@NgDirective(selector: 'ng-view')
class NgViewDirective implements NgDetachAware {
  final _RoutingHelper locationService;
  final BlockCache blockCache;
  final Scope scope;
  final Injector injector;
  final Element element;
  RouteHandle route;
  bool _showingRoute = false;

  Block _previousBlock;
  Scope _previousScope;

  NgViewDirective(Element this.element, RouteProvider routeProvider,
                  BlockCache this.blockCache, Scope this.scope,
                  Injector injector, Router router):
      injector = injector, locationService = injector.get(_RoutingHelper) {
    if (routeProvider != null) {
      route = routeProvider.route.newHandle();
    } else {
      route = router.root.newHandle();
    }
    locationService._registerPortal(this);
    _maybeReloadViews();
  }

  void _maybeReloadViews() {
    if (route.isActive) {
      locationService._reloadViews(startingFrom: route);
    }
  }

  detach() {
    route.discard();
    locationService._unregisterPortal(this);
  }

  _show(String templateUrl, Route route) {
    assert(route.isActive);

    if (_showingRoute) return;
    _showingRoute = true;

    StreamSubscription _leaveSubscription;
    _leaveSubscription = route.onLeave.listen((_) {
      _leaveSubscription.cancel();
      _leaveSubscription = null;
      _showingRoute = false;
      _cleanUp();
    });

    blockCache.fromUrl(templateUrl).then((blockFactory) {
      _cleanUp();
      _previousScope = scope.$new();
      _previousBlock = blockFactory(
          injector.createChild([new Module()..value(Scope, _previousScope)]));

      _previousBlock.elements.forEach((elm) => element.append(elm));
    });
  }

  _cleanUp() {
    if (_previousBlock == null) {
      return;
    }

    _previousBlock.remove();
    _previousScope.$destroy();

    _previousBlock = null;
    _previousScope = null;
  }
}
