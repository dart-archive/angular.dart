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
 *     void initRoutes(Router router, RouteViewFactory view) {
 *       router.root
 *         ..addRoute(
 *             name: 'library',
 *             path: '/library',
 *             enter: view('library.html'),
 *             mount: (Route route) => route
 *               ..addRoute(
 *                   name: 'all',
 *                   path: '/all',
 *                   enter: view('book_list.html'))
 *               ..addRoute(
 *                   name: 'book',
 *                   path: '/:bookId',
 *                   mount: (Route route) => route
 *                     ..addRoute(
 *                         name: 'overview',
 *                         path: '/overview',
 *                         defaultRoute: true,
 *                         enter: view('book_overview.html'))
 *                     ..addRoute(
 *                         name: 'read',
 *                         path: '/read',
 *                         enter: view('book_read.html'))));
 *     }
 *   }
 *
 * index.html:
 *
 *     <ng-view></ng-view>
 *
 * library.html:
 *
 *     <div>
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
@Decorator(
    selector: 'ng-view',
    module: NgView.module,
    visibility: Directive.CHILDREN_VISIBILITY)
class NgView implements DetachAware, RouteProvider {
  static final Module _module = new Module()
    ..factory(RouteProvider,
              (i) => i.get(NgView),
              visibility: Directive.CHILDREN_VISIBILITY);
  static module() => _module;

  final NgRoutingHelper locationService;
  final ViewCache viewCache;
  final Injector injector;
  final Element element;
  final Scope scope;
  RouteHandle _route;

  View _view;
  Scope _scope;
  Route _viewRoute;

  NgView(this.element, this.viewCache,
                  Injector injector, Router router,
                  this.scope)
      : injector = injector,
        locationService = injector.get(NgRoutingHelper)
  {
    RouteProvider routeProvider = injector.parent.get(NgView);
    _route = routeProvider != null ?
        routeProvider.route.newHandle() :
        router.root.newHandle();
    locationService._registerPortal(this);
    _maybeReloadViews();
  }

  void _maybeReloadViews() {
    if (_route.isActive) locationService._reloadViews(startingFrom: _route);
  }

  detach() {
    _route.discard();
    locationService._unregisterPortal(this);
  }

  _show(String templateUrl, Route route, List<Module> modules) {
    assert(route.isActive);

    if (_viewRoute != null) return;
    _viewRoute = route;

    StreamSubscription _leaveSubscription;
    _leaveSubscription = route.onLeave.listen((_) {
      _leaveSubscription.cancel();
      _leaveSubscription = null;
      _viewRoute = null;
      _cleanUp();
    });

    var viewInjector = injector;
    if (modules != null) {
      viewInjector = forceNewDirectivesAndFilters(viewInjector, modules);
    }

    var newDirectives = viewInjector.get(DirectiveMap);
    viewCache.fromUrl(templateUrl, newDirectives).then((viewFactory) {
      _cleanUp();
      _scope = scope.createChild(new PrototypeMap(scope.context));
      _view = viewFactory(
          viewInjector.createChild(
              [new Module()..value(Scope, _scope)]));

      _view.nodes.forEach((elm) => element.append(elm));
    });
  }

  _cleanUp() {
    if (_view == null) return;

    _view.nodes.forEach((node) => node.remove());
    _scope.destroy();

    _view = null;
    _scope = null;
  }

  Route get route => _viewRoute;
  String get routeName => _viewRoute.name;
  Map<String, String> get parameters {
    var res = <String, String>{};
    var p = _viewRoute;
    while (p != null) {
      res.addAll(p.parameters);
      p = p.parent;
    }
    return res;
  }
}


/**
 * Class that can be injected to retrieve information about the current route.
 * For example:
 *
 *     @Component(/* ... */)
 *     class MyComponent implement DetachAware {
 *       RouteHandle route;
 *
 *       MyComponent(RouteProvider routeProvider) {
 *         _loadFoo(routeProvider.parameters['fooId']);
 *         route = routeProvider.route.newHandle();
 *         route.onEnter.listen((RouteEvent e) {
 *           // Do something when the route is activated.
 *         });
 *         route.onLeave.listen((RouteEvent e) {
 *           // Do something when the route is de-activated.
 *           e.allowLeave(allDataSaved());
 *         });
 *       }
 *
 *       detach() {
 *         // The route handle must be discarded.
 *         route.discard();
 *       }
 *
 *       Future<bool> allDataSaved() {
 *         // Check that all data is saved and confirm with the user if needed.
 *       }
 *     }
 *
 * If user component is used outside of ng-view directive then
 * injected [RouteProvider] will be null.
 */
abstract class RouteProvider {

  /**
   * Returns [Route] for current view.
   */
  Route get route;

  /**
   * Returns the name of the current route.
   */
  String get routeName;

  /**
   * Returns parameters for this route.
   */
  Map<String, String> get parameters;
}
